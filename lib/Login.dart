import 'package:flutter/material.dart';
import 'cadastro.dart';
import 'home_cliente_screen.dart';
import 'home_profissional_screen.dart';
import 'redefinir_senha_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _senhaController = TextEditingController();

  bool _senhaVisivel = false;
  bool _loading = false;
  String _erro = '';

  Future<void> _handleLogin() async {
    setState(() {
      _erro = '';
    });

    if (_emailController.text.isEmpty || _senhaController.text.isEmpty) {
      setState(() {
        _erro = 'Preencha todos os campos.';
      });
      return;
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(_emailController.text.trim())) {
      setState(() {
        _erro = 'Digite um e-mail válido.';
      });
      return;
    }

    setState(() {
      _loading = true;
    });

    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _senhaController.text,
      );

      final uid = credential.user!.uid;

      final docCliente = await FirebaseFirestore.instance
          .collection('Clientes')
          .doc(uid)
          .get();

      if (docCliente.exists) {
        if (!mounted) return;
        setState(() => _loading = false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeClienteScreen()),
        );
        return;
      }

      final docProfissional = await FirebaseFirestore.instance
          .collection('Profissionais')
          .doc(uid)
          .get();

      if (docProfissional.exists) {
        if (!mounted) return;
        setState(() => _loading = false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeProfissionalScreen()),
        );
        return;
      }

      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      setState(() {
        _loading = false;
        _erro = 'Conta não encontrada. Cadastre-se primeiro.';
      });
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;

        if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
          _erro = 'Email ou senha incorretos.';
        } else if (e.code == 'wrong-password') {
          _erro = 'Email ou senha incorretos.';
        } else if (e.code == 'invalid-email') {
          _erro = 'Digite um email válido.';
        } else if (e.code == 'user-disabled') {
          _erro = 'Esta conta foi desativada.';
        } else if (e.code == 'too-many-requests') {
          _erro = 'Muitas tentativas. Tente novamente mais tarde.';
        } else {
          _erro = 'Erro ao entrar: ${e.message}';
        }
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _loading = false;
        _erro = 'Erro ao entrar: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Color(0xFF111111),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                      style: TextStyle(fontSize: 15, color: Color(0xFF666666)),
                    ),
                    const SizedBox(height: 36),
                    const Text(
                      'Email',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
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
                      controller: _senhaController,
                      obscureText: !_senhaVisivel,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _senhaVisivel = !_senhaVisivel;
                            });
                          },
                          icon: Icon(
                            _senhaVisivel
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
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
                          style: TextStyle(
                            color: Color(0xFF00B4D8),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (_erro.isNotEmpty)
                      Text(
                        _erro,
                        style: const TextStyle(color: Colors.red, fontSize: 13),
                      ),
                    const SizedBox(height: 24),
                    Container(
                      height: 55,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00B4D8), Color(0xFF0077B6)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ElevatedButton(
                        onPressed: _loading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
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
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CadastroScreen(),
                              ),
                            );
                          },
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
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
