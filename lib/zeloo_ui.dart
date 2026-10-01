import 'package:flutter/material.dart';

const zelooAzul = Color(0xFF0077B6);
const zelooTurquesa = Color(0xFF00B4C8);
const zelooTexto = Color(0xFF1A1A2E);
const zelooSuave = Color(0xFFEAF8FC);
const zelooGradiente = LinearGradient(
  colors: [Color(0xFF00C6D7), zelooAzul],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

BoxDecoration painelZeloo({bool destaque = false}) => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(22),
  border: Border.all(color: destaque ? const Color(0xFFB3E8EF) : const Color(0xFFE4EDF4)),
  boxShadow: [BoxShadow(color: zelooAzul.withValues(alpha: 0.05), blurRadius: 18, offset: const Offset(0, 6))],
);

InputDecoration campoZeloo(String label, {IconData? icon}) => InputDecoration(
  labelText: label,
  labelStyle: const TextStyle(color: Color(0xFF60758A), fontSize: 14),
  prefixIcon: icon == null ? null : Icon(icon, color: zelooAzul, size: 21),
  filled: true,
  fillColor: const Color(0xFFF4F8FC),
  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE1EBF3))),
  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFE1EBF3))),
  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: zelooTurquesa, width: 2)),
);

class CabecalhoCampo extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final String descricao;
  final String? indicador;
  const CabecalhoCampo({super.key, required this.icon, required this.titulo, required this.descricao, this.indicador});

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(width: 42, height: 42,
        decoration: BoxDecoration(gradient: zelooGradiente, borderRadius: BorderRadius.circular(13)),
        child: Icon(icon, color: Colors.white, size: 22)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(titulo, style: const TextStyle(color: zelooTexto, fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(descricao, style: const TextStyle(color: Color(0xFF64788B), fontSize: 12, height: 1.5)),
      ])),
      if (indicador != null) ...[
        const SizedBox(width: 8),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: zelooSuave, borderRadius: BorderRadius.circular(10)),
          child: Text(indicador!, style: const TextStyle(color: zelooAzul, fontSize: 12, fontWeight: FontWeight.w800))),
      ],
    ],
  );
}

class BotaoZeloo extends StatelessWidget {
  final String texto;
  final IconData icon;
  final VoidCallback? onPressed;
  const BotaoZeloo({super.key, required this.texto, required this.onPressed, this.icon = Icons.check_rounded});

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: onPressed == null ? 0.55 : 1,
    child: DecoratedBox(
      decoration: BoxDecoration(gradient: zelooGradiente, borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: zelooAzul.withValues(alpha: 0.16), blurRadius: 14, offset: const Offset(0, 5))]),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(texto, textAlign: TextAlign.center),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 52),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          backgroundColor: Colors.transparent, disabledBackgroundColor: Colors.transparent,
          foregroundColor: Colors.white, disabledForegroundColor: Colors.white,
          shadowColor: Colors.transparent, elevation: 0,
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
    ),
  );
}
