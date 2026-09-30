import 'package:flutter/material.dart';

import 'dados_profissionais.dart';

class SeletorAreas extends StatelessWidget {
  final List<String> selecionadas;
  final ValueChanged<List<String>> onChanged;
  const SeletorAreas({
    super.key,
    required this.selecionadas,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Áreas de atuação (${selecionadas.length}/3)',
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      const Text('Escolha de 1 a 3 opções.'),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        runSpacing: 4,
        children: [
          for (final area in areasAtuacao)
            FilterChip(
              label: Text(area),
              selected: selecionadas.contains(area),
              onSelected:
                  !selecionadas.contains(area) && selecionadas.length >= 3
                  ? null
                  : (marcado) {
                      final novas = List<String>.of(selecionadas);
                      if (marcado) {
                        novas.add(area);
                      } else {
                        novas.remove(area);
                      }
                      onChanged(novas);
                    },
            ),
        ],
      ),
    ],
  );
}

class SeletorHorarios extends StatefulWidget {
  final Map<String, HorarioAtendimento> horarios;
  final ValueChanged<Map<String, HorarioAtendimento>> onChanged;
  const SeletorHorarios({
    super.key,
    required this.horarios,
    required this.onChanged,
  });

  @override
  State<SeletorHorarios> createState() => _SeletorHorariosState();
}

class _SeletorHorariosState extends State<SeletorHorarios> {
  late HorarioAtendimento _padrao;
  final _personalizados = <String>{};
  final _desmarcados = <String, HorarioAtendimento>{};

  @override
  void initState() {
    super.initState();
    _padrao = widget.horarios.isEmpty
        ? const HorarioAtendimento('08:00', '18:00')
        : widget.horarios.values.first;
    for (final entry in widget.horarios.entries) {
      if (entry.value.inicio != _padrao.inicio ||
          entry.value.fim != _padrao.fim) {
        _personalizados.add(entry.key);
      }
    }
  }

  Future<void> _escolher({String? dia, required bool inicio}) async {
    final atual = dia == null ? _padrao : widget.horarios[dia]!;
    final partes = (inicio ? atual.inicio : atual.fim).split(':');
    final hora = int.tryParse(partes.first) ?? 8;
    final minuto = partes.length == 2 ? int.tryParse(partes.last) ?? 0 : 0;
    final escolhido = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: hora.clamp(0, 23),
        minute: minuto.clamp(0, 59),
      ),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: child!,
      ),
    );
    if (escolhido == null || !mounted) return;
    final texto =
        '${escolhido.hour.toString().padLeft(2, '0')}:${escolhido.minute.toString().padLeft(2, '0')}';
    final novo = HorarioAtendimento(
      inicio ? texto : atual.inicio,
      inicio ? atual.fim : texto,
    );
    final horarios = Map<String, HorarioAtendimento>.of(widget.horarios);
    setState(() {
      if (dia == null) {
        _padrao = novo;
        for (final chave in horarios.keys.toList()) {
          if (!_personalizados.contains(chave)) horarios[chave] = novo;
        }
      } else {
        horarios[dia] = novo;
        _personalizados.add(dia);
      }
    });
    widget.onChanged(horarios);
  }

  Widget _botoes(HorarioAtendimento horario, {String? dia}) => Wrap(
    spacing: 8,
    children: [
      OutlinedButton(
        key: ValueKey('inicio-${dia ?? 'padrao'}'),
        onPressed: () => _escolher(dia: dia, inicio: true),
        child: Text('Início: ${horario.inicio}'),
      ),
      OutlinedButton(
        key: ValueKey('fim-${dia ?? 'padrao'}'),
        onPressed: () => _escolher(dia: dia, inicio: false),
        child: Text('Término: ${horario.fim}'),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Dias e horários de atendimento',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      const SizedBox(height: 8),
      const Text(
        'Defina o horário padrão e marque os dias. Você pode ajustar cada dia abaixo.',
      ),
      _botoes(_padrao),
      if (!_padrao.valido)
        const Text(
          'O término deve ser depois do início.',
          style: TextStyle(color: Colors.red),
        ),
      TextButton(
        onPressed: widget.horarios.isEmpty || !_padrao.valido
            ? null
            : () {
                setState(() {
                  _personalizados.clear();
                  _desmarcados.clear();
                });
                widget.onChanged({
                  for (final dia in widget.horarios.keys) dia: _padrao,
                });
              },
        child: const Text('Aplicar padrão a todos os dias selecionados'),
      ),
      const Text(
        'Alterar o padrão mantém os dias que você ajustou individualmente.',
      ),
      const SizedBox(height: 8),
      for (final dia in diasSemana.entries)
        Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CheckboxListTile(
                  key: ValueKey('dia-${dia.key}'),
                  contentPadding: EdgeInsets.zero,
                  title: Text(dia.value),
                  subtitle: widget.horarios.containsKey(dia.key)
                      ? null
                      : const Text('Não atende'),
                  value: widget.horarios.containsKey(dia.key),
                  onChanged: (valor) {
                    final horarios = Map<String, HorarioAtendimento>.of(
                      widget.horarios,
                    );
                    if (valor == true) {
                      horarios[dia.key] = _personalizados.contains(dia.key)
                          ? _desmarcados[dia.key] ?? _padrao
                          : _padrao;
                    } else {
                      _desmarcados[dia.key] = horarios.remove(dia.key)!;
                    }
                    widget.onChanged(horarios);
                  },
                ),
                if (widget.horarios.containsKey(dia.key)) ...[
                  _botoes(widget.horarios[dia.key]!, dia: dia.key),
                  if (!widget.horarios[dia.key]!.valido)
                    const Text(
                      'O término deve ser depois do início.',
                      style: TextStyle(color: Colors.red),
                    ),
                ],
              ],
            ),
          ),
        ),
    ],
  );
}
