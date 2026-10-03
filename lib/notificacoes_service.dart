import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'notificacao_navegacao.dart';

class NotificacoesService {
  static final _messaging = FirebaseMessaging.instance;
  static final _db = FirebaseFirestore.instance;
  static StreamSubscription<String>? _tokenSubscription;
  static StreamSubscription<RemoteMessage>? _messageSubscription;
  static StreamSubscription<RemoteMessage>? _openedSubscription;
  static bool _mensagemInicialVerificada = false;

  static Future<void> inicializar() async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return;
    }
    final usuario = FirebaseAuth.instance.currentUser;
    if (usuario == null) return;
    try {
      await _openedSubscription?.cancel();
      _openedSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
        _abrirMensagem,
      );

      if (!_mensagemInicialVerificada) {
        _mensagemInicialVerificada = true;
        final mensagemInicial = await _messaging.getInitialMessage();
        if (mensagemInicial != null) {
          Future<void>.delayed(
            const Duration(milliseconds: 500),
            () => _abrirMensagem(mensagemInicial),
          );
        }
      }

      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      if (settings.authorizationStatus == AuthorizationStatus.denied) return;

      final token = await _messaging.getToken();
      if (token != null) await registrarToken(token, usuario.uid);

      await _tokenSubscription?.cancel();
      _tokenSubscription = _messaging.onTokenRefresh.listen(
        (novoToken) => registrarToken(novoToken, usuario.uid),
      );

      await _messageSubscription?.cancel();
      _messageSubscription = FirebaseMessaging.onMessage.listen((message) {
        // A central é criada pelo Firestore; a mensagem em foreground serve
        // apenas para atualizar a interface imediatamente.
      });
    } catch (_) {
      // A central funciona mesmo sem permissão de push ou sem APNs configurado.
    }
  }

  static Future<void> _abrirMensagem(RemoteMessage mensagem) async {
    final notificacaoId = mensagem.data['notificacaoId']?.toString();
    if (notificacaoId != null && notificacaoId.isNotEmpty) {
      try {
        await marcarComoLida(notificacaoId);
      } catch (_) {
        // A navegação continua mesmo se a confirmação de leitura falhar.
      }
    }
    await NotificacaoNavegacao.abrir(mensagem.data);
  }

  static Future<void> registrarToken(String token, String uid) {
    return _db.collection('Dispositivos').doc(uid).set({
      'tokens': FieldValue.arrayUnion([token]),
      'atualizadoEm': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> minhas() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();
    return _db
        .collection('Notificacoes')
        .where('destinatarioId', isEqualTo: uid)
        .limit(50)
        .snapshots();
  }

  static Future<void> marcarComoLida(String id) {
    return _db.collection('Notificacoes').doc(id).update({'lida': true});
  }

  static Future<void> apagarLida(String id) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw StateError('Entre novamente para apagar notificações.');
    final ref = _db.collection('Notificacoes').doc(id);
    await _db.runTransaction((transaction) async {
      final documento = await transaction.get(ref);
      if (!documento.exists) return;
      final dados = documento.data()!;
      if (dados['destinatarioId'] != uid || dados['lida'] != true) {
        throw StateError('Só é possível apagar suas notificações já lidas.');
      }
      transaction.delete(ref);
    });
  }

  static Future<int> apagarTodasLidas() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) throw StateError('Entre novamente para apagar notificações.');

    // Busca também as notificações antigas, além das 50 exibidas na central.
    final resultado = await _db.collection('Notificacoes')
        .where('destinatarioId', isEqualTo: uid).get();
    final lidas = resultado.docs.where((doc) => doc.data()['lida'] == true).toList();
    // Divide a limpeza em lotes para respeitar o limite de operações do Firebase.
    for (var inicio = 0; inicio < lidas.length; inicio += 400) {
      final lote = _db.batch();
      for (final doc in lidas.skip(inicio).take(400)) {
        lote.delete(doc.reference);
      }
      await lote.commit();
    }
    return lidas.length;
  }
}
