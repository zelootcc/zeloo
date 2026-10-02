import 'package:flutter_test/flutter_test.dart';
import 'package:aplicativo_zeloo/formatadores.dart';

void main() {
  test('avaliação sempre usa uma casa decimal e vírgula', () {
    expect(formatarAvaliacao(4.6666666667), '4,7');
    expect(formatarAvaliacao(5), '5,0');
    expect(formatarAvaliacao(0), '0,0');
  });
}
