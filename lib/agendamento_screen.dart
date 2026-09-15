import 'package:flutter/material.dart';

import 'firebase_service.dart';
import 'profissional_model.dart';

class AgendamentoScreen extends StatefulWidget {
  final ProfissionalModel profissional;

  const AgendamentoScreen({
    super.key,
    required this.profissional,
  });

  @override
  State<AgendamentoScreen> createState() => _AgendamentoScreenState();
}

class _AgendamentoScreenState extends State<AgendamentoScreen> {
  String? _servicoId;
  Map<String, dynamic>? _servico;
  DateTime? _data;
  TimeOfDay? _horario;
  bool _loading = false;

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
        const SnackBar(
          content: Text('Preencha serviço, data e horário.'),
        ),
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
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido enviado com sucesso!')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar pedido: $e')),
        );
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
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                valor,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
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
      appBar: AppBar(
        title: const Text('Solicitar serviço'),
        backgroundColor: const Color(0xFF0077B6),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder(
        stream: FirebaseService.meusServicosDoProfissional(profissional.id),
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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 28,
                            child: Icon(Icons.person, size: 30),
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
                            : '${profissional.avaliacao.toStringAsFixed(1)} '
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
                        style: TextStyle(
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Escolha o serviço',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              if (servicos.isEmpty)
                const Text(
                  'Este profissional ainda não cadastrou serviços ativos.',
                )
              else
                ...servicos.map((doc) {
                  final dados = doc.data() as Map<String, dynamic>;
                  final selecionado = _servicoId == doc.id;
                  final preco = dados['preco'] is num
                      ? (dados['preco'] as num).toDouble()
                      : 0.0;

                  return Card(
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
                    ),
                  );
                }),
              const SizedBox(height: 20),
              const Text(
                'Data',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _selecionarData,
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  _data == null ? 'Escolher data' : _formatarData(_data!),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Horário',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _selecionarHorario,
                icon: const Icon(Icons.schedule),
                label: Text(
                  _horario == null
                      ? 'Escolher horário'
                      : _horario!.format(context),
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _loading ? null : _enviarPedido,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0077B6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Enviar pedido',
                          style: TextStyle(fontWeight: FontWeight.w700),
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
