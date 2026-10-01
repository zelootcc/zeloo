import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'configuracoes_usuario.dart';
import 'pedido_status.dart';

class FirebaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static User? get usuario => _auth.currentUser;

  static Stream<DocumentSnapshot<Map<String, dynamic>>>
  observarUsuario() async* {
    final id = uid;
    final colecao = await colecaoUsuario();
    if (colecao == null) throw Exception('Perfil não encontrado.');
    yield* _db.collection(colecao).doc(id).snapshots();
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> observarProfissional() {
    return _db.collection('Profissionais').doc(uid).snapshots();
  }

  // Informações privadas nunca ficam no perfil público do profissional.
  static DocumentReference<Map<String, dynamic>> get _configuracoes =>
      _db.collection('ConfiguracoesUsuarios').doc(uid);

  static Stream<DocumentSnapshot<Map<String, dynamic>>> configuracoes() =>
      _configuracoes.snapshots();

  static Future<void> salvarNotificacao(String campo, bool valor) {
    if (!{'email', 'sms', 'atualizacoes', 'seguranca'}.contains(campo)) {
      throw ArgumentError('Preferência inválida.');
    }
    return _configuracoes.set({
      'notificacoes': {campo: valor},
    }, SetOptions(merge: true));
  }

  static Future<void> alterarItemPrivado(
    String campo, {
    Map<String, dynamic>? adicionar,
    String? remover,
    String? principal,
  }) async {
    if (!{'enderecos', 'cartoes'}.contains(campo)) {
      throw ArgumentError('Lista inválida.');
    }
    final ref = _configuracoes;
    final novoId = _db.collection('ConfiguracoesUsuarios').doc().id;
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      final itens = atualizarListaPrivada(
        (snapshot.data()?[campo] as List?) ?? [],
        campo: campo,
        novoId: novoId,
        adicionar: adicionar,
        remover: remover,
        principal: principal,
      );
      transaction.set(ref, {campo: itens}, SetOptions(merge: true));
    });
  }

  static Future<void> alterarSenha(String atual, String nova) async {
    final user = usuario;
    if (user == null || user.email == null) {
      throw Exception('Entre novamente para alterar a senha.');
    }
    await user.reauthenticateWithCredential(
      EmailAuthProvider.credential(email: user.email!, password: atual),
    );
    await user.updatePassword(nova);
  }

  static Future<void> recuperarSenha(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  static String get uid {
    final id = usuario?.uid;
    if (id == null) {
      throw Exception('Usuário não autenticado.');
    }
    return id;
  }

  static Future<String?> colecaoUsuario() async {
    final id = usuario?.uid;
    if (id == null) return null;

    final cliente = await _db.collection('Clientes').doc(id).get();
    if (cliente.exists) return 'Clientes';

    final profissional = await _db.collection('Profissionais').doc(id).get();
    if (profissional.exists) return 'Profissionais';

    return null;
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>?> dadosUsuario() async {
    final id = usuario?.uid;
    final colecao = await colecaoUsuario();

    if (id == null || colecao == null) return null;

    return _db.collection(colecao).doc(id).get();
  }

  static Future<DocumentSnapshot<Map<String, dynamic>>?>
  dadosProfissional() async {
    final id = usuario?.uid;
    if (id == null) return null;

    return _db.collection('Profissionais').doc(id).get();
  }

  static Future<void> atualizarUsuario(Map<String, dynamic> dados) async {
    final colecao = await colecaoUsuario();

    if (colecao == null) {
      throw Exception('Perfil do usuário não encontrado.');
    }

    await _db.collection(colecao).doc(uid).update({
      ...dados,
      'atualizadoEm': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> atualizarDisponibilidade(bool disponivel) async {
    await _db.collection('Profissionais').doc(uid).update({
      'disponivel': disponivel,
    });
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> profissionais() {
    return _db.collection('Profissionais').snapshots();
  }

  static CollectionReference<Map<String, dynamic>> get _servicos {
    return _db.collection('Servicos');
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> meusServicos() {
    return _servicos.where('profissionalId', isEqualTo: uid).snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> meusServicosDoProfissional(
    String profissionalId,
  ) {
    return _servicos
        .where('profissionalId', isEqualTo: profissionalId)
        .where('ativo', isEqualTo: true)
        .snapshots();
  }

  static Future<void> adicionarServico({
    required String titulo,
    required String descricao,
    required double preco,
    required String categoria,
  }) async {
    await _servicos.add({
      'profissionalId': uid,
      'titulo': titulo,
      'descricao': descricao,
      'preco': preco,
      'categoria': categoria,
      'ativo': true,
      'criadoEm': FieldValue.serverTimestamp(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> atualizarServico(
    String id,
    Map<String, dynamic> dados,
  ) async {
    final dadosAtualizados = Map<String, dynamic>.from(dados);
    dadosAtualizados['atualizadoEm'] = FieldValue.serverTimestamp();

    await _servicos.doc(id).update(dadosAtualizados);
  }

  static Future<void> removerServico(String id) async {
    await _servicos.doc(id).delete();
  }

  static Future<String> criarPedido({
    required String profissionalId,
    required String profissionalNome,
    required String servicoId,
    required String servico,
    required double valor,
    required String data,
    required String horario,
    String descricao = '',
  }) async {
    final clienteId = uid;

    final cliente = await _db.collection('Clientes').doc(clienteId).get();
    final clienteNome =
        cliente.data()?['nome']?.toString().trim().isNotEmpty == true
        ? cliente.data()!['nome'].toString().trim()
        : 'Cliente';

    final profissional = await _db
        .collection('Profissionais')
        .doc(profissionalId)
        .get();

    if (!profissional.exists) {
      throw Exception('Profissional não encontrado.');
    }

    final servicoDoc = await _servicos.doc(servicoId).get();

    if (!servicoDoc.exists) {
      throw Exception('Serviço não encontrado.');
    }

    final dadosServico = servicoDoc.data()!;

    if (dadosServico['profissionalId'] != profissionalId) {
      throw Exception('Serviço inválido para este profissional.');
    }

    if (dadosServico['ativo'] != true) {
      throw Exception('Este serviço não está disponível.');
    }

    final pedidoRef = _db.collection('Pedidos').doc();
    final codigoRef = _db.collection('CodigosPedidos').doc(pedidoRef.id);
    final notificacaoRef = _db.collection('Notificacoes').doc();
    final codigo = Random.secure().nextInt(10000).toString().padLeft(4, '0');
    final pedido = {
      'clienteId': clienteId,
      'clienteNome': clienteNome,
      'profissionalId': profissionalId,
      'profissionalNome': profissionalNome,
      'servicoId': servicoId,
      'servico': servico,
      'valor': valor,
      'data': data,
      'horario': horario,
      'descricao': descricao,
      'status': PedidoStatus.aguardando,
      'tentativasCodigo': 0,
      'codigoValidado': false,
      'criadoEm': FieldValue.serverTimestamp(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    };
    final lote = _db.batch();
    lote.set(pedidoRef, pedido);
    lote.set(codigoRef, {
      'pedidoId': pedidoRef.id,
      'clienteId': clienteId,
      'profissionalId': profissionalId,
      'codigo': codigo,
      'criadoEm': FieldValue.serverTimestamp(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    });
    lote.set(notificacaoRef, {
      'destinatarioId': profissionalId,
      'remetenteId': clienteId,
      'pedidoId': pedidoRef.id,
      'tipo': 'novo_pedido',
      'titulo': 'Novo pedido recebido',
      'mensagem': 'Você recebeu um pedido para o serviço "$servico".',
      'lida': false,
      'criadoEm': FieldValue.serverTimestamp(),
    });
    await lote.commit();

    return pedidoRef.id;
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> meusPedidosCliente() {
    return _db
        .collection('Pedidos')
        .where('clienteId', isEqualTo: uid)
        .snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> meusPedidosProfissional() {
    return _db
        .collection('Pedidos')
        .where('profissionalId', isEqualTo: uid)
        .snapshots();
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> observarAvaliacaoPedido(
    String pedidoId,
  ) {
    return _db.collection('Avaliacoes').doc(pedidoId).snapshots();
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>>
  minhasAvaliacoesProfissional() {
    return _db
        .collection('Avaliacoes')
        .where('profissionalId', isEqualTo: uid)
        .snapshots();
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> observarCodigoPedido(
    String pedidoId,
  ) {
    return _db.collection('CodigosPedidos').doc(pedidoId).snapshots();
  }

  static DocumentReference<Map<String, dynamic>> _pedido(String id) =>
      _db.collection('Pedidos').doc(id);

  static Future<void> _atualizarPedidoComNotificacao(
    String id,
    Map<String, dynamic> alteracoes, {
    required String tipo,
    required String titulo,
    required String mensagem,
  }) async {
    final pedidoRef = _pedido(id);
    final pedido = await pedidoRef.get();
    final dados = pedido.data();
    if (dados == null) throw Exception('Pedido não encontrado.');

    final remetenteId = uid;
    final destinatarioId = remetenteId == dados['clienteId']
        ? dados['profissionalId']?.toString()
        : dados['clienteId']?.toString();
    if (destinatarioId == null || destinatarioId.isEmpty) {
      throw Exception('Participante do pedido não encontrado.');
    }

    final lote = _db.batch();
    lote.update(pedidoRef, alteracoes);
    lote.set(_db.collection('Notificacoes').doc(), {
      'destinatarioId': destinatarioId,
      'remetenteId': remetenteId,
      'pedidoId': id,
      'tipo': tipo,
      'titulo': titulo,
      'mensagem': mensagem,
      'lida': false,
      'criadoEm': FieldValue.serverTimestamp(),
    });
    await lote.commit();
  }

  static Future<void> aceitarPedido(String id) {
    return _atualizarPedidoComNotificacao(
      id,
      {
        'status': PedidoStatus.aceito,
        'aceitoEm': FieldValue.serverTimestamp(),
        'atualizadoEm': FieldValue.serverTimestamp(),
      },
      tipo: 'pedido_aceito',
      titulo: 'Pedido aceito',
      mensagem: 'O profissional aceitou seu pedido.',
    );
  }

  static Future<void> iniciarDeslocamento(String id) {
    return _atualizarPedidoComNotificacao(
      id,
      {
        'status': PedidoStatus.aCaminho,
        'aCaminhoEm': FieldValue.serverTimestamp(),
        'atualizadoEm': FieldValue.serverTimestamp(),
      },
      tipo: 'profissional_a_caminho',
      titulo: 'Profissional a caminho',
      mensagem: 'O profissional iniciou o deslocamento até o local.',
    );
  }

  static Future<void> marcarChegada(String id) {
    return _atualizarPedidoComNotificacao(
      id,
      {
        'status': PedidoStatus.aguardandoCodigo,
        'chegouEm': FieldValue.serverTimestamp(),
        'tentativasCodigo': 0,
        'codigoValidado': false,
        'atualizadoEm': FieldValue.serverTimestamp(),
      },
      tipo: 'profissional_chegou',
      titulo: 'Profissional no local',
      mensagem: 'Informe o código de quatro dígitos para iniciar o serviço.',
    );
  }

  static Future<void> validarCodigoInicio(String id, String codigo) async {
    if (!RegExp(r'^\d{4}$').hasMatch(codigo)) {
      throw Exception('Digite os quatro números do código.');
    }

    final ref = _pedido(id);
    final snapshot = await ref.get();
    final tentativas =
        (snapshot.data()?['tentativasCodigo'] as num?)?.toInt() ?? 0;
    if (tentativas >= 5) {
      throw Exception('Limite de tentativas atingido. Peça um novo código.');
    }

    try {
      await _atualizarPedidoComNotificacao(
        id,
        {
          'status': PedidoStatus.emAndamento,
          'codigoVerificacaoInformado': codigo,
          'codigoValidado': true,
          'tentativasCodigo': tentativas + 1,
          'iniciadoEm': FieldValue.serverTimestamp(),
          'atualizadoEm': FieldValue.serverTimestamp(),
        },
        tipo: 'servico_iniciado',
        titulo: 'Serviço iniciado',
        mensagem: 'O código foi confirmado e o serviço está em andamento.',
      );
    } on FirebaseException catch (erro) {
      if (erro.code != 'permission-denied') rethrow;

      // A regra permite este segundo update somente quando o código está errado.
      await ref.update({
        'codigoVerificacaoInformado': codigo,
        'codigoValidado': false,
        'tentativasCodigo': tentativas + 1,
        'atualizadoEm': FieldValue.serverTimestamp(),
      });
      throw Exception('Código incorreto. Confira com o cliente.');
    }
  }

  static Future<void> solicitarConclusao(String id) {
    return _atualizarPedidoComNotificacao(
      id,
      {
        'status': PedidoStatus.aguardandoConclusao,
        'conclusaoSolicitadaEm': FieldValue.serverTimestamp(),
        'atualizadoEm': FieldValue.serverTimestamp(),
      },
      tipo: 'confirmar_conclusao',
      titulo: 'Confirme a conclusão',
      mensagem: 'O profissional informou que terminou o serviço.',
    );
  }

  static Future<void> confirmarConclusao(String id) {
    return _atualizarPedidoComNotificacao(
      id,
      {
        'status': PedidoStatus.concluido,
        'concluidoEm': FieldValue.serverTimestamp(),
        'atualizadoEm': FieldValue.serverTimestamp(),
      },
      tipo: 'servico_concluido',
      titulo: 'Serviço concluído',
      mensagem: 'O cliente confirmou a conclusão do serviço.',
    );
  }

  static Future<void> cancelarPedido(String id, String motivo) {
    final motivoLimpo = motivo.trim();
    if (motivoLimpo.length < 3) {
      throw Exception('Informe o motivo do cancelamento.');
    }
    return _atualizarPedidoComNotificacao(
      id,
      {
        'status': PedidoStatus.cancelado,
        'motivoCancelamento': motivoLimpo,
        'canceladoPor': uid,
        'canceladoEm': FieldValue.serverTimestamp(),
        'atualizadoEm': FieldValue.serverTimestamp(),
      },
      tipo: 'pedido_cancelado',
      titulo: 'Pedido cancelado',
      mensagem: 'Motivo: $motivoLimpo',
    );
  }

  static Future<String> gerarNovoCodigo(String pedidoId) async {
    final novoCodigo = Random.secure()
        .nextInt(10000)
        .toString()
        .padLeft(4, '0');
    final pedido = await _pedido(pedidoId).get();
    final dados = pedido.data();
    if (dados == null) throw Exception('Pedido não encontrado.');
    final codigoRef = _db.collection('CodigosPedidos').doc(pedidoId);
    final codigoAtual = await codigoRef.get();

    final lote = _db.batch();
    lote.set(codigoRef, {
      if (!codigoAtual.exists) ...{
        'pedidoId': pedidoId,
        'clienteId': dados['clienteId'],
        'profissionalId': dados['profissionalId'],
        'criadoEm': FieldValue.serverTimestamp(),
      },
      'codigo': novoCodigo,
      'atualizadoEm': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    lote.update(_pedido(pedidoId), {
      'tentativasCodigo': 0,
      'codigoValidado': false,
      'codigoVerificacaoInformado': FieldValue.delete(),
      'atualizadoEm': FieldValue.serverTimestamp(),
    });
    lote.set(_db.collection('Notificacoes').doc(), {
      'destinatarioId': dados['profissionalId'],
      'remetenteId': uid,
      'pedidoId': pedidoId,
      'tipo': 'codigo_renovado',
      'titulo': 'Novo código gerado',
      'mensagem': 'O cliente gerou um novo código para iniciar o serviço.',
      'lida': false,
      'criadoEm': FieldValue.serverTimestamp(),
    });
    await lote.commit();
    return novoCodigo;
  }

  static Future<void> avaliarPedido({
    required String pedidoId,
    required int nota,
    String comentario = '',
  }) async {
    if (nota < 1 || nota > 5) {
      throw Exception('Escolha uma nota de uma a cinco estrelas.');
    }
    final comentarioLimpo = comentario.trim();
    if (comentarioLimpo.length > 300) {
      throw Exception('O comentário deve ter no máximo 300 caracteres.');
    }

    final pedidoRef = _pedido(pedidoId);
    final avaliacaoRef = _db.collection('Avaliacoes').doc(pedidoId);
    final notificacaoRef = _db.collection('Notificacoes').doc();

    await _db.runTransaction((transaction) async {
      final pedido = await transaction.get(pedidoRef);
      final dadosPedido = pedido.data();
      if (dadosPedido == null || dadosPedido['clienteId'] != uid) {
        throw Exception('Pedido não encontrado.');
      }
      if (dadosPedido['status'] != PedidoStatus.concluido) {
        throw Exception('A avaliação só pode ser feita após a conclusão.');
      }

      final avaliacaoExistente = await transaction.get(avaliacaoRef);
      if (avaliacaoExistente.exists) {
        throw Exception('Este serviço já foi avaliado.');
      }

      final profissionalId = dadosPedido['profissionalId'].toString();
      final profissionalRef = _db
          .collection('Profissionais')
          .doc(profissionalId);
      final profissional = await transaction.get(profissionalRef);
      final dadosProfissional = profissional.data() ?? {};
      final totalAnterior =
          (dadosProfissional['totalAvaliacoes'] as num?)?.toInt() ?? 0;
      final somaAnterior = dadosProfissional['somaAvaliacoes'] is num
          ? (dadosProfissional['somaAvaliacoes'] as num).toDouble()
          : ((dadosProfissional['avaliacao'] as num?)?.toDouble() ?? 0) *
                totalAnterior;
      final novaSoma = somaAnterior + nota;
      final novoTotal = totalAnterior + 1;

      transaction.set(avaliacaoRef, {
        'pedidoId': pedidoId,
        'clienteId': uid,
        'clienteNome': dadosPedido['clienteNome'] ?? 'Cliente',
        'profissionalId': profissionalId,
        'servico': dadosPedido['servico'] ?? 'Serviço',
        'nota': nota,
        'comentario': comentarioLimpo,
        'criadoEm': FieldValue.serverTimestamp(),
      });
      transaction.update(profissionalRef, {
        'somaAvaliacoes': novaSoma,
        'totalAvaliacoes': novoTotal,
        'avaliacao': novaSoma / novoTotal,
        'ultimaAvaliacaoPedidoId': pedidoId,
        'atualizadoEm': FieldValue.serverTimestamp(),
      });
      transaction.set(notificacaoRef, {
        'destinatarioId': profissionalId,
        'remetenteId': uid,
        'pedidoId': pedidoId,
        'tipo': 'nova_avaliacao',
        'titulo': 'Nova avaliação recebida',
        'mensagem':
            'Você recebeu uma avaliação de $nota estrela${nota == 1 ? '' : 's'}.',
        'lida': false,
        'criadoEm': FieldValue.serverTimestamp(),
      });
    });
  }

  static Future<void> sair() {
    return _auth.signOut();
  }
}
