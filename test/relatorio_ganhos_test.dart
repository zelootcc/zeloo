import 'package:aplicativo_zeloo/relatorio_ganhos.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('relatório soma sete dias e calcula médias do mês', () {
    final resumo = ResumoGanhos.calcular([
      GanhoServico(valor: 100, concluidoEm: DateTime(2026, 9, 24, 10)),
      GanhoServico(valor: 200, concluidoEm: DateTime(2026, 9, 30, 14)),
      GanhoServico(valor: 90, concluidoEm: DateTime(2026, 9, 23, 9)),
      GanhoServico(valor: 500, concluidoEm: DateTime(2026, 8, 31, 18)),
    ], agora: DateTime(2026, 9, 30, 18));

    expect(resumo.totalUltimosSeteDias, 300);
    expect(resumo.servicosUltimosSeteDias, 2);
    expect(resumo.totalMes, 390);
    expect(resumo.servicosMes, 3);
    expect(resumo.mediaPorServicoMes, 130);
    expect(resumo.mediaDiariaMes, 13);
    expect(resumo.valoresPorDia.first, 100);
    expect(resumo.valoresPorDia.last, 200);
  });
}
