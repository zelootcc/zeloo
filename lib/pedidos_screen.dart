import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'avaliacao_dialog.dart';
import 'botao_voltar.dart';
import 'firebase_service.dart';
import 'pedido_status.dart';
import 'zeloo_ui.dart';

class PedidosScreen extends StatefulWidget {
  final VoidCallback? onVoltar;
  final String? pedidoDestacadoId;

  const PedidosScreen({super.key, this.onVoltar, this.pedidoDestacadoId});

  @override
  State<PedidosScreen> createState() => _PedidosScreenState();
}

class _PedidosScreenState extends State<PedidosScreen> {
  String _filtro = 'Todos';
  static const _filtros = [
    'Todos',
    'Aguardando',
    'Ativos',
    'Concluídos',
    'Cancelados',
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF4F7FB),
    body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseService.meusPedidosCliente(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text('Não foi possível carregar seus pedidos.'),
          );
        }

        final pedidos = [...?snapshot.data?.docs]
          ..sort((a, b) {
            final dataA = a.data()['criadoEm'] as Timestamp?;
            final dataB = b.data()['criadoEm'] as Timestamp?;
            return (dataB?.millisecondsSinceEpoch ?? 0).compareTo(
              dataA?.millisecondsSinceEpoch ?? 0,
            );
          });
        if (widget.pedidoDestacadoId != null) {
          final indice = pedidos.indexWhere(
            (pedido) => pedido.id == widget.pedidoDestacadoId,
          );
          if (indice > 0) pedidos.insert(0, pedidos.removeAt(indice));
        }
        final filtrados = pedidos.where((doc) {
          final status =
              doc.data()['status']?.toString() ?? PedidoStatus.aguardando;
          return PedidoStatus.pertenceAoFiltro(status, _filtro);
        }).toList();

        return CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 140,
              pinned: true,
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
              leading: Align(
                alignment: Alignment.topLeft,
                child: BotaoVoltar(onVoltar: widget.onVoltar),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: zelooGradiente,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 56, 24, 20),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Meus Pedidos',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Acompanhe cada etapa do serviço',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: _Filtros(
                filtros: _filtros,
                selecionado: _filtro,
                onSelecionar: (filtro) => setState(() => _filtro = filtro),
              ),
            ),
            if (filtrados.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.receipt_long_rounded,
                        size: 64,
                        color: Color(0xFFB7C6D2),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Nenhum pedido encontrado.',
                        style: TextStyle(color: Color(0xFF718496)),
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
                    (context, index) => _CardPedidoCliente(
                      key: ValueKey(filtrados[index].id),
                      id: filtrados[index].id,
                      dados: filtrados[index].data(),
                    ),
                    childCount: filtrados.length,
                  ),
                ),
              ),
          ],
        );
      },
    ),
  );
}

class _Filtros extends StatelessWidget {
  final List<String> filtros;
  final String selecionado;
  final ValueChanged<String> onSelecionar;

  const _Filtros({
    required this.filtros,
    required this.selecionado,
    required this.onSelecionar,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 58,
    child: ListView.separated(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: filtros.length,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (_, index) {
        final filtro = filtros[index];
        final ativo = filtro == selecionado;
        return GestureDetector(
          onTap: () => onSelecionar(filtro),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
            decoration: BoxDecoration(
              gradient: ativo ? zelooGradiente : null,
              color: ativo ? null : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: ativo ? Colors.transparent : const Color(0xFFE4EDF4),
              ),
            ),
            child: Text(
              filtro,
              style: TextStyle(
                color: ativo ? Colors.white : const Color(0xFF64788B),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        );
      },
    ),
  );
}

class _CardPedidoCliente extends StatefulWidget {
  final String id;
  final Map<String, dynamic> dados;

  const _CardPedidoCliente({super.key, required this.id, required this.dados});

  @override
  State<_CardPedidoCliente> createState() => _CardPedidoClienteState();
}

class _CardPedidoClienteState extends State<_CardPedidoCliente> {
  bool _processando = false;

  String _texto(dynamic valor, [String padrao = 'Não informado']) {
    final texto = valor?.toString().trim() ?? '';
    return texto.isEmpty ? padrao : texto;
  }

  Future<void> _executar(Future<void> Function() acao, String sucesso) async {
    setState(() => _processando = true);
    try {
      await acao();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(sucesso)));
      }
    } catch (erro) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível concluir a ação: $erro')),
        );
      }
    } finally {
      if (mounted) setState(() => _processando = false);
    }
  }

  Future<void> _cancelar() async {
    final controller = TextEditingController();
    final motivo = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text(
          'Cancelar pedido?',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: TextField(
          controller: controller,
          minLines: 2,
          maxLines: 3,
          decoration: campoZeloo(
            'Conte brevemente o motivo',
            icon: Icons.chat_bubble_outline_rounded,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Voltar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53E3E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Cancelar pedido'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (motivo == null) return;
    await _executar(
      () => FirebaseService.cancelarPedido(widget.id, motivo),
      'Pedido cancelado.',
    );
  }

  Future<void> _novoCodigo() => _executar(() async {
    await FirebaseService.gerarNovoCodigo(widget.id);
  }, 'Um novo código foi gerado.');

  Future<void> _abrirAvaliacao() async {
    final enviada = await mostrarAvaliacaoPedido(
      context,
      pedidoId: widget.id,
      profissionalNome: _texto(
        widget.dados['profissionalNome'],
        'o profissional',
      ),
    );
    if (enviada && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Obrigado pela sua avaliação!')),
      );
    }
  }

  Future<void> _confirmarEAvaliar() async {
    setState(() => _processando = true);
    try {
      await FirebaseService.confirmarConclusao(widget.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Serviço concluído com sucesso.')),
      );
    } catch (erro) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível concluir: $erro')),
        );
      }
      return;
    } finally {
      if (mounted) setState(() => _processando = false);
    }
    if (mounted) await _abrirAvaliacao();
  }

  @override
  Widget build(BuildContext context) {
    final dados = widget.dados;
    final status = PedidoStatus.normalizar(
      _texto(dados['status'], PedidoStatus.aguardando),
    );
    final cor = PedidoStatus.cor(status);
    final valor = (dados['valor'] as num?)?.toDouble() ?? 0;
    final iniciadoEm = dados['iniciadoEm'] as Timestamp?;
    final motivo = dados['motivoCancelamento']?.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: painelZeloo(destaque: status == PedidoStatus.emAndamento),
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
                    color: cor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(PedidoStatus.icone(status), color: cor),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _texto(dados['profissionalNome'], 'Profissional'),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: zelooTexto,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _texto(dados['servico'], 'Serviço'),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64788B),
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusChip(status: status),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEDF2F6)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.calendar_today_rounded,
                  size: 14,
                  color: Color(0xFF8DA0B0),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${_texto(dados['data'])} às ${_texto(dados['horario'])}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64788B),
                    ),
                  ),
                ),
                Text(
                  'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: zelooAzul,
                  ),
                ),
              ],
            ),
          ),
          if (status != PedidoStatus.cancelado) ProgressoPedido(status: status),
          if (PedidoStatus.codigoVisivelParaCliente(status))
            _CodigoDoPedido(
              pedidoId: widget.id,
              tentativas: (dados['tentativasCodigo'] as num?)?.toInt() ?? 0,
              processando: _processando,
              onNovoCodigo: _novoCodigo,
            ),
          if (status == PedidoStatus.emAndamento && iniciadoEm != null)
            _AvisoPedido(
              icon: Icons.timer_outlined,
              titulo: 'Serviço em andamento',
              child: CronometroPedido(iniciadoEm: iniciadoEm),
            ),
          if (status == PedidoStatus.aguardandoConclusao)
            _AcaoConclusao(
              processando: _processando,
              onConfirmar: _confirmarEAvaliar,
            ),
          if (status == PedidoStatus.concluido)
            _AvaliacaoDoPedido(pedidoId: widget.id, onAvaliar: _abrirAvaliacao),
          if (status == PedidoStatus.cancelado && motivo != null)
            _AvisoPedido(
              icon: Icons.info_outline_rounded,
              titulo: 'Motivo do cancelamento',
              child: Text(
                motivo,
                style: const TextStyle(color: Color(0xFF64788B), height: 1.35),
              ),
            ),
          if (PedidoStatus.podeCancelar(status))
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _processando ? null : _cancelar,
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text('Cancelar pedido'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE53E3E),
                    side: const BorderSide(color: Color(0xFFE9A7A7)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final cor = PedidoStatus.cor(status);
    return Container(
      constraints: const BoxConstraints(maxWidth: 118),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        PedidoStatus.nome(status),
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: cor),
      ),
    );
  }
}

class _CodigoDoPedido extends StatelessWidget {
  final String pedidoId;
  final int tentativas;
  final bool processando;
  final VoidCallback onNovoCodigo;

  const _CodigoDoPedido({
    required this.pedidoId,
    required this.tentativas,
    required this.processando,
    required this.onNovoCodigo,
  });

  @override
  Widget build(
    BuildContext context,
  ) => StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
    stream: FirebaseService.observarCodigoPedido(pedidoId),
    builder: (context, snapshot) {
      final codigo = snapshot.data?.data()?['codigo']?.toString();
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 3, 16, 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE9FBFD), Color(0xFFEDF5FF)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFBCE8EF)),
        ),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shield_outlined, color: zelooAzul, size: 19),
                SizedBox(width: 7),
                Text(
                  'Código para iniciar o serviço',
                  style: TextStyle(
                    color: zelooTexto,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              codigo ?? '••••',
              style: const TextStyle(
                color: zelooAzul,
                fontSize: 31,
                fontWeight: FontWeight.w900,
                letterSpacing: 10,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              tentativas >= 5
                  ? 'As tentativas acabaram. Gere um novo código.'
                  : 'Informe somente quando o profissional estiver no local.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF64788B),
                fontSize: 11,
                height: 1.35,
              ),
            ),
            if (codigo == null || tentativas >= 5) ...[
              const SizedBox(height: 10),
              TextButton.icon(
                onPressed: processando ? null : onNovoCodigo,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Gerar novo código'),
              ),
            ],
          ],
        ),
      );
    },
  );
}

class _AvisoPedido extends StatelessWidget {
  final IconData icon;
  final String titulo;
  final Widget child;

  const _AvisoPedido({
    required this.icon,
    required this.titulo,
    required this.child,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: const EdgeInsets.fromLTRB(16, 3, 16, 14),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFF2F9FC),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: zelooAzul),
            const SizedBox(width: 7),
            Text(
              titulo,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: zelooTexto,
              ),
            ),
          ],
        ),
        const SizedBox(height: 9),
        child,
      ],
    ),
  );
}

class _AcaoConclusao extends StatelessWidget {
  final bool processando;
  final VoidCallback onConfirmar;

  const _AcaoConclusao({required this.processando, required this.onConfirmar});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(16, 3, 16, 14),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFEAF8FC),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFB3E8EF)),
    ),
    child: Column(
      children: [
        const Text(
          'O profissional informou que terminou.',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w800, color: zelooTexto),
        ),
        const SizedBox(height: 6),
        const Text(
          'Confira o serviço antes de confirmar.',
          style: TextStyle(fontSize: 12, color: Color(0xFF64788B)),
        ),
        const SizedBox(height: 12),
        BotaoZeloo(
          texto: processando ? 'Confirmando...' : 'Confirmar conclusão',
          icon: Icons.verified_rounded,
          onPressed: processando ? null : onConfirmar,
        ),
      ],
    ),
  );
}

class _AvaliacaoDoPedido extends StatelessWidget {
  final String pedidoId;
  final VoidCallback onAvaliar;

  const _AvaliacaoDoPedido({required this.pedidoId, required this.onAvaliar});

  @override
  Widget build(BuildContext context) =>
      StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseService.observarAvaliacaoPedido(pedidoId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.only(bottom: 14),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            );
          }
          final dados = snapshot.data?.data();
          if (dados == null) {
            return Container(
              margin: const EdgeInsets.fromLTRB(16, 3, 16, 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E8),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFFE19A)),
              ),
              child: Column(
                children: [
                  const Text(
                    'Conte como foi sua experiência',
                    style: TextStyle(
                      color: zelooTexto,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onAvaliar,
                      icon: const Icon(Icons.star_rounded),
                      label: const Text('Avaliar profissional'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFB300),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final nota = (dados['nota'] as num?)?.toInt() ?? 0;
          final comentario = dados['comentario']?.toString().trim() ?? '';
          return Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(16, 3, 16, 14),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF9E8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ...List.generate(
                      5,
                      (index) => Icon(
                        index < nota
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        size: 19,
                        color: const Color(0xFFFFB300),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$nota/5',
                      style: const TextStyle(
                        color: zelooTexto,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                if (comentario.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    comentario,
                    style: const TextStyle(
                      color: Color(0xFF64788B),
                      height: 1.35,
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      );
}
