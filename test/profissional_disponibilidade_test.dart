import 'package:aplicativo_zeloo/profissional_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('perfil antigo continua disponível sem pedido em atendimento', () {
    expect(ProfissionalModel.estaDisponivel({'disponivel': true}), isTrue);
    expect(ProfissionalModel.estaDisponivel({}), isTrue);
  });

  test('pedido aceito torna o profissional ocupado apesar da opção manual', () {
    final dados = {'disponivel': true, 'pedidoEmAtendimento': 'pedido-1'};
    expect(ProfissionalModel.estaOcupado(dados), isTrue);
    expect(ProfissionalModel.estaDisponivel(dados), isFalse);
    expect(
      ProfissionalModel.fromFirestore('profissional-1', dados).disponivel,
      isFalse,
    );
  });

  test('liberar o atendimento restaura a disponibilidade manual', () {
    expect(
      ProfissionalModel.estaDisponivel({
        'disponivel': true,
        'pedidoEmAtendimento': '',
      }),
      isTrue,
    );
    expect(
      ProfissionalModel.estaDisponivel({
        'disponivel': false,
        'pedidoEmAtendimento': '',
      }),
      isFalse,
    );
  });

  test('perfis antigos indisponíveis continuam bloqueados', () {
    expect(
      ProfissionalModel.estaDisponivel({'disponibilidade': 'Ocupado'}),
      isFalse,
    );
    expect(
      ProfissionalModel.estaDisponivel({'disponibilidade': 'Indisponível'}),
      isFalse,
    );
  });
}
