import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'cartao_validacao.dart';
import 'firebase_service.dart';
import 'zeloo_ui.dart';

class AdicionarCartaoSheet extends StatefulWidget {
  const AdicionarCartaoSheet({super.key});

  @override
  State<AdicionarCartaoSheet> createState() => _AdicionarCartaoSheetState();
}

class _AdicionarCartaoSheetState extends State<AdicionarCartaoSheet> {
  final _form = GlobalKey<FormState>();
  final _numero = TextEditingController();
  final _titular = TextEditingController();
  final _validade = TextEditingController();
  final _cvv = TextEditingController();
  String _bandeira = 'Visa';
  bool _salvando = false;
  bool _mostrarCvv = false;
  String? _erro;

  @override
  void dispose() {
    _numero.dispose();
    _titular.dispose();
    _validade.dispose();
    _cvv.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_salvando || !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _salvando = true;
      _erro = null;
    });
    try {
      final numero = digitosCartao(_numero.text);
      // Apenas identificação: número completo e CVV nunca vão ao Firebase.
      // Uma cobrança real exige tokenizar o cartão com um provedor de pagamentos.
      await FirebaseService.alterarItemPrivado(
        'cartoes',
        adicionar: {
          'bandeira': _bandeira,
          'ultimos4': numero.substring(numero.length - 4),
          'titular': _titular.text.trim(),
          'validade': _validade.text,
          'demonstracao': true,
        },
      );
      _numero.clear();
      _cvv.clear();
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        setState(() => _erro = 'Não foi possível salvar. Tente novamente.');
      }
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
        8,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _form,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CabecalhoCampo(
              icon: Icons.credit_card_rounded,
              titulo: 'Adicionar cartão',
              descricao: 'Preencha os dados do cartão de demonstração.',
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: zelooGradiente,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.credit_card_rounded,
                        color: Colors.white,
                      ),
                      const Spacer(),
                      Text(
                        _bandeira,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    digitosCartao(_numero.text).length < 4
                        ? '••••  ••••  ••••  ••••'
                        : '••••  ••••  ••••  ${digitosCartao(_numero.text).substring(digitosCartao(_numero.text).length - 4)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _titular.text.trim().isEmpty
                              ? 'NOME DO TITULAR'
                              : _titular.text.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _validade.text.isEmpty ? 'MM/AA' : _validade.text,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: zelooSuave,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded, color: zelooAzul, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Modo TCC: use dados fictícios. Não há cobranças. '
                      'O número completo e o CVV não são salvos.',
                      style: TextStyle(
                        color: zelooAzul,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            DropdownButtonFormField<String>(
              initialValue: _bandeira,
              decoration: campoZeloo(
                'Bandeira',
                icon: Icons.credit_card_rounded,
              ),
              items:
                  const [
                        'Visa',
                        'Mastercard',
                        'Elo',
                        'American Express',
                        'Hipercard',
                        'Discover',
                        'Outra',
                      ]
                      .map(
                        (bandeira) => DropdownMenuItem(
                          value: bandeira,
                          child: Text(bandeira),
                        ),
                      )
                      .toList(),
              onChanged: _salvando
                  ? null
                  : (valor) => setState(() {
                      _bandeira = valor!;
                      _cvv.clear();
                    }),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _numero,
              enabled: !_salvando,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.next,
              enableSuggestions: false,
              autocorrect: false,
              inputFormatters: [_MascaraCartao(maximo: 19, grupo: 4)],
              decoration: campoZeloo(
                'Número do cartão',
                icon: Icons.credit_card_rounded,
              ).copyWith(hintText: '0000 0000 0000 0000'),
              onChanged: (_) => setState(() {}),
              validator: (valor) => numeroCartaoValido(valor ?? '')
                  ? null
                  : 'Informe um número de cartão válido.',
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _titular,
              enabled: !_salvando,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              maxLength: 80,
              textCapitalization: TextCapitalization.characters,
              textInputAction: TextInputAction.next,
              decoration: campoZeloo(
                'Nome do titular',
                icon: Icons.person_outline_rounded,
              ).copyWith(counterText: '', hintText: 'Como aparece no cartão'),
              onChanged: (_) => setState(() {}),
              validator: (valor) => (valor ?? '').trim().length >= 3
                  ? null
                  : 'Informe o nome do titular.',
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _validade,
                    enabled: !_salvando,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    inputFormatters: [
                      _MascaraCartao(maximo: 4, grupo: 2, separador: '/'),
                    ],
                    decoration: campoZeloo(
                      'Validade',
                    ).copyWith(hintText: 'MM/AA', errorMaxLines: 2),
                    onChanged: (_) => setState(() {}),
                    validator: (valor) => validadeCartaoValida(valor ?? '')
                        ? null
                        : 'Validade inválida ou vencida.',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _cvv,
                    enabled: !_salvando,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    obscureText: !_mostrarCvv,
                    enableSuggestions: false,
                    autocorrect: false,
                    maxLength: _bandeira == 'American Express' ? 4 : 3,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: campoZeloo('CVV').copyWith(
                      counterText: '',
                      hintText: _bandeira == 'American Express'
                          ? '4 dígitos'
                          : '3 dígitos',
                      suffixIcon: IconButton(
                        tooltip: _mostrarCvv ? 'Ocultar CVV' : 'Mostrar CVV',
                        onPressed: () =>
                            setState(() => _mostrarCvv = !_mostrarCvv),
                        icon: Icon(
                          _mostrarCvv
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                          color: zelooAzul,
                        ),
                      ),
                    ),
                    validator: (valor) =>
                        cvvCartaoValido(valor ?? '', _bandeira)
                        ? null
                        : 'CVV inválido.',
                    onFieldSubmitted: (_) => _salvar(),
                  ),
                ),
              ],
            ),
            if (_erro != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(_erro!, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 20),
            BotaoZeloo(
              onPressed: _salvando ? null : _salvar,
              icon: Icons.check_rounded,
              texto: _salvando
                  ? 'Salvando...'
                  : 'Salvar cartão de demonstração',
            ),
          ],
        ),
      ),
    ),
  );
}

// Limita os dígitos, formata e mantém o cursor próximo ao ponto editado.
class _MascaraCartao extends TextInputFormatter {
  final int maximo;
  final int grupo;
  final String separador;
  _MascaraCartao({
    required this.maximo,
    required this.grupo,
    this.separador = ' ',
  });

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var numero = digitosCartao(newValue.text);
    if (numero.length > maximo) numero = numero.substring(0, maximo);
    final partes = <String>[];
    for (var i = 0; i < numero.length; i += grupo) {
      partes.add(numero.substring(i, (i + grupo).clamp(0, numero.length)));
    }
    final texto = partes.join(separador);
    final fim = newValue.selection.extentOffset.clamp(0, newValue.text.length);
    final antes = digitosCartao(
      newValue.text.substring(0, fim),
    ).length.clamp(0, numero.length);
    final posicao = antes == 0 ? 0 : antes + (antes - 1) ~/ grupo;
    return TextEditingValue(
      text: texto,
      selection: TextSelection.collapsed(
        offset: posicao.clamp(0, texto.length),
      ),
    );
  }
}
