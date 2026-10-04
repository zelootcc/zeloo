import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'zeloo_ui.dart';

const estadosEndereco = [
  'AC',
  'AL',
  'AP',
  'AM',
  'BA',
  'CE',
  'DF',
  'ES',
  'GO',
  'MA',
  'MT',
  'MS',
  'MG',
  'PA',
  'PB',
  'PR',
  'PE',
  'PI',
  'RJ',
  'RN',
  'RS',
  'RO',
  'RR',
  'SC',
  'SP',
  'SE',
  'TO',
];

class EnderecoController {
  final campos = {
    for (final nome in [
      'rua',
      'numero',
      'bairro',
      'cidade',
      'estado',
      'cep',
      'complemento',
    ])
      nome: TextEditingController(),
  };
  Map<String, dynamic> coordenadas = {};

  Map<String, dynamic> get dados => {
    for (final campo in campos.entries) campo.key: campo.value.text.trim(),
    ...coordenadas,
  };

  void preencher(Map<String, dynamic> local) {
    for (final campo in campos.entries) {
      // Endereços antigos ficam visíveis para o usuário completar os campos.
      campo.value.text =
          (local[campo.key] ??
                  (campo.key == 'rua' ? local['logradouro'] : '') ??
                  '')
              .toString();
    }
    coordenadas = {
      if (local['latitude'] is num && local['longitude'] is num) ...{
        'latitude': local['latitude'],
        'longitude': local['longitude'],
      },
    };
  }

  void dispose() {
    for (final campo in campos.values) {
      campo.dispose();
    }
  }
}

class EnderecoCampos extends StatelessWidget {
  final EnderecoController controller;
  final bool habilitado;
  final ValueChanged<String>? onChanged;
  const EnderecoCampos({
    super.key,
    required this.controller,
    this.habilitado = true,
    this.onChanged,
  });

  Widget _campo(
    String chave,
    String titulo, {
    String? dica,
    IconData? icone,
    int limite = 100,
    TextInputType? teclado,
    bool obrigatorio = true,
  }) => TextFormField(
    controller: controller.campos[chave],
    enabled: habilitado,
    maxLength: limite,
    keyboardType: teclado,
    textInputAction: TextInputAction.next,
    textCapitalization: chave == 'estado'
        ? TextCapitalization.characters
        : TextCapitalization.words,
    autovalidateMode: AutovalidateMode.onUserInteraction,
    inputFormatters: chave == 'cep'
        ? [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(8),
            _MascaraCep(),
          ]
        : null,
    decoration: campoZeloo(
      titulo,
      icon: icone,
    ).copyWith(hintText: dica, counterText: '', errorMaxLines: 2),
    validator: (valor) {
      final texto = (valor ?? '').trim();
      if (obrigatorio && texto.isEmpty) {
        return 'Informe ${titulo.toLowerCase()}.';
      }
      if (chave == 'cep' && !RegExp(r'^\d{5}-\d{3}$').hasMatch(texto)) {
        return 'CEP com 8 dígitos.';
      }
      if (chave == 'estado' && !estadosEndereco.contains(texto.toUpperCase())) {
        return 'UF inválida.';
      }
      return null;
    },
    onChanged: (_) => onChanged?.call(chave),
  );

  @override
  Widget build(BuildContext context) => Column(
    children: [
      _campo(
        'rua',
        'Rua / avenida',
        dica: 'Nome da rua',
        icone: Icons.signpost_outlined,
        limite: 120,
        teclado: TextInputType.streetAddress,
      ),
      const SizedBox(height: 12),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: _campo('numero', 'Número', dica: '123 ou S/N', limite: 12),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: _campo(
              'cep',
              'CEP',
              dica: '00000-000',
              limite: 9,
              teclado: TextInputType.number,
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      _campo('bairro', 'Bairro', icone: Icons.holiday_village_outlined),
      const SizedBox(height: 12),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: _campo(
              'cidade',
              'Cidade',
              icone: Icons.location_city_outlined,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: _campo('estado', 'UF', dica: 'SP', limite: 2),
          ),
        ],
      ),
      const SizedBox(height: 12),
      _campo(
        'complemento',
        'Complemento / referência (opcional)',
        dica: 'Apartamento, bloco, portão...',
        icone: Icons.door_front_door_outlined,
        limite: 150,
        obrigatorio: false,
      ),
    ],
  );
}

class _MascaraCep extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digitos = newValue.text.replaceAll(RegExp(r'\D'), '');
    final texto = digitos.length > 5
        ? '${digitos.substring(0, 5)}-${digitos.substring(5)}'
        : digitos;
    final fim = newValue.selection.extentOffset.clamp(0, newValue.text.length);
    final antes = newValue.text
        .substring(0, fim)
        .replaceAll(RegExp(r'\D'), '')
        .length;
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(
        offset: (antes > 5 ? antes + 1 : antes).clamp(0, texto.length),
      ),
    );
  }
}
