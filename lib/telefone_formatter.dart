import 'package:flutter/services.dart';

bool telefoneValido(String valor) =>
    RegExp(r'^\d{10,11}$').hasMatch(valor.replaceAll(RegExp(r'\D'), ''));

class TelefoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var numeros = newValue.text.replaceAll(RegExp(r'\D'), '');
    final cursor = newValue.selection.extentOffset.clamp(
      0,
      newValue.text.length,
    );
    var antes = newValue.text
        .substring(0, cursor)
        .replaceAll(RegExp(r'\D'), '')
        .length;
    final antigos = oldValue.text.replaceAll(RegExp(r'\D'), '');
    if (newValue.text.length < oldValue.text.length &&
        numeros == antigos &&
        newValue.selection.isCollapsed &&
        antes > 0) {
      numeros = numeros.replaceRange(antes - 1, antes, '');
      antes--;
    }
    if (numeros.length > 11) numeros = numeros.substring(0, 11);
    antes = antes.clamp(0, numeros.length);
    String texto = numeros;
    if (numeros.length > 2) {
      final corte = numeros.length <= 10 ? 6 : 7;
      texto =
          '(${numeros.substring(0, 2)}) ${numeros.substring(2, numeros.length.clamp(2, corte))}';
      if (numeros.length > corte) texto += '-${numeros.substring(corte)}';
    }
    var posicao = 0;
    var contagem = 0;
    while (posicao < texto.length && contagem < antes) {
      if (RegExp(r'\d').hasMatch(texto[posicao])) contagem++;
      posicao++;
    }
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: posicao),
    );
  }
}
