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

    if (data != null) setState(() => _data = data);
  }

  Future<void> _selecionarHorario() async {
    final horario = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (horario != null) setState(() => _horario = horario);
  }

  String _formatarData(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  Future<void> _enviarPedido() async {
    if (_servicoId == null || _servico == null || _data == null || _horario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha serviço, data e horário.')),
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
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text('Solicitar serviço'),
        backgroundColor: const Color(0xFF0077B6),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder(
        stream: FirebaseService.meusServicosDoProfissional(widget.profissional.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro ao carregar serviços.\n${snapshot.error}'));
          }

          final servicos = snapshot.data?.docs ?? [];

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                widget.profissional.nome,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.profissional.especialidade,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
              const Text(
                'Escolha o serviço',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              if (servicos.isEmpty)
                const Text('Este profissional ainda não cadastrou serviços.')
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
                        '${dados['descricao'] ?? 'Sem descrição'}\nR\$ ${preco.toStringAsFixed(2)}',
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
                  _horario == null ? 'Escolher horário' : _horario!.format(context),
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
