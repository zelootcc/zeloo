import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'firebase_service.dart';
import 'formatadores.dart';
import 'zeloo_ui.dart';

class AvaliacoesProfissionalScreen extends StatelessWidget {
  const AvaliacoesProfissionalScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF4F7FB),
    appBar: const AppBarZeloo(
      titulo: 'Minhas avaliações',
      subtitulo: 'Veja o que os clientes acharam dos seus serviços',
    ),
    body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseService.minhasAvaliacoesProfissional(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text('Não foi possível carregar as avaliações.'),
          );
        }
        final avaliacoes = [...?snapshot.data?.docs]
          ..sort((a, b) {
            final dataA = a.data()['criadoEm'] as Timestamp?;
            final dataB = b.data()['criadoEm'] as Timestamp?;
            return (dataB?.millisecondsSinceEpoch ?? 0).compareTo(
              dataA?.millisecondsSinceEpoch ?? 0,
            );
          });
        if (avaliacoes.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.star_outline_rounded,
                  size: 70,
                  color: Color(0xFFB7C6D2),
                ),
                SizedBox(height: 14),
                Text(
                  'Nenhuma avaliação ainda',
                  style: TextStyle(
                    color: zelooTexto,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'As avaliações dos serviços concluídos aparecerão aqui.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF718496)),
                ),
              ],
            ),
          );
        }

        final soma = avaliacoes.fold<int>(
          0,
          (total, doc) => total + ((doc.data()['nota'] as num?)?.toInt() ?? 0),
        );
        final media = soma / avaliacoes.length;

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFC84D), Color(0xFFFFA000)],
                ),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.white, size: 45),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatarAvaliacao(media),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '${avaliacoes.length} avaliação${avaliacoes.length == 1 ? '' : 'ões'}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            ...avaliacoes.map((doc) => _CardAvaliacao(dados: doc.data())),
          ],
        );
      },
    ),
  );
}

class _CardAvaliacao extends StatelessWidget {
  final Map<String, dynamic> dados;

  const _CardAvaliacao({required this.dados});

  String _data(Timestamp? timestamp) {
    if (timestamp == null) return 'Agora';
    final data = timestamp.toDate();
    return '${data.day.toString().padLeft(2, '0')}/${data.month.toString().padLeft(2, '0')}/${data.year}';
  }

  @override
  Widget build(BuildContext context) {
    final nota = (dados['nota'] as num?)?.toInt() ?? 0;
    final comentario = dados['comentario']?.toString().trim() ?? '';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: painelZeloo(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4D6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Color(0xFFFFA000),
                ),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      dados['clienteNome']?.toString() ?? 'Cliente',
                      style: const TextStyle(
                        color: zelooTexto,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${dados['servico'] ?? 'Serviço'} • ${_data(dados['criadoEm'] as Timestamp?)}',
                      style: const TextStyle(
                        color: Color(0xFF718496),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$nota,0',
                style: const TextStyle(
                  color: Color(0xFFFFA000),
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Icon(
                Icons.star_rounded,
                color: Color(0xFFFFB300),
                size: 20,
              ),
            ],
          ),
          if (comentario.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              comentario,
              style: const TextStyle(color: Color(0xFF526A7C), height: 1.45),
            ),
          ],
        ],
      ),
    );
  }
}
