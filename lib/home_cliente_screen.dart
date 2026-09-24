import 'package:flutter/material.dart';
import 'firebase_service.dart';
import 'lista_profissionais_real.dart';
import 'perfil_screen.dart';
import 'pedidos_screen.dart';

const _gradientPrincipal = LinearGradient(
  colors: [Color(0xFF00C6D7), Color(0xFF0077B6)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class HomeClienteScreen extends StatefulWidget {
  const HomeClienteScreen({super.key});
  @override
  State<HomeClienteScreen> createState() => _HomeClienteScreenState();
}

class _HomeClienteScreenState extends State<HomeClienteScreen> {
  late final _perfil = FirebaseService.observarUsuario();
  String nome(Map<String, dynamic> d) =>
      d['nome']?.toString().split(' ').first ?? 'Cliente';
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF4F7FB),
    body: StreamBuilder(
      stream: _perfil,
      builder: (context, s) {
        if (s.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (s.hasError || !s.hasData || !s.data!.exists) {
          return const Center(
            child: Text('Não foi possível carregar seu perfil.'),
          );
        }
        final d = s.data?.data() ?? {};
        return SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 55, 24, 28),
                decoration: const BoxDecoration(
                  gradient: _gradientPrincipal,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(36),
                    bottomRight: Radius.circular(36),
                  ),
                ),
                child: Column(
                  children: [
                    Image.asset('assets/imagens/logominimal.png', height: 80),
                    const SizedBox(height: 10),
                    Text(
                      'Olá, ${nome(d)}!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Tudo que você precisa em um só lugar.',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 18),
                    GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ListaProfissionaisRealScreen(),
                        ),
                      ),
                      child: Container(
                        height: 46,
                        padding: const EdgeInsets.symmetric(horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.search_rounded,
                              color: Color(0xFF0077B6),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Buscar profissionais...',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'O que você precisa hoje?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
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
                        _Card(
                          'Profissionais',
                          'Encontre quem pode ajudar',
                          Icons.people_alt_rounded,
                          const Color(0xFF0077B6),
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const ListaProfissionaisRealScreen(),
                            ),
                          ),
                        ),
                        _Card(
                          'Meu Perfil',
                          'Seus dados pessoais',
                          Icons.person_rounded,
                          const Color(0xFF00B4D8),
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PerfilScreen(),
                            ),
                          ),
                        ),
                        _Card(
                          'Meus Pedidos',
                          'Acompanhe seus serviços',
                          Icons.receipt_long_rounded,
                          const Color(0xFF023E8A),
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PedidosScreen(),
                            ),
                          ),
                        ),
                        _Card(
                          'Buscar Serviço',
                          'Escolha um serviço',
                          Icons.search_rounded,
                          const Color(0xFF4CAF50),
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const ListaProfissionaisRealScreen(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF023E8A), Color(0xFF0077B6)],
                        ),
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Text(
                        'Encontre o profissional certo, rápido e sem enrolação.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          height: 1.35,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}

class _Card extends StatelessWidget {
  final String titulo, sub;
  final IconData icon;
  final Color cor;
  final VoidCallback onTap;
  const _Card(this.titulo, this.sub, this.icon, this.cor, this.onTap);
  @override
  Widget build(BuildContext c) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.06), blurRadius: 12),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: cor.withOpacity(.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: cor, size: 28),
          ),
          const Spacer(),
          Text(
            titulo,
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(sub, style: TextStyle(color: Colors.grey[500], fontSize: 11.5)),
        ],
      ),
    ),
  );
}
