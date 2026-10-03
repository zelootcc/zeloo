import 'package:flutter/material.dart';

import 'firebase_service.dart';
import 'formatadores.dart';
import 'profissional_model.dart';
import 'zeloo_ui.dart';
import 'local_pedido_campo.dart';

class AgendamentoScreen extends StatefulWidget {
  final ProfissionalModel profissional;

  const AgendamentoScreen({super.key, required this.profissional});

  @override
  State<AgendamentoScreen> createState() => _AgendamentoScreenState();
}

class _AgendamentoScreenState extends State<AgendamentoScreen> {
  String? _servicoId;
  Map<String, dynamic>? _servico;
  DateTime? _data;
  TimeOfDay? _horario;
  bool _loading = false;
  Map<String, dynamic>? _local;
  late final _servicos = FirebaseService.meusServicosDoProfissional(widget.profissional.id);

  Future<void> _selecionarData() async {
    final data = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 180)),
      initialDate: DateTime.now(),
    );

    if (data != null) {
      setState(() => _data = data);
    }
  }

  Future<void> _selecionarHorario() async {
    final horario = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (horario != null) {
      setState(() => _horario = horario);
    }
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  Future<void> _enviarPedido() async {
    if (_servicoId == null ||
        _servico == null ||
        _data == null ||
        _horario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha serviço, data e horário.')),
      );
      return;
    }

    if ((_local?['logradouro']?.toString().trim().length ?? 0) < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o endereço completo do atendimento.')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final valor = _servico!['preco'] is num
          ? (_servico!['preco'] as num).toDouble()
          : double.tryParse(
                  _servico!['preco']?.toString().replaceAll(',', '.') ?? '',
                ) ??
                0;

      await FirebaseService.criarPedido(
        profissionalId: widget.profissional.id,
        profissionalNome: widget.profissional.nome,
        servicoId: _servicoId!,
        servico: _servico!['titulo']?.toString() ?? 'Serviço',
        valor: valor,
        data: _formatarData(_data!),
        horario: _horario!.format(context),
        descricao: _servico!['descricao']?.toString() ?? '',
        localAtendimento: _local!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido enviado com sucesso!')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao enviar pedido: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Widget _info(String titulo, String valor, IconData icone) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icone, color: const Color(0xFF0077B6), size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(valor, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final profissional = widget.profissional;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: const AppBarZeloo(
        titulo: 'Solicitar serviço',
        subtitulo: 'Escolha o serviço, a data e o horário',
      ),
      body: StreamBuilder(
        stream: _servicos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar serviços.\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final servicos = snapshot.data?.docs ?? [];

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                decoration: painelZeloo(),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              gradient: zelooGradiente,
                              borderRadius: BorderRadius.circular(19),
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profissional.nome,
                                  style: const TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w800,
                                    color: zelooTexto,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  profissional.especialidade,
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      _info(
                        'Região',
                        profissional.cidade,
                        Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 14),
                      _info(
                        'Avaliação',
                        profissional.totalAvaliacoes == 0
                            ? 'Ainda sem avaliações'
                            : '${formatarAvaliacao(profissional.avaliacao)} '
                                  '(${profissional.totalAvaliacoes} avaliações)',
                        Icons.star_outline,
                      ),
                      const SizedBox(height: 14),
                      _info(
                        'Valor por hora',
                        'R\$ ${profissional.precoHora.toStringAsFixed(2)}',
                        Icons.attach_money,
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Sobre o profissional',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        profissional.descricao,
                        style: TextStyle(color: Colors.grey[700], height: 1.4),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const CabecalhoCampo(
                icon: Icons.home_repair_service_rounded,
                titulo: 'Escolha o serviço',
                descricao: 'Selecione uma das opções oferecidas',
              ),
              const SizedBox(height: 10),
              if (servicos.isEmpty)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: painelZeloo(),
                  child: const Text(
                    'Este profissional ainda não cadastrou serviços ativos.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF64788B)),
                  ),
                )
              else
                ...servicos.map((doc) {
                  final dados = doc.data() as Map<String, dynamic>;
                  final selecionado = _servicoId == doc.id;
                  final preco = dados['preco'] is num
                      ? (dados['preco'] as num).toDouble()
                      : 0.0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: painelZeloo(destaque: selecionado),
                    child: RadioListTile<String>(
                      value: doc.id,
                      groupValue: _servicoId,
                      onChanged: (value) {
                        setState(() {
                          _servicoId = value;
                          _servico = dados;
                        });
                      },
                      title: Text(
                        dados['titulo']?.toString() ?? 'Serviço',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        '${dados['descricao'] ?? 'Sem descrição'}\n'
                        'R\$ ${preco.toStringAsFixed(2)}',
                      ),
                      selected: selecionado,
                      fillColor: const WidgetStatePropertyAll(zelooTurquesa),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: painelZeloo(),
                child: Column(
                  children: [
                    const CabecalhoCampo(
                      icon: Icons.event_available_rounded,
                      titulo: 'Quando será?',
                      descricao: 'Defina a data e o horário do atendimento',
                    ),
                    const SizedBox(height: 18),
                    _botaoEscolha(
                      icone: Icons.calendar_today_rounded,
                      rotulo: 'Data',
                      valor: _data == null
                          ? 'Escolher data'
                          : _formatarData(_data!),
                      onTap: _selecionarData,
                    ),
                    const SizedBox(height: 12),
                    _botaoEscolha(
                      icone: Icons.schedule_rounded,
                      rotulo: 'Horário',
                      valor: _horario == null
                          ? 'Escolher horário'
                          : _horario!.format(context),
                      onTap: _selecionarHorario,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              LocalPedidoCampo(
                habilitado: !_loading,
                onChanged: (local) => _local = local,
              ),
              const SizedBox(height: 28),
              BotaoZeloo(
                texto: _loading ? 'Enviando...' : 'Enviar pedido',
                icon: Icons.send_rounded,
                onPressed: _loading ? null : _enviarPedido,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _botaoEscolha({
    required IconData icone,
    required String rotulo,
    required String valor,
    required VoidCallback onTap,
  }) => Material(
    color: const Color(0xFFF4F8FC),
    borderRadius: BorderRadius.circular(16),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            Icon(icone, color: zelooAzul, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rotulo,
                    style: const TextStyle(
                      color: Color(0xFF718496),
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    valor,
                    style: const TextStyle(
                      color: zelooTexto,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFF9AAAB8)),
          ],
        ),
      ),
    ),
  );
}
