import 'package:flutter/material.dart';

import 'firebase_service.dart';

const _gradient = LinearGradient(
  colors: [Color(0xFF00C6D7), Color(0xFF0077B6)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class PedidosProfissionalScreen extends StatefulWidget {
  const PedidosProfissionalScreen({super.key});

  @override
  State<PedidosProfissionalScreen> createState() =>
      _PedidosProfissionalScreenState();
}

class _PedidosProfissionalScreenState
    extends State<PedidosProfissionalScreen> {
  String _filtro = 'Todos';

  static const _filtros = [
    'Todos',
    'Aguardando',
    'Confirmado',
    'Concluído',
    'Cancelado',
  ];

  String _statusDoFiltro(String filtro) {
    switch (filtro) {
      case 'Aguardando':
        return 'aguardando';
      case 'Confirmado':
        return 'confirmado';
      case 'Concluído':
        return 'concluido';
      case 'Cancelado':
        return 'cancelado';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: StreamBuilder(
        stream: FirebaseService.meusPedidosProfissional(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Não foi possível carregar os pedidos.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          final status = _statusDoFiltro(_filtro);
          final pedidos = docs.where((doc) {
            final dados = doc.data() as Map<String, dynamic>;
            return status.isEmpty || dados['status'] == status;
          }).toList();

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 140,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(
                    Icons.chevron_left_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: _gradient,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 56, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pedidos Recebidos',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Gerencie suas solicitações',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 54,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    itemCount: _filtros.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final filtro = _filtros[i];
                      final selecionado = _filtro == filtro;

                      return GestureDetector(
                        onTap: () => setState(() => _filtro = filtro),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: selecionado ? _gradient : null,
                            color: selecionado ? null : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.06),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: Text(
                            filtro,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: selecionado
                                  ? Colors.white
                                  : Colors.grey[600],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              if (pedidos.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_rounded,
                          size: 64,
                          color: Color(0xFFCCCCCC),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Nenhum pedido encontrado.',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final doc = pedidos[index];
                        return _CardPedido(
                          dados: doc.data() as Map<String, dynamic>,
                          id: doc.id,
                        );
                      },
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
  final String id;
  final Map<String, dynamic> dados;

  const _CardPedido({required this.id, required this.dados});

  @override
  State<_CardPedido> createState() => _CardPedidoState();
}

class _CardPedidoState extends State<_CardPedido> {
  double _scale = 1.0;
  bool _processando = false;

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

  Future<void> _atualizarStatus(String status) async {
    setState(() => _processando = true);

    try {
      await FirebaseService.atualizarStatusPedido(widget.id, status);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar pedido: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _processando = false);
    }
  }

  void _mostrarAcoes(BuildContext context) {
    final status = _texto(widget.dados['status'], 'aguardando');

    if (status != 'aguardando') return;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Text(
              _texto(widget.dados['clienteNome'], 'Cliente'),
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _texto(widget.dados['descricao'], 'Sem descrição.'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _processando
                        ? null
                        : () => _atualizarStatus('cancelado'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFE53E3E),
                      side: const BorderSide(
                        color: Color(0xFFE53E3E),
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Recusar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _processando
                        ? null
                        : () => _atualizarStatus('confirmado'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0077B6),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Aceitar'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = _texto(widget.dados['status'], 'aguardando');
    final config = _statusConfig[status] ?? _statusConfig['aguardando']!;
    final cor = Color(config['color'] as int);
    final label = config['label'] as String;

    final valor = widget.dados['valor'] is num
        ? (widget.dados['valor'] as num).toDouble()
        : double.tryParse(
              _texto(widget.dados['valor'], '0').replaceAll(',', '.'),
            ) ??
            0;

    return GestureDetector(
      onTap: () => _mostrarAcoes(context),
      onTapDown: (_) => setState(() => _scale = 0.97),
      onTapUp: (_) => setState(() => _scale = 1.0),
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: cor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        color: cor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _texto(widget.dados['clienteNome'], 'Cliente'),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            _texto(widget.dados['servico'], 'Serviço'),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: cor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: cor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'R\$ ${valor.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0077B6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: Colors.grey[100]),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 14,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '${_texto(widget.dados['data'])} às ${_texto(widget.dados['horario'])}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    const Spacer(),
                    if (status == 'aguardando')
                      Text(
                        'Toque para responder',
                        style: TextStyle(
                          fontSize: 11,
                          color: const Color(0xFF0077B6).withOpacity(0.8),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
