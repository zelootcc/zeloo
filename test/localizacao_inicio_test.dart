import 'dart:async';

import 'package:aplicativo_zeloo/localizacao_inicio.dart';
import 'package:aplicativo_zeloo/localizacao_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final enderecos = <Map<String, dynamic>>[
    {
      'id': 'trabalho',
      'apelido': 'Trabalho',
      'bairro': 'Centro',
      'cidade': 'São José',
      'logradouro': 'Rua B, 200',
      'principal': false,
    },
    {
      'id': 'casa',
      'apelido': 'Casa',
      'bairro': 'Jardim',
      'cidade': 'São José',
      'logradouro': 'Rua A, 100',
      'principal': true,
    },
  ];

  testWidgets('visitante vê o bloqueio e pode abrir o acesso à conta', (
    tester,
  ) async {
    var abriuConta = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CartaoLocalizacao(
            local: 'Endereço de exemplo',
            bloqueado: true,
            onTap: () => abriuConta = true,
          ),
        ),
      ),
    );
    expect(find.byType(ImageFiltered), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    await tester.tap(find.byType(CartaoLocalizacao));
    expect(abriuConta, isTrue);
  });

  testWidgets('cliente vê o principal e a escolha salva uma nova preferência', (
    tester,
  ) async {
    var locais = enderecos.map((e) => Map<String, dynamic>.from(e)).toList();
    String? escolhido;
    var chamadasGps = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) => Scaffold(
            body: LocalizacaoCliente(
              enderecos: locais,
              selecionarEndereco: (id) async {
                escolhido = id;
                setState(
                  () => locais = [
                    for (final e in locais) {...e, 'principal': e['id'] == id},
                  ],
                );
              },
              gerenciarEnderecos: () {},
              localizar: () async {
                chamadasGps++;
                return {'bairro': 'Outro bairro', 'cidade': 'Outra cidade'};
              },
            ),
          ),
        ),
      ),
    );
    expect(find.text('Jardim • São José'), findsOneWidget);
    expect(find.byType(ImageFiltered), findsNothing);
    expect(chamadasGps, 0);
    await tester.tap(find.byType(CartaoLocalizacao));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Trabalho'));
    await tester.pumpAndSettle();
    expect(escolhido, 'trabalho');
    expect(find.text('Centro • São José'), findsOneWidget);
    expect(chamadasGps, 0);
  });

  testWidgets('GPS só inicia ao pedir; mostra espera e o endereço retornado', (
    tester,
  ) async {
    final gps = Completer<Map<String, dynamic>>();
    var chamadas = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LocalizacaoCliente(
            enderecos: enderecos,
            selecionarEndereco: (_) async {},
            gerenciarEnderecos: () {},
            localizar: () {
              chamadas++;
              return gps.future;
            },
          ),
        ),
      ),
    );
    expect(chamadas, 0);
    await tester.tap(find.byType(CartaoLocalizacao));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Usar minha localização atual'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(chamadas, 1);
    expect(find.text('Obtendo localização...'), findsOneWidget);
    expect(
      tester.widget<CartaoLocalizacao>(find.byType(CartaoLocalizacao)).onTap,
      isNull,
    );
    gps.complete({
      'bairro': 'Vila Nova',
      'cidade': 'Taubaté',
      'latitude': -23,
      'longitude': -45,
    });
    await tester.pumpAndSettle();
    expect(find.text('Vila Nova • Taubaté'), findsOneWidget);
  });

  testWidgets(
    'permissão negada mantém o endereço salvo e permite tentar de novo',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LocalizacaoCliente(
              enderecos: enderecos,
              selecionarEndereco: (_) async {},
              gerenciarEnderecos: () {},
              localizar: () async =>
                  throw const ErroLocalizacao('Localização não autorizada.'),
            ),
          ),
        ),
      );
      await tester.tap(find.byType(CartaoLocalizacao));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Usar minha localização atual'));
      await tester.pumpAndSettle();
      expect(find.text('Localização não autorizada.'), findsOneWidget);
      expect(find.text('Jardim • São José'), findsOneWidget);
      expect(
        tester.widget<CartaoLocalizacao>(find.byType(CartaoLocalizacao)).onTap,
        isNotNull,
      );
    },
  );

  testWidgets(
    'falha ao salvar conserva o principal; lista vazia abre gerenciamento',
    (tester) async {
      var abriuGerenciamento = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LocalizacaoCliente(
              enderecos: enderecos,
              selecionarEndereco: (_) async => throw Exception('Sem conexão'),
              gerenciarEnderecos: () => abriuGerenciamento = true,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(CartaoLocalizacao));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Trabalho'));
      await tester.pumpAndSettle();
      expect(find.text('Jardim • São José'), findsOneWidget);
      expect(
        find.text('Não foi possível selecionar o endereço. Tente novamente.'),
        findsOneWidget,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LocalizacaoCliente(
              enderecos: const [],
              selecionarEndereco: (_) async {},
              gerenciarEnderecos: () => abriuGerenciamento = true,
            ),
          ),
        ),
      );
      await tester.tap(find.byType(CartaoLocalizacao));
      await tester.pumpAndSettle();
      expect(find.text('Você ainda não tem endereços salvos.'), findsOneWidget);
      await tester.tap(find.text('Cadastrar ou gerenciar endereços'));
      await tester.pumpAndSettle();
      expect(abriuGerenciamento, isTrue);
    },
  );
}
