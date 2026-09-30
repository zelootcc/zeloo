import 'dados_profissionais.dart';

class ProfissionalModel {
  final String id;
  final String nome;
  final String especialidade;
  final List<String> areas;
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
    this.areas = const [],
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
        : double.tryParse(valor?.toString().replaceAll(',', '.') ?? '') ?? 0;

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

    final areas = lerAreas(dados);
    return ProfissionalModel(
      id: id,
      nome: dados['nome']?.toString() ?? 'Profissional',
      especialidade: areas.isEmpty ? 'Serviço' : areas.join(', '),
      areas: areas,
      avaliacao: avaliacao,
      totalAvaliacoes: totalAvaliacoes,
      cidade:
          dados['regiao']?.toString() ??
          dados['cidade']?.toString() ??
          'Não informado',
      descricao:
          dados['descricao']?.toString() ??
          dados['descricaoProfissional']?.toString() ??
          'Profissional cadastrado na Zeloo.',
      precoHora: preco,
      disponivel: disponivel,
    );
  }
}
