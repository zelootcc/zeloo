import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'zeloo_ui.dart';

/// As mensagens ficam dentro do pedido, que já identifica cliente e profissional.
class ChatPedidoScreen extends StatefulWidget {
  final String pedidoId;

  const ChatPedidoScreen({super.key, required this.pedidoId});

  @override
  State<ChatPedidoScreen> createState() => _ChatPedidoScreenState();
}

class _ChatPedidoScreenState extends State<ChatPedidoScreen> {
  final _texto = TextEditingController();
  bool _enviando = false;

  DocumentReference<Map<String, dynamic>> get _pedido =>
      FirebaseFirestore.instance.collection('Pedidos').doc(widget.pedidoId);

  CollectionReference<Map<String, dynamic>> get _mensagens =>
      _pedido.collection('Mensagens');

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    final mensagem = _texto.text.trim();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (_enviando || uid == null || mensagem.isEmpty || mensagem.length > 2000) {
      return;
    }
    setState(() => _enviando = true);
    try {
      await _mensagens.add({
        'remetenteId': uid,
        'texto': mensagem,
        'criadoEm': FieldValue.serverTimestamp(),
      });
      if (mounted && _texto.text.trim() == mensagem) _texto.clear();
    } on FirebaseException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível enviar: ${e.message ?? e.code}')),
        );
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Entre na sua conta para conversar.')));
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _pedido.snapshots(),
      builder: (context, pedidoSnapshot) {
        if (pedidoSnapshot.hasError) {
          return const Scaffold(body: Center(child: Text('Não foi possível acessar este pedido.')));
        }
        if (!pedidoSnapshot.hasData) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final dados = pedidoSnapshot.data!.data();
        if (dados == null ||
            (dados['clienteId'] != uid && dados['profissionalId'] != uid)) {
          return const Scaffold(body: Center(child: Text('Conversa indisponível.')));
        }
        final cliente = dados['clienteId'] == uid;
        final nome = (cliente ? dados['profissionalNome'] : dados['clienteNome'])
                ?.toString() ??
            (cliente ? 'Profissional' : 'Cliente');

        return Scaffold(
          backgroundColor: const Color(0xFFF4F7FB),
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(nome, maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(
                  dados['servico']?.toString() ?? 'Pedido',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                ),
              ],
            ),
            foregroundColor: Colors.white,
            flexibleSpace: Container(decoration: const BoxDecoration(gradient: zelooGradiente)),
          ),
          body: Column(
            children: [
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _mensagens.orderBy('criadoEm', descending: true).limit(200).snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(child: Text('Erro ao carregar mensagens. Verifique as permissões.'));
                    }
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final mensagens = snapshot.data!.docs;
                    if (mensagens.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child: Text(
                            'Ainda não há mensagens. Envie a primeira para combinar os detalhes do serviço.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      reverse: true,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
                      itemCount: mensagens.length,
                      itemBuilder: (context, index) {
                        final msg = mensagens[index].data();
                        final minha = msg['remetenteId'] == uid;
                        final instante = (msg['criadoEm'] as Timestamp?)?.toDate();
                        final hora = instante == null
                            ? ''
                            : '${instante.hour.toString().padLeft(2, '0')}:${instante.minute.toString().padLeft(2, '0')}';
                        return Align(
                          alignment: minha ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.sizeOf(context).width * .78,
                            ),
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: minha ? const Color(0xFF0077B6) : Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  msg['texto']?.toString() ?? '',
                                  style: TextStyle(color: minha ? Colors.white : zelooTexto, fontSize: 15),
                                ),
                                if (hora.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    hora,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: minha ? Colors.white70 : Colors.grey,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _texto,
                          minLines: 1,
                          maxLines: 4,
                          maxLength: 2000,
                          textCapitalization: TextCapitalization.sentences,
                          decoration: const InputDecoration(
                            hintText: 'Digite uma mensagem...',
                            counterText: '',
                            border: OutlineInputBorder(),
                            isDense: true,
                          ),
                          onSubmitted: (_) => _enviar(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        onPressed: _enviando ? null : _enviar,
                        icon: _enviando
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.send_rounded),
                        style: IconButton.styleFrom(backgroundColor: zelooAzul),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
