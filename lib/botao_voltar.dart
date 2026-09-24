import 'package:flutter/material.dart';

class BotaoVoltar extends StatelessWidget {
  final VoidCallback? onVoltar;

  const BotaoVoltar({super.key, this.onVoltar});

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: 'Voltar',
    constraints: const BoxConstraints.tightFor(width: 40, height: 40),
    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
    onPressed: onVoltar ?? () => Navigator.maybePop(context),
  );
}

class ComBotaoVoltar extends StatelessWidget {
  final Widget child;
  final VoidCallback? onVoltar;

  const ComBotaoVoltar({super.key, required this.child, this.onVoltar});

  @override
  Widget build(BuildContext context) => Stack(
    children: [
      child,
      Positioned(
        top: MediaQuery.paddingOf(context).top,
        left: 8,
        child: BotaoVoltar(onVoltar: onVoltar),
      ),
    ],
  );
}
