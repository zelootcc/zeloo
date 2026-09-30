import 'package:aplicativo_zeloo/campos_profissionais.dart';
import 'package:aplicativo_zeloo/dados_profissionais.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('quarta área fica bloqueada e volta ao desmarcar uma', (
    tester,
  ) async {
    var areas = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => SingleChildScrollView(
              child: SeletorAreas(
                selecionadas: areas,
                onChanged: (v) => setState(() => areas = v),
              ),
            ),
          ),
        ),
      ),
    );
    for (final area in ['Eletricista', 'Encanador', 'Limpeza']) {
      await tester.tap(find.widgetWithText(FilterChip, area));
      await tester.pump();
    }
    expect(
      tester
          .widget<FilterChip>(find.widgetWithText(FilterChip, 'Diarista'))
          .onSelected,
      isNull,
    );
    await tester.tap(find.widgetWithText(FilterChip, 'Limpeza'));
    await tester.pump();
    expect(
      tester
          .widget<FilterChip>(find.widgetWithText(FilterChip, 'Diarista'))
          .onSelected,
      isNotNull,
    );
  });

  testWidgets('padrão preenche dias e preserva exceções individuais', (
    tester,
  ) async {
    var horarios = <String, HorarioAtendimento>{};
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => SingleChildScrollView(
              child: SeletorHorarios(
                horarios: horarios,
                onChanged: (v) => setState(() => horarios = v),
              ),
            ),
          ),
        ),
      ),
    );
    Future<void> tocar(String chave) async {
      final finder = find.byKey(ValueKey(chave));
      await tester.ensureVisible(finder);
      await tester.pumpAndSettle();
      await tester.tap(finder);
      await tester.pumpAndSettle();
    }

    Future<void> hora(String chave, String valor) async {
      await tocar(chave);
      await tester.tap(find.byIcon(Icons.keyboard_outlined));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, valor);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    }

    await tocar('dia-segunda');
    await tocar('dia-sabado');
    expect(horarios['segunda']!.inicio, '08:00');
    expect(horarios['sabado']!.fim, '18:00');
    await hora('fim-sabado', '13');
    await hora('inicio-padrao', '09');
    expect(horarios['segunda']!.inicio, '09:00');
    expect(horarios['sabado']!.inicio, '08:00');
    expect(horarios['sabado']!.fim, '13:00');
    await tocar('dia-domingo');
    expect(horarios['domingo']!.inicio, '09:00');
    await tocar('dia-sabado');
    expect(horarios.containsKey('sabado'), isFalse);
    await tocar('dia-sabado');
    expect(horarios['sabado']!.fim, '13:00');
    final aplicar = find.text('Aplicar padrão a todos os dias selecionados');
    await tester.ensureVisible(aplicar);
    await tester.pumpAndSettle();
    await tester.tap(aplicar);
    await tester.pumpAndSettle();
    expect(horarios['sabado']!.inicio, '09:00');
    expect(horarios['sabado']!.fim, '18:00');
  });
}
