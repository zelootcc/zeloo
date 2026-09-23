import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'cadastro_real.dart';
import 'home_profissional_screen.dart';
import 'redefinir_senha_screen.dart';
import 'shell_cliente.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {
  final email = TextEditingController();
  final senha = TextEditingController();

  bool visivel = false;
  bool loading = false;
  String erro = '';

  Future<void> entrar() async {
    setState(() => erro = '');

    if (email.text.trim().isEmpty || senha.text.isEmpty) {
      setState(() => erro = 'Preencha todos os campos.');
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
        .hasMatch(email.text.trim())) {
      setState(() => erro = 'Digite um e-mail válido.');
      return;
    }

    setState(() => loading = true);

    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text.trim(),
        password: senha.text,
      );

      final uid = cred.user!.uid;

      final cliente = await FirebaseFirestore.instance
          .collection('Clientes')
          .doc(uid)
          .get();

      if (cliente.exists) {
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);        return;
      }

      final profissional = await FirebaseFirestore.instance
          .collection('Profissionais')
          .doc(uid)
          .get();

      if (profissional.exists) {
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);        return;
      }

      await FirebaseAuth.instance.signOut();

      if (mounted) {
        setState(() => erro = 'Conta não encontrada. Cadastre-se primeiro.');
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() {
          erro = e.code == 'user-not-found' ||
                  e.code == 'invalid-credential' ||
                  e.code == 'wrong-password'
              ? 'Email ou senha incorretos.'
              : 'Erro ao entrar: ${e.message}';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => erro = 'Erro ao entrar: $e');
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  @override
  void dispose() {
    email.dispose();
    senha.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              IconButton(
                alignment: Alignment.centerLeft,
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 10),
              Center(
                child: Image.asset(
                  'assets/imagens/logo.png',
                  width: 110,
                  height: 110,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Bem-vindo',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Entre na sua conta para continuar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF666666),
                ),
              ),
              const SizedBox(height: 36),
              const Text(
                'Email',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Senha',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: senha,
                obscureText: !visivel,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      visivel ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => visivel = !visivel),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RedefinirSenhaScreen(),
                    ),
                  ),
                  child: const Text(
                    'Esqueci minha senha',
                    style: TextStyle(color: Color(0xFF00B4D8)),
                  ),
                ),
              ),
              if (erro.isNotEmpty)
                Text(
                  erro,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 13,
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                height: 55,
                child: ElevatedButton(
                  onPressed: loading ? null : entrar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0077B6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Entrar',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Não tem uma conta? '),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CadastroScreen(),
                      ),
                    ),
                    child: const Text(
                      'Cadastre-se',
                      style: TextStyle(
                        color: Color(0xFF00B4D8),
                        fontWeight: FontWeight.w700,
                      ),
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
