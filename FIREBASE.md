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
| Avaliações dos serviços concluídos | `Avaliacoes/{pedidoId}` |
| Endereços e identificação dos cartões | `ConfiguracoesUsuarios/{uid}` |
| Preferências de notificações | `ConfiguracoesUsuarios/{uid}.notificacoes` |

Perfis e configurações acompanham alterações do Firestore em tempo real.
As categorias de navegação continuam sendo opções fixas da interface; a lista de
profissionais de cada categoria já consulta o Firestore.

## Áreas e horários do profissional

Cadastro e edição usam o catálogo de `lib/dados_profissionais.dart`, com até três
áreas em `areasAtuacao`. Os campos antigos `area` e `especialidade` mantêm a primeira
seleção para compatibilidade. A busca considera todas as áreas selecionadas.

`horariosAtendimento` contém apenas os dias escolhidos, com as chaves `segunda`,
`terca`, `quarta`, `quinta`, `sexta`, `sabado`, `domingo`. Cada dia contém `inicio`
e `fim` no formato `HH:mm`. `disponibilidade` mantém um resumo legível.
O horário padrão preenche os dias; alterações individuais não são sobrescritas
ao mudar o padrão. Sem dias selecionados, o atendimento fica sob consulta.
Os intervalos terminam no mesmo dia e o término deve ser posterior ao início.

Perfis antigos continuam legíveis. As opções antigas com intervalo explícito
(segunda a sexta/sábado, 8h–18h) são convertidas ao abrir a edição. Outros textos
antigos não permitem inferir horários: o profissional deve selecionar seus dias.
As regras existentes já permitem salvar esses campos; não é necessário novo deploy.

As formas aceitas ficam em `pagamentos` como uma lista (PIX, dinheiro, cartões,
transferência bancária e boleto). O campo antigo `pagamento` continua sendo salvo
com o resumo em texto para manter compatibilidade com perfis existentes.

## Notificações de pedidos

Ao criar um pedido, o aplicativo grava uma notificação em `Notificacoes` no mesmo
lote do pedido. O profissional vê essa notificação na central pelo botão no canto
superior direito da tela inicial; o contador mostra itens ainda não lidos. O token
do celular fica em `Dispositivos/{uid}` e nunca é exibido a outros usuários.

O código da Cloud Function está em `functions/index.js`. Ela observa as notificações
das etapas do pedido e envia o push via Firebase Cloud Messaging, removendo tokens
inválidos. Cliente e profissional possuem um botão com contador para abrir a central.
As regras do Firestore já foram publicadas e a central funciona imediatamente.

A publicação da Cloud Function foi bloqueada pelo Firebase porque o projeto
`zeloo-5aac7` está no plano Spark. O Firebase exige o plano Blaze para habilitar
Cloud Functions e Artifact Registry. Para ativar o push real, faça o upgrade em
`https://console.firebase.google.com/project/zeloo-5aac7/usage/details` e execute:

```sh
firebase deploy --only functions --project zeloo-5aac7
```

Não coloque chaves privadas do FCM no aplicativo. O push só deve ser enviado pela
Cloud Function; o aplicativo registra somente o token do próprio usuário.

## Fluxo dos pedidos e código de início

Pedidos novos passam por `aguardando`, `aceito`, `a_caminho`,
`aguardando_codigo`, `em_andamento`, `aguardando_conclusao` e `concluido`.
Também podem terminar como `cancelado`, sempre com um motivo. Cada mudança guarda
o horário correspondente usando o relógio do Firestore.

O código de quatro dígitos é criado junto com o pedido em
`CodigosPedidos/{pedidoId}`. Somente o cliente pode ler esse documento. O
profissional envia o número digitado e as regras do Firestore fazem a comparação;
cinco erros bloqueiam novas tentativas até o cliente gerar outro código. Quando o
código está correto, o pedido muda para `em_andamento` e `iniciadoEm` inicia o
cronômetro exibido nas duas contas.

O profissional solicita a conclusão e o cliente precisa confirmá-la. O aplicativo
grava notificações de pedido aceito, deslocamento, chegada, início, solicitação de
conclusão, conclusão, cancelamento e renovação do código. Pedidos antigos com o
status `confirmado` continuam sendo tratados como aceitos.

## Avaliações e relatórios

Depois de confirmar a conclusão, o cliente pode escolher de uma a cinco estrelas e
escrever um comentário opcional de até 300 caracteres. Cada pedido usa seu próprio
ID em `Avaliacoes`, então só pode receber uma avaliação. A mesma transação atualiza
`avaliacao`, `somaAvaliacoes` e `totalAvaliacoes` no perfil do profissional.

A tela de avaliações lista as notas e comentários recebidos. O relatório usa apenas
pedidos com status `concluido` e calcula o total dos últimos sete dias, o total do
mês atual, a média por serviço no mês e a média diária considerando os dias já
decorridos. Pedidos concluídos antes deste fluxo usam `atualizadoEm` quando não têm
o campo `concluidoEm`.

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
Salvar preferências de notificações não envia SMS ou e-mail por si só; pedidos usam a
central do aplicativo e o fluxo de push FCM descrito acima. Alterações de senha usam reautenticação no Firebase
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
