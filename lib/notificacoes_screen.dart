import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'notificacoes_service.dart';

const _notificacaoGradient = LinearGradient(
  colors: [Color(0xFF00C6D7), Color(0xFF0077B6)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class NotificacoesScreen extends StatelessWidget {
  const NotificacoesScreen({super.key});

  String _tempo(Timestamp? timestamp) {
    if (timestamp == null) return 'Agora';
    final diferenca = DateTime.now().difference(timestamp.toDate());
    if (diferenca.inMinutes < 1) return 'Agora';
    if (diferenca.inMinutes < 60) return 'Há ${diferenca.inMinutes} min';
    if (diferenca.inHours < 24) return 'Há ${diferenca.inHours} h';
    return 'Há ${diferenca.inDays} d';
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF4F7FB),
    appBar: AppBar(
      title: const Text('Notificações'),
      foregroundColor: Colors.white,
      backgroundColor: const Color(0xFF0077B6),
      flexibleSpace: const DecoratedBox(
        decoration: BoxDecoration(gradient: _notificacaoGradient),
      ),
    ),
    body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: NotificacoesService.minhas(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Não foi possível carregar as notificações.'),
          );
        }
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());
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
        return ListView.separated(
          padding: const EdgeInsets.all(20),
          itemCount: notificacoes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final doc = notificacoes[index];
            final dados = doc.data();
            final lida = dados['lida'] == true;
            return Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: lida
                    ? null
                    : () => NotificacoesService.marcarComoLida(doc.id),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: lida
                          ? const Color(0xFFE5EDF3)
                          : const Color(0xFF9EE4EB),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: _notificacaoGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.receipt_long_rounded,
                          color: Colors.white,
                        ),
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
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    ),
  );
}
