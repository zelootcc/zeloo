// Mantém apenas os números usados pela máscara do campo.
String digitosCartao(String valor) => valor.replaceAll(RegExp(r'\D'), '');
