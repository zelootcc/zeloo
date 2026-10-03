import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'firebase_service.dart';
import 'localizacao_service.dart';
import 'perfil_enderecos_screen.dart';
import 'zeloo_ui.dart';

class LocalPedidoCampo extends StatefulWidget {
  final bool habilitado;
  final ValueChanged<Map<String, dynamic>> onChanged;
  const LocalPedidoCampo({
    super.key,
    required this.onChanged,
    this.habilitado = true,
  });

  @override
  State<LocalPedidoCampo> createState() => _LocalPedidoCampoState();
}

class _LocalPedidoCampoState extends State<LocalPedidoCampo> {
  late final _enderecos = FirebaseService.configuracoes();
  final _endereco = TextEditingController();
  final _complemento = TextEditingController();
  Map<String, dynamic> _coordenadas = {};
  bool _localizando = false;
  bool _enderecoGpsPendente = false;
  String? _aviso;

  @override
  void dispose() {
    _endereco.dispose();
    _complemento.dispose();
    super.dispose();
  }

  void _informar() => widget.onChanged({
    'logradouro': _endereco.text.trim(),
    'complemento': _complemento.text.trim(),
    ..._coordenadas,
  });

  Future<void> _usarLocalizacao() async {
    setState(() {
      _localizando = true;
      _aviso = null;
    });
    try {
      final local = await LocalizacaoService.atual();
      if (!mounted) return;
      setState(() {
        _endereco.text = local['logradouro'] as String;
        _enderecoGpsPendente = _endereco.text.isEmpty;
        _complemento.clear();
        _coordenadas = {
          'latitude': local['latitude'],
          'longitude': local['longitude'],
        };
        _aviso = _endereco.text.isEmpty
            ? 'Localização obtida. Digite o endereço e o número para confirmar.'
            : 'Confira o endereço e o número. O GPS pode indicar um local próximo.';
      });
      _informar();
    } catch (erro) {
      if (!mounted) return;
      setState(
        () => _aviso = erro is ErroLocalizacao
            ? erro.mensagem
            : 'Não foi possível obter a localização. Digite o endereço ou escolha um salvo.',
      );
    } finally {
      if (mounted) setState(() => _localizando = false);
    }
  }

  void _selecionar(Map<String, dynamic> local) {
    setState(() {
      _endereco.text = local['logradouro']?.toString() ?? '';
      _enderecoGpsPendente = false;
      _complemento.text = local['complemento']?.toString() ?? '';
      _coordenadas = {
        if (local['latitude'] is num && local['longitude'] is num) ...{
          'latitude': local['latitude'],
          'longitude': local['longitude'],
        },
      };
      _aviso = '${local['apelido'] ?? 'Endereço'} selecionado.';
    });
    _informar();
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: painelZeloo(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const CabecalhoCampo(
          icon: Icons.location_on_rounded,
          titulo: 'Onde será o atendimento?',
          descricao: 'Escolha um endereço salvo ou informe o local',
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: !widget.habilitado || _localizando
              ? null
              : _usarLocalizacao,
          icon: _localizando
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.my_location_rounded, size: 20),
          label: Text(
            _localizando
                ? 'Obtendo localização...'
                : 'Usar minha localização atual',
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: zelooAzul,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
        StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _enderecos,
          builder: (context, snapshot) {
            final itens = ((snapshot.data?.data()?['enderecos'] as List?) ?? [])
                .map((item) => Map<String, dynamic>.from(item as Map))
                .toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (snapshot.hasError)
                  const Text(
                    'Não foi possível carregar os endereços salvos. Você pode digitar o local.',
                  ),
                if (itens.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      for (final local in itens)
                        ActionChip(
                          avatar: const Icon(
                            Icons.home_outlined,
                            color: zelooAzul,
                            size: 18,
                          ),
                          label: Text(
                            '${local['apelido'] ?? 'Endereço'}${local['principal'] == true ? ' • Principal' : ''}',
                          ),
                          backgroundColor: zelooSuave,
                          side: BorderSide.none,
                          onPressed: widget.habilitado && !_localizando
                              ? () => _selecionar(local)
                              : null,
                        ),
                    ],
                  ),
                ],
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: widget.habilitado && !_localizando
                        ? () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PerfilEnderecosScreen(),
                            ),
                          )
                        : null,
                    icon: const Icon(Icons.add_location_alt_outlined, size: 18),
                    label: const Text('Cadastrar ou gerenciar endereços'),
                    style: TextButton.styleFrom(foregroundColor: zelooAzul),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _endereco,
          enabled: widget.habilitado && !_localizando,
          maxLength: 300,
          keyboardType: TextInputType.streetAddress,
          textInputAction: TextInputAction.next,
          decoration: campoZeloo(
            'Endereço completo',
            icon: Icons.location_on_outlined,
          ).copyWith(hintText: 'Rua, número, bairro e cidade', counterText: ''),
          onChanged: (_) {
            // Se o endereço for alterado, o ponto anterior deixa de representá-lo.
            setState(() {
              if (!_enderecoGpsPendente) _coordenadas = {};
              _aviso = null;
            });
            _informar();
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _complemento,
          enabled: widget.habilitado && !_localizando,
          maxLength: 150,
          decoration:
              campoZeloo(
                'Complemento ou referência (opcional)',
                icon: Icons.door_front_door_outlined,
              ).copyWith(
                hintText: 'Apartamento, portão, ponto de referência',
                counterText: '',
              ),
          onChanged: (_) => _informar(),
        ),
        if (_aviso != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              _aviso!,
              style: const TextStyle(color: zelooAzul, fontSize: 12),
            ),
          ),
      ],
    ),
  );
}
