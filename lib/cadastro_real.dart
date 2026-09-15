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
  final nome = TextEditingController();
  final email = TextEditingController();
  final telefone = TextEditingController();
  final senha = TextEditingController();
  final confirmar = TextEditingController();
  final cpfCnpj = TextEditingController();
  final nascimento = TextEditingController();
  final regiao = TextEditingController();
  final descricao = TextEditingController();
  final precoHora = TextEditingController();

  static const areas = [
    'Eletricista', 'Encanador', 'Mecânico', 'Pintor', 'Diarista',
    'Jardineiro', 'Marceneiro', 'Pedreiro', 'Serviços Gerais',
  ];

  static const disponibilidades = [
    'Segunda a Sexta, 8h–18h', 'Segunda a Sábado, 8h–18h',
    'Finais de semana', 'Período integral (todos os dias)', 'Sob consulta',
  ];

  static const pagamentos = [
    'PIX', 'Dinheiro', 'Cartão de Crédito', 'Cartão de Débito', 'Boleto',
  ];

  late bool profissional;
  String? area;
  String? disponibilidade;
  String? pagamento;
  bool carregando = false;
  String erro = '';

  @override
  void initState() {
    super.initState();
    profissional = widget.isProfissional;
  }

  @override
  void dispose() {
    nome.dispose();
    email.dispose();
    telefone.dispose();
    senha.dispose();
    confirmar.dispose();
    cpfCnpj.dispose();
    nascimento.dispose();
    regiao.dispose();
    descricao.dispose();
    precoHora.dispose();
    super.dispose();
  }

  bool get senhaValida =>
      senha.text.length >= 8 &&
      senha.text.contains(RegExp(r'[A-Z]')) &&
      senha.text.contains(RegExp(r'[0-9]')) &&
      senha.text.contains(RegExp(r'[^A-Za-z0-9]'));

  Future<void> cadastrar() async {
    setState(() => erro = '');

    if (nome.text.trim().isEmpty ||
        email.text.trim().isEmpty ||
        telefone.text.trim().isEmpty ||
        senha.text.isEmpty ||
        confirmar.text.isEmpty) {
      setState(() => erro = 'Preencha todos os campos obrigatórios.');
      return;
    }

    if (!RegExp(r'^\S+@\S+\.\S+$').hasMatch(email.text.trim())) {
      setState(() => erro = 'Digite um email válido.');
      return;
    }

    if (profissional &&
        (cpfCnpj.text.trim().isEmpty ||
            nascimento.text.trim().isEmpty ||
            area == null ||
            regiao.text.trim().isEmpty)) {
      setState(() => erro = 'Preencha todos os dados profissionais.');
      return;
    }

    if (!senhaValida) {
      setState(() => erro = 'A senha não atende aos requisitos.');
      return;
    }

    if (senha.text != confirmar.text) {
      setState(() => erro = 'As senhas não são iguais.');
      return;
    }

    setState(() => carregando = true);
    UserCredential? cred;

    try {
      cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email.text.trim(),
        password: senha.text,
      );

      final uid = cred.user!.uid;
      final colecao = profissional ? 'Profissionais' : 'Clientes';
      final dados = <String, dynamic>{
        'uid': uid,
        'nome': nome.text.trim(),
        'email': email.text.trim(),
        'telefone': telefone.text.trim(),
        'tipoConta': profissional ? 'profissional' : 'cliente',
        'criadoEm': FieldValue.serverTimestamp(),
        'atualizadoEm': FieldValue.serverTimestamp(),
      };

      if (profissional) {
        dados.addAll({
          'cpfCnpj': cpfCnpj.text.trim(),
          'nascimento': nascimento.text.trim(),
          'area': area,
          'especialidade': area,
          'regiao': regiao.text.trim(),
          'cidade': regiao.text.trim(),
          'disponibilidade': disponibilidade ?? 'Sob consulta',
          'pagamento': pagamento ?? 'PIX',
          'descricao': descricao.text.trim(),
          'precoHora': double.tryParse(
                precoHora.text.trim().replaceAll(',', '.'),
              ) ??
              0.0,
          'disponivel': true,
          'avaliacao': 0.0,
          'totalAvaliacoes': 0,
        });
      }

      await FirebaseFirestore.instance
          .collection(colecao)
          .doc(uid)
          .set(dados);

      if (!mounted) return;
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (cred?.user != null) {
        try {
          await cred!.user!.delete();
        } catch (_) {}
      }

      if (!mounted) return;
      setState(() {
        carregando = false;
        erro = e.code == 'email-already-in-use'
            ? 'Este email já está cadastrado.'
            : 'Erro ao criar conta: ${e.message ?? e.code}';
      });
    } catch (e) {
      if (cred?.user != null) {
        try {
          await cred!.user!.delete();
        } catch (_) {}
      }

      if (!mounted) return;
      setState(() {
        carregando = false;
        erro = 'Erro ao salvar cadastro: $e';
      });
    }
  }

  Widget campo(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool senhaCampo = false,
    TextInputType teclado = TextInputType.text,
    String? hint,
    int linhas = 1,
  }) {
    return TextField(
      controller: controller,
      obscureText: senhaCampo,
      keyboardType: teclado,
      maxLines: linhas,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: const Color(0xFFE8E8E8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget dropdown(
    String label,
    String? valor,
    List<String> itens,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: valor,
      isExpanded: true,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: const Color(0xFFE8E8E8),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      items: itens
          .map((item) => DropdownMenuItem(value: item, child: Text(item)))
          .toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            campo('Nome *', nome, Icons.person_outline),
            const SizedBox(height: 16),
            campo('Email *', email, Icons.email_outlined,
                teclado: TextInputType.emailAddress),
            const SizedBox(height: 16),
            campo('Telefone *', telefone, Icons.phone_outlined,
                teclado: TextInputType.phone),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Cliente'),
                    value: false,
                    groupValue: profissional,
                    onChanged: (v) => setState(() => profissional = v!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<bool>(
                    title: const Text('Profissional'),
                    value: true,
                    groupValue: profissional,
                    onChanged: (v) => setState(() => profissional = v!),
                  ),
                ),
              ],
            ),
            if (profissional) ...[
              const SizedBox(height: 16),
              campo('CPF/CNPJ *', cpfCnpj, Icons.badge_outlined,
                  teclado: TextInputType.number),
              const SizedBox(height: 16),
              campo('Nascimento *', nascimento, Icons.cake_outlined,
                  hint: 'DD/MM/AAAA'),
              const SizedBox(height: 16),
              dropdown('Área de atuação *', area, areas,
                  (v) => setState(() => area = v)),
              const SizedBox(height: 16),
              campo('Região *', regiao, Icons.location_on_outlined),
              const SizedBox(height: 16),
              dropdown('Disponibilidade', disponibilidade, disponibilidades,
                  (v) => setState(() => disponibilidade = v)),
              const SizedBox(height: 16),
              dropdown('Pagamento', pagamento, pagamentos,
                  (v) => setState(() => pagamento = v)),
              const SizedBox(height: 16),
              campo('Descrição', descricao, Icons.description_outlined,
                  linhas: 3),
              const SizedBox(height: 16),
              campo('Valor por hora', precoHora, Icons.attach_money,
                  teclado: const TextInputType.numberWithOptions(decimal: true)),
            ],
            const SizedBox(height: 16),
            campo('Senha *', senha, Icons.lock_outline,
                senhaCampo: true),
            const SizedBox(height: 16),
            campo('Confirmar senha *', confirmar, Icons.lock_reset_outlined,
                senhaCampo: true),
            if (erro.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(erro, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: carregando ? null : cadastrar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0077B6),
                  foregroundColor: Colors.white,
                ),
                child: carregando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Cadastrar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
