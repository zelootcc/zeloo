# Integração Firebase

O aplicativo utiliza o projeto existente `zeloo-5aac7`, configurado em
`lib/firebase_options.dart`. Não é necessário criar outro banco.

## Dados por tela

| Telas | Fonte |
| --- | --- |
| Login, cadastro e recuperação/troca de senha | Firebase Authentication |
| Início e perfil do cliente, edição do perfil | `Clientes/{uid}` |
| Início, perfil e edição do profissional, busca de profissionais | `Profissionais/{uid}` |
| Serviços e seleção do serviço no agendamento | `Servicos` |
| Agendamento, pedidos do cliente e pedidos do profissional | `Pedidos` |
| Endereços e identificação dos cartões | `ConfiguracoesUsuarios/{uid}` |
| Preferências de notificações | `ConfiguracoesUsuarios/{uid}.notificacoes` |

Perfis e configurações acompanham alterações do Firestore em tempo real.
As categorias de navegação continuam sendo opções fixas da interface; a lista de
profissionais de cada categoria já consulta o Firestore.

## Configurações privadas

O documento é criado na primeira gravação. Não requer preenchimento manual nem
migração dos perfis existentes. Os dados fictícios das antigas telas não são copiados.

- `enderecos`: lista de mapas com `id`, `apelido`, `logradouro`, `principal`.
- `cartoes`: lista de mapas com `id`, `bandeira`, `ultimos4`, `principal`.
- `notificacoes`: mapa com `email`, `sms`, `atualizacoes`, `seguranca` (booleanos).

Adicionar/remover/selecionar o item principal usa transações, preservando alterações
concorrentes. Ao remover o principal, outro item passa a ser principal.
Configurações de profissionais ficam separadas de seus perfis, que são consultáveis
por outros usuários autenticados.

Cartões armazenam somente identificação. Não há tokenização nem cobrança implementada.
Salvar preferências não envia SMS, e-mail ou push; o projeto ainda não contém um
serviço de envio de notificações. Alterações de senha usam reautenticação no Firebase
Auth, e mudanças de e-mail exigem confirmação do link enviado ao novo endereço.

## Regras publicadas

As regras de `firestore.rules` foram compiladas e publicadas com sucesso no projeto
`zeloo-5aac7`. Elas incluem acesso exclusivo do proprietário a
`ConfiguracoesUsuarios/{uid}`. A versão anterior permitia leitura e escrita em todo
o banco por qualquer usuário autenticado; não havia regras específicas de outras
coleções a preservar. A publicação não modificou documentos do banco.

Para futuras alterações, publique novamente com uma conta autorizada:

```sh
firebase deploy --only firestore:rules --project zeloo-5aac7
```

Esse comando publica o arquivo completo de regras. Compare com as regras atualmente
publicadas se elas forem mantidas fora deste repositório.

## Validação

```sh
flutter test test/configuracoes_usuario_test.dart
flutter analyze --no-fatal-infos --no-fatal-warnings
```

Os testes cobrem validação, campos permitidos nos cartões, troca/remoção do principal
e preservação dos dados originais. Não substituem testes autenticados contra o banco.
Para testar o aplicativo, valide com duas contas: salvar endereços/preferências,
reabrir as telas, confirmar persistência e verificar isolamento entre usuários.

Os botões preexistentes de foto, avaliações e relatórios ainda são funcionalidades
sem implementação; não há upload de fotos nem fluxo de avaliação neste projeto.
