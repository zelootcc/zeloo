import 'package:flutter/material.dart';
import 'dados_profissionais.dart';
import 'zeloo_ui.dart';

class SeletorAreas extends StatelessWidget {
  final List<String> selecionadas;
  final ValueChanged<List<String>> onChanged;
  final bool enabled;
  const SeletorAreas({super.key, required this.selecionadas, required this.onChanged, this.enabled = true});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: painelZeloo(),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      CabecalhoCampo(icon: Icons.auto_awesome_rounded, titulo: 'Seus talentos',
        descricao: 'Escolha até 3 áreas para mostrar o que você faz de melhor.', indicador: '${selecionadas.length}/3'),
      const SizedBox(height: 18),
      Wrap(spacing: 7, runSpacing: 5, children: areasAtuacao.map((area) {
        final selecionada = selecionadas.contains(area);
        return FilterChip(
          label: Text(area),
          labelStyle: TextStyle(fontSize: 12, fontWeight: selecionada ? FontWeight.w700 : FontWeight.w500,
            color: selecionada ? zelooAzul : const Color(0xFF52677B)),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          side: BorderSide(color: selecionada ? const Color(0xFF73D7E2) : const Color(0xFFE1EBF3)),
          backgroundColor: const Color(0xFFF6F9FC),
          disabledColor: const Color(0xFFF4F6F8),
          checkmarkColor: zelooAzul,
          selected: selecionada,
          selectedColor: const Color(0xFFCAF0F8),
          onSelected: !enabled || (!selecionada && selecionadas.length >= 3) ? null : (valor) {
            onChanged(valor ? [...selecionadas, area] : selecionadas.where((a) => a != area).toList());
          },
        );
      }).toList()),
      if (selecionadas.length == 3) const Padding(
        padding: EdgeInsets.only(top: 12),
        child: Text('Para trocar, desmarque uma área selecionada.', style: TextStyle(color: zelooAzul, fontSize: 12)),
      ),
    ],
    ),
  );
}

class SeletorDisponibilidade extends StatefulWidget {
  final Map<String, HorarioAtendimento> horarios;
  final ValueChanged<Map<String, HorarioAtendimento>> onChanged;
  final bool enabled;
  const SeletorDisponibilidade({super.key, required this.horarios, required this.onChanged, this.enabled = true});

  @override
  State<SeletorDisponibilidade> createState() => _SeletorDisponibilidadeState();
}

class _SeletorDisponibilidadeState extends State<SeletorDisponibilidade> {
  HorarioAtendimento _padrao = const HorarioAtendimento();
  final Set<String> _personalizados = {};

  @override
  void initState() {
    super.initState();
    if (widget.horarios.isNotEmpty) {
      _padrao = widget.horarios.values.first;
      for (final dia in widget.horarios.entries) {
        if (dia.value.inicio != _padrao.inicio || dia.value.fim != _padrao.fim) {
          _personalizados.add(dia.key);
        }
      }
    }
  }

  Future<void> _escolher(bool inicio, {String? dia}) async {
    final atual = dia == null ? _padrao : widget.horarios[dia]!;
    final minutos = inicio ? atual.inicio : atual.fim;
    final escolhido = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: minutos ~/ 60, minute: minutos % 60),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
        child: Theme(data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.fromSeed(seedColor: zelooAzul, primary: zelooAzul, secondary: zelooTurquesa),
          timePickerTheme: TimePickerThemeData(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          ),
        ), child: child!),
      ),
    );
    if (!mounted || escolhido == null || !widget.enabled) return;
    final valor = escolhido.hour * 60 + escolhido.minute;
    final novo = HorarioAtendimento(inicio: inicio ? valor : atual.inicio, fim: inicio ? atual.fim : valor);
    if (!novo.valido) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('O término deve ser depois do início, no mesmo dia.')));
      return;
    }
    final horarios = Map<String, HorarioAtendimento>.from(widget.horarios);
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

  Widget _horas(HorarioAtendimento horario, {String? dia}) => Row(
    children: [
      for (final inicio in [true, false]) ...[
        if (!inicio) const Padding(padding: EdgeInsets.symmetric(horizontal: 6),
          child: Icon(Icons.arrow_forward_rounded, size: 15, color: zelooTurquesa)),
        Expanded(child: TextButton(
          style: TextButton.styleFrom(
            foregroundColor: zelooAzul, backgroundColor: const Color(0xFFEAF8FC),
            minimumSize: const Size(0, 48), padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
            textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          onPressed: widget.enabled ? () => _escolher(inicio, dia: dia) : null,
          child: Text('${inicio ? 'Início' : 'Término'}: ${HorarioAtendimento.formatar(inicio ? horario.inicio : horario.fim)}', textAlign: TextAlign.center),
        )),
      ],
    ],
  );

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        padding: const EdgeInsets.all(18), decoration: painelZeloo(destaque: true),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const CabecalhoCampo(icon: Icons.schedule_rounded, titulo: 'Sua semana, seu ritmo',
            descricao: 'Defina seu horário padrão e escolha os dias em que atende.'),
          const SizedBox(height: 18),
          const Text('HORÁRIO PADRÃO', style: TextStyle(color: zelooAzul, fontSize: 10, letterSpacing: 1.4, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          _horas(_padrao),
          const SizedBox(height: 12),
          const Text('Preenche os dias selecionados sem alterar horários personalizados.', style: TextStyle(color: Color(0xFF64788B), fontSize: 12, height: 1.5)),
        ]),
      ),
      const SizedBox(height: 20),
      Row(children: [
        const Expanded(child: Text('Dias de atendimento', style: TextStyle(color: zelooTexto, fontSize: 14, fontWeight: FontWeight.w800))),
        Text('${widget.horarios.length} de 7', style: const TextStyle(color: zelooAzul, fontSize: 12, fontWeight: FontWeight.w700)),
      ]),
      const SizedBox(height: 12),
      for (final dia in diasSemana.entries) ...[
        AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.only(bottom: 10),
          decoration: painelZeloo(destaque: widget.horarios.containsKey(dia.key)),
          child: Material(color: Colors.transparent, borderRadius: BorderRadius.circular(22), child: Column(children: [
        CheckboxListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          controlAffinity: ListTileControlAffinity.trailing,
          activeColor: zelooTurquesa,
          checkColor: Colors.white,
          checkboxShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          secondary: Container(width: 36, height: 36,
            decoration: BoxDecoration(color: widget.horarios.containsKey(dia.key) ? zelooSuave : const Color(0xFFF4F7FA), borderRadius: BorderRadius.circular(11)),
            child: Icon(dia.key == 'sabado' || dia.key == 'domingo' ? Icons.wb_sunny_outlined : Icons.work_outline_rounded,
              color: widget.horarios.containsKey(dia.key) ? zelooAzul : const Color(0xFF8B9BAB), size: 18)),
          title: Text(dia.value, style: const TextStyle(fontSize: 14, color: zelooTexto, fontWeight: FontWeight.w700)),
          subtitle: Text(widget.horarios.containsKey(dia.key)
              ? (_personalizados.contains(dia.key) ? 'Horário personalizado' : 'Usando horário padrão') : 'Sem atendimento',
            style: TextStyle(fontSize: 11, color: widget.horarios.containsKey(dia.key) ? zelooAzul : const Color(0xFF8B9BAB))),
          value: widget.horarios.containsKey(dia.key),
          onChanged: !widget.enabled ? null : (selecionado) {
            final horarios = Map<String, HorarioAtendimento>.from(widget.horarios);
            if (selecionado == true) {
              horarios[dia.key] = _padrao;
            } else {
              horarios.remove(dia.key);
              _personalizados.remove(dia.key);
            }
            widget.onChanged(horarios);
          },
        ),
        if (widget.horarios.containsKey(dia.key)) Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          child: _horas(widget.horarios[dia.key]!, dia: dia.key)),
          ])),
        ),
      ],
      if (widget.horarios.isEmpty) const Padding(padding: EdgeInsets.symmetric(vertical: 4),
        child: Text('Por enquanto, seu atendimento fica sob consulta.', style: TextStyle(fontSize: 12, color: Color(0xFF64788B)))),
    ],
  );
}
