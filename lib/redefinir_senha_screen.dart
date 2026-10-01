import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RedefinirSenhaScreen extends StatefulWidget {
  const RedefinirSenhaScreen({super.key});

  @override
  State<RedefinirSenhaScreen> createState() =>
      _RedefinirSenhaScreenState();
}

class _RedefinirSenhaScreenState extends State<RedefinirSenhaScreen> {
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _enviado = false;
  String _emailEnviado = '';

  static const Color primaryBlue = Color(0xFF087FE5);
  static const Color secondaryBlue = Color(0xFF20B5E8);
  static const Color darkText = Color(0xFF142443);
  static const Color secondaryText = Color(0xFF7185A2);

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
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );

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

  void _showMessage(
    String message, {
    required bool isSuccess,
  }) {
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FD),
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const Positioned.fill(
            child: _BackgroundDecoration(),
          ),
          SafeArea(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(
                      left: 20,
                      top: 8,
                    ),
                    child: IconButton(
                      onPressed: _goBack,
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        size: 25,
                      ),
                      color: darkText,
                      tooltip: 'Voltar',
                    ),
                  ),
                ),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: IntrinsicHeight(
                            child: _enviado
                                ? _buildConfirmation()
                                : _buildForm(),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        const Center(
          child: LockIllustration(),
        ),
        const SizedBox(height: 36),
        const Text(
          'Redefinir senha',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: darkText,
            letterSpacing: -1.2,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 30),
        const Text(
          'Esqueceu sua senha? Sem problemas!',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Color(0xFF3D5678),
            height: 1.4,
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'Digite o e-mail cadastrado na sua conta e enviaremos '
          'um link para você criar uma nova senha.',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: secondaryText,
            height: 1.65,
            letterSpacing: 0.1,
          ),
        ),
        const SizedBox(height: 48),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'E-mail',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: darkText,
                ),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _emailController,
                validator: _validateEmail,
                enabled: !_isLoading,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                autofillHints: const [
                  AutofillHints.email,
                ],
                autocorrect: false,
                enableSuggestions: false,
                style: const TextStyle(
                  fontSize: 18,
                  color: darkText,
                  fontWeight: FontWeight.w500,
                ),
                onFieldSubmitted: (_) => _sendResetLink(),
                decoration: InputDecoration(
                  hintText: 'seu@email.com',
                  hintStyle: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFFA0B0C7),
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: const Icon(
                    Icons.mail_outline_rounded,
                    size: 28,
                    color: Color(0xFF8195B1),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 60,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(
                      color: Color(0xFFE5EDF7),
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(
                      color: Color(0xFFE5EDF7),
                      width: 1.5,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(
                      color: Color(0xFFE5EDF7),
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(
                      color: primaryBlue,
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(
                      color: Color(0xFFE05252),
                      width: 1.5,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(
                      color: Color(0xFFE05252),
                      width: 2,
                    ),
                  ),
                  errorStyle: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 34),
              _buildGradientButton(
                label: 'Enviar link de redefinição',
                onPressed: _isLoading ? null : _sendResetLink,
                isLoading: _isLoading,
                icon: Icons.arrow_forward_rounded,
              ),
            ],
          ),
        ),
        const Spacer(),
        const SizedBox(height: 42),
        _buildLoginButton(),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildConfirmation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        const Icon(
          Icons.mark_email_read_rounded,
          size: 100,
          color: primaryBlue,
        ),
        const SizedBox(height: 28),
        const Text(
          'Verifique seu e-mail',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: darkText,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Se $_emailEnviado estiver cadastrado, você receberá '
          'um link para redefinir sua senha. '
          'Verifique sua caixa de entrada e a pasta de spam.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            color: secondaryText,
            height: 1.65,
          ),
        ),
        const SizedBox(height: 40),
        _buildGradientButton(
          label: 'Voltar ao login',
          onPressed: _goBack,
          icon: Icons.arrow_back_rounded,
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: _voltarAoFormulario,
          style: TextButton.styleFrom(
            foregroundColor: primaryBlue,
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 14,
            ),
          ),
          child: const Text(
            'Reenviar ou alterar e-mail',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const Spacer(),
        const SizedBox(height: 30),
      ],
    );
  }

  Widget _buildGradientButton({
    required String label,
    required VoidCallback? onPressed,
    required IconData icon,
    bool isLoading = false,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 76,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              secondaryBlue,
              primaryBlue,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withValues(alpha: 0.18),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            foregroundColor: Colors.white,
            disabledForegroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 26,
                  height: 26,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Icon(
                      icon,
                      size: 28,
                      color: Colors.white,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return Center(
      child: TextButton.icon(
        onPressed: _goBack,
        icon: const Icon(
          Icons.arrow_back_rounded,
          size: 25,
          color: primaryBlue,
        ),
        label: const Text(
          'Voltar ao login',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: primaryBlue,
          ),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 14,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}

class LockIllustration extends StatelessWidget {
  const LockIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 290,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 12,
            top: 55,
            child: Container(
              width: 220,
              height: 190,
              decoration: BoxDecoration(
                color: const Color(0xFFDDEEFF).withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          Positioned(
            right: 5,
            top: 95,
            child: Container(
              width: 190,
              height: 145,
              decoration: BoxDecoration(
                color: const Color(0xFFD9EDFF).withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(100),
              ),
            ),
          ),
          Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF42C6EF),
                  Color(0xFF087FE5),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF087FE5).withValues(alpha: 0.14),
                  blurRadius: 35,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
          ),
          Positioned(
            top: 70,
            child: Container(
              width: 68,
              height: 78,
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFF4F8FD),
                  width: 12,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(40),
                  topRight: Radius.circular(40),
                ),
              ),
            ),
          ),
          Positioned(
            top: 120,
            child: Container(
              width: 110,
              height: 88,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F9FF),
                borderRadius: BorderRadius.circular(17),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF003F8A).withValues(alpha: 0.12),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.lock_rounded,
                  size: 45,
                  color: Color(0xFF1688E8),
                ),
              ),
            ),
          ),
          Positioned(
            top: 28,
            right: 65,
            child: Transform.rotate(
              angle: 0.5,
              child: Container(
                width: 10,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF1599E8),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Positioned(
            top: 55,
            right: 35,
            child: Transform.rotate(
              angle: 1.05,
              child: Container(
                width: 10,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF1599E8),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Positioned(
            top: 91,
            right: 25,
            child: Transform.rotate(
              angle: 1.65,
              child: Container(
                width: 10,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF1599E8),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BackgroundDecoration extends StatelessWidget {
  const _BackgroundDecoration();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: const Color(0xFFF4F8FD),
        ),
        Positioned(
          top: -130,
          right: -110,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3FF).withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(150),
            ),
          ),
        ),
        Positioned(
          bottom: -180,
          left: -130,
          child: Container(
            width: 380,
            height: 380,
            decoration: BoxDecoration(
              color: const Color(0xFFE5F1FF).withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(190),
            ),
          ),
        ),
      ],
    );
  }
}