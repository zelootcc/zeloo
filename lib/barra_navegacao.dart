import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'zeloo_ui.dart';

class ItemNavegacaoZeloo {
  final IconData icon;
  final String label;

  const ItemNavegacaoZeloo({required this.icon, required this.label});
}

class BarraNavegacaoZeloo extends StatelessWidget {
  final int indice;
  final List<ItemNavegacaoZeloo> itens;
  final ValueChanged<int> onTap;

  const BarraNavegacaoZeloo({
    super.key,
    required this.indice,
    required this.itens,
    required this.onTap,
  }) : assert(itens.length >= 2),
       assert(indice >= 0 && indice < itens.length);

  @override
  Widget build(BuildContext context) {
    final duracao = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 300);
    final rodape = MediaQuery.paddingOf(context).bottom;
    final alturaTexto = math.max(
      16.0,
      MediaQuery.textScalerOf(context).scale(11) * 1.4,
    );
    final altura = 64 + alturaTexto;

    return SizedBox(
      height: altura + rodape,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final larguraItem = constraints.maxWidth / itens.length;
          return TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: indice.toDouble(), end: indice.toDouble()),
            duration: duracao,
            curve: Curves.easeInOutCubic,
            builder: (context, posicao, _) {
              return Stack(
                children: [
                  Positioned.fill(
                    child: IgnorePointer(
                      child: CustomPaint(
                        painter: _FundoBarra(
                          centro: (posicao + 0.5) * larguraItem,
                          meiaLargura: math.min(46.0, larguraItem / 2),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: altura,
                    child: Row(
                      children: List.generate(itens.length, (i) {
                        final item = itens[i];
                        final selecionado = i == indice;
                        final destaque = (1 - (posicao - i).abs())
                            .clamp(0.0, 1.0).toDouble();
                        return Expanded(
                          child: Semantics(
                            button: true,
                            selected: selecionado,
                            label: item.label,
                            child: Tooltip(
                              message: item.label,
                              child: TextButton(
                                onPressed: () => onTap(i),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  foregroundColor: Colors.white,
                                  shape: const RoundedRectangleBorder(),
                                ),
                                child: ExcludeSemantics(
                                  child: SizedBox.expand(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Transform.translate(
                                          offset: Offset(0, -12 * destaque),
                                          child: Container(
                                            width: 44,
                                            height: 44,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white.withValues(
                                                alpha: destaque,
                                              ),
                                            ),
                                            child: Icon(
                                              item.icon,
                                              size: 25 + destaque,
                                              color: Color.lerp(
                                                Colors.white70,
                                                zelooAzul,
                                                destaque,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: alturaTexto,
                                          child: Text(
                                            item.label,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: selecionado
                                                  ? Colors.white
                                                  : Colors.white70,
                                              fontWeight: selecionado
                                                  ? FontWeight.w700
                                                  : FontWeight.w400,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _FundoBarra extends CustomPainter {
  final double centro;
  final double meiaLargura;

  const _FundoBarra({required this.centro, required this.meiaLargura});

  @override
  void paint(Canvas canvas, Size size) {
    const topo = 20.0;
    final caminho = Path()
      ..moveTo(0, topo)
      ..lineTo(centro - meiaLargura, topo)
      ..cubicTo(
        centro - meiaLargura * 0.5, topo,
        centro - meiaLargura * 0.5, 0,
        centro, 0,
      )
      ..cubicTo(
        centro + meiaLargura * 0.5, 0,
        centro + meiaLargura * 0.5, topo,
        centro + meiaLargura, topo,
      )
      ..lineTo(size.width, topo)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawShadow(caminho, Colors.black26, 4, false);
    canvas.drawPath(
      caminho,
      Paint()..shader = zelooGradiente.createShader(Offset.zero & size),
    );
  }

  @override
  bool shouldRepaint(_FundoBarra oldDelegate) =>
      centro != oldDelegate.centro || meiaLargura != oldDelegate.meiaLargura;
}
