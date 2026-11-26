import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'chat_pedido_screen.dart';
import 'firebase_service.dart';
import 'zeloo_ui.dart';

/// Lista de conversas baseada nos pedidos reais do usuário autenticado.
class ConversasScreen extends StatelessWidget {
  final bool profissional;

  const ConversasScreen({super.key, required this.profissional});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Mensagens'),
        foregroundColor: Colors.white,
        flexibleSpace: Container(
          decoration: const BoxDecoration(gradient: zelooGradiente),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: profissional
            ? FirebaseService.meusPedidosProfissional()
            : FirebaseService.meusPedidosCliente(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Não foi possível carregar as conversas.'),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final pedidos = snapshot.data!.docs
              .where((doc) => doc.data()['profissionalId'] != '')
              .toList();
          if (pedidos.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Suas conversas aparecerão aqui quando houver pedidos.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: pedidos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final pedido = pedidos[index];
              final dados = pedido.data();
              final nome =
                  (profissional
                          ? dados['clienteNome']
                          : dados['profissionalNome'])
                      ?.toString() ??
                  (profissional ? 'Cliente' : 'Profissional');
              final servico = dados['servico']?.toString() ?? 'Serviço';
              return Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE4F7FB),
                    child: Icon(Icons.chat_rounded, color: zelooAzul),
                  ),
                  title: Text(
                    nome,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    servico,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPedidoScreen(pedidoId: pedido.id),
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
}
