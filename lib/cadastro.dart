import 'package:flutter/material.dart';

class CadastroScreen extends StatefulWidget {
  final bool isProfissional;
  const CadastroScreen({super.key, this.isProfissional = false});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}
 
class _CadastroScreenState extends State<CadastroScreen> {
  late bool _isPro;

  final _emailCtrl = TextEditingController();
  final _telefoneCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _confirmarCtrl = TextEditingController();
  final _nomeCtrl = TextEditingController();
  final _cpfCnpjCtrl = TextEditingController();
  final _nascimentoCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _regiaoCtrl = TextEditingController();
  final _disponibilidadeCtrl = TextEditingController();
  final _pagamentoCtrl = TextEditingController();

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
    _emailCtrl.dispose();
    _telefoneCtrl.dispose();
    _senhaCtrl.dispose();
    _confirmarCtrl.dispose();
    _nomeCtrl.dispose();
    _cpfCnpjCtrl.dispose();
    _nascimentoCtrl.dispose();
    _areaCtrl.dispose();
    _regiaoCtrl.dispose();
    _disponibilidadeCtrl.dispose();
    _pagamentoCtrl.dispose();
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
    if (d.length <= 11)
      return '(${d.substring(0, 2)}) ${d.substring(2, 7)}-${d.substring(7)}';
    return val;
  }

  String _formatCpfCnpj(String val) {
    final d = val.replaceAll(RegExp(r'\D'), '');
    if (d.length <= 11) {
      if (d.length <= 3) return d;
      if (d.length <= 6) return '${d.substring(0, 3)}.${d.substring(3)}';
      if (d.length <= 9)
        return '${d.substring(0, 3)}.${d.substring(3, 6)}.${d.substring(6)}';
      return '${d.substring(0, 3)}.${d.substring(3, 6)}.${d.substring(6, 9)}-${d.substring(9)}';
    } else {
      if (d.length <= 12)
        return '${d.substring(0, 2)}.${d.substring(2, 5)}.${d.substring(5, 8)}/${d.substring(8)}';
      return '${d.substring(0, 2)}.${d.substring(2, 5)}.${d.substring(5, 8)}/${d.substring(8, 12)}-${d.substring(12, d.length.clamp(0, 14))}';
    }
  }

  String _formatData(String val) {
    final d = val.replaceAll(RegExp(r'\D'), '');
    if (d.length <= 2) return d;
    if (d.length <= 4) return '${d.substring(0, 2)}/${d.substring(2)}';
    return '${d.substring(0, 2)}/${d.substring(2, 4)}/${d.substring(4, d.length.clamp(0, 8))}';
  }

  void _handleCadastrar() {
    setState(() => _erro = '');

    if (_emailCtrl.text.isEmpty ||
        _telefoneCtrl.text.isEmpty ||
        _senhaCtrl.text.isEmpty) {
      setState(() => _erro = 'Preencha todos os campos obrigatórios.');
      return;
    }
    if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(_emailCtrl.text)) {
      setState(() => _erro = 'Digite um email válido.');
      return;
    }
    if (_isPro &&
        (_nomeCtrl.text.isEmpty ||
            _cpfCnpjCtrl.text.isEmpty ||
            _nascimentoCtrl.text.isEmpty ||
            _areaCtrl.text.isEmpty ||
            _regiaoCtrl.text.isEmpty)) {
      setState(() => _erro = 'Preencha todos os campos obrigatórios.');
      return;
    }
    if (!_senhaValida) {
      setState(() => _erro = 'Senha não atende aos requisitos.');
      return;
    }
    if (!_senhasIguais) {
      setState(() => _erro = 'As senhas não são iguais.');
      return;
    }

    setState(() => _loading = true);
    Future.delayed(const Duration(milliseconds: 1500), () {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastro realizado com sucesso!')),
      );
      Navigator.pop(context);
    });
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
                  if (f != v)
                    _telefoneCtrl.value = TextEditingValue(
                      text: f,
                      selection: TextSelection.collapsed(offset: f.length),
                    );
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
          child: Row(
            children: const [
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

        _label('Nome completo *'),
        const SizedBox(height: 6),
        _buildField(controller: _nomeCtrl, prefixIcon: Icons.person_outline),
        const SizedBox(height: 16),

        _label('CPF ou CNPJ *'),
        const SizedBox(height: 6),
        _buildField(
          controller: _cpfCnpjCtrl,
          keyboardType: TextInputType.number,
          prefixIcon: Icons.badge_outlined,
          onChanged: (v) {
            final f = _formatCpfCnpj(v);
            if (f != v)
              _cpfCnpjCtrl.value = TextEditingValue(
                text: f,
                selection: TextSelection.collapsed(offset: f.length),
              );
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
            if (f != v)
              _nascimentoCtrl.value = TextEditingValue(
                text: f,
                selection: TextSelection.collapsed(offset: f.length),
              );
          },
        ),
        const SizedBox(height: 16),

        _label('Área de atuação *'),
        const SizedBox(height: 6),
        _buildField(
          controller: _areaCtrl,
          prefixIcon: Icons.work_outline,
          hint: 'Ex.: Eletricista, Mecânico...',
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
        _buildField(
          controller: _disponibilidadeCtrl,
          prefixIcon: Icons.schedule_outlined,
          hint: 'Ex.: Segunda a Sexta, 8h–18h',
        ),
        const SizedBox(height: 16),

        _label('Formas de pagamento'),
        const SizedBox(height: 6),
        _buildField(
          controller: _pagamentoCtrl,
          prefixIcon: Icons.payments_outlined,
          hint: 'Ex.: PIX, Dinheiro, Cartão',
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
    Color focusBorderColor = const Color(0xFF00B4D8),
    ValueChanged<String>? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
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
