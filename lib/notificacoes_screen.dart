import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'notificacao_navegacao.dart';
import 'notificacoes_service.dart';
import 'zeloo_ui.dart';

class NotificacoesScreen extends StatefulWidget {
  const NotificacoesScreen({super.key});

  @override
  State<NotificacoesScreen> createState() => _NotificacoesScreenState();
}

class _NotificacoesScreenState extends State<NotificacoesScreen> {
  late final _notificacoes = NotificacoesService.minhas();
  bool _excluindo = false;

  Future<void> _apagar({String? id}) async {
    if (_excluindo) return;
    setState(() => _excluindo = true);
    try {
      final String mensagem;
      if (id != null) {
        await NotificacoesService.apagarLida(id);
        mensagem = 'Notificação apagada.';
      } else {
        final quantidade = await NotificacoesService.apagarTodasLidas();
        mensagem = quantidade == 0
            ? 'Não há notificações lidas para apagar.'
            : '$quantidade notificaç${quantidade == 1 ? 'ão apagada' : 'ões apagadas'}.';
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(mensagem)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível concluir a exclusão. Tente novamente.')),
      );
    } finally {
      if (mounted) setState(() => _excluindo = false);
    }
  }

  String _tempo(Timestamp? timestamp) {
    if (timestamp == null) return 'Agora';
    final diferenca = DateTime.now().difference(timestamp.toDate());
    if (diferenca.inMinutes < 1) return 'Agora';
    if (diferenca.inMinutes < 60) return 'Há ${diferenca.inMinutes} min';
    if (diferenca.inHours < 24) return 'Há ${diferenca.inHours} h';
    return 'Há ${diferenca.inDays} d';
  }

  ({IconData icon, Color color}) _aparencia(String tipo) {
    switch (tipo) {
      case 'novo_pedido':
        return (icon: Icons.receipt_long_rounded, color: zelooAzul);
      case 'pedido_aceito':
        return (icon: Icons.thumb_up_alt_rounded, color: zelooTurquesa);
      case 'profissional_a_caminho':
        return (icon: Icons.directions_car_filled_rounded, color: zelooAzul);
      case 'profissional_chegou':
        return (
          icon: Icons.location_on_rounded,
          color: const Color(0xFF7B61FF),
        );
      case 'servico_iniciado':
        return (icon: Icons.handyman_rounded, color: const Color(0xFFFF8A3D));
      case 'confirmar_conclusao':
      case 'servico_concluido':
        return (icon: Icons.verified_rounded, color: const Color(0xFF20A76B));
      case 'pedido_cancelado':
        return (icon: Icons.cancel_rounded, color: const Color(0xFFE55353));
      case 'codigo_renovado':
        return (icon: Icons.pin_rounded, color: const Color(0xFF7B61FF));
      case 'nova_avaliacao':
        return (icon: Icons.star_rounded, color: const Color(0xFFFFB020));
      default:
        return (icon: Icons.notifications_rounded, color: zelooAzul);
    }
  }

  Future<void> _abrir(
    BuildContext context,
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final dados = doc.data();
    if (dados['lida'] != true) {
      try {
        await NotificacoesService.marcarComoLida(doc.id);
      } catch (_) {
        // A tela relacionada ainda abre se a confirmação de leitura falhar.
      }
    }
    if (!context.mounted) return;
    await NotificacaoNavegacao.abrir(dados);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF4F7FB),
    appBar: const AppBarZeloo(
      titulo: 'Notificações',
      subtitulo: 'Acompanhe pedidos e novidades do seu perfil',
    ),
    body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _notificacoes,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Não foi possível carregar as notificações.'),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final notificacoes = [...snapshot.data!.docs]
          ..sort((a, b) {
            final criadoA = a.data()['criadoEm'];
            final criadoB = b.data()['criadoEm'];
            if (criadoA is! Timestamp && criadoB is! Timestamp) return 0;
            if (criadoA is! Timestamp) return 1;
            if (criadoB is! Timestamp) return -1;
            return criadoB.toDate().compareTo(criadoA.toDate());
          });
        if (notificacoes.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  size: 68,
                  color: Color(0xFFB8CAD8),
                ),
                SizedBox(height: 16),
                Text(
                  'Tudo tranquilo por aqui!',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Novos pedidos aparecerão nesta central.',
                  style: TextStyle(color: Color(0xFF64788B)),
                ),
              ],
            ),
          );
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Sua central',
                      style: TextStyle(color: zelooTexto, fontWeight: FontWeight.w800)),
                  ),
                  TextButton.icon(
                    onPressed: _excluindo ? null : () => _apagar(),
                    icon: _excluindo
                        ? const SizedBox(width: 16, height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.delete_sweep_rounded, size: 20),
                    label: Text(_excluindo ? 'Apagando...' : 'Apagar lidas'),
                    style: TextButton.styleFrom(
                      foregroundColor: zelooAzul,
                      backgroundColor: zelooSuave,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                itemCount: notificacoes.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final doc = notificacoes[index];
                  final dados = doc.data();
                  final lida = dados['lida'] == true;
                  final aparencia = _aparencia(dados['tipo']?.toString() ?? '');
                  return Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(22),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: () => _abrir(context, doc),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: painelZeloo(destaque: !lida),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: aparencia.color.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(aparencia.icon, color: aparencia.color),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          dados['titulo']?.toString() ??
                                              'Nova notificação',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w800,
                                            color: Color(0xFF1A1A2E),
                                          ),
                                        ),
                                      ),
                                      if (!lida)
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF00B4C8),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    dados['mensagem']?.toString() ?? '',
                                    style: const TextStyle(
                                      color: Color(0xFF64788B),
                                      height: 1.35,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _tempo((dados['criadoEm'] as Timestamp?)),
                                    style: const TextStyle(
                                      color: Color(0xFF8DA0B0),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Padding(
                                  padding: EdgeInsets.only(top: 11),
                                  child: Icon(Icons.chevron_right_rounded,
                                    color: Color(0xFF9AAAB8), size: 22),
                                ),
                                if (lida)
                                  IconButton(
                                    tooltip: 'Apagar notificação lida',
                                    onPressed: _excluindo ? null : () => _apagar(id: doc.id),
                                    icon: const Icon(Icons.delete_outline_rounded, size: 20),
                                    color: zelooAzul,
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    ),
  );
}
