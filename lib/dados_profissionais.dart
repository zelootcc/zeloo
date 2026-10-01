const areasAtuacao = [
  'Eletricista', 'Encanador', 'Limpeza', 'Diarista', 'Mecânico',
  'Pintor', 'Jardineiro', 'Marceneiro', 'Pedreiro', 'Serviços Gerais',
  'Montador de móveis', 'Técnico de ar-condicionado',
  'Técnico de eletrodomésticos', 'Técnico de informática',
  'Serralheiro', 'Vidraceiro', 'Chaveiro', 'Gesseiro',
  'Azulejista', 'Dedetizador', 'Piscineiro', 'Tapeceiro',
];

const diasSemana = {
  'segunda': 'Segunda-feira', 'terca': 'Terça-feira',
  'quarta': 'Quarta-feira', 'quinta': 'Quinta-feira',
  'sexta': 'Sexta-feira', 'sabado': 'Sábado', 'domingo': 'Domingo',
};

List<String> lerAreas(Map<String, dynamic> dados) {
  final areas = dados['areasAtuacao'];
  if (areas is List && areas.isNotEmpty) {
    return areas.whereType<String>().where((a) => a.trim().isNotEmpty).toSet().toList();
  }
  final antiga = dados['area'] ?? dados['especialidade'];
  return antiga is String && antiga.trim().isNotEmpty ? [antiga.trim()] : [];
}

class HorarioAtendimento {
  final int inicio;
  final int fim;
  const HorarioAtendimento({this.inicio = 480, this.fim = 1080});

  bool get valido => inicio >= 0 && fim < 1440 && inicio < fim;
  static String formatar(int minutos) =>
      '${(minutos ~/ 60).toString().padLeft(2, '0')}:${(minutos % 60).toString().padLeft(2, '0')}';
  Map<String, String> toMap() => {'inicio': formatar(inicio), 'fim': formatar(fim)};

  static int? _minutos(dynamic valor) {
    if (valor is! String || !RegExp(r'^\d{2}:\d{2}$').hasMatch(valor)) return null;
    final partes = valor.split(':').map(int.parse).toList();
    if (partes[0] > 23 || partes[1] > 59) return null;
    return partes[0] * 60 + partes[1];
  }

  static HorarioAtendimento? fromMap(dynamic dados) {
    if (dados is! Map) return null;
    final inicio = _minutos(dados['inicio']);
    final fim = _minutos(dados['fim']);
    if (inicio == null || fim == null) return null;
    final horario = HorarioAtendimento(inicio: inicio, fim: fim);
    return horario.valido ? horario : null;
  }
}

Map<String, HorarioAtendimento> lerHorarios(Map<String, dynamic> dados) {
  final mapa = dados['horariosAtendimento'];
  if (mapa is Map) {
    final resultado = <String, HorarioAtendimento>{};
    for (final dia in diasSemana.keys) {
      final horario = HorarioAtendimento.fromMap(mapa[dia]);
      if (horario != null) resultado[dia] = horario;
    }
    return resultado;
  }
  // Migração apenas das opções antigas cujo intervalo era conhecido.
  final antiga = dados['disponibilidade'];
  final quantidade = antiga == 'Segunda a Sexta, 8h–18h' ? 5
      : antiga == 'Segunda a Sábado, 8h–18h' ? 6 : 0;
  return {for (final dia in diasSemana.keys.take(quantidade)) dia: const HorarioAtendimento()};
}

String resumoHorarios(Map<String, HorarioAtendimento> horarios) {
  if (horarios.isEmpty) return 'Sob consulta';
  return diasSemana.entries.where((dia) => horarios.containsKey(dia.key)).map((dia) {
    final horario = horarios[dia.key]!;
    return '${dia.value}: ${HorarioAtendimento.formatar(horario.inicio)}–${HorarioAtendimento.formatar(horario.fim)}';
  }).join('; ');
}
