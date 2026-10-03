import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'firebase_service.dart';
import 'pedido_status.dart';
import 'zeloo_ui.dart';

class PedidosProfissionalScreen extends StatefulWidget {
  final String? pedidoDestacadoId;
  final VoidCallback? onVoltar;

  const PedidosProfissionalScreen({super.key, this.pedidoDestacadoId, this.onVoltar});

  @override
  State<PedidosProfissionalScreen> createState() =>
      _PedidosProfissionalScreenState();
}

class _PedidosProfissionalScreenState extends State<PedidosProfissionalScreen> {
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
      stream: FirebaseService.meusPedidosProfissional(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text('Não foi possível carregar os pedidos.'),
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
              leading: IconButton(
                icon: const Icon(
                  Icons.chevron_left_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: widget.onVoltar ?? () => Navigator.pop(context),
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
                        'Pedidos Recebidos',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Avance uma etapa de cada vez',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 58,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  itemCount: _filtros.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, index) {
                    final filtro = _filtros[index];
                    final ativo = filtro == _filtro;
                    return GestureDetector(
                      onTap: () => setState(() => _filtro = filtro),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: ativo ? zelooGradiente : null,
                          color: ativo ? null : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: ativo
                                ? Colors.transparent
                                : const Color(0xFFE4EDF4),
                          ),
                        ),
                        child: Text(
                          filtro,
                          style: TextStyle(
                            color: ativo
                                ? Colors.white
                                : const Color(0xFF64788B),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  },
                ),
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
                    (context, index) => _CardPedidoProfissional(
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

class _CardPedidoProfissional extends StatefulWidget {
  final String id;
  final Map<String, dynamic> dados;

  const _CardPedidoProfissional({
    super.key,
    required this.id,
    required this.dados,
  });

  @override
  State<_CardPedidoProfissional> createState() =>
      _CardPedidoProfissionalState();
}

class _CardPedidoProfissionalState extends State<_CardPedidoProfissional> {
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
          SnackBar(
            content: Text(erro.toString().replaceFirst('Exception: ', '')),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _processando = false);
    }
  }

  Future<String?> _pedirMotivo(String titulo) async {
    final controller = TextEditingController();
    final motivo = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        content: TextField(
          controller: controller,
          minLines: 2,
          maxLines: 3,
          decoration: campoZeloo(
            'Informe brevemente o motivo',
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
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
    controller.dispose();
    return motivo;
  }

  Future<void> _cancelar(String titulo) async {
    final motivo = await _pedirMotivo(titulo);
    if (motivo == null) return;
    await _executar(
      () => FirebaseService.cancelarPedido(widget.id, motivo),
      'Pedido cancelado.',
    );
  }

  Future<void> _digitarCodigo() async {
    final controller = TextEditingController();
    final codigo = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Código do cliente',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Peça ao cliente o código de quatro números.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF64788B)),
            ),
            const SizedBox(height: 18),
            TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 4,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(4),
              ],
              style: const TextStyle(
                color: zelooAzul,
                fontSize: 30,
                fontWeight: FontWeight.w900,
                letterSpacing: 12,
              ),
              decoration: InputDecoration(
                counterText: '',
                filled: true,
                fillColor: const Color(0xFFF2F9FC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFB3E8EF)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(color: Color(0xFFB3E8EF)),
                ),
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(context, controller.text),
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Validar e iniciar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: zelooAzul,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
          ),
        ],
      ),
    );
    controller.dispose();
    if (codigo == null) return;
    await _executar(
      () => FirebaseService.validarCodigoInicio(widget.id, codigo),
      'Código correto. Serviço iniciado!',
    );
  }

  Widget _acoes(String status, Timestamp? iniciadoEm, int tentativas) {
    switch (status) {
      case PedidoStatus.aguardando:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _processando
                    ? null
                    : () => _cancelar('Recusar pedido?'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFE53E3E),
                  side: const BorderSide(color: Color(0xFFE9A7A7)),
                  minimumSize: const Size(0, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Recusar'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: BotaoZeloo(
                texto: _processando ? 'Aceitando...' : 'Aceitar',
                icon: Icons.check_rounded,
                onPressed: _processando
                    ? null
                    : () => _executar(
                        () => FirebaseService.aceitarPedido(widget.id),
                        'Pedido aceito.',
                      ),
              ),
            ),
          ],
        );
      case PedidoStatus.aceito:
        return _BotaoEtapa(
          texto: 'Iniciar deslocamento',
          icon: Icons.directions_car_rounded,
          processando: _processando,
          onPressed: () => _executar(
            () => FirebaseService.iniciarDeslocamento(widget.id),
            'O cliente já pode acompanhar seu deslocamento.',
          ),
        );
      case PedidoStatus.aCaminho:
        return _BotaoEtapa(
          texto: 'Cheguei ao local',
          icon: Icons.location_on_rounded,
          processando: _processando,
          onPressed: () => _executar(
            () => FirebaseService.marcarChegada(widget.id),
            'Agora peça o código ao cliente.',
          ),
        );
      case PedidoStatus.aguardandoCodigo:
        final restantes = 5 - tentativas;
        return Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFF1ECFB), Color(0xFFEAF8FC)],
            ),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              const Icon(Icons.pin_rounded, color: Color(0xFF8E5BC7), size: 28),
              const SizedBox(height: 7),
              const Text(
                'Peça o código de início ao cliente',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: zelooTexto,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                restantes > 0
                    ? '$restantes tentativa${restantes == 1 ? '' : 's'} restante${restantes == 1 ? '' : 's'}'
                    : 'Peça ao cliente para gerar um novo código',
                style: const TextStyle(fontSize: 11, color: Color(0xFF64788B)),
              ),
              const SizedBox(height: 11),
              BotaoZeloo(
                texto: 'Digitar código',
                icon: Icons.dialpad_rounded,
                onPressed: _processando || restantes <= 0
                    ? null
                    : _digitarCodigo,
              ),
            ],
          ),
        );
      case PedidoStatus.emAndamento:
        return Column(
          children: [
            if (iniciadoEm != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFE9F8F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Tempo do serviço',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64788B)),
                    ),
                    const SizedBox(height: 6),
                    CronometroPedido(iniciadoEm: iniciadoEm),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            _BotaoEtapa(
              texto: 'Solicitar conclusão',
              icon: Icons.task_alt_rounded,
              processando: _processando,
              onPressed: () => _executar(
                () => FirebaseService.solicitarConclusao(widget.id),
                'Aguardando a confirmação do cliente.',
              ),
            ),
          ],
        );
      case PedidoStatus.aguardandoConclusao:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: const Color(0xFFEAF8FC),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            children: [
              Icon(Icons.hourglass_top_rounded, color: zelooAzul),
              SizedBox(width: 11),
              Expanded(
                child: Text(
                  'Aguardando o cliente confirmar a conclusão.',
                  style: TextStyle(
                    color: zelooTexto,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dados = widget.dados;
    final status = PedidoStatus.normalizar(
      _texto(dados['status'], PedidoStatus.aguardando),
    );
    final cor = PedidoStatus.cor(status);
    final valor = (dados['valor'] as num?)?.toDouble() ?? 0;
    final tentativas = (dados['tentativasCodigo'] as num?)?.toInt() ?? 0;
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
                        _texto(dados['clienteNome'], 'Cliente'),
                        style: const TextStyle(
                          color: zelooTexto,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        _texto(dados['servico'], 'Serviço'),
                        style: const TextStyle(
                          color: Color(0xFF64788B),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  constraints: const BoxConstraints(maxWidth: 118),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: cor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    PedidoStatus.nome(status),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: cor,
                    ),
                  ),
                ),
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
          if (status != PedidoStatus.concluido &&
              status != PedidoStatus.cancelado)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 3, 16, 14),
              child: _acoes(status, iniciadoEm, tentativas),
            ),
          if (status == PedidoStatus.cancelado && motivo != null)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 3, 16, 14),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3F3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Motivo: $motivo',
                style: const TextStyle(color: Color(0xFF8B4B4B)),
              ),
            ),
          if (PedidoStatus.podeCancelar(status) &&
              status != PedidoStatus.aguardando)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: TextButton.icon(
                onPressed: _processando
                    ? null
                    : () => _cancelar('Cancelar atendimento?'),
                icon: const Icon(Icons.close_rounded, size: 18),
                label: const Text('Cancelar atendimento'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFE53E3E),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _BotaoEtapa extends StatelessWidget {
  final String texto;
  final IconData icon;
  final bool processando;
  final VoidCallback onPressed;

  const _BotaoEtapa({
    required this.texto,
    required this.icon,
    required this.processando,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => BotaoZeloo(
    texto: processando ? 'Atualizando...' : texto,
    icon: icon,
    onPressed: processando ? null : onPressed,
  );
}
