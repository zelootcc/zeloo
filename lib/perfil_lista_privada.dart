import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'firebase_service.dart';

/// Lista privada do usuário, com gravações confirmadas antes de fechar o editor.
class PerfilListaPrivada extends StatefulWidget {
  final bool cartoes;
  const PerfilListaPrivada({super.key, this.cartoes = false});

  @override
  State<PerfilListaPrivada> createState() => _PerfilListaPrivadaState();
}

class _PerfilListaPrivadaState extends State<PerfilListaPrivada> {
  late final Stream<DocumentSnapshot<Map<String, dynamic>>> _stream =
      FirebaseService.configuracoes();
  bool _salvando = false;
  String get _campo => widget.cartoes ? 'cartoes' : 'enderecos';

  Future<void> _alterar({String? remover, String? principal}) async {
    if (_salvando) return;
    setState(() => _salvando = true);
    try {
      await FirebaseService.alterarItemPrivado(
        _campo,
        remover: remover,
        principal: principal,
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível salvar. Tente novamente.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  Future<void> _adicionar() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _EditorItem(cartoes: widget.cartoes),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF4F7FB),
    appBar: AppBar(
      title: Text(widget.cartoes ? 'Formas de pagamento' : 'Meus endereços'),
      foregroundColor: Colors.white,
      backgroundColor: const Color(0xFF0077B6),
    ),
    body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _stream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(
            child: Text('Não foi possível carregar seus dados.'),
          );
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final itens = ((snapshot.data!.data()?[_campo] as List?) ?? [])
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (widget.cartoes)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  'Salve a identificação dos seus cartões. '
                  'O pagamento é combinado com o profissional; '
                  'não são realizadas cobranças pelo aplicativo.',
                ),
              ),
            if (_salvando) const LinearProgressIndicator(),
            if (itens.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Text(
                  widget.cartoes
                      ? 'Nenhum cartão cadastrado.'
                      : 'Nenhum endereço cadastrado.',
                ),
              ),
            for (final item in itens)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          widget.cartoes
                              ? Icons.credit_card
                              : Icons.location_on,
                          color: const Color(0xFF0077B6),
                        ),
                        title: Text(
                          '${item[widget.cartoes ? 'bandeira' : 'apelido'] ?? ''}',
                        ),
                        subtitle: Text(
                          widget.cartoes
                              ? '•••• ${item['ultimos4'] ?? ''}'
                              : '${item['logradouro'] ?? ''}',
                        ),
                        trailing: IconButton(
                          tooltip: 'Remover',
                          onPressed: _salvando
                              ? null
                              : () => _alterar(remover: item['id'] as String),
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                        ),
                      ),
                      if (item['principal'] == true)
                        const Chip(label: Text('Principal'))
                      else
                        TextButton(
                          onPressed: _salvando
                              ? null
                              : () => _alterar(principal: item['id'] as String),
                          child: const Text('Tornar principal'),
                        ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _salvando ? null : _adicionar,
              icon: const Icon(Icons.add),
              label: Text(
                widget.cartoes ? 'Adicionar cartão' : 'Adicionar local',
              ),
            ),
          ],
        );
      },
    ),
  );
}

class _EditorItem extends StatefulWidget {
  final bool cartoes;
  const _EditorItem({required this.cartoes});
  @override
  State<_EditorItem> createState() => _EditorItemState();
}

class _EditorItemState extends State<_EditorItem> {
  final _titulo = TextEditingController();
  final _detalhe = TextEditingController();
  final _form = GlobalKey<FormState>();
  bool _salvando = false;
  String? _erro;

  @override
  void dispose() {
    _titulo.dispose();
    _detalhe.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_salvando || !_form.currentState!.validate()) return;
    setState(() {
      _salvando = true;
      _erro = null;
    });
    try {
      await FirebaseService.alterarItemPrivado(
        widget.cartoes ? 'cartoes' : 'enderecos',
        adicionar: widget.cartoes
            ? {
                'bandeira': _titulo.text.trim(),
                'ultimos4': _detalhe.text.trim(),
              }
            : {
                'apelido': _titulo.text.trim(),
                'logradouro': _detalhe.text.trim(),
              },
      );
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted)
        setState(() => _erro = 'Não foi possível salvar. Tente novamente.');
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_salvando,
    child: SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.cartoes ? 'Adicionar cartão' : 'Novo endereço',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            TextFormField(
              controller: _titulo,
              enabled: !_salvando,
              maxLength: 80,
              decoration: InputDecoration(
                labelText: widget.cartoes ? 'Bandeira' : 'Apelido',
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Preencha este campo.'
                  : null,
            ),
            TextFormField(
              controller: _detalhe,
              enabled: !_salvando,
              maxLength: widget.cartoes ? 4 : 300,
              keyboardType: widget.cartoes
                  ? TextInputType.number
                  : TextInputType.streetAddress,
              inputFormatters: widget.cartoes
                  ? [FilteringTextInputFormatter.digitsOnly]
                  : null,
              decoration: InputDecoration(
                labelText: widget.cartoes
                    ? 'Últimos 4 dígitos'
                    : 'Endereço completo',
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty)
                  return 'Preencha este campo.';
                if (widget.cartoes && !RegExp(r'^\d{4}$').hasMatch(value))
                  return 'Informe os 4 últimos dígitos.';
                return null;
              },
            ),
            if (_erro != null)
              Text(_erro!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _salvando ? null : _salvar,
              child: Text(_salvando ? 'Salvando...' : 'Salvar'),
            ),
          ],
        ),
      ),
    ),
  );
}
