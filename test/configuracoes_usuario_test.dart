import 'package:aplicativo_zeloo/configuracoes_usuario.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final enderecos = [
    {'id': 'casa', 'apelido': 'Casa', 'logradouro': 'Rua A', 'principal': true},
    {
      'id': 'trabalho',
      'apelido': 'Trabalho',
      'logradouro': 'Rua B',
      'principal': false,
    },
  ];

  test('primeiro endereço é principal e textos são normalizados', () {
    final resultado = atualizarListaPrivada(
      [],
      campo: 'enderecos',
      novoId: 'novo',
      adicionar: {'apelido': ' Casa ', 'logradouro': ' Rua A '},
    );
    expect(resultado.single, {
      'id': 'novo',
      'apelido': 'Casa',
      'logradouro': 'Rua A',
      'principal': true,
    });
  });

  test('remover principal promove outro sem alterar snapshot original', () {
    final resultado = atualizarListaPrivada(
      enderecos,
      campo: 'enderecos',
      novoId: '',
      remover: 'casa',
    );
    expect(resultado.single['id'], 'trabalho');
    expect(resultado.single['principal'], true);
    expect(enderecos.last['principal'], false);
    expect(enderecos.length, 2);
  });

  test('seleção mantém exatamente um principal e preserva demais campos', () {
    final resultado = atualizarListaPrivada(
      enderecos,
      campo: 'enderecos',
      novoId: '',
      principal: 'trabalho',
    );
    expect(
      resultado.where((item) => item['principal'] == true).single['id'],
      'trabalho',
    );
    expect(resultado.first['logradouro'], 'Rua A');
  });

  test(
    'operações sobre item removido em outro dispositivo preservam lista atual',
    () {
      final resultado = atualizarListaPrivada(
        enderecos,
        campo: 'enderecos',
        novoId: '',
        principal: 'inexistente',
        remover: 'inexistente',
      );
      expect(resultado, enderecos);
    },
  );

  test(
    'cartão persiste somente identificação, nunca número completo ou CVV',
    () {
      final resultado = atualizarListaPrivada(
        [],
        campo: 'cartoes',
        novoId: 'novo',
        adicionar: {
          'bandeira': 'Visa',
          'ultimos4': '1234',
          'numero': '4111111111111234',
          'cvv': '123',
        },
      );
      expect(
        resultado.single.keys,
        unorderedEquals(['bandeira', 'ultimos4', 'id', 'principal']),
      );
      expect(
        () => atualizarListaPrivada(
          [],
          campo: 'cartoes',
          novoId: 'novo',
          adicionar: {'bandeira': 'Visa', 'ultimos4': '4111111111111234'},
        ),
        throwsArgumentError,
      );
    },
  );

  test('dados incompletos e listas desconhecidas não são aceitos', () {
    expect(
      () => atualizarListaPrivada(
        [],
        campo: 'enderecos',
        novoId: 'novo',
        adicionar: {'apelido': '  ', 'logradouro': 'Rua A'},
      ),
      throwsArgumentError,
    );
    expect(
      () => atualizarListaPrivada([], campo: 'senhas', novoId: 'novo'),
      throwsArgumentError,
    );
  });
}
