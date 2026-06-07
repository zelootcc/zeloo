// mock_data_profissional.dart

class ProfissionalLogado {
  static String nome = 'Carlos Elétrica';
  static String email = 'carlos@email.com';
  static String telefone = '(12) 99999-5678';
  static String especialidade = 'Eletricista';
  static String regiao = 'São José dos Campos - SP';
  static String disponibilidade = 'Segunda a Sexta, 08:00 - 18:00';
  static String pagamento = 'PIX, Dinheiro, Cartão';
  static String descricao = 'Eletricista com 10 anos de experiência. Instalações, reparos e laudos elétricos.';
  static double avaliacao = 4.9;
  static int totalAvaliacoes = 134;
  static double precoHora = 80;
  static bool disponivel = true;
  static String fotoUrl = '';
  static List<String> portfolio = [];
}

class MockPedidoProfissional {
  final String id;
  final String clienteNome;
  final String servico;
  final String data;
  final String horario;
  final String status;
  final double valor;
  final String descricao;

  const MockPedidoProfissional({
    required this.id,
    required this.clienteNome,
    required this.servico,
    required this.data,
    required this.horario,
    required this.status,
    required this.valor,
    required this.descricao,
  });
}

class MockServico {
  final String id;
  final String titulo;
  final String descricao;
  final double preco;
  final String categoria;
  bool ativo;

  MockServico({
    required this.id,
    required this.titulo,
    required this.descricao,
    required this.preco,
    required this.categoria,
    this.ativo = true,
  });
}

final List<MockPedidoProfissional> pedidosProfissionalMock = [
  MockPedidoProfissional(
    id: 'PP001',
    clienteNome: 'Lucas Oliveira',
    servico: 'Instalação elétrica',
    data: '10/06/2026',
    horario: '09:00',
    status: 'aguardando',
    valor: 160,
    descricao: 'Preciso instalar tomadas no quarto e sala.',
  ),
  MockPedidoProfissional(
    id: 'PP002',
    clienteNome: 'Ana Costa',
    servico: 'Reparo de curto',
    data: '08/06/2026',
    horario: '14:00',
    status: 'confirmado',
    valor: 120,
    descricao: 'Curto-circuito no painel elétrico.',
  ),
  MockPedidoProfissional(
    id: 'PP003',
    clienteNome: 'Roberto Lima',
    servico: 'Laudo elétrico',
    data: '02/06/2026',
    horario: '10:00',
    status: 'concluido',
    valor: 200,
    descricao: 'Laudo para locação do imóvel.',
  ),
  MockPedidoProfissional(
    id: 'PP004',
    clienteNome: 'Maria Santos',
    servico: 'Troca de disjuntor',
    data: '28/05/2026',
    horario: '08:00',
    status: 'cancelado',
    valor: 80,
    descricao: 'Disjuntor desarmando constantemente.',
  ),
];

final List<MockServico> servicosMock = [
  MockServico(
    id: 'S001',
    titulo: 'Instalação Elétrica',
    descricao: 'Instalação de tomadas, interruptores e iluminação.',
    preco: 80,
    categoria: 'Eletricista',
    ativo: true,
  ),
  MockServico(
    id: 'S002',
    titulo: 'Reparo e Manutenção',
    descricao: 'Conserto de curtos e manutenção preventiva.',
    preco: 70,
    categoria: 'Eletricista',
    ativo: true,
  ),
  MockServico(
    id: 'S003',
    titulo: 'Laudo Elétrico',
    descricao: 'Laudo técnico para locação e venda de imóveis.',
    preco: 150,
    categoria: 'Eletricista',
    ativo: false,
  ),
];
