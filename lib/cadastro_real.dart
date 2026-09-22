import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CadastroScreen extends StatefulWidget {
  final bool isProfissional;
  const CadastroScreen({super.key, this.isProfissional = false});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  late bool _isPro;

  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telefoneCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _confirmarCtrl = TextEditingController();
  final _cpfCnpjCtrl = TextEditingController();
  final _nascimentoCtrl = TextEditingController();
  final _regiaoCtrl = TextEditingController();
  final _descricaoCtrl = TextEditingController();
  final _precoCtrl = TextEditingController();

  static const _areas = [
    'Eletricista',
    'Encanador',
    'Mecânico',
    'Pintor',
    'Diarista',
    'Jardineiro',
    'Marceneiro',
    'Pedreiro',
    'Serviços Gerais',
  ];

  static const _disponibilidades = [
    'Segunda a Sexta, 8h–18h',
    'Segunda a Sábado, 8h–18h',
    'Finais de semana',
    'Período integral (todos os dias)',
    'Sob consulta',
  ];

  static const _pagamentos = [
    'PIX',
    'Dinheiro',
    'Cartão de Crédito',
    'Cartão de Débito',
    'Boleto',
  ];

  String? _area;
  String? _disponibilidade;
  String? _pagamento;

  bool _showSenha = false;
  bool _showConfirmar = false;
  bool _loading = false;
  String _erro = '';

  @override
  void initState() {
    super.initState();
    _isPro = widget.isProfissional;
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _telefoneCtrl.dispose();
    _senhaCtrl.dispose();
    _confirmarCtrl.dispose();
    _cpfCnpjCtrl.dispose();
    _nascimentoCtrl.dispose();
    _regiaoCtrl.dispose();
    _descricaoCtrl.dispose();
    _precoCtrl.dispose();
    super.dispose();
  }

  bool get _temMinCaracteres => _senhaCtrl.text.length >= 8;
  bool get _temMaiuscula => _senhaCtrl.text.contains(RegExp(r'[A-Z]'));
  bool get _temNumero => _senhaCtrl.text.contains(RegExp(r'[0-9]'));
  bool get _temEspecial => _senhaCtrl.text.contains(RegExp(r'[^A-Za-z0-9]'));
  bool get _senhaValida =>
      _temMinCaracteres && _temMaiuscula && _temNumero && _temEspecial;
  bool get _senhasIguais =>
      _confirmarCtrl.text == _senhaCtrl.text && _senhaCtrl.text.isNotEmpty;

  Color _barColor(int index) {
    final score = [
      _temMinCaracteres,
      _temMaiuscula,
      _temNumero,
      _temEspecial,
    ].where((v) => v).length;
    if (index >= score) return const Color(0xFFE0E0E0);
    const colors = [
      Color(0xFFEF4444),
      Color(0xFFF97316),
      Color(0xFFEAB308),
      Color(0xFF22C55E),
    ];
    return colors[score - 1];
  }

  String _formatTelefone(String val) {
    final d = val.replaceAll(RegExp(r'\D'), '');
    if (d.length <= 2) return d;
    if (d.length <= 7) return '(${d.substring(0, 2)}) ${d.substring(2)}';
    if (d.length <= 11) {
      return '(${d.substring(0, 2)}) ${d.substring(2, 7)}-${d.substring(7)}';
    }
    return val;
  }

  String _formatCpfCnpj(String val) {
    final d = val.replaceAll(RegExp(r'\D'), '');
    if (d.length <= 11) {
      if (d.length <= 3) return d;
      if (d.length <= 6) return '${d.substring(0, 3)}.${d.substring(3)}';
      if (d.length <= 9) {
        return '${d.substring(0, 3)}.${d.substring(3, 6)}.${d.substring(6)}';
      }
      return '${d.substring(0, 3)}.${d.substring(3, 6)}.${d.substring(6, 9)}-${d.substring(9)}';
    }
    if (d.length <= 12) {
      return '${d.substring(0, 2)}.${d.substring(2, 5)}.${d.substring(5, 8)}/${d.substring(8)}';
    }
    return '${d.substring(0, 2)}.${d.substring(2, 5)}.${d.substring(5, 8)}/${d.substring(8, 12)}-${d.substring(12, d.length.clamp(0, 14))}';
  }

  String _formatData(String val) {
    final d = val.replaceAll(RegExp(r'\D'), '');
    if (d.length <= 2) return d;
    if (d.length <= 4) return '${d.substring(0, 2)}/${d.substring(2)}';
    return '${d.substring(0, 2)}/${d.substring(2, 4)}/${d.substring(4, d.length.clamp(0, 8))}';
  }

  Future<void> _handleCadastrar() async {
    setState(() => _erro = '');

    if (_nomeCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _telefoneCtrl.text.trim().isEmpty ||
        _senhaCtrl.text.isEmpty) {
      setState(() => _erro = 'Preencha todos os campos obrigatórios.');
      return;
    }
    if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(_emailCtrl.text.trim())) {
      setState(() => _erro = 'Digite um email válido.');
      return;
    }
    if (_isPro &&
        (_cpfCnpjCtrl.text.trim().isEmpty ||
            _nascimentoCtrl.text.trim().isEmpty ||
            _area == null ||
            _regiaoCtrl.text.trim().isEmpty)) {
      setState(() => _erro = 'Preencha todos os dados profissionais.');
      return;
    }
    if (!_senhaValida) {
      setState(() => _erro = 'A senha não atende aos requisitos.');
      return;
    }
    if (!_senhasIguais) {
      setState(() => _erro = 'As senhas não são iguais.');
      return;
    }

    setState(() => _loading = true);
    UserCredential? cred;

    try {
      cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailCtrl.text.trim(),
        password: _senhaCtrl.text,
      );

      final uid = cred.user!.uid;
      final colecao = _isPro ? 'Profissionais' : 'Clientes';
      final dados = <String, dynamic>{
        'uid': uid,
        'nome': _nomeCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'telefone': _telefoneCtrl.text.trim(),
        'tipoConta': _isPro ? 'profissional' : 'cliente',
        'criadoEm': FieldValue.serverTimestamp(),
        'atualizadoEm': FieldValue.serverTimestamp(),
      };

      if (_isPro) {
        dados.addAll({
          'cpfCnpj': _cpfCnpjCtrl.text.trim(),
          'nascimento': _nascimentoCtrl.text.trim(),
          'area': _area,
          'especialidade': _area,
          'regiao': _regiaoCtrl.text.trim(),
          'cidade': _regiaoCtrl.text.trim(),
          'disponibilidade': _disponibilidade ?? 'Sob consulta',
          'pagamento': _pagamento ?? 'PIX',
          'descricao': _descricaoCtrl.text.trim(),
          'precoHora':
              double.tryParse(_precoCtrl.text.trim().replaceAll(',', '.')) ??
                  0.0,
          'disponivel': true,
          'avaliacao': 0.0,
          'totalAvaliacoes': 0,
        });
      }

      await FirebaseFirestore.instance.collection(colecao).doc(uid).set(dados);

      if (!mounted) return;
      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastro realizado com sucesso!')),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (cred?.user != null) {
        try {
          await cred!.user!.delete();
        } catch (_) {}
      }

      if (!mounted) return;
      setState(() {
        _loading = false;
        if (e.code == 'email-already-in-use') {
          _erro = 'Este email já está cadastrado.';
        } else if (e.code == 'invalid-email') {
          _erro = 'Digite um email válido.';
        } else if (e.code == 'weak-password') {
          _erro = 'A senha é muito fraca.';
        } else {
          _erro = 'Erro ao criar conta: ${e.message ?? e.code}';
        }
      });
    } catch (e) {
      if (cred?.user != null) {
        try {
          await cred!.user!.delete();
        } catch (_) {}
      }

      if (!mounted) return;
      setState(() {
        _loading = false;
        _erro = 'Erro ao salvar cadastro: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              Center(
                child: Image.asset(
                  'assets/imagens/logo.png',
                  width: 80,
                  height: 80,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Cadastro',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111111),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Escolha como deseja se cadastrar',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
              ),
              const SizedBox(height: 20),

              _toggle(),
              const SizedBox(height: 24),

              _label('Nome completo *'),
              const SizedBox(height: 6),
              _buildField(
                controller: _nomeCtrl,
                prefixIcon: Icons.person_outline,
              ),
              const SizedBox(height: 16),

              _label('Email *'),
              const SizedBox(height: 6),
              _buildField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
              ),
              const SizedBox(height: 16),

              _label('Telefone *'),
              const SizedBox(height: 6),
              _buildField(
                controller: _telefoneCtrl,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_outlined,
                onChanged: (v) {
                  final f = _formatTelefone(v);
                  if (f != v) {
                    _telefoneCtrl.value = TextEditingValue(
                      text: f,
                      selection: TextSelection.collapsed(offset: f.length),
                    );
                  }
                },
              ),
              const SizedBox(height: 16),

              AnimatedSize(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeInOut,
                child: _isPro ? _camposColaborador() : const SizedBox.shrink(),
              ),

              _label('Senha *'),
              const SizedBox(height: 6),
              _buildField(
                controller: _senhaCtrl,
                obscureText: !_showSenha,
                prefixIcon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(
                    _showSenha ? Icons.visibility_off : Icons.visibility,
                    color: const Color(0xFF888888),
                  ),
                  onPressed: () => setState(() => _showSenha = !_showSenha),
                ),
                onChanged: (_) => setState(() {}),
              ),

              if (_senhaCtrl.text.isNotEmpty) ...[
                const SizedBox(height: 10),
                Row(
                  children: List.generate(
                    4,
                    (i) => Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: i < 3 ? 4 : 0),
                        height: 4,
                        decoration: BoxDecoration(
                          color: _barColor(i),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Requisitos da senha:',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF888888),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _reqItem('8 ou mais caracteres', _temMinCaracteres),
                      _reqItem('Uma letra maiúscula', _temMaiuscula),
                      _reqItem('Um número', _temNumero),
                      _reqItem('Um caractere especial', _temEspecial),
                    ],
                  ),
                ),
              ],

              AnimatedSize(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                child: _senhaValida
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          _label('Confirme sua senha *'),
                          const SizedBox(height: 6),
                          _buildField(
                            controller: _confirmarCtrl,
                            obscureText: !_showConfirmar,
                            prefixIcon: Icons.lock_reset_outlined,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _showConfirmar
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: const Color(0xFF888888),
                              ),
                              onPressed: () => setState(
                                () => _showConfirmar = !_showConfirmar,
                              ),
                            ),
                            focusBorderColor: _confirmarCtrl.text.isEmpty
                                ? const Color(0xFF00B4D8)
                                : _senhasIguais
                                ? const Color(0xFF22C55E)
                                : const Color(0xFFEF4444),
                            onChanged: (_) => setState(() {}),
                          ),
                          if (_confirmarCtrl.text.isNotEmpty && !_senhasIguais)
                            const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text(
                                'As senhas não coincidem',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFEF4444),
                                ),
                              ),
                            ),
                        ],
                      )
                    : const SizedBox.shrink(),
              ),

              if (_erro.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF5F5),
                    border: Border.all(color: const Color(0xFFFED7D7)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _erro,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFFEF4444),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),

              Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00B4D8), Color(0xFF0077B6)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _handleCadastrar,
                  icon: _loading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Icon(
                          Icons.person_add_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                  label: _loading
                      ? const SizedBox.shrink()
                      : const Text(
                          'Cadastrar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Já tem uma conta? ',
                    style: TextStyle(fontSize: 14, color: Color(0xFF555555)),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      'Entrar',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF00B4D8),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _toggle() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8E8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _tab('Cliente', !_isPro, () => setState(() => _isPro = false)),
          _tab('Colaborador', _isPro, () => setState(() => _isPro = true)),
        ],
      ),
    );
  }

  Widget _tab(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: selected
                  ? const Color(0xFF0077B6)
                  : const Color(0xFF888888),
            ),
          ),
        ),
      ),
    );
  }

  Widget _camposColaborador() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 20),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF9FB),
            border: Border.all(color: const Color(0xFF00B4D8).withOpacity(0.4)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: Color(0xFF0077B6), size: 18),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Como colaborador, precisamos de dados adicionais para verificar sua identidade.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF0077B6)),
                ),
              ),
            ],
          ),
        ),

        _label('CPF ou CNPJ *'),
        const SizedBox(height: 6),
        _buildField(
          controller: _cpfCnpjCtrl,
          keyboardType: TextInputType.number,
          prefixIcon: Icons.badge_outlined,
          onChanged: (v) {
            final f = _formatCpfCnpj(v);
            if (f != v) {
              _cpfCnpjCtrl.value = TextEditingValue(
                text: f,
                selection: TextSelection.collapsed(offset: f.length),
              );
            }
          },
        ),
        const SizedBox(height: 16),

        _label('Data de nascimento *'),
        const SizedBox(height: 6),
        _buildField(
          controller: _nascimentoCtrl,
          keyboardType: TextInputType.number,
          prefixIcon: Icons.cake_outlined,
          hint: 'DD/MM/AAAA',
          onChanged: (v) {
            final f = _formatData(v);
            if (f != v) {
              _nascimentoCtrl.value = TextEditingValue(
                text: f,
                selection: TextSelection.collapsed(offset: f.length),
              );
            }
          },
        ),
        const SizedBox(height: 16),

        _label('Área de atuação *'),
        const SizedBox(height: 6),
        _buildDropdown(
          valor: _area,
          itens: _areas,
          prefixIcon: Icons.work_outline,
          onChanged: (v) => setState(() => _area = v),
        ),
        const SizedBox(height: 16),

        _label('Região de atendimento *'),
        const SizedBox(height: 6),
        _buildField(
          controller: _regiaoCtrl,
          prefixIcon: Icons.location_on_outlined,
          hint: 'Ex.: São José dos Campos',
        ),
        const SizedBox(height: 16),

        _label('Disponibilidade'),
        const SizedBox(height: 6),
        _buildDropdown(
          valor: _disponibilidade,
          itens: _disponibilidades,
          prefixIcon: Icons.schedule_outlined,
          onChanged: (v) => setState(() => _disponibilidade = v),
        ),
        const SizedBox(height: 16),

        _label('Forma de pagamento'),
        const SizedBox(height: 6),
        _buildDropdown(
          valor: _pagamento,
          itens: _pagamentos,
          prefixIcon: Icons.payments_outlined,
          onChanged: (v) => setState(() => _pagamento = v),
        ),
        const SizedBox(height: 16),

        _label('Valor por hora (R\$)'),
        const SizedBox(height: 6),
        _buildField(
          controller: _precoCtrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          prefixIcon: Icons.attach_money_rounded,
          hint: 'Ex.: 80',
        ),
        const SizedBox(height: 16),

        _label('Descrição'),
        const SizedBox(height: 6),
        _buildField(
          controller: _descricaoCtrl,
          prefixIcon: Icons.description_outlined,
          hint: 'Conte um pouco sobre sua experiência...',
          linhas: 3,
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Color(0xFF333333),
    ),
  );

  Widget _buildField({
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
    String? hint,
    int linhas = 1,
    Color focusBorderColor = const Color(0xFF00B4D8),
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: obscureText ? 1 : linhas,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFE8E8E8),
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF888888), size: 20),
        suffixIcon: suffixIcon,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: focusBorderColor, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }

  Widget _buildDropdown({
    required String? valor,
    required List<String> itens,
    required IconData prefixIcon,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: valor,
      isExpanded: true,
      onChanged: onChanged,
      borderRadius: BorderRadius.circular(12),
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Color(0xFF888888),
      ),
      decoration: InputDecoration(
        hintText: 'Selecione',
        hintStyle: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFE8E8E8),
        prefixIcon: Icon(prefixIcon, color: const Color(0xFF888888), size: 20),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00B4D8), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 14),
      ),
      items: itens
          .map(
            (item) => DropdownMenuItem(
              value: item,
              child: Text(item, overflow: TextOverflow.ellipsis),
            ),
          )
          .toList(),
    );
  }

  Widget _reqItem(String label, bool ok) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: ok ? const Color(0xFF22C55E) : const Color(0xFFE0E0E0),
              shape: BoxShape.circle,
            ),
            child: ok
                ? const Icon(Icons.check, size: 10, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: ok ? const Color(0xFF22C55E) : const Color(0xFF888888),
              fontWeight: ok ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
