import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'barra_navegacao.dart';
import 'categorias_screen.dart';
import 'home_cliente_screen.dart';
import 'pedidos_screen.dart';
import 'perfil_screen.dart';

class ClienteShell extends StatefulWidget {
  const ClienteShell({super.key});

  @override
  State<ClienteShell> createState() => _ClienteShellState();
}

class _ClienteShellState extends State<ClienteShell> {
  int _indice = 0;

  void _voltarAoInicio() => setState(() => _indice = 0);

  late final List<Widget> _telas = [
    const HomeClienteScreen(),
    CategoriasScreen(showBottomNavigation: false, onVoltar: _voltarAoInicio),
    PedidosScreen(onVoltar: _voltarAoInicio),
    PerfilScreen(onVoltar: _voltarAoInicio),
  ];

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: IndexedStack(index: _indice, children: _telas),
      bottomNavigationBar: BarraNavegacaoZeloo(
        indice: _indice,
        onTap: (indice) => setState(() => _indice = indice),
        itens: const [
          ItemNavegacaoZeloo(icon: Icons.home_rounded, label: 'Início'),
          ItemNavegacaoZeloo(icon: Icons.grid_view_rounded, label: 'Categorias'),
          ItemNavegacaoZeloo(icon: Icons.receipt_long_rounded, label: 'Pedidos'),
          ItemNavegacaoZeloo(icon: Icons.person_rounded, label: 'Perfil'),
        ],
      ),
    );
  }
}
