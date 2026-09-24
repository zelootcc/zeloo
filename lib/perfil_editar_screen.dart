import 'package:flutter/material.dart';
import 'firebase_service.dart';

class PerfilEditarScreen extends StatefulWidget {
  const PerfilEditarScreen({super.key});

  @override
  State<PerfilEditarScreen> createState() => _PerfilEditarScreenState();
}

class _PerfilEditarScreenState extends State<PerfilEditarScreen> {
  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telefoneCtrl = TextEditingController();
  bool _carregando = true;
  bool _loading = false;
  bool _erroCarregamento = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erroCarregamento = false;
    });
    try {
      final doc = await FirebaseService.dadosUsuario();
      if (!mounted) return;
      if (doc == null || !doc.exists) throw Exception('Perfil não encontrado.');
      final d = doc.data() ?? {};
      _nomeCtrl.text = d['nome']?.toString() ?? '';
      _emailCtrl.text =
          FirebaseService.usuario?.email ?? d['email']?.toString() ?? '';
      _telefoneCtrl.text = d['telefone']?.toString() ?? '';
    } catch (_) {
      if (mounted) setState(() => _erroCarregamento = true);
    }
    if (mounted) setState(() => _carregando = false);
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _telefoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (_loading) return;
    if (_nomeCtrl.text.trim().isEmpty) {
      _mostrarErro('Informe seu nome.');
      return;
    }
    final emailRegex = RegExp(r'^\S+@\S+\.\S+$');
    if (!emailRegex.hasMatch(_emailCtrl.text)) {
      _mostrarErro('Informe um e-mail válido.');
      return;
    }
    setState(() => _loading = true);
    try {
      final email = _emailCtrl.text.trim();
      final usuario = FirebaseService.usuario;
      final emailAlterado = usuario != null && email != usuario.email;
      if (emailAlterado) await usuario.verifyBeforeUpdateEmail(email);
      await FirebaseService.atualizarUsuario({
        'nome': _nomeCtrl.text.trim(),
        'email': usuario?.email ?? email,
        'telefone': _telefoneCtrl.text.trim(),
      });
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            emailAlterado
                ? 'Perfil atualizado! Confirme o novo e-mail pelo link enviado antes de usá-lo para entrar.'
                : 'Perfil atualizado!',
          ),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _mostrarErro('Não foi possível salvar: $e');
    }
  }

  void _mostrarErro(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: const Color(0xFFE53E3E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_erroCarregamento) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar perfil')),
        body: Center(
          child: TextButton(
            onPressed: _carregar,
            child: const Text('Não foi possível carregar. Tentar novamente'),
          ),
        ),
      );
    }
    if (_carregando) {
      return const Scaffold(
        backgroundColor: Color(0xFFF4F7FB),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final iniciais = _nomeCtrl.text
        .trim()
        .split(' ')
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBarGradiente(
        titulo: 'Configurações',
        subtitulo: 'Gerencie suas preferências',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00C6D7), Color(0xFF0077B6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: const Color(0xFF00C6D7), width: 2),
                ),
                child: Center(
                  child: Text(
                    iniciais,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 30,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _BotaoFoto(label: 'Alterar Foto', onTap: () {}),
                const SizedBox(width: 12),
                _BotaoFoto(label: 'Remover Foto', onTap: () {}, outline: true),
              ],
            ),
            const SizedBox(height: 32),
            _CampoLabel('Nome Completo'),
            const SizedBox(height: 8),
            _Campo(controller: _nomeCtrl, hint: 'Seu nome completo'),
            const SizedBox(height: 20),
            _CampoLabel('Email'),
            const SizedBox(height: 8),
            _Campo(
              controller: _emailCtrl,
              hint: 'seu@email.com',
              tipo: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            _CampoLabel('Telefone'),
            const SizedBox(height: 8),
            _Campo(
              controller: _telefoneCtrl,
              hint: '(00) 00000-0000',
              tipo: TextInputType.phone,
            ),
            const SizedBox(height: 36),
            _BotaoSalvar(loading: _loading, onTap: _salvar),
          ],
        ),
      ),
    );
  }
}

class _BotaoFoto extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final bool outline;

  const _BotaoFoto({
    required this.label,
    required this.onTap,
    this.outline = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: outline
              ? Colors.transparent
              : const Color(0xFF0077B6).withOpacity(0.1),
          border: Border.all(
            color: const Color(0xFF0077B6).withOpacity(outline ? 0.4 : 0),
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: outline ? Colors.grey[500] : const Color(0xFF0077B6),
          ),
        ),
      ),
    );
  }
}

Widget _CampoLabel(String text) {
  return Align(
    alignment: Alignment.centerLeft,
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1A2E),
      ),
    ),
  );
}

class _Campo extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType tipo;

  const _Campo({
    required this.controller,
    required this.hint,
    this.tipo = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: tipo,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
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
    );
  }
}

class _BotaoSalvar extends StatelessWidget {
  final bool loading;
  final VoidCallback onTap;

  const _BotaoSalvar({required this.loading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: loading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Text(
                  'Editar Perfil',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}

class AppBarGradiente extends StatelessWidget implements PreferredSizeWidget {
  final String titulo;
  final String subtitulo;

  const AppBarGradiente({required this.titulo, required this.subtitulo});

  @override
  Size get preferredSize => const Size.fromHeight(80);

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
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
                mainAxisAlignment: MainAxisAlignment.center,
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
      ),
    );
  }
}
