import 'package:flutter/material.dart';

import 'barra_navegacao.dart';
import 'home_profissional_screen.dart';
import 'meus_servicos_screen.dart';
import 'pedidos_profissional_screen.dart';
import 'perfil_profissional_screen.dart';
import 'relatorios_profissional_screen.dart';

class ProfissionalShell extends StatefulWidget {
  const ProfissionalShell({super.key});

  @override
  State<ProfissionalShell> createState() => _ProfissionalShellState();
}

class _ProfissionalShellState extends State<ProfissionalShell> {
  int _indice = 2;

  void _selecionar(int indice) => setState(() => _indice = indice);
  void _voltarAoInicio() => _selecionar(2);

  late final List<Widget> _telas = [
    MeusServicosScreen(onVoltar: _voltarAoInicio),
    PedidosProfissionalScreen(onVoltar: _voltarAoInicio),
    HomeProfissionalScreen(mostrarRodape: false, onNavegar: _selecionar),
    RelatoriosProfissionalScreen(onVoltar: _voltarAoInicio),
    PerfilProfissionalScreen(mostrarRodape: false, onVoltar: _voltarAoInicio),
  ];

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: _indice == 2,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop && _indice != 2) _voltarAoInicio();
    },
    child: Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: IndexedStack(index: _indice, children: _telas),
      bottomNavigationBar: BarraNavegacaoZeloo(
        indice: _indice,
        indiceCentral: 2,
        onTap: _selecionar,
        itens: const [
          ItemNavegacaoZeloo(icon: Icons.assignment_rounded, label: 'Serviços'),
          ItemNavegacaoZeloo(icon: Icons.receipt_long_rounded, label: 'Pedidos'),
          ItemNavegacaoZeloo(icon: Icons.home_rounded, label: 'Início'),
          ItemNavegacaoZeloo(icon: Icons.bar_chart_rounded, label: 'Relatórios'),
          ItemNavegacaoZeloo(icon: Icons.person_rounded, label: 'Perfil'),
        ],
      ),
    ),
  );
}
