import 'package:flutter/material.dart';
import 'botao_voltar.dart';

import 'cadastro_perfil_profissional_screen.dart';
import 'firebase_service.dart';
import 'meus_servicos_screen.dart';
import 'pedidos_profissional_screen.dart';
import 'perfil_notificacoes_screen.dart';

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
  late final _perfil = FirebaseService.observarProfissional();
  bool _disponivel = false;

  Future<void> _alternarDisponibilidade() async {
    try {
      final novoValor = !_disponivel;
      await FirebaseService.atualizarDisponibilidade(novoValor);

      if (mounted) {
        setState(() => _disponivel = novoValor);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar disponibilidade: $e')),
      );
    }
  }

  String _texto(
    Map<String, dynamic> dados,
    String campo, [
    String padrao = 'Não informado',
  ]) {
    final valor = dados[campo];
    if (valor == null || valor.toString().trim().isEmpty) return padrao;
    return valor.toString();
  }

  double _numero(Map<String, dynamic> dados, String campo) {
    final valor = dados[campo];
    if (valor is num) return valor.toDouble();
    return double.tryParse(valor?.toString().replaceAll(',', '.') ?? '') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: StreamBuilder(
        stream: _perfil,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError ||
              !snapshot.hasData ||
              !snapshot.data!.exists) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Não foi possível carregar seu perfil.\n${snapshot.error ?? 'Perfil não encontrado.'}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final dados = snapshot.data!.data()!;
          final nome = _texto(dados, 'nome', 'Profissional');
          final especialidade = _texto(dados, 'area', 'Serviço');
          final email =
              FirebaseService.usuario?.email ?? _texto(dados, 'email');
          final avaliacao = _numero(dados, 'avaliacao');
          final totalAvaliacoes = (dados['totalAvaliacoes'] is num)
              ? dados['totalAvaliacoes'] as num
              : 0;
          final preco = _numero(dados, 'precoHora');
          _disponivel = dados['disponivel'] is bool
              ? dados['disponivel'] as bool
              : false;

          final iniciais = nome
              .trim()
              .split(' ')
              .where((parte) => parte.isNotEmpty)
              .take(2)
              .map((parte) => parte[0].toUpperCase())
              .join();

          return SingleChildScrollView(
            child: Column(
              children: [
                ComBotaoVoltar(
                  child: _HeaderPerfil(
                  nome: nome,
                  especialidade: especialidade,
                  email: email,
                  iniciais: iniciais,
                  disponivel: _disponivel,
                  onToggle: _alternarDisponibilidade,
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _StatCard(
                            icon: Icons.star_rounded,
                            iconColor: const Color(0xFFFFC107),
                            label: 'Avaliação',
                            valor: avaliacao.toString(),
                          ),
                          const SizedBox(width: 10),
                          _StatCard(
                            icon: Icons.people_rounded,
                            iconColor: const Color(0xFF0077B6),
                            label: 'Avaliações',
                            valor: totalAvaliacoes.toString(),
                          ),
                          const SizedBox(width: 10),
                          _StatCard(
                            icon: Icons.attach_money_rounded,
                            iconColor: const Color(0xFF4CAF50),
                            label: 'Valor/hora',
                            valor: 'R\$ ${preco.toStringAsFixed(0)}',
                          ),
                        ],
                      ),
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
                                const CadastroPerfilProfissionalScreen(),
                          ),
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
                            builder: (_) => const MeusServicosScreen(),
                          ),
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
                            builder: (_) => const PedidosProfissionalScreen(),
                          ),
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
                            builder: (_) => const PerfilNotificacoesScreen(
                              abaSeguranca: true,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: OutlinedButton(
                          onPressed: () async {
                            await FirebaseService.sair();
                            if (!context.mounted) return;
                            Navigator.of(
                              context,
                            ).popUntil((route) => route.isFirst);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFE53E3E),
                            side: const BorderSide(
                              color: Color(0xFFFFCDD2),
                              width: 1.5,
                            ),
                            backgroundColor: const Color(0xFFFFF5F5),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Sair da conta',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
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
  final String nome;
  final String especialidade;
  final String email;
  final String iniciais;
  final bool disponivel;
  final VoidCallback onToggle;

  const _HeaderPerfil({
    required this.nome,
    required this.especialidade,
    required this.email,
    required this.iniciais,
    required this.disponivel,
    required this.onToggle,
  });

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
                      nome,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      especialidade,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      email,
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
            onTap: onToggle,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.circle,
                    size: 10,
                    color: disponivel
                        ? const Color(0xFF4CAF50)
                        : Colors.white54,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    disponivel
                        ? 'Disponível para serviços'
                        : 'Indisponível no momento',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.swap_horiz_rounded,
                    color: Colors.white70,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
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
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10),
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

class _MenuCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                color: cor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(icon, color: cor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
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
    );
  }
}
