import 'package:flutter/material.dart';
import 'mock_data_profissional.dart';
import 'perfil_profissional_screen.dart';
import 'meus_servicos_screen.dart';
import 'pedidos_profissional_screen.dart';

const _gradient = LinearGradient(
  colors: [Color(0xFF00C6D7), Color(0xFF0077B6)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class HomeProfissionalScreen extends StatefulWidget {
  const HomeProfissionalScreen({super.key});

  @override
  State<HomeProfissionalScreen> createState() => _HomeProfissionalScreenState();
}

class _HomeProfissionalScreenState extends State<HomeProfissionalScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _BannerHeroProfissional(),
            const SizedBox(height: 28),
            FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ResumoCards(),
                      const SizedBox(height: 28),
                      const Text(
                        'O que você precisa hoje?',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 0.95,
                        children: _menuCards(context),
                      ),
                      const SizedBox(height: 28),
                      _PedidosRecentes(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        height: 52,
        decoration: const BoxDecoration(gradient: _gradient),
        child: const Center(
          child: Text(
            'Zeloo © 2026',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ),
      ),
    );
  }

  List<Widget> _menuCards(BuildContext context) {
    final cards = [
      _MenuCard(
        title: 'Meu Perfil',
        description: 'Edite seu perfil profissional',
        icon: Icons.person_rounded,
        cor: const Color(0xFF0077B6),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PerfilProfissionalScreen()),
        ),
      ),
      _MenuCard(
        title: 'Meus Serviços',
        description: 'Gerencie seus serviços',
        icon: Icons.assignment_rounded,
        cor: const Color(0xFF00B4D8),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MeusServicosScreen()),
        ),
      ),
      _MenuCard(
        title: 'Pedidos',
        description: 'Veja solicitações recebidas',
        icon: Icons.receipt_long_rounded,
        cor: const Color(0xFFFF6B35),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PedidosProfissionalScreen()),
        ),
      ),
      _MenuCard(
        title: 'Cadastro de Serviço',
        description: 'Adicione novos serviços',
        icon: Icons.add_circle_outline_rounded,
        cor: const Color(0xFF4CAF50),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const MeusServicosScreen()),
        ),
      ),
    ];
    return cards.map((c) => _CardItem(card: c)).toList();
  }
}

class _BannerHeroProfissional extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final primeiroNome = ProfissionalLogado.nome.split(' ').first;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: _gradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
      child: Column(
        children: [
          Image.asset('assets/imagens/logo.png', height: 90),
          const SizedBox(height: 4),
          Text(
            'Olá, $primeiroNome! 👋',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.circle, color: Color(0xFF4CAF50), size: 8),
                    const SizedBox(width: 6),
                    Text(
                      ProfissionalLogado.disponivel ? 'Disponível' : 'Indisponível',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        ProfissionalLogado.disponivel = !ProfissionalLogado.disponivel;
                      },
                      child: const Icon(Icons.swap_horiz_rounded,
                          color: Colors.white70, size: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            ProfissionalLogado.especialidade,
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _ResumoCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MiniCard(
          label: 'Avaliação',
          valor: '${ProfissionalLogado.avaliacao}',
          icon: Icons.star_rounded,
          cor: const Color(0xFFFFC107),
        ),
        const SizedBox(width: 12),
        _MiniCard(
          label: 'Pedidos',
          valor: '${pedidosProfissionalMock.length}',
          icon: Icons.receipt_long_rounded,
          cor: const Color(0xFF0077B6),
        ),
        const SizedBox(width: 12),
        _MiniCard(
          label: 'Valor/h',
          valor: 'R\$ ${ProfissionalLogado.precoHora.toInt()}',
          icon: Icons.attach_money_rounded,
          cor: const Color(0xFF4CAF50),
        ),
      ],
    );
  }
}

class _MiniCard extends StatelessWidget {
  final String label;
  final String valor;
  final IconData icon;
  final Color cor;

  const _MiniCard({
    required this.label,
    required this.valor,
    required this.icon,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: cor, size: 22),
            const SizedBox(height: 6),
            Text(
              valor,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}

class _PedidosRecentes extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final recentes = pedidosProfissionalMock.take(3).toList();
    if (recentes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Pedidos recentes',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A2E),
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const PedidosProfissionalScreen()),
              ),
              child: const Text(
                'Ver todos',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF0077B6),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...recentes.map((p) => _CardPedidoMini(pedido: p)),
      ],
    );
  }
}

class _CardPedidoMini extends StatelessWidget {
  final MockPedidoProfissional pedido;
  const _CardPedidoMini({required this.pedido});

  static const _statusConfig = {
    'aguardando': {'label': 'Aguardando', 'color': 0xFFFF9800},
    'confirmado': {'label': 'Confirmado', 'color': 0xFF0077B6},
    'concluido': {'label': 'Concluído', 'color': 0xFF4CAF50},
    'cancelado': {'label': 'Cancelado', 'color': 0xFFE53E3E},
  };

  @override
  Widget build(BuildContext context) {
    final cfg = _statusConfig[pedido.status]!;
    final cor = Color(cfg['color'] as int);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: cor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.person_rounded, color: cor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pedido.clienteNome,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                Text(
                  '${pedido.data} às ${pedido.horario}',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: cor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              cfg['label'] as String,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700, color: cor),
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuCard {
  final String title;
  final String description;
  final IconData icon;
  final Color cor;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.cor,
    required this.onTap,
  });
}

class _CardItem extends StatefulWidget {
  final _MenuCard card;
  const _CardItem({required this.card});

  @override
  State<_CardItem> createState() => _CardItemState();
}

class _CardItemState extends State<_CardItem> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.card.onTap,
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: widget.card.cor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(widget.card.icon, color: widget.card.cor, size: 28),
              ),
              const Spacer(),
              Text(
                widget.card.title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.card.description,
                style: TextStyle(fontSize: 11.5, color: Colors.grey[500], height: 1.35),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: widget.card.cor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      color: widget.card.cor,
                      size: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
