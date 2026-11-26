import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_service.dart';
import 'zeloo_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'barra_navegacao.dart';
import 'categorias_screen.dart';
import 'chamados_screen.dart';
import 'home_cliente_screen.dart';
import 'pedidos_screen.dart';
import 'perfil_screen.dart';

class ClienteShell extends StatefulWidget {
  const ClienteShell({super.key});

  @override
  State<ClienteShell> createState() => _ClienteShellState();
}

class _ClienteShellState extends State<ClienteShell> {
  int _indice = 0;

  late final StreamSubscription<QuerySnapshot<Map<String, dynamic>>> assinatura;
  List<QueryDocumentSnapshot<Map<String, dynamic>>> pendentes = [];
  bool exibindo = false;

  @override
  void initState() {
    super.initState();
    assinatura = FirebaseService.meusPedidosCliente().listen(
      (snapshot) {
        pendentes = snapshot.docs
            .where(
              (doc) =>
                  doc.data()['status'] == 'aguardando' &&
                  doc.data()['proposta'] is Map,
            )
            .toList();
        mostrarPropostas();
      },
      onError: (Object erro) {
        debugPrint('Falha ao acompanhar propostas: $erro');
      },
    );
  }

  @override
  void dispose() {
    assinatura.cancel();
    super.dispose();
  }

  Future<void> mostrarPropostas() async {
    if (exibindo) return;
    exibindo = true;
    try {
      while (mounted && pendentes.isNotEmpty) {
        final doc = pendentes.first;
        final proposta = doc.data()['proposta'] as Map;
        final valor = (proposta['valor'] as num)
            .toStringAsFixed(2)
            .replaceAll('.', ',');
        final comentario = proposta['comentario'] as String;
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            bool enviando = false;
            String? erro;
            return StatefulBuilder(
              builder: (context, atualizar) {
                Future<void> responder(bool aceitar) async {
                  atualizar(() {
                    enviando = true;
                    erro = null;
                  });
                  try {
                    await FirebaseService.responderProposta(
                      doc.id,
                      proposta,
                      aceitar,
                    );
                    if (context.mounted) Navigator.pop(context);
                  } catch (_) {
                    if (!context.mounted) return;
                    if (!pendentes.any(
                      (p) =>
                          p.id == doc.id &&
                          p.data()['proposta']?['id'] == proposta['id'],
                    )) {
                      Navigator.pop(context);
                      return;
                    }
                    atualizar(() {
                      enviando = false;
                      erro =
                          'Não foi possível confirmar. Tente novamente ou recuse a proposta.';
                    });
                  }
                }

                return PopScope(
                  canPop: false,
                  child: AlertDialog(
                    backgroundColor: Colors.white,
                    icon: const CircleAvatar(
                      backgroundColor: zelooSuave,
                      child: Icon(Icons.handshake_outlined, color: zelooAzul),
                    ),
                    title: const Text('Proposta recebida'),
                    content: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            "${proposta['nome']} quer atender seu chamado de ${doc.data()['servico']}.",
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'R\$ $valor',
                            style: const TextStyle(
                              color: zelooAzul,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (comentario.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(comentario),
                            ),
                          if (erro != null) Text(erro!),
                          const SizedBox(height: 20),
                          BotaoZeloo(
                            texto: 'Aceitar proposta',
                            onPressed: enviando ? null : () => responder(true),
                          ),
                          TextButton(
                            onPressed: enviando ? null : () => responder(false),
                            child: const Text('Recusar'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
        pendentes.removeWhere(
          (p) =>
              p.id == doc.id && p.data()['proposta']?['id'] == proposta['id'],
        );
      }
    } finally {
      exibindo = false;
    }
  }

  void _voltarAoInicio() => setState(() => _indice = 0);

  late final List<Widget> _telas = [
    const HomeClienteScreen(),
    CategoriasScreen(showBottomNavigation: false, onVoltar: _voltarAoInicio),
    PedidosScreen(onVoltar: _voltarAoInicio),
    PerfilScreen(onVoltar: _voltarAoInicio),
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: IndexedStack(index: _indice, children: _telas),
      bottomNavigationBar: BarraNavegacaoZeloo(
        indice: _indice < 2 ? _indice : _indice + 1,
        indiceCentral: 2,
        onTap: (indice) {
          if (indice == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChamadosScreen()),
            );
            return;
          }
          setState(() => _indice = indice < 2 ? indice : indice - 1);
        },
        itens: const [
          ItemNavegacaoZeloo(icon: Icons.home_rounded, label: 'Início'),
          ItemNavegacaoZeloo(
            icon: Icons.grid_view_rounded,
            label: 'Categorias',
          ),
          ItemNavegacaoZeloo(
            icon: Icons.add_rounded,
            label: 'Chamado',
            acao: true,
          ),
          ItemNavegacaoZeloo(
            icon: Icons.receipt_long_rounded,
            label: 'Pedidos',
          ),
          ItemNavegacaoZeloo(icon: Icons.person_rounded, label: 'Perfil'),
        ],
      ),
    );
  }
}
