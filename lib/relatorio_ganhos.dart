class GanhoServico {
  final double valor;
  final DateTime concluidoEm;

  const GanhoServico({required this.valor, required this.concluidoEm});
}

class ResumoGanhos {
  final double totalUltimosSeteDias;
  final int servicosUltimosSeteDias;
  final double totalMes;
  final int servicosMes;
  final double mediaPorServicoMes;
  final double mediaDiariaMes;
  final List<double> valoresPorDia;

  const ResumoGanhos({
    required this.totalUltimosSeteDias,
    required this.servicosUltimosSeteDias,
    required this.totalMes,
    required this.servicosMes,
    required this.mediaPorServicoMes,
    required this.mediaDiariaMes,
    required this.valoresPorDia,
  });

  factory ResumoGanhos.calcular(List<GanhoServico> ganhos, {DateTime? agora}) {
    final hoje = agora ?? DateTime.now();
    final inicioHoje = DateTime(hoje.year, hoje.month, hoje.day);
    final inicioSemana = inicioHoje.subtract(const Duration(days: 6));
    final fimHoje = inicioHoje.add(const Duration(days: 1));
    final inicioMes = DateTime(hoje.year, hoje.month);
    final inicioProximoMes = DateTime(hoje.year, hoje.month + 1);

    final semana = ganhos.where(
      (ganho) =>
          !ganho.concluidoEm.isBefore(inicioSemana) &&
          ganho.concluidoEm.isBefore(fimHoje),
    );
    final mes = ganhos.where(
      (ganho) =>
          !ganho.concluidoEm.isBefore(inicioMes) &&
          ganho.concluidoEm.isBefore(inicioProximoMes),
    );
    final totalSemana = semana.fold<double>(
      0,
      (soma, ganho) => soma + ganho.valor,
    );
    final listaMes = mes.toList();
    final totalMes = listaMes.fold<double>(
      0,
      (soma, ganho) => soma + ganho.valor,
    );
    final porDia = List<double>.filled(7, 0);
    for (final ganho in semana) {
      final dia = DateTime(
        ganho.concluidoEm.year,
        ganho.concluidoEm.month,
        ganho.concluidoEm.day,
      );
      final indice = dia.difference(inicioSemana).inDays;
      if (indice >= 0 && indice < 7) porDia[indice] += ganho.valor;
    }

    return ResumoGanhos(
      totalUltimosSeteDias: totalSemana,
      servicosUltimosSeteDias: semana.length,
      totalMes: totalMes,
      servicosMes: listaMes.length,
      mediaPorServicoMes: listaMes.isEmpty ? 0 : totalMes / listaMes.length,
      mediaDiariaMes: totalMes / hoje.day,
      valoresPorDia: porDia,
    );
  }
}
