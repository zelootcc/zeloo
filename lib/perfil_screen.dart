import 'package:flutter/material.dart';
import 'mock_data.dart';
import 'perfil_editar_screen.dart';
import 'perfil_enderecos_screen.dart';
import 'perfil_pagamentos_screen_1.dart';
import 'perfil_notificacoes_screen.dart';

const _gradientPrincipal = LinearGradient(
  colors: [Color(0xFF00C6D7), Color(0xFF0077B6)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final iniciais = ClienteLogado.nome
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
            _HeaderPerfil(iniciais: iniciais),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                    subtitle: 'Altere seus dados pessoais',
                    cor: const Color(0xFF0077B6),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PerfilEditarScreen(),
                      ),
                    ),
                  ),
                  _MenuCard(
                    icon: Icons.location_on_outlined,
                    title: 'Endereços',
                    subtitle: 'Gerencie seus endereços',
                    cor: const Color(0xFF4CAF50),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PerfilEnderecosScreen(),
                      ),
                    ),
                  ),
                  _MenuCard(
                    icon: Icons.credit_card_rounded,
                    title: 'Pagamentos',
                    subtitle: 'Formas de pagamento',
                    cor: const Color(0xFFFF6B35),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PerfilPagamentosScreen(),
                      ),
                    ),
                  ),
                  _MenuCard(
                    icon: Icons.notifications_outlined,
                    title: 'Notificações',
                    subtitle: 'Preferências de notificação',
                    cor: const Color(0xFFAB47BC),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PerfilNotificacoesScreen(),
                      ),
                    ),
                  ),
                  _MenuCard(
                    icon: Icons.lock_outline_rounded,
                    title: 'Segurança',
                    subtitle: 'Senha e autenticação',
                    cor: const Color(0xFF023E8A),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const PerfilNotificacoesScreen(abaSeguranca: true),
                      ),
                    ),
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
        decoration: const BoxDecoration(gradient: _gradientPrincipal),
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
  const _HeaderPerfil({required this.iniciais});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: _gradientPrincipal,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 56, 24, 28),
      child: Row(
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
                  ClienteLogado.nome,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ClienteLogado.email,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  ClienteLogado.telefone,
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
              Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey[400],
                size: 22,
              ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Sair da conta',
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: const Text('Tem certeza que deseja sair?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text(
                'Sair',
                style: TextStyle(
                  color: Color(0xFFE53E3E),
                  fontWeight: FontWeight.w700,
                ),
              ),
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
