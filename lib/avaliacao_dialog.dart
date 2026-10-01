import 'package:flutter/material.dart';

import 'firebase_service.dart';
import 'zeloo_ui.dart';

Future<bool> mostrarAvaliacaoPedido(
  BuildContext context, {
  required String pedidoId,
  required String profissionalNome,
}) async {
  return await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => _AvaliacaoSheet(
          pedidoId: pedidoId,
          profissionalNome: profissionalNome,
        ),
      ) ??
      false;
}

class _AvaliacaoSheet extends StatefulWidget {
  final String pedidoId;
  final String profissionalNome;

  const _AvaliacaoSheet({
    required this.pedidoId,
    required this.profissionalNome,
  });

  @override
  State<_AvaliacaoSheet> createState() => _AvaliacaoSheetState();
}

class _AvaliacaoSheetState extends State<_AvaliacaoSheet> {
  final _comentario = TextEditingController();
  int _nota = 0;
  bool _enviando = false;
  String? _erro;

  @override
  void dispose() {
    _comentario.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (_nota == 0) {
      setState(() => _erro = 'Escolha de uma a cinco estrelas.');
      return;
    }
    setState(() {
      _enviando = true;
      _erro = null;
    });
    try {
      await FirebaseService.avaliarPedido(
        pedidoId: widget.pedidoId,
        nota: _nota,
        comentario: _comentario.text,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (erro) {
      if (mounted) {
        setState(() {
          _erro = erro.toString().replaceFirst('Exception: ', '');
          _enviando = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
    child: Container(
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFD8E2EA),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: zelooGradiente,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(height: 13),
              const Text(
                'Como foi o serviço?',
                style: TextStyle(
                  color: zelooTexto,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Avalie o atendimento de ${widget.profissionalNome}.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF64788B)),
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  final estrela = index + 1;
                  return IconButton(
                    tooltip: '$estrela estrela${estrela == 1 ? '' : 's'}',
                    onPressed: _enviando
                        ? null
                        : () => setState(() {
                            _nota = estrela;
                            _erro = null;
                          }),
                    iconSize: 39,
                    icon: Icon(
                      estrela <= _nota
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: const Color(0xFFFFB300),
                    ),
                  );
                }),
              ),
              Text(
                _nota == 0 ? 'Toque nas estrelas' : '$_nota de 5 estrelas',
                style: const TextStyle(
                  color: Color(0xFF64788B),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _comentario,
                enabled: !_enviando,
                maxLength: 300,
                minLines: 3,
                maxLines: 4,
                decoration: campoZeloo(
                  'Comentário opcional',
                  icon: Icons.chat_bubble_outline_rounded,
                ),
              ),
              if (_erro != null) ...[
                const SizedBox(height: 4),
                Text(
                  _erro!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFE53E3E),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              BotaoZeloo(
                texto: _enviando ? 'Enviando...' : 'Enviar avaliação',
                icon: Icons.send_rounded,
                onPressed: _enviando ? null : _enviar,
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: _enviando ? null : () => Navigator.pop(context),
                child: const Text('Avaliar depois'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
