import 'package:flutter/material.dart';

class PerfilNotificacoesScreen extends StatefulWidget {
  final bool abaSeguranca;

  const PerfilNotificacoesScreen({super.key, this.abaSeguranca = false});

  @override
  State<PerfilNotificacoesScreen> createState() =>
      _PerfilNotificacoesScreenState();
}

class _PerfilNotificacoesScreenState extends State<PerfilNotificacoesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  bool _email = true;
  bool _sms = true;
  bool _atualizacoes = true;
  bool _segurancaNotif = true;

  final _senhaAtualCtrl = TextEditingController();
  final _novaSenhaCtrl = TextEditingController();
  final _confirmarCtrl = TextEditingController();
  bool _showSenhaAtual = false;
  bool _showNovaSenha = false;
  bool _showConfirmar = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.abaSeguranca ? 1 : 0,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _senhaAtualCtrl.dispose();
    _novaSenhaCtrl.dispose();
    _confirmarCtrl.dispose();
    super.dispose();
  }

  void _salvarSenha() {
    if (_senhaAtualCtrl.text.isEmpty ||
        _novaSenhaCtrl.text.isEmpty ||
        _confirmarCtrl.text.isEmpty) {
      _snack('Preencha todos os campos.', erro: true);
      return;
    }
    if (_novaSenhaCtrl.text != _confirmarCtrl.text) {
      _snack('As senhas não coincidem.', erro: true);
      return;
    }
    if (_novaSenhaCtrl.text.length < 8) {
      _snack('A nova senha deve ter pelo menos 8 caracteres.', erro: true);
      return;
    }
    setState(() => _loading = true);
    Future.delayed(const Duration(milliseconds: 1200), () {
      setState(() => _loading = false);
      _senhaAtualCtrl.clear();
      _novaSenhaCtrl.clear();
      _confirmarCtrl.clear();
      _snack('Senha alterada com sucesso!');
    });
  }

  void _snack(String msg, {bool erro = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: erro
            ? const Color(0xFFE53E3E)
            : const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: _AppBarComTabs(
        titulo: 'Configurações',
        subtitulo: 'Gerencie suas preferências',
        tabController: _tabController,
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_AbaNotificacoes(), _AbaSeguranca()],
      ),
    );
  }

  Widget _AbaNotificacoes() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 8),
        _ItemToggle(
          titulo: 'Email',
          subtitulo: 'Atualizações por email',
          valor: _email,
          onChanged: (v) => setState(() => _email = v),
        ),
        _ItemToggle(
          titulo: 'SMS',
          subtitulo: 'Mensagens via SMS',
          valor: _sms,
          onChanged: (v) => setState(() => _sms = v),
        ),
        _ItemToggle(
          titulo: 'Atualizações',
          subtitulo: 'Novidades e recursos',
          valor: _atualizacoes,
          onChanged: (v) => setState(() => _atualizacoes = v),
        ),
        _ItemToggle(
          titulo: 'Segurança',
          subtitulo: 'Alertas importantes',
          valor: _segurancaNotif,
          onChanged: (v) => setState(() => _segurancaNotif = v),
        ),
      ],
    );
  }

  Widget _AbaSeguranca() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 8),
        const Text(
          'Alterar senha',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 16),
        _CampoSenha(
          label: 'Senha atual',
          controller: _senhaAtualCtrl,
          visivel: _showSenhaAtual,
          onToggle: () => setState(() => _showSenhaAtual = !_showSenhaAtual),
        ),
        const SizedBox(height: 16),
        _CampoSenha(
          label: 'Nova senha',
          controller: _novaSenhaCtrl,
          visivel: _showNovaSenha,
          onToggle: () => setState(() => _showNovaSenha = !_showNovaSenha),
        ),
        const SizedBox(height: 16),
        _CampoSenha(
          label: 'Confirmar nova senha',
          controller: _confirmarCtrl,
          visivel: _showConfirmar,
          onToggle: () => setState(() => _showConfirmar = !_showConfirmar),
        ),
        const SizedBox(height: 28),
        GestureDetector(
          onTap: _loading ? null : _salvarSenha,
          child: Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'Salvar senha',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _DivisorSecao('Autenticação em dois fatores'),
        const SizedBox(height: 12),
        _ItemToggleSimples(
          titulo: 'Autenticação 2FA',
          subtitulo: 'Código por SMS ao entrar',
        ),
      ],
    );
  }
}

class _ItemToggle extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final bool valor;
  final ValueChanged<bool> onChanged;

  const _ItemToggle({
    required this.titulo,
    required this.subtitulo,
    required this.valor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitulo,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Switch(
            value: valor,
            onChanged: onChanged,
            activeColor: const Color(0xFF0077B6),
            activeTrackColor: const Color(0xFF00C6D7).withOpacity(0.4),
          ),
        ],
      ),
    );
  }
}

class _ItemToggleSimples extends StatefulWidget {
  final String titulo;
  final String subtitulo;

  const _ItemToggleSimples({required this.titulo, required this.subtitulo});

  @override
  State<_ItemToggleSimples> createState() => _ItemToggleSimplesState();
}

class _ItemToggleSimplesState extends State<_ItemToggleSimples> {
  bool _valor = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.titulo,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.subtitulo,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Switch(
            value: _valor,
            onChanged: (v) => setState(() => _valor = v),
            activeColor: const Color(0xFF0077B6),
            activeTrackColor: const Color(0xFF00C6D7).withOpacity(0.4),
          ),
        ],
      ),
    );
  }
}

class _CampoSenha extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool visivel;
  final VoidCallback onToggle;

  const _CampoSenha({
    required this.label,
    required this.controller,
    required this.visivel,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1A1A2E),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: !visivel,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                visivel
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey[400],
                size: 20,
              ),
              onPressed: onToggle,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF00C6D7), width: 2),
            ),
          ),
        ),
      ],
    );
  }
}

Widget _DivisorSecao(String texto) {
  return Row(
    children: [
      Expanded(child: Divider(color: Colors.grey[200])),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Text(
          texto,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[400],
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      Expanded(child: Divider(color: Colors.grey[200])),
    ],
  );
}

class _AppBarComTabs extends StatelessWidget implements PreferredSizeWidget {
  final String titulo;
  final String subtitulo;
  final TabController tabController;

  const _AppBarComTabs({
    required this.titulo,
    required this.subtitulo,
    required this.tabController,
  });

  @override
  Size get preferredSize => const Size.fromHeight(110);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00C6D7), Color(0xFF0077B6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.chevron_left_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        subtitulo,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            TabBar(
              controller: tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
              tabs: const [
                Tab(text: 'Notificações'),
                Tab(text: 'Segurança'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
