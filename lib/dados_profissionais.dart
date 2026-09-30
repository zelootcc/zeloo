const areasAtuacao = <String>[
  'Eletricista',
  'Encanador',
  'Limpeza',
  'Diarista',
  'Mecânico',
  'Pintor',
  'Jardineiro',
  'Marceneiro',
  'Pedreiro',
  'Serviços Gerais',
  'Montador de Móveis',
  'Técnico de Informática',
  'Técnico de Ar-condicionado',
  'Técnico de Eletrodomésticos',
  'Chaveiro',
  'Serralheiro',
  'Vidraceiro',
  'Gesseiro',
  'Azulejista',
  'Dedetizador',
  'Piscineiro',
  'Instalador de Câmeras',
];

List<String> lerAreas(Map<String, dynamic> dados) {
  final lista = dados['areasAtuacao'];
  final valores = lista is List
      ? lista.map((v) => v.toString())
      : (dados['area'] ?? dados['especialidade'] ?? '').toString().split(',');
  return valores
      .map((v) => v.trim())
      .where((v) => v.isNotEmpty)
      .toSet()
      .toList();
}

bool areasValidas(List<String> areas) =>
    areas.isNotEmpty &&
    areas.length <= 3 &&
    areas.toSet().length == areas.length &&
    areas.every(areasAtuacao.contains);

const diasSemana = <String, String>{
  'segunda': 'Segunda-feira',
  'terca': 'Terça-feira',
  'quarta': 'Quarta-feira',
  'quinta': 'Quinta-feira',
  'sexta': 'Sexta-feira',
  'sabado': 'Sábado',
  'domingo': 'Domingo',
};

class HorarioAtendimento {
  final String inicio;
  final String fim;
  const HorarioAtendimento(this.inicio, this.fim);

  bool get valido {
    final formato = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$');
    return formato.hasMatch(inicio) &&
        formato.hasMatch(fim) &&
        inicio.compareTo(fim) < 0;
  }

  Map<String, String> toMap() => {'inicio': inicio, 'fim': fim};
}

Map<String, HorarioAtendimento> lerHorarios(Map<String, dynamic> dados) {
  final mapa = dados['horariosAtendimento'];
  if (mapa is Map) {
    return {
      for (final dia in diasSemana.keys)
        if (mapa[dia] is Map)
          dia: HorarioAtendimento(
            mapa[dia]['inicio']?.toString() ?? '',
            mapa[dia]['fim']?.toString() ?? '',
          ),
    };
  }
  // Só converte os horários antigos que tinham início e fim definidos.
  final antigo = dados['disponibilidade'];
  final quantidade = antigo == 'Segunda a Sexta, 8h–18h'
      ? 5
      : antigo == 'Segunda a Sábado, 8h–18h'
      ? 6
      : 0;
  return {
    for (final dia in diasSemana.keys.take(quantidade))
      dia: const HorarioAtendimento('08:00', '18:00'),
  };
}

String? validarHorarios(Map<String, HorarioAtendimento> horarios) {
  if (horarios.isEmpty) return 'Escolha pelo menos um dia de atendimento.';
  for (final entry in horarios.entries) {
    if (!diasSemana.containsKey(entry.key) || !entry.value.valido) {
      return 'Em ${diasSemana[entry.key] ?? entry.key}, o término deve ser depois do início.';
    }
  }
  return null;
}

Map<String, dynamic> dadosAtuacao(
  List<String> areas,
  Map<String, HorarioAtendimento> horarios,
) {
  if (!areasValidas(areas))
    throw ArgumentError('Selecione de 1 a 3 áreas da lista.');
  final erro = validarHorarios(horarios);
  if (erro != null) throw ArgumentError(erro);
  return {
    'areasAtuacao': areas.toList(),
    'area': areas.join(', '),
    'especialidade': areas.join(', '),
    'horariosAtendimento': {
      for (final dia in diasSemana.keys)
        if (horarios.containsKey(dia)) dia: horarios[dia]!.toMap(),
    },
    'disponibilidade': diasSemana.entries
        .where((dia) => horarios.containsKey(dia.key))
        .map(
          (dia) =>
              '${dia.value}: ${horarios[dia.key]!.inicio}–${horarios[dia.key]!.fim}',
        )
        .join('; '),
  };
}
