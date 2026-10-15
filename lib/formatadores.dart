String formatarAvaliacao(num valor) {
  final nota = valor.toDouble();
  final limitada = nota.isFinite ? nota.clamp(0, 5).toDouble() : 0.0;
  return limitada.toStringAsFixed(1).replaceAll('.', ',');
}
