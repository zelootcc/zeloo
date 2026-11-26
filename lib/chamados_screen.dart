import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'dados_profissionais.dart';
import 'firebase_service.dart';
import 'local_pedido_campo.dart';
import 'zeloo_ui.dart';

class ChamadosScreen extends StatefulWidget {
  final bool profissional;
  const ChamadosScreen({super.key, this.profissional = false});

  @override
  State<ChamadosScreen> createState() => _ChamadosScreenState();
}

class _ChamadosScreenState extends State<ChamadosScreen> {
  late final chamados = FirebaseService.chamadosRecebidos();
  String? area;
  Map<String, dynamic> local = {};
  String descricao = '';
  bool ocupado = false;

  Future<void> executar(Future<void> Function() acao) async {
    if (ocupado) return;
    setState(() => ocupado = true);
    try {
      await acao();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => ocupado = false);
    }
  }

  Future<void> publicar() async {
    if (area == null || descricao.trim().isEmpty) {
      throw Exception('Selecione a área e descreva o serviço.');
    }
    await FirebaseService.publicarChamado(area!, local, descricao.trim());
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Chamado publicado! Acompanhe em Meus Pedidos e converse após o aceite.',
        ),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF4F7FB),
    appBar: AppBarZeloo(
      titulo: widget.profissional ? 'Chamados da região' : 'Publicar chamado',
    ),
    body: widget.profissional
        ? recebidos()
        : ListView(
            padding: const EdgeInsets.all(16),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: painelZeloo(destaque: true),
                child: Column(
                  children: [
                    const CabecalhoCampo(
                      icon: Icons.campaign_rounded,
                      titulo: 'Qual serviço você precisa?',
                      descricao:
                          'Receba uma proposta de um profissional da sua região e decida se quer contratar.',
                    ),
                    const SizedBox(height: 20),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      decoration: campoZeloo(
                        'Área do serviço',
                        icon: Icons.grid_view_rounded,
                      ),
                      items: areasAtuacao
                          .map(
                            (a) => DropdownMenuItem(value: a, child: Text(a)),
                          )
                          .toList(),
                      onChanged: (v) => area = v,
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      decoration: campoZeloo('Descrição do serviço').copyWith(
                        alignLabelWithHint: true,
                        hintText: 'Ex.: preciso trocar a torneira da cozinha.',
                      ),
                      maxLines: 3,
                      maxLength: 600,
                      onChanged: (v) => descricao = v,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              LocalPedidoCampo(
                habilitado: !ocupado,
                onChanged: (v) => local = v,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: zelooAzul,
                      size: 19,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'O endereço completo será compartilhado com quem você contratar.',
                      ),
                    ),
                  ],
                ),
              ),
              BotaoZeloo(
                icon: Icons.campaign_rounded,
                onPressed: ocupado ? null : () => executar(publicar),
                texto: ocupado ? 'Publicando…' : 'Publicar chamado',
              ),
            ],
          ),
  );
  Future<void> ofertar(String id) async {
    String preco = '', comentario = '';
    String? erro;
    final enviar = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, atualizar) => AlertDialog(
          title: const Text('Sua proposta'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: campoZeloo(
                    'Valor do serviço',
                  ).copyWith(prefixText: 'R\$ ', errorText: erro),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (v) => preco = v,
                ),
                const SizedBox(height: 12),
                TextField(
                  decoration: campoZeloo('Comentário (opcional)'),
                  maxLength: 300,
                  maxLines: 2,
                  onChanged: (v) => comentario = v,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Voltar'),
            ),
            FilledButton(
              onPressed: () {
                if (!RegExp(
                      r'^\d{1,8}([,.]\d{1,2})?$',
                    ).hasMatch(preco.trim()) ||
                    double.parse(preco.replaceAll(',', '.')) <= 0 ||
                    double.parse(preco.replaceAll(',', '.')) > 99999999) {
                  atualizar(() => erro = 'Informe um valor válido.');
                  return;
                }
                Navigator.pop(context, true);
              },
              child: const Text('Enviar proposta'),
            ),
          ],
        ),
      ),
    );
    if (enviar != true || !mounted) return;
    await FirebaseService.proporChamado(
      id,
      double.parse(preco.replaceAll(',', '.')),
      comentario.trim(),
    );
    if (mounted)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Proposta enviada. Aguarde a resposta do cliente.'),
        ),
      );
  }

  Widget recebidos() => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: chamados,
    builder: (context, snap) {
      if (snap.hasError) {
        return const Center(child: Text('Falha ao carregar chamados.'));
      }
      if (!snap.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      final docs = snap.data!.docs
          .where((d) => d.data()['proposta'] == null)
          .toList();
      if (docs.isEmpty) {
        return const Center(child: Text('Nenhum chamado na sua região agora.'));
      }
      return ListView(
        padding: const EdgeInsets.all(16),
        children: docs.map((doc) {
          final d = doc.data();
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d['servico'].toString(),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text("${d['clienteNome']} · ${d['regiao']}"),
                  Text(d['descricao'].toString()),
                  Wrap(
                    spacing: 8,
                    children: [
                      TextButton(
                        onPressed: ocupado
                            ? null
                            : () => executar(
                                () => FirebaseService.recusarChamado(doc.id),
                              ),
                        child: const Text('Recusar'),
                      ),
                      FilledButton(
                        onPressed: ocupado
                            ? null
                            : () => executar(() => ofertar(doc.id)),
                        child: const Text('Fazer proposta'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      );
    },
  );
}
