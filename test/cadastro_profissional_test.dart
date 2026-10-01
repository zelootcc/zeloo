import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aplicativo_zeloo/campos_profissionais.dart';
import 'package:aplicativo_zeloo/dados_profissionais.dart';
import 'package:aplicativo_zeloo/profissional_model.dart';
import 'package:aplicativo_zeloo/telefone_formatter.dart';

void main() {
  test('telefone limita colagem a 11 dígitos e formata fixo e celular', () {
    const formatter = TelefoneFormatter();
    TextEditingValue entrada(String valor) => TextEditingValue(text: valor, selection: TextSelection.collapsed(offset: valor.length));
    expect(formatter.formatEditUpdate(TextEditingValue.empty, entrada('129876543219999')).text, '(12) 98765-4321');
    expect(formatter.formatEditUpdate(TextEditingValue.empty, entrada('(12) 3456-7890')).text, '(12) 3456-7890');
    expect(TelefoneFormatter.valido('123'), false);
    expect(TelefoneFormatter.valido('(12) 98765-4321'), true);
    expect(formatter.formatEditUpdate(entrada('12'), entrada('')).text, '');
    final edicao = formatter.formatEditUpdate(entrada('(12) 98765-4321'),
        const TextEditingValue(text: '(13) 98765-4321', selection: TextSelection.collapsed(offset: 3)));
    expect(edicao.selection.baseOffset, 3);
  });

  test('profissionais antigos e novos mantêm áreas e horários legíveis', () {
    expect(lerAreas({'area': 'Pintor'}), ['Pintor']);
    final pro = ProfissionalModel.fromFirestore('id', {'areasAtuacao': ['Pintor', 'Pedreiro', 'Jardineiro']});
    expect(pro.areas, contains('Pedreiro'));
    expect(pro.especialidade, contains('Jardineiro'));
    expect(lerHorarios({'disponibilidade': 'Segunda a Sexta, 8h–18h'}).length, 5);
    final horario = HorarioAtendimento.fromMap({'inicio': '09:30', 'fim': '17:15'})!;
    expect(horario.toMap(), {'inicio': '09:30', 'fim': '17:15'});
    expect(HorarioAtendimento.fromMap({'inicio': '18:00', 'fim': '08:00'}), null);
    expect(HorarioAtendimento.fromMap({'inicio': '24:00', 'fim': '25:00'}), null);
    expect(lerHorarios({'horariosAtendimento': {}, 'disponibilidade': 'Segunda a Sexta, 8h–18h'}), isEmpty);
  });

  testWidgets('até três áreas; desmarcar permite escolher outra', (tester) async {
    var areas = <String>[];
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(
      child: StatefulBuilder(builder: (context, setState) => SeletorAreas(
        selecionadas: areas, onChanged: (valor) => setState(() => areas = valor),
      )),
    ))));
    for (final nome in ['Eletricista', 'Encanador', 'Limpeza']) {
      await tester.tap(find.widgetWithText(FilterChip, nome));
      await tester.pump();
    }
    expect(areas.length, 3);
    expect(tester.widget<FilterChip>(find.widgetWithText(FilterChip, 'Pintor')).onSelected, isNull);
    await tester.tap(find.widgetWithText(FilterChip, 'Limpeza'));
    await tester.pump();
    await tester.tap(find.widgetWithText(FilterChip, 'Pintor'));
    await tester.pump();
    expect(areas, ['Eletricista', 'Encanador', 'Pintor']);
  });

  testWidgets('horário padrão preenche dias e preserva ajuste individual', (tester) async {
    var horarios = <String, HorarioAtendimento>{};
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: SingleChildScrollView(
      child: StatefulBuilder(builder: (context, setState) => SeletorDisponibilidade(
        horarios: horarios, onChanged: (valor) => setState(() => horarios = valor),
      )),
    ))));
    Future<void> selecionar(String dia) async {
      final checkbox = find.widgetWithText(CheckboxListTile, dia);
      await tester.ensureVisible(checkbox);
      await tester.tap(checkbox);
      await tester.pumpAndSettle();
    }
    Future<void> escolher(Finder botao, TimeOfDay valor) async {
      await tester.ensureVisible(botao);
      await tester.tap(botao);
      await tester.pumpAndSettle();
      Navigator.of(tester.element(find.byType(TimePickerDialog))).pop(valor);
      await tester.pumpAndSettle();
    }
    await selecionar('Segunda-feira');
    await selecionar('Sábado');
    expect(horarios['segunda']!.inicio, horarios['sabado']!.inicio);
    await escolher(find.widgetWithText(TextButton, 'Término: 18:00').last, const TimeOfDay(hour: 12, minute: 0));
    expect(horarios['segunda']!.fim, 1080);
    expect(horarios['sabado']!.fim, 720);
    await escolher(find.widgetWithText(TextButton, 'Início: 08:00').first, const TimeOfDay(hour: 9, minute: 0));
    expect(horarios['segunda']!.inicio, 540);
    expect(horarios['sabado']!.inicio, 480);
    await selecionar('Terça-feira');
    expect(horarios['terca']!.inicio, 540);
    final recarregado = lerHorarios({'horariosAtendimento': horarios.map((dia, h) => MapEntry(dia, h.toMap()))});
    expect(recarregado['sabado']!.fim, 720);
    await escolher(find.widgetWithText(TextButton, 'Término: 18:00').at(1), const TimeOfDay(hour: 7, minute: 0));
    expect(horarios['segunda']!.fim, 1080);
    expect(find.text('O término deve ser depois do início, no mesmo dia.'), findsOneWidget);
  });
}
