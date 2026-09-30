import 'package:flutter/services.dart';

class TelefoneFormatter extends TextInputFormatter {
  const TelefoneFormatter();

  static bool valido(String telefone) =>
      RegExp(r'^\d{10,11}$').hasMatch(telefone.replaceAll(RegExp(r'\D'), ''));

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final numeros = newValue.text.replaceAll(RegExp(r'\D'), '');
    final d = numeros.substring(0, numeros.length.clamp(0, 11));
    String formatar(String valor) {
      if (valor.length <= 2) return valor;
      if (valor.length <= 6) return '(${valor.substring(0, 2)}) ${valor.substring(2)}';
      final corte = valor.length == 11 ? 7 : 6;
      return '(${valor.substring(0, 2)}) ${valor.substring(2, corte)}-${valor.substring(corte)}';
    }
    final texto = formatar(d);
    final antesCursor = newValue.selection.extentOffset.clamp(0, newValue.text.length);
    final quantidade = newValue.text.substring(0, antesCursor).replaceAll(RegExp(r'\D'), '').length.clamp(0, d.length);
    int cursor = 0, vistos = 0;
    while (cursor < texto.length && vistos < quantidade) {
      if (RegExp(r'\d').hasMatch(texto[cursor])) vistos++;
      cursor++;
    }
    return TextEditingValue(text: texto, selection: TextSelection.collapsed(offset: cursor));
  }
}
