import 'package:aplicativo_zeloo/dados_profissionais.dart';
import 'package:aplicativo_zeloo/profissional_model.dart';
import 'package:aplicativo_zeloo/telefone_formatter.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('telefone limita colagem, remove letras e formata fixo e celular', () {
    final formatter = TelefoneFormatter();
    for (final entrada in ['119876543210000', '(11) 98765-4321 abc']) {
      final resultado = formatter.formatEditUpdate(
        TextEditingValue.empty,
        TextEditingValue(
          text: entrada,
          selection: TextSelection.collapsed(offset: entrada.length),
        ),
      );
      expect(resultado.text, '(11) 98765-4321');
      expect(resultado.selection.baseOffset, resultado.text.length);
    }
    expect(
      formatter
          .formatEditUpdate(
            TextEditingValue.empty,
            const TextEditingValue(text: '1134567890'),
          )
          .text,
      '(11) 3456-7890',
    );
    expect(telefoneValido('123'), isFalse);
    expect(telefoneValido('(11) 3456-7890'), isTrue);
    expect(telefoneValido('119876543210'), isFalse);
  });

  test('telefone permite apagar separador e substituir seleção', () {
    final formatter = TelefoneFormatter();
    final resultado = formatter.formatEditUpdate(
      const TextEditingValue(
        text: '(11) 98765-4321',
        selection: TextSelection.collapsed(offset: 10),
      ),
      const TextEditingValue(
        text: '(11) 987654321',
        selection: TextSelection.collapsed(offset: 9),
      ),
    );
    expect(resultado.text.replaceAll(RegExp(r'\D'), ''), '1198764321');
    final substituido = formatter.formatEditUpdate(
      resultado,
      const TextEditingValue(
        text: '21999998888',
        selection: TextSelection.collapsed(offset: 11),
      ),
    );
    expect(substituido.text, '(21) 99999-8888');
  });

  test('aceita somente uma a três áreas predefinidas e distintas', () {
    expect(areasValidas([]), isFalse);
    expect(areasValidas(['Inventada']), isFalse);
    expect(areasValidas(['Pintor', 'Pintor']), isFalse);
    expect(areasValidas(areasAtuacao.take(4).toList()), isFalse);
    expect(areasValidas(['Pedreiro', 'Pintor', 'Eletricista']), isTrue);
  });

  test('salvar e reabrir preserva exceção do sábado e dias não atendidos', () {
    final dados = dadosAtuacao(
      ['Pintor', 'Pedreiro'],
      {
        'segunda': const HorarioAtendimento('08:00', '18:00'),
        'sabado': const HorarioAtendimento('09:30', '13:00'),
      },
    );
    final reaberto = lerHorarios(dados);
    expect(reaberto.keys, ['segunda', 'sabado']);
    expect(reaberto['sabado']!.inicio, '09:30');
    expect(reaberto['sabado']!.fim, '13:00');
    expect(lerAreas(dados), ['Pintor', 'Pedreiro']);
    expect(dados['disponibilidade'], contains('Sábado: 09:30–13:00'));
    final profissional = ProfissionalModel.fromFirestore('id', dados);
    expect(profissional.areas, contains('Pedreiro'));
    expect(profissional.especialidade, 'Pintor, Pedreiro');
  });

  test('não salva agenda vazia, horário invertido, igual ou malformado', () {
    for (final horarios in <Map<String, HorarioAtendimento>>[
      {},
      {'segunda': const HorarioAtendimento('18:00', '08:00')},
      {'segunda': const HorarioAtendimento('08:00', '08:00')},
      {'segunda': const HorarioAtendimento('25:00', '26:00')},
      {'inexistente': const HorarioAtendimento('08:00', '18:00')},
    ]) {
      expect(() => dadosAtuacao(['Pintor'], horarios), throwsArgumentError);
    }
  });

  test('perfis antigos continuam legíveis sem inventar horários', () {
    expect(lerAreas({'especialidade': 'Diarista'}), ['Diarista']);
    expect(
      lerHorarios({'disponibilidade': 'Segunda a Sexta, 8h–18h'}).length,
      5,
    );
    expect(
      lerHorarios({'disponibilidade': 'Segunda a Sábado, 8h–18h'}).length,
      6,
    );
    expect(lerHorarios({'disponibilidade': 'Finais de semana'}), isEmpty);
    expect(lerHorarios({'disponibilidade': 'Sob consulta'}), isEmpty);
  });
}
