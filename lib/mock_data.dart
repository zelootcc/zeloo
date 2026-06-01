// mock_data.dart
// Dados fictícios compartilhados entre as telas do cliente logado

class ClienteLogado {
  static const String nome = 'Lucas Oliveira';
  static const String email = 'lucas.oliveira@email.com';
  static const String telefone = '(12) 99999-1234';
  static const String endereco = 'Jardim Satélite, São José dos Campos - SP';
  static const String fotoUrl = ''; // vazio = usar avatar com iniciais
}

class MockProfissional {
  final String id;
  final String nome;
  final String especialidade;
  final double avaliacao;
  final int totalAvaliacoes;
  final String cidade;
  final String descricao;
  final double precoHora;
  final bool disponivel;

  const MockProfissional({
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

class MockPedido {
  final String id;
  final String profissionalNome;
  final String servico;
  final String data;
  final String horario;
  final String status; // 'aguardando', 'confirmado', 'concluido', 'cancelado'
  final double valor;

  const MockPedido({
    required this.id,
    required this.profissionalNome,
    required this.servico,
    required this.data,
    required this.horario,
    required this.status,
    required this.valor,
  });
}

final List<MockProfissional> profissionaisMock = [
  MockProfissional(
    id: '1',
    nome: 'Carlos Elétrica',
    especialidade: 'Eletricista',
    avaliacao: 4.9,
    totalAvaliacoes: 134,
    cidade: 'São José dos Campos - SP',
    descricao:
        'Eletricista com 10 anos de experiência. Instalações, reparos e laudos elétricos.',
    precoHora: 80,
    disponivel: true,
  ),
  MockProfissional(
    id: '2',
    nome: 'João Hidráulica',
    especialidade: 'Encanador',
    avaliacao: 4.7,
    totalAvaliacoes: 89,
    cidade: 'São José dos Campos - SP',
    descricao:
        'Conserto de vazamentos, instalação de pias, chuveiros e aquecedores.',
    precoHora: 70,
    disponivel: true,
  ),
  MockProfissional(
    id: '3',
    nome: 'Maria Limpeza',
    especialidade: 'Limpeza',
    avaliacao: 5.0,
    totalAvaliacoes: 212,
    cidade: 'Jacareí - SP',
    descricao:
        'Limpeza residencial e comercial. Diarista e faxineira com materiais próprios.',
    precoHora: 50,
    disponivel: false,
  ),
  MockProfissional(
    id: '4',
    nome: 'Roberto Pintor',
    especialidade: 'Pintor',
    avaliacao: 4.6,
    totalAvaliacoes: 67,
    cidade: 'São José dos Campos - SP',
    descricao:
        'Pintura interna e externa, textura, grafiato e lavagem de fachadas.',
    precoHora: 65,
    disponivel: true,
  ),
  MockProfissional(
    id: '5',
    nome: 'André Jardins',
    especialidade: 'Jardineiro',
    avaliacao: 4.8,
    totalAvaliacoes: 45,
    cidade: 'Taubaté - SP',
    descricao: 'Manutenção de jardins, poda, paisagismo e plantio.',
    precoHora: 55,
    disponivel: true,
  ),
  MockProfissional(
    id: '6',
    nome: 'Paulo Marcenaria',
    especialidade: 'Marceneiro',
    avaliacao: 4.5,
    totalAvaliacoes: 38,
    cidade: 'São José dos Campos - SP',
    descricao: 'Móveis planejados, reparos em móveis e instalação de cozinhas.',
    precoHora: 90,
    disponivel: true,
  ),
];

final List<MockPedido> pedidosMock = [
  MockPedido(
    id: 'P001',
    profissionalNome: 'Carlos Elétrica',
    servico: 'Eletricista',
    data: '28/05/2025',
    horario: '14:00',
    status: 'concluido',
    valor: 160,
  ),
  MockPedido(
    id: 'P002',
    profissionalNome: 'Maria Limpeza',
    servico: 'Limpeza',
    data: '02/06/2025',
    horario: '08:00',
    status: 'confirmado',
    valor: 150,
  ),
  MockPedido(
    id: 'P003',
    profissionalNome: 'João Hidráulica',
    servico: 'Encanador',
    data: '10/06/2025',
    horario: '10:00',
    status: 'aguardando',
    valor: 140,
  ),
  MockPedido(
    id: 'P004',
    profissionalNome: 'Roberto Pintor',
    servico: 'Pintor',
    data: '15/04/2025',
    horario: '09:00',
    status: 'cancelado',
    valor: 130,
  ),
];
