import 'package:flutter/material.dart';
import 'mock_data_profissional.dart';
import 'cadastro_perfil_profissional_screen.dart';
import 'meus_servicos_screen.dart';
import 'pedidos_profissional_screen.dart';

const _gradient = LinearGradient(
  colors: [Color(0xFF00C6D7), Color(0xFF0077B6)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class PerfilProfissionalScreen extends StatefulWidget {
  const PerfilProfissionalScreen({super.key});

  @override
  State<PerfilProfissionalScreen> createState() =>
      _PerfilProfissionalScreenState();
}

class _PerfilProfissionalScreenState extends State<PerfilProfissionalScreen> {
  @override
  Widget build(BuildContext context) {
    final iniciais = ProfissionalLogado.nome
        .trim()
        .split(' ')
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _HeaderPerfil(
              iniciais: iniciais,
              onToggleDisponivel: () => setState(() {
                ProfissionalLogado.disponivel = !ProfissionalLogado.disponivel;
              }),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _StatsRow(),
                  const SizedBox(height: 24),
                  const Text(
                    'Minha Conta',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _MenuCard(
                    icon: Icons.person_outline_rounded,
                    title: 'Editar Perfil',
                    subtitle: 'Altere seus dados profissionais',
                    cor: const Color(0xFF0077B6),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              const CadastroPerfilProfissionalScreen()),
                    ).then((_) => setState(() {})),
                  ),
                  _MenuCard(
                    icon: Icons.assignment_rounded,
                    title: 'Meus Serviços',
                    subtitle: 'Gerencie seus serviços cadastrados',
                    cor: const Color(0xFF00B4D8),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MeusServicosScreen()),
                    ),
                  ),
                  _MenuCard(
                    icon: Icons.receipt_long_rounded,
                    title: 'Pedidos Recebidos',
                    subtitle: 'Veja e gerencie solicitações',
                    cor: const Color(0xFFFF6B35),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const PedidosProfissionalScreen()),
                    ),
                  ),
                  _MenuCard(
                    icon: Icons.star_outline_rounded,
                    title: 'Avaliações',
                    subtitle: 'Veja o que clientes dizem',
                    cor: const Color(0xFFFFC107),
                    onTap: () {},
                  ),
                  _MenuCard(
                    icon: Icons.bar_chart_rounded,
                    title: 'Relatórios',
                    subtitle: 'Acompanhe seus ganhos',
                    cor: const Color(0xFF4CAF50),
                    onTap: () {},
                  ),
                  _MenuCard(
                    icon: Icons.notifications_outlined,
                    title: 'Notificações',
                    subtitle: 'Preferências de notificação',
                    cor: const Color(0xFFAB47BC),
                    onTap: () {},
                  ),
                  _MenuCard(
                    icon: Icons.lock_outline_rounded,
                    title: 'Segurança',
                    subtitle: 'Senha e autenticação',
                    cor: const Color(0xFF023E8A),
                    onTap: () {},
                  ),
                  const SizedBox(height: 24),
                  _BotaoSair(context),
                  const SizedBox(height: 32),
                ],
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
}

class _HeaderPerfil extends StatelessWidget {
  final String iniciais;
  final VoidCallback onToggleDisponivel;

  const _HeaderPerfil({required this.iniciais, required this.onToggleDisponivel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: _gradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 28),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white38, width: 2),
                ),
                child: Center(
                  child: Text(
                    iniciais,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ProfissionalLogado.nome,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ProfissionalLogado.especialidade,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ProfissionalLogado.email,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onToggleDisponivel,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: ProfissionalLogado.disponivel
                    ? Colors.white.withOpacity(0.2)
                    : Colors.black.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.circle,
                    size: 10,
                    color: ProfissionalLogado.disponivel
                        ? const Color(0xFF4CAF50)
                        : Colors.white54,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    ProfissionalLogado.disponivel
                        ? 'Disponível para serviços'
                        : 'Indisponível no momento',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.swap_horiz_rounded,
                      color: Colors.white70, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatCard(
          icon: Icons.star_rounded,
          iconColor: const Color(0xFFFFC107),
          label: 'Avaliação',
          valor: '${ProfissionalLogado.avaliacao}',
        ),
        const SizedBox(width: 10),
        _StatCard(
          icon: Icons.people_rounded,
          iconColor: const Color(0xFF0077B6),
          label: 'Avaliações',
          valor: '${ProfissionalLogado.totalAvaliacoes}',
        ),
        const SizedBox(width: 10),
        _StatCard(
          icon: Icons.attach_money_rounded,
          iconColor: const Color(0xFF4CAF50),
          label: 'Valor/hora',
          valor: 'R\$ ${ProfissionalLogado.precoHora.toInt()}',
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String valor;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.valor,
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
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(height: 6),
            Text(
              valor,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color cor;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.cor,
    required this.onTap,
  });

  @override
  State<_MenuCard> createState() => _MenuCardState();
}

class _MenuCardState extends State<_MenuCard> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: widget.cor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(widget.icon, color: widget.cor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Colors.grey[400], size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _BotaoSair(BuildContext context) {
  return GestureDetector(
    onTap: () {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Sair da conta',
              style: TextStyle(fontWeight: FontWeight.w800)),
          content: const Text('Tem certeza que deseja sair?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar',
                  style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('Sair',
                  style: TextStyle(
                      color: Color(0xFFE53E3E),
                      fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      );
    },
    child: Container(
      width: double.infinity,
      height: 52,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFFFCDD2), width: 1.5),
        borderRadius: BorderRadius.circular(14),
        color: const Color(0xFFFFF5F5),
      ),
      child: const Center(
        child: Text(
          'Sair da conta',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Color(0xFFE53E3E),
          ),
        ),
      ),
    ),
  );
}
