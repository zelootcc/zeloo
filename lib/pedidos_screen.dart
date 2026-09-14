import 'package:flutter/material.dart';
import 'firebase_service.dart';

class PedidosScreen extends StatefulWidget {
  const PedidosScreen({super.key});

  @override
  State<PedidosScreen> createState() => _PedidosScreenState();
}

class _PedidosScreenState extends State<PedidosScreen> {
  static const _gradient = LinearGradient(
    colors: [Color(0xFF00C6D7), Color(0xFF0077B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  String _filtro = 'Todos';
  static const _filtros = ['Todos', 'Aguardando', 'Confirmado', 'Concluído', 'Cancelado'];

  String _statusDoFiltro(String filtro) {
    switch (filtro) {
      case 'Aguardando': return 'aguardando';
      case 'Confirmado': return 'confirmado';
      case 'Concluído': return 'concluido';
      case 'Cancelado': return 'cancelado';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: StreamBuilder(
        stream: FirebaseService.meusPedidosCliente(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text('Não foi possível carregar seus pedidos.\n${snapshot.error}', textAlign: TextAlign.center),
            ));
          }

          final docs = snapshot.data?.docs ?? [];
          final status = _statusDoFiltro(_filtro);
          final pedidos = docs.where((doc) {
            final dados = doc.data();
            return status.isEmpty || dados['status'] == status;
          }).toList();

          pedidos.sort((a, b) {
            final da = a.data()['criadoEm'];
            final db = b.data()['criadoEm'];
            if (da is Timestamp && db is Timestamp) return db.compareTo(da);
            return 0;
          });

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 140,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                automaticallyImplyLeading: false,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: _gradient,
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 56, 24, 20),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Meus Pedidos', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text('Acompanhe seus serviços', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14)),
                    ]),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 54,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: _filtros.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final f = _filtros[i];
                      final selected = _filtro == f;
                      return GestureDetector(
                        onTap: () => setState(() => _filtro = f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: selected ? _gradient : null,
                            color: selected ? null : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8)],
                          ),
                          child: Text(f, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: selected ? Colors.white : Colors.grey[600])),
                        ),
                      );
                    },
                  ),
                ),
              ),
              pedidos.isEmpty
                  ? const SliverFillRemaining(
                      child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(Icons.receipt_long_rounded, size: 64, color: Color(0xFFCCCCCC)),
                        SizedBox(height: 16),
                        Text('Nenhum pedido encontrado.', style: TextStyle(color: Colors.grey, fontSize: 15)),
                      ])),
                    )
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, i) => _CardPedido(dados: pedidos[i].data()),
                          childCount: pedidos.length,
                        ),
                      ),
                    ),
            ],
          );
        },
      ),
    );
  }
}

class _CardPedido extends StatefulWidget {
  final Map<String, dynamic> dados;
  const _CardPedido({required this.dados});

  @override
  State<_CardPedido> createState() => _CardPedidoState();
}

class _CardPedidoState extends State<_CardPedido> {
  double _scale = 1.0;

  static const _statusConfig = {
    'aguardando': {'label': 'Aguardando', 'color': 0xFFFF9800},
    'confirmado': {'label': 'Confirmado', 'color': 0xFF0077B6},
    'concluido': {'label': 'Concluído', 'color': 0xFF4CAF50},
    'cancelado': {'label': 'Cancelado', 'color': 0xFFE53E3E},
  };

  String _texto(dynamic valor, [String padrao = 'Não informado']) {
    if (valor == null || valor.toString().trim().isEmpty) return padrao;
    return valor.toString();
  }

  String _valor(dynamic valor) {
    if (valor is num) return valor.toDouble().toStringAsFixed(2);
    return _texto(valor, '0,00');
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.dados;
    final status = _texto(p['status'], 'aguardando');
    final cfg = _statusConfig[status] ?? _statusConfig['aguardando']!;
    final cor = Color(cfg['color'] as int);
    final label = cfg['label'] as String;

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 3))]),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                Container(width: 48, height: 48, decoration: BoxDecoration(color: cor.withOpacity(0.12), borderRadius: BorderRadius.circular(14)), child: Icon(Icons.receipt_long_rounded, color: cor, size: 24)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(_texto(p['profissionalNome']), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF1A1A2E))),
                  const SizedBox(height: 3),
                  Text(_texto(p['servico']), style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ])),
                Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: cor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)), child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: cor))),
              ]),
            ),
            Divider(height: 1, color: Colors.grey[100]),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(children: [
                Icon(Icons.calendar_today_rounded, size: 14, color: Colors.grey[400]),
                const SizedBox(width: 5),
                Text('${_texto(p['data'])} às ${_texto(p['horario'])}', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                const Spacer(),
                Text('R\$ ${_valor(p['valor'])}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0077B6))),
              ]),
            ),
          ]),
        ),
      ),
    );
  }
}
