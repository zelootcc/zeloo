import 'package:flutter_test/flutter_test.dart';
import 'package:aplicativo_zeloo/formatadores.dart';

void main() {
  test('avaliação sempre usa uma casa decimal e vírgula', () {
    expect(formatarAvaliacao(4.6666666667), '4,7');
    expect(formatarAvaliacao(5), '5,0');
    expect(formatarAvaliacao(0), '0,0');
  });

  test('nota fora da escala nunca aparece acima de cinco ou abaixo de zero', () {
    expect(formatarAvaliacao(7.6), '5,0');
    expect(formatarAvaliacao(-2), '0,0');
    expect(formatarAvaliacao(double.nan), '0,0');
    expect(formatarAvaliacao(double.infinity), '0,0');
  });
}
