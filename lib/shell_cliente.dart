// cliente_shell.dart
// Shell principal com navegação para o cliente logado

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_cliente_screen.dart';

class ClienteShell extends StatefulWidget {
  const ClienteShell({super.key});

  @override
  State<ClienteShell> createState() => _ClienteShellState();
}

class _ClienteShellState extends State<ClienteShell> {
  int _indice = 0;

  static const _gradient = LinearGradient(
    colors: [Color(0xFF00C6D7), Color(0xFF0077B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  final List<Widget> _telas = const [HomeClienteScreen()];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      body: IndexedStack(index: _indice, children: _telas),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          gradient: _gradient,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 60,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _NavBtn(
                  icon: Icons.home_rounded,
                  label: 'Início',
                  selected: _indice == 0,
                  onTap: () => setState(() => _indice = 0),
                ),
                _NavBtn(
                  icon: Icons.grid_view_rounded,
                  label: 'Categorias',
                  selected: _indice == 1,
                  onTap: () => setState(() => _indice = 1),
                ),
                _NavBtn(
                  icon: Icons.receipt_long_rounded,
                  label: 'Pedidos',
                  selected: _indice == 2,
                  onTap: () => setState(() => _indice = 2),
                ),
                _NavBtn(
                  icon: Icons.person_rounded,
                  label: 'Perfil',
                  selected: _indice == 3,
                  onTap: () => setState(() => _indice = 3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavBtn({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: selected ? Colors.white : Colors.white60, size: 26),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: selected ? Colors.white : Colors.white60,
              fontSize: 11,
              fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
