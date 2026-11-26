import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'firebase_service.dart';
import 'pedido_status.dart';
import 'zeloo_ui.dart';

class ChatPedidoScreen extends StatefulWidget {
  final String pedidoId;

  const ChatPedidoScreen({super.key, required this.pedidoId});

  @override
  State<ChatPedidoScreen> createState() => _ChatPedidoScreenState();
}

class _ChatPedidoScreenState extends State<ChatPedidoScreen> {
  final _mensagem = TextEditingController();
  final _rolagem = ScrollController();
  bool _enviando = false;

  @override
  void dispose() {
    _mensagem.dispose();
    _rolagem.dispose();
    super.dispose();
  }

  void _usarSugestao(String texto) {
    _mensagem.value = TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(offset: texto.length),
    );
  }

  Future<void> _enviar() async {
    final texto = _mensagem.text.trim();
    if (_enviando || texto.isEmpty) return;
    setState(() => _enviando = true);
    try {
      await FirebaseService.enviarMensagemPedido(
        pedidoId: widget.pedidoId,
        mensagem: texto,
      );
      _mensagem.clear();
      if (_rolagem.hasClients) {
        await _rolagem.animateTo(
          0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
        );
      }
    } catch (erro) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(erro.toString().replaceFirst('Exception: ', '')),
        ),
      );
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) => StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
    stream: FirebaseService.observarPedido(widget.pedidoId),
    builder: (context, pedidoSnapshot) {
      if (pedidoSnapshot.connectionState == ConnectionState.waiting) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (pedidoSnapshot.hasError ||
          !pedidoSnapshot.hasData ||
          !pedidoSnapshot.data!.exists) {
        return const Scaffold(
          body: Center(child: Text('Não foi possível abrir esta conversa.')),
        );
      }

      final pedido = pedidoSnapshot.data!.data()!;
      final souCliente = pedido['clienteId'] == FirebaseService.usuario?.uid;
      final nomeContato =
          (souCliente ? pedido['profissionalNome'] : pedido['clienteNome'])
              ?.toString()
              .trim();
      final contato = (nomeContato == null || nomeContato.isEmpty)
          ? 'Contato do pedido'
          : nomeContato;
      final servico = pedido['servico']?.toString().trim() ?? 'Serviço';
      final status = PedidoStatus.normalizar(
        pedido['status']?.toString() ?? PedidoStatus.aguardando,
      );
      final podeConversar = PedidoStatus.chatDisponivel(status);

      return Scaffold(
        backgroundColor: const Color(0xFFF4F7FB),
        appBar: AppBarZeloo(
          titulo: contato,
          subtitulo: 'Conversa sobre $servico',
        ),
        body: Column(
          children: [
            _AvisoChat(status: status),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseService.mensagensPedido(widget.pedidoId),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Não foi possível carregar as mensagens.'),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final mensagens = [...?snapshot.data?.docs]
                    ..sort((a, b) {
                      final dataA = a.data()['criadoEm'] as Timestamp?;
                      final dataB = b.data()['criadoEm'] as Timestamp?;
                      return (dataB?.millisecondsSinceEpoch ?? 0).compareTo(
                        dataA?.millisecondsSinceEpoch ?? 0,
                      );
                    });
                  if (mensagens.isEmpty) {
                    return _ChatVazio(
                      sugestoes: _sugestoes(status),
                      onSugestao: _usarSugestao,
                    );
                  }
                  return ListView.builder(
                    controller: _rolagem,
                    reverse: true,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
                    itemCount: mensagens.length,
                    itemBuilder: (context, index) {
                      final dados = mensagens[index].data();
                      return _BolhaMensagem(
                        texto: dados['texto']?.toString() ?? '',
                        enviadaPorMim:
                            dados['remetenteId'] ==
                            FirebaseService.usuario?.uid,
                        horario: dados['criadoEm'] as Timestamp?,
                      );
                    },
                  );
                },
              ),
            ),
            if (podeConversar)
              _CampoMensagem(
                controller: _mensagem,
                enviando: _enviando,
                onEnviar: _enviar,
              )
            else
              const _ConversaEncerrada(),
          ],
        ),
      );
    },
  );

  List<String> _sugestoes(String status) => switch (status) {
    PedidoStatus.aguardando => const [
      'Olá! Gostaria de confirmar alguns detalhes do serviço.',
      'O endereço e o horário continuam corretos?',
    ],
    PedidoStatus.aceito || PedidoStatus.aCaminho => const [
      'Estou a caminho. Aviso quando estiver próximo.',
      'Pode confirmar o melhor ponto de encontro?',
    ],
    _ => const [
      'Há alguma informação importante para o serviço?',
      'Estou no local e pronto para começar.',
    ],
  };
}

class BotaoChatPedido extends StatelessWidget {
  final String pedidoId;

  const BotaoChatPedido({super.key, required this.pedidoId});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
    child: SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChatPedidoScreen(pedidoId: pedidoId),
          ),
        ),
        icon: const Icon(Icons.chat_bubble_outline_rounded, size: 19),
        label: const Text('Conversar sobre o pedido'),
        style: OutlinedButton.styleFrom(
          foregroundColor: zelooAzul,
          backgroundColor: zelooSuave,
          side: const BorderSide(color: Color(0xFFB3E8EF)),
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    ),
  );
}

class _AvisoChat extends StatelessWidget {
  final String status;

  const _AvisoChat({required this.status});

  @override
  Widget build(BuildContext context) {
    final texto = switch (status) {
      PedidoStatus.aguardando =>
        'Combine detalhes importantes antes de aceitar o pedido.',
      PedidoStatus.aceito || PedidoStatus.aCaminho =>
        'Use o chat para confirmar o ponto de encontro e avisos do trajeto.',
      PedidoStatus.emAndamento || PedidoStatus.aguardandoCodigo =>
        'Registre informações importantes sobre o atendimento.',
      PedidoStatus.aguardandoConclusao =>
        'Conversa disponível enquanto o cliente confirma a conclusão.',
      _ => 'Esta conversa está vinculada ao pedido.',
    };
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF8FC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: zelooAzul, size: 20),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                color: Color(0xFF42647A),
                fontSize: 12,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatVazio extends StatelessWidget {
  final List<String> sugestoes;
  final ValueChanged<String> onSugestao;

  const _ChatVazio({required this.sugestoes, required this.onSugestao});

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 66,
            height: 66,
            decoration: BoxDecoration(
              color: zelooSuave,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Icon(Icons.forum_outlined, color: zelooAzul, size: 34),
          ),
          const SizedBox(height: 14),
          const Text(
            'Comece a conversa',
            style: TextStyle(color: zelooTexto, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          const Text(
            'Use o chat apenas para informações do serviço. Não envie senhas ou dados de cartão.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF64788B),
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          ...sugestoes.map(
            (texto) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ActionChip(
                label: Text(texto, textAlign: TextAlign.center),
                labelStyle: const TextStyle(fontSize: 11, color: zelooAzul),
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFB3E8EF)),
                onPressed: () => onSugestao(texto),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _BolhaMensagem extends StatelessWidget {
  final String texto;
  final bool enviadaPorMim;
  final Timestamp? horario;

  const _BolhaMensagem({
    required this.texto,
    required this.enviadaPorMim,
    required this.horario,
  });

  @override
  Widget build(BuildContext context) {
    final horarioTexto = horario == null
        ? 'Agora'
        : '${horario!.toDate().hour.toString().padLeft(2, '0')}:${horario!.toDate().minute.toString().padLeft(2, '0')}';
    return Align(
      alignment: enviadaPorMim ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 290),
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.fromLTRB(14, 10, 12, 8),
        decoration: BoxDecoration(
          color: enviadaPorMim ? zelooAzul : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(enviadaPorMim ? 18 : 4),
            bottomRight: Radius.circular(enviadaPorMim ? 4 : 18),
          ),
          border: enviadaPorMim
              ? null
              : Border.all(color: const Color(0xFFE1EBF3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              texto,
              style: TextStyle(
                color: enviadaPorMim ? Colors.white : zelooTexto,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              horarioTexto,
              style: TextStyle(
                color: enviadaPorMim ? Colors.white70 : const Color(0xFF8DA0B0),
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CampoMensagem extends StatelessWidget {
  final TextEditingController controller;
  final bool enviando;
  final VoidCallback onEnviar;

  const _CampoMensagem({
    required this.controller,
    required this.enviando,
    required this.onEnviar,
  });

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE4EDF4))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !enviando,
              minLines: 1,
              maxLines: 4,
              maxLength: 600,
              textCapitalization: TextCapitalization.sentences,
              decoration: campoZeloo('Escreva uma mensagem').copyWith(
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
              ),
              onSubmitted: (_) => onEnviar(),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 50,
            width: 50,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: zelooGradiente,
                borderRadius: BorderRadius.circular(15),
              ),
              child: IconButton(
                tooltip: 'Enviar mensagem',
                onPressed: enviando ? null : onEnviar,
                icon: enviando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.send_rounded, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class _ConversaEncerrada extends StatelessWidget {
  const _ConversaEncerrada();

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    child: Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: const Color(0xFFF0F4F7),
      child: const Text(
        'Esta conversa foi encerrada porque o pedido não está mais ativo.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Color(0xFF64788B), fontSize: 12),
      ),
    ),
  );
}
