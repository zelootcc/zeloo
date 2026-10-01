const { onCreate } = require('firebase-functions/v2/firestore');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');

initializeApp();

exports.enviarNotificacaoPedido = onCreate('Notificacoes/{notificacaoId}', async (event) => {
  const notificacao = event.data?.data();
  if (!notificacao) return;

  const destino = notificacao.destinatarioId;
  if (typeof destino !== 'string' || !destino) return;

  const db = getFirestore();
  const dispositivo = await db.collection('Dispositivos').doc(destino).get();
  const tokens = dispositivo.data()?.tokens;
  if (!Array.isArray(tokens) || tokens.length === 0) return;

  const resposta = await getMessaging().sendEachForMulticast({
    tokens,
    notification: {
      title: notificacao.titulo || 'Novo pedido recebido',
      body: notificacao.mensagem || 'Você recebeu um novo pedido na Zeloo.',
    },
    data: {
      tipo: String(notificacao.tipo || 'pedido'),
      pedidoId: String(notificacao.pedidoId || ''),
      notificacaoId: event.params.notificacaoId,
    },
    android: {
      priority: 'high',
      notification: { channelId: 'zeloo_pedidos', sound: 'default' },
    },
  });

  const invalidos = [];
  resposta.responses.forEach((resultado, indice) => {
    const codigo = resultado.error?.code || '';
    if (codigo.includes('registration-token-not-registered') || codigo.includes('invalid-registration-token')) {
      invalidos.push(tokens[indice]);
    }
  });
  if (invalidos.length > 0) {
    const atuais = tokens.filter((token) => !invalidos.includes(token));
    await dispositivo.ref.update({ tokens: atuais });
  }
});
