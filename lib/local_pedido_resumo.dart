import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'local_atendimento.dart';
import 'zeloo_ui.dart';

class LocalPedidoResumo extends StatelessWidget {
  final Map<String, dynamic> dados;
  const LocalPedidoResumo({super.key, required this.dados});

  @override
  Widget build(BuildContext context) {
    final valor = dados['localAtendimento'];
    if (valor is! Map || valor['logradouro'] is! String) {
      return const SizedBox.shrink();
    }
    final local = Map<String, dynamic>.from(valor);
    final complemento = local['complemento']?.toString() ?? '';
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: zelooSuave,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.location_on_outlined, color: zelooAzul, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Local do atendimento',
                  style: TextStyle(
                    color: zelooAzul,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  local['logradouro'] as String,
                  style: const TextStyle(color: zelooTexto, fontSize: 12),
                ),
                if (complemento.isNotEmpty)
                  Text(
                    complemento,
                    style: const TextStyle(color: zelooTexto, fontSize: 12),
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Abrir endereço no mapa',
            icon: const Icon(Icons.map_outlined, color: zelooAzul, size: 22),
            onPressed: () async {
              try {
                if (!await launchUrl(
                  mapaLocalAtendimento(local),
                  mode: LaunchMode.externalApplication,
                )) {
                  throw StateError('Mapa indisponível');
                }
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Não foi possível abrir o mapa.'),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
