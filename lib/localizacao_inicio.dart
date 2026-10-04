import 'dart:ui';

import 'package:flutter/material.dart';

import 'localizacao_service.dart';
import 'zeloo_ui.dart';

/// Mesmo cartão nas duas telas; o visitante vê o endereço borrado.
class CartaoLocalizacao extends StatelessWidget {
  final String local;
  final VoidCallback? onTap;
  final bool bloqueado;
  final bool carregando;

  const CartaoLocalizacao({
    super.key,
    required this.local,
    required this.onTap,
    this.bloqueado = false,
    this.carregando = false,
  });

  @override
  Widget build(BuildContext context) {
    final endereco = Text(
      local,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    );

    return Semantics(
      button: true,
      enabled: onTap != null,
      label: bloqueado
          ? 'Sua localização. Entre para selecionar um endereço.'
          : 'Sua localização. $local',
      onTap: onTap,
      child: ExcludeSemantics(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: carregando
                      ? const Padding(
                          padding: EdgeInsets.all(9),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(
                          Icons.location_on_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sua localização',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (!bloqueado)
                        endereco
                      else
                        Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: ImageFiltered(
                                imageFilter: ImageFilter.blur(
                                  sigmaX: 6,
                                  sigmaY: 6,
                                ),
                                child: endereco,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.22),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.lock_rounded,
                                    color: Colors.white,
                                    size: 12,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Entrar',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.white70,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String resumoLocalizacao(Map<String, dynamic> local) {
  final regiao = [local['bairro'], local['cidade']]
      .whereType<String>()
      .map((parte) => parte.trim())
      .where((parte) => parte.isNotEmpty)
      .join(' • ');
  if (regiao.isNotEmpty) return regiao;
  final endereco = local['logradouro']?.toString().trim() ?? '';
  return endereco.isNotEmpty ? endereco : 'Localização atual obtida';
}

/// Usa os endereços do Firebase; o ponto do GPS fica só nesta sessão.
class LocalizacaoCliente extends StatefulWidget {
  final List<Map<String, dynamic>> enderecos;
  final bool carregandoEnderecos;
  final bool erroEnderecos;
  final Future<void> Function(String id) selecionarEndereco;
  final VoidCallback gerenciarEnderecos;
  final Future<Map<String, dynamic>> Function() localizar;

  const LocalizacaoCliente({
    super.key,
    required this.enderecos,
    required this.selecionarEndereco,
    required this.gerenciarEnderecos,
    this.carregandoEnderecos = false,
    this.erroEnderecos = false,
    this.localizar = LocalizacaoService.atual,
  });

  @override
  State<LocalizacaoCliente> createState() => _LocalizacaoClienteState();
}

class _LocalizacaoClienteState extends State<LocalizacaoCliente> {
  Map<String, dynamic>? _localAtual;
  bool _localizando = false;
  bool _salvando = false;
  bool get _ocupado => _localizando || _salvando;

  Map<String, dynamic>? get _principal {
    for (final endereco in widget.enderecos) {
      if (endereco['principal'] == true) return endereco;
    }
    return widget.enderecos.isEmpty ? null : widget.enderecos.first;
  }

  void _avisar(String mensagem) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensagem)));
  }

  Future<void> _usarGps() async {
    if (_ocupado) return;
    setState(() => _localizando = true);
    try {
      final local = await widget.localizar();
      if (!mounted) return;
      setState(() => _localAtual = local);
    } catch (erro) {
      if (mounted) {
        _avisar(
          erro is ErroLocalizacao
              ? erro.mensagem
              : 'Não foi possível obter sua localização. Escolha um endereço salvo ou tente novamente.',
        );
      }
    } finally {
      if (mounted) setState(() => _localizando = false);
    }
  }

  Future<void> _selecionar(Map<String, dynamic> endereco) async {
    final id = endereco['id'];
    if (_ocupado || id is! String || id.isEmpty) return;
    setState(() => _salvando = true);
    try {
      await widget.selecionarEndereco(id);
      if (mounted) setState(() => _localAtual = null);
    } catch (_) {
      if (mounted) {
        _avisar('Não foi possível selecionar o endereço. Tente novamente.');
      }
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  void _abrirOpcoes() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFFF4F7FB),
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) => SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.75,
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CabecalhoCampo(
                  icon: Icons.location_on_outlined,
                  titulo: 'Onde você está?',
                  descricao:
                      'Use sua posição atual ou escolha seu endereço principal.',
                ),
                const SizedBox(height: 20),
                BotaoZeloo(
                  texto: 'Usar minha localização atual',
                  icon: Icons.my_location_rounded,
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    _usarGps();
                  },
                ),
                const SizedBox(height: 20),
                if (widget.carregandoEnderecos)
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (widget.erroEnderecos)
                  const Text(
                    'Não foi possível carregar os endereços. Você ainda pode usar o GPS.',
                  ),
                if (!widget.carregandoEnderecos &&
                    !widget.erroEnderecos &&
                    widget.enderecos.isEmpty)
                  const Text(
                    'Você ainda não tem endereços salvos.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF64788B)),
                  ),
                for (final endereco in widget.enderecos)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: painelZeloo(
                      destaque: endereco['principal'] == true,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(22),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                        leading: const Icon(
                          Icons.home_outlined,
                          color: zelooAzul,
                        ),
                        title: Text(
                          '${endereco['apelido'] ?? 'Endereço'}${endereco['principal'] == true ? ' • Principal' : ''}',
                          style: const TextStyle(
                            color: zelooTexto,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          endereco['logradouro']?.toString() ??
                              resumoLocalizacao(endereco),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Icon(
                          endereco['principal'] == true && _localAtual == null
                              ? Icons.check_circle_rounded
                              : Icons.chevron_right_rounded,
                          color: zelooAzul,
                        ),
                        onTap:
                            endereco['id'] is String &&
                                (endereco['id'] as String).isNotEmpty
                            ? () {
                                Navigator.pop(sheetContext);
                                _selecionar(endereco);
                              }
                            : null,
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    widget.gerenciarEnderecos();
                  },
                  icon: const Icon(Icons.add_location_alt_outlined),
                  label: const Text('Cadastrar ou gerenciar endereços'),
                  style: TextButton.styleFrom(foregroundColor: zelooAzul),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final local = _localAtual ?? _principal;
    final texto = _localizando
        ? 'Obtendo localização...'
        : _salvando
        ? 'Salvando endereço...'
        : local != null
        ? resumoLocalizacao(local)
        : widget.carregandoEnderecos
        ? 'Carregando endereço...'
        : 'Selecione sua localização';
    return CartaoLocalizacao(
      local: texto,
      carregando: _ocupado || widget.carregandoEnderecos && local == null,
      onTap: _ocupado ? null : _abrirOpcoes,
    );
  }
}
