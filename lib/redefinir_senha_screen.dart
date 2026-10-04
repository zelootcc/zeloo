import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'zeloo_ui.dart';

class RedefinirSenhaScreen extends StatefulWidget {
  const RedefinirSenhaScreen({super.key});

  @override
  State<RedefinirSenhaScreen> createState() => _RedefinirSenhaScreenState();
}

class _RedefinirSenhaScreenState extends State<RedefinirSenhaScreen> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _enviado = false;
  String _emailEnviado = '';

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Digite seu endereço de e-mail.';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (!emailRegex.hasMatch(value.trim())) {
      return 'Digite um endereço de e-mail válido.';
    }

    return null;
  }

  Future<void> _sendResetLink() async {
    if (_isLoading) return;

    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final email = _emailController.text.trim();

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;

      setState(() {
        _emailEnviado = email;
        _enviado = true;
      });

      _showMessage(
        'Se o endereço estiver cadastrado, você receberá '
        'as instruções para redefinir sua senha.',
        isSuccess: true,
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String message;

      switch (e.code) {
        case 'user-not-found':
          message = 'Não existe conta com este e-mail.';
          break;
        case 'invalid-email':
          message = 'Digite um endereço de e-mail válido.';
          break;
        case 'too-many-requests':
          message = 'Muitas tentativas. Tente novamente mais tarde.';
          break;
        case 'network-request-failed':
          message = 'Verifique sua conexão e tente novamente.';
          break;
        default:
          message = 'Não foi possível enviar o link. Tente novamente.';
      }

      _showMessage(message, isSuccess: false);
    } catch (_) {
      if (!mounted) return;

      _showMessage(
        'Não foi possível enviar o link. Tente novamente.',
        isSuccess: false,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showMessage(String message, {required bool isSuccess}) {
    final messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess
                  ? Icons.check_circle_outline_rounded
                  : Icons.error_outline_rounded,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isSuccess
            ? const Color(0xFF168B68)
            : const Color(0xFFD94343),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _goBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  void _voltarAoFormulario() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    setState(() => _enviado = false);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF4F7FB),
    body: SafeArea(
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: IconButton(
                onPressed: _isLoading ? null : _goBack,
                tooltip: 'Voltar',
                icon: const Icon(
                  Icons.chevron_left_rounded,
                  color: zelooAzul,
                  size: 30,
                ),
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: (constraints.maxHeight - 48).clamp(
                      0,
                      double.infinity,
                    ),
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 440,
                      child: _enviado ? _buildConfirmation() : _buildForm(),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Widget _icone(IconData icone) => Container(
    width: 76,
    height: 76,
    decoration: BoxDecoration(
      gradient: zelooGradiente,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: zelooAzul.withValues(alpha: 0.15),
          blurRadius: 24,
          offset: const Offset(0, 8),
        ),
      ],
    ),
    child: Icon(icone, color: Colors.white, size: 36),
  );

  Widget _buildForm() => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Align(child: _icone(Icons.lock_reset_rounded)),
      const SizedBox(height: 26),
      const Text(
        'Esqueceu sua senha?',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 27,
          fontWeight: FontWeight.w800,
          color: zelooTexto,
          letterSpacing: -0.6,
        ),
      ),
      const SizedBox(height: 10),
      const Text(
        'Vamos ajudar você a voltar. Informe seu e-mail e receba um link para criar uma nova senha.',
        textAlign: TextAlign.center,
        style: TextStyle(color: Color(0xFF64788B), fontSize: 14, height: 1.5),
      ),
      const SizedBox(height: 28),
      Container(
        decoration: painelZeloo(),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                validator: _validateEmail,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                enabled: !_isLoading,
                maxLength: 254,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.email],
                autocorrect: false,
                enableSuggestions: false,
                decoration: campoZeloo(
                  'E-mail cadastrado',
                  icon: Icons.mail_outline_rounded,
                ).copyWith(hintText: 'seu@email.com', counterText: ''),
                onFieldSubmitted: (_) => _sendResetLink(),
              ),
              const SizedBox(height: 18),
              BotaoZeloo(
                texto: _isLoading
                    ? 'Enviando...'
                    : 'Enviar link de recuperação',
                icon: Icons.send_rounded,
                onPressed: _isLoading ? null : _sendResetLink,
              ),
              if (_isLoading)
                const Padding(
                  padding: EdgeInsets.only(top: 12),
                  child: Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 18),
      TextButton(
        onPressed: _isLoading ? null : _goBack,
        style: TextButton.styleFrom(foregroundColor: zelooAzul),
        child: const Text('Voltar ao login'),
      ),
    ],
  );

  Widget _buildConfirmation() => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Align(child: _icone(Icons.mark_email_read_outlined)),
      const SizedBox(height: 26),
      const Text(
        'Confira seu e-mail',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 27,
          fontWeight: FontWeight.w800,
          color: zelooTexto,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        'Se $_emailEnviado estiver cadastrado, você receberá um link para redefinir sua senha.',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Color(0xFF64788B),
          fontSize: 14,
          height: 1.5,
        ),
      ),
      const SizedBox(height: 22),
      Container(
        decoration: painelZeloo(),
        padding: const EdgeInsets.all(18),
        child: const Row(
          children: [
            Icon(Icons.inbox_outlined, color: zelooAzul),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Verifique também a pasta de spam ou lixo eletrônico.',
                style: TextStyle(
                  color: Color(0xFF64788B),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      BotaoZeloo(
        texto: 'Voltar ao login',
        icon: Icons.arrow_back_rounded,
        onPressed: _goBack,
      ),
      const SizedBox(height: 10),
      TextButton(
        onPressed: _voltarAoFormulario,
        style: TextButton.styleFrom(foregroundColor: zelooAzul),
        child: const Text('Reenviar ou alterar e-mail'),
      ),
    ],
  );
}
