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
}
