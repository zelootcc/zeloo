class ProfissionalModel {
  final String id;
  final String nome;
  final String especialidade;
  final double avaliacao;
  final int totalAvaliacoes;
  final String cidade;
  final String descricao;
  final double precoHora;
  final bool disponivel;

  const ProfissionalModel({
    required this.id,
    required this.nome,
    required this.especialidade,
    required this.avaliacao,
    required this.totalAvaliacoes,
    required this.cidade,
    required this.descricao,
    required this.precoHora,
    required this.disponivel,
  });

  factory ProfissionalModel.fromFirestore(
    String id,
    Map<String, dynamic> dados,
  ) {
    final valor = dados['precoHora'] ?? dados['valorHora'] ?? dados['preco'];
    final preco = valor is num
        ? valor.toDouble()
        : double.tryParse(
              valor?.toString().replaceAll(',', '.') ?? '',
            ) ??
            0;

    final avaliacao = dados['avaliacao'] is num
        ? (dados['avaliacao'] as num).toDouble()
        : 0.0;

    final totalAvaliacoes = dados['totalAvaliacoes'] is num
        ? (dados['totalAvaliacoes'] as num).toInt()
        : 0;

    final disponibilidade =
        dados['disponibilidade']?.toString().toLowerCase() ?? '';

    final disponivel = dados['disponivel'] is bool
        ? dados['disponivel'] as bool
        : !disponibilidade.contains('ocupado') &&
              !disponibilidade.contains('indispon');

    return ProfissionalModel(
      id: id,
      nome: dados['nome']?.toString() ?? 'Profissional',
      especialidade: dados['area']?.toString() ??
          dados['especialidade']?.toString() ??
          'Serviço',
      avaliacao: avaliacao,
      totalAvaliacoes: totalAvaliacoes,
      cidade: dados['regiao']?.toString() ??
          dados['cidade']?.toString() ??
          'Não informado',
      descricao: dados['descricao']?.toString() ??
          dados['descricaoProfissional']?.toString() ??
          'Profissional cadastrado na Zeloo.',
      precoHora: preco,
      disponivel: disponivel,
    );
  }
}
