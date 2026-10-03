// Validação local para a demonstração. Não autoriza pagamentos.
String digitosCartao(String valor) => valor.replaceAll(RegExp(r'\D'), '');

bool numeroCartaoValido(String valor) {
  final numero = digitosCartao(valor);
  if (numero.length < 13 ||
      numero.length > 19 ||
      RegExp(r'^(\d)\1+$').hasMatch(numero)) {
    return false;
  }
  // Algoritmo de Luhn: detecta erros de digitação no número do cartão.
  var soma = 0;
  var dobrar = false;
  for (var i = numero.length - 1; i >= 0; i--) {
    var digito = int.parse(numero[i]);
    if (dobrar) {
      digito *= 2;
      if (digito > 9) digito -= 9;
    }
    soma += digito;
    dobrar = !dobrar;
  }
  return soma % 10 == 0;
}

bool validadeCartaoValida(String valor, {DateTime? agora}) {
  if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(valor)) return false;
  final mes = int.parse(valor.substring(0, 2));
  final ano = 2000 + int.parse(valor.substring(3));
  final hoje = agora ?? DateTime.now();
  return mes >= 1 &&
      mes <= 12 &&
      (ano > hoje.year || (ano == hoje.year && mes >= hoje.month));
}

bool cvvCartaoValido(String valor, String bandeira) => RegExp(
  bandeira == 'American Express' ? r'^\d{4}$' : r'^\d{3}$',
).hasMatch(valor);
