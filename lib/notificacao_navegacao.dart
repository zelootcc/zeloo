import 'package:flutter/material.dart';

import 'avaliacoes_profissional_screen.dart';
import 'firebase_service.dart';
import 'pedidos_profissional_screen.dart';
import 'pedidos_screen.dart';

final navegadorZeloo = GlobalKey<NavigatorState>();

class NotificacaoNavegacao {
  static bool _abrindo = false;

  static Future<void> abrir(Map<String, dynamic> dados) async {
    if (_abrindo) return;
    _abrindo = true;

    try {
      final navigator = await _aguardarNavegador();
      if (navigator == null || FirebaseService.usuario == null) return;

      final tipo = dados['tipo']?.toString() ?? '';
      final pedidoId = dados['pedidoId']?.toString();

      if (tipo == 'nova_avaliacao') {
        navigator.push(
          MaterialPageRoute(
            builder: (_) => const AvaliacoesProfissionalScreen(),
          ),
        );
        return;
      }

      final colecao = await FirebaseService.colecaoUsuario();
      if (!navigator.mounted) return;

      if (colecao == 'Profissionais') {
        navigator.push(
          MaterialPageRoute(
            builder: (_) =>
                PedidosProfissionalScreen(pedidoDestacadoId: pedidoId),
          ),
        );
      } else if (colecao == 'Clientes') {
        navigator.push(
          MaterialPageRoute(
            builder: (_) => PedidosScreen(pedidoDestacadoId: pedidoId),
          ),
        );
      }
    } finally {
      _abrindo = false;
    }
  }

  static Future<NavigatorState?> _aguardarNavegador() async {
    for (var tentativa = 0; tentativa < 12; tentativa++) {
      final navigator = navegadorZeloo.currentState;
      if (navigator != null) return navigator;
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }
    return null;
  }
}
