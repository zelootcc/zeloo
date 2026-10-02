String formatarAvaliacao(num valor) =>
    valor.toDouble().toStringAsFixed(1).replaceAll('.', ',');
