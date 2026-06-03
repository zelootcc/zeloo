import 'package:flutter/material.dart';
import 'mock_data.dart';

class PerfilEditarScreen extends StatefulWidget {
  const PerfilEditarScreen({super.key});

  @override
  State<PerfilEditarScreen> createState() => _PerfilEditarScreenState();
}

class _PerfilEditarScreenState extends State<PerfilEditarScreen> {
  late final TextEditingController _nomeCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _telefoneCtrl;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nomeCtrl = TextEditingController(text: ClienteLogado.nome);
    _emailCtrl = TextEditingController(text: ClienteLogado.email);
    _telefoneCtrl = TextEditingController(text: ClienteLogado.telefone);
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _telefoneCtrl.dispose();
    super.dispose();
  }

  void _salvar() {
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
    Future.delayed(const Duration(milliseconds: 1200), () {
      ClienteLogado.nome = _nomeCtrl.text.trim();
      ClienteLogado.email = _emailCtrl.text.trim();
      ClienteLogado.telefone = _telefoneCtrl.text.trim();
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Perfil atualizado!'),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      Navigator.pop(context);
    });
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
    final iniciais = ClienteLogado.nome
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
              child: Stack(
                children: [
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00C6D7), Color(0xFF0077B6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: const Color(0xFF00C6D7),
                        width: 2,
                      ),
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
                ],
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
