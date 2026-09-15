import 'package:flutter/material.dart';

import 'firebase_service.dart';
import 'meus_servicos_screen.dart';
import 'pedidos_profissional_screen.dart';
import 'perfil_profissional_screen.dart';

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

class _HomeProfissionalScreenState extends State<HomeProfissionalScreen> {
  Future<Map<String, dynamic>> _dados() async {
    final documento = await FirebaseService.dadosProfissional();

    if (documento == null || !documento.exists) {
      throw Exception('Perfil profissional não encontrado.');
    }

    return documento.data()!;
  }

  String _texto(Map<String, dynamic> dados, String campo,
      [String padrao = 'Não informado']) {
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
    return FutureBuilder(
      future: _dados(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFFF4F7FB),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            backgroundColor: const Color(0xFFF4F7FB),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Não foi possível carregar seus dados.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        final dados = snapshot.data as Map<String, dynamic>;
        final nome = _texto(dados, 'nome', 'Profissional');
        final area = _texto(dados, 'area', 'Serviço');
        final avaliacao = _numero(dados, 'avaliacao');
        final preco = _numero(dados, 'precoHora');
        final disponivel = dados['disponivel'] == true;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F7FB),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: _gradient,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(36),
                      bottomRight: Radius.circular(36),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 48, 24, 28),
                  child: Column(
                    children: [
                      Image.asset('assets/imagens/logo.png', height: 80),
                      const SizedBox(height: 8),
                      Text(
                        'Olá, ${nome.split(' ').first}! 👋',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        area,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.circle,
                              color: disponivel
                                  ? const Color(0xFF4CAF50)
                                  : Colors.white54,
                              size: 8,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              disponivel ? 'Disponível' : 'Indisponível',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _ResumoCard(
                            label: 'Avaliação',
                            valor: avaliacao.toString(),
                            icon: Icons.star_rounded,
                            cor: const Color(0xFFFFC107),
                          ),
                          const SizedBox(width: 12),
                          _ResumoCard(
                            label: 'Pedidos',
                            valor: 'Ver',
                            icon: Icons.receipt_long_rounded,
                            cor: const Color(0xFF0077B6),
                          ),
                          const SizedBox(width: 12),
                          _ResumoCard(
                            label: 'Valor/h',
                            valor: 'R\$ ${preco.toStringAsFixed(0)}',
                            icon: Icons.attach_money_rounded,
                            cor: const Color(0xFF4CAF50),
                          ),
                        ],
                      ),
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
                        childAspectRatio: 1.05,
                        children: [
                          _MenuCard(
                            title: 'Meu Perfil',
                            description: 'Edite seu perfil profissional',
                            icon: Icons.person_rounded,
                            cor: const Color(0xFF0077B6),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PerfilProfissionalScreen(),
                              ),
                            ),
                          ),
                          _MenuCard(
                            title: 'Meus Serviços',
                            description: 'Gerencie seus serviços',
                            icon: Icons.assignment_rounded,
                            cor: const Color(0xFF00B4D8),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MeusServicosScreen(),
                              ),
                            ),
                          ),
                          _MenuCard(
                            title: 'Pedidos',
                            description: 'Veja solicitações recebidas',
                            icon: Icons.receipt_long_rounded,
                            cor: const Color(0xFFFF6B35),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PedidosProfissionalScreen(),
                              ),
                            ),
                          ),
                          _MenuCard(
                            title: 'Novo Serviço',
                            description: 'Adicione um serviço',
                            icon: Icons.add_circle_outline_rounded,
                            cor: const Color(0xFF4CAF50),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const MeusServicosScreen(),
                              ),
                            ),
                          ),
                        ],
                      ),
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
      },
    );
  }
}

class _ResumoCard extends StatelessWidget {
  final String label;
  final String valor;
  final IconData icon;
  final Color cor;

  const _ResumoCard({
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
                fontSize: 13,
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

class _MenuCard extends StatelessWidget {
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                color: cor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: cor, size: 28),
            ),
            const Spacer(),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 11.5,
                color: Colors.grey[500],
                height: 1.35,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
