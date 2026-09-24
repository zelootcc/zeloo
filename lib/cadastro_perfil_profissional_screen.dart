import 'package:flutter/material.dart';

import 'firebase_service.dart';

const _gradient = LinearGradient(
  colors: [Color(0xFF00C6D7), Color(0xFF0077B6)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class CadastroPerfilProfissionalScreen extends StatefulWidget {
  const CadastroPerfilProfissionalScreen({super.key});

  @override
  State<CadastroPerfilProfissionalScreen> createState() =>
      _CadastroPerfilProfissionalScreenState();
}

class _CadastroPerfilProfissionalScreenState
    extends State<CadastroPerfilProfissionalScreen> {
  final _nomeCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _regiaoCtrl = TextEditingController();
  final _disponibilidadeCtrl = TextEditingController();
  final _pagamentoCtrl = TextEditingController();
  final _descricaoCtrl = TextEditingController();
  final _precoCtrl = TextEditingController();

  bool _loading = true;
  bool _salvando = false;

  @override
  void initState() {
    super.initState();
    _carregarDados();
  }

  Future<void> _carregarDados() async {
    try {
      final documento = await FirebaseService.dadosProfissional();

      if (documento == null || !documento.exists) {
        throw Exception('Perfil profissional não encontrado.');
      }

      final dados = documento.data()!;
      if (!mounted) return;

      _nomeCtrl.text = dados['nome']?.toString() ?? '';
      _areaCtrl.text = dados['area']?.toString() ?? '';
      _regiaoCtrl.text = dados['regiao']?.toString() ?? '';
      _disponibilidadeCtrl.text = dados['disponibilidade']?.toString() ?? '';
      _pagamentoCtrl.text = dados['pagamento']?.toString() ?? '';
      _descricaoCtrl.text = dados['descricao']?.toString() ?? '';
      _precoCtrl.text = dados['precoHora']?.toString() ?? '';
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao carregar perfil: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _salvar() async {
    if (_nomeCtrl.text.trim().isEmpty || _areaCtrl.text.trim().isEmpty) {
      _snack('Preencha os campos obrigatórios.', erro: true);
      return;
    }

    final preco = _precoCtrl.text.trim().isEmpty
        ? 0.0
        : double.tryParse(_precoCtrl.text.trim().replaceAll(',', '.'));

    if (preco == null || preco < 0) {
      _snack('Digite um valor por hora válido.', erro: true);
      return;
    }

    setState(() => _salvando = true);

    try {
      await FirebaseService.atualizarUsuario({
        'nome': _nomeCtrl.text.trim(),
        'area': _areaCtrl.text.trim(),
        'especialidade': _areaCtrl.text.trim(),
        'regiao': _regiaoCtrl.text.trim(),
        'cidade': _regiaoCtrl.text.trim(),
        'disponibilidade': _disponibilidadeCtrl.text.trim(),
        'pagamento': _pagamentoCtrl.text.trim(),
        'descricao': _descricaoCtrl.text.trim(),
        'precoHora': preco,
      });

      if (!mounted) return;

      _snack('Perfil atualizado com sucesso!');
      Navigator.pop(context);
    } catch (e) {
      if (mounted) _snack('Erro ao salvar perfil: $e', erro: true);
    } finally {
      if (mounted) setState(() => _salvando = false);
    }
  }

  void _snack(String mensagem, {bool erro = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensagem),
        backgroundColor: erro
            ? const Color(0xFFE53E3E)
            : const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _areaCtrl.dispose();
    _regiaoCtrl.dispose();
    _disponibilidadeCtrl.dispose();
    _pagamentoCtrl.dispose();
    _descricaoCtrl.dispose();
    _precoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF4F7FB),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 150,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                Icons.chevron_left_rounded,
                color: Colors.white,
                size: 28,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: _gradient,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(32),
                    bottomRight: Radius.circular(32),
                  ),
                ),
                child: const SafeArea(
                  child: Center(
                    child: Text(
                      'Editar perfil profissional',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _Secao('Informações Básicas'),
                  const SizedBox(height: 14),
                  _campo(
                    'Nome de preferência *',
                    _nomeCtrl,
                    Icons.person_outline_rounded,
                  ),
                  _campo(
                    'Área de atuação *',
                    _areaCtrl,
                    Icons.work_outline_rounded,
                  ),
                  _campo(
                    'Região de atendimento',
                    _regiaoCtrl,
                    Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 12),
                  const _Secao('Sobre o Trabalho'),
                  const SizedBox(height: 14),
                  _campo(
                    'Disponibilidade',
                    _disponibilidadeCtrl,
                    Icons.schedule_outlined,
                  ),
                  _campo(
                    'Opções de pagamento',
                    _pagamentoCtrl,
                    Icons.payments_outlined,
                  ),
                  _campo(
                    'Valor por hora (R\$)',
                    _precoCtrl,
                    Icons.attach_money_rounded,
                    tipo: TextInputType.number,
                  ),
                  _campoMultilinha('Descrição / Bio', _descricaoCtrl),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _salvando ? null : _salvar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0077B6),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _salvando
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Salvar alterações',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _campo(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType tipo = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: tipo,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, size: 20),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _campoMultilinha(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _Secao extends StatelessWidget {
  final String titulo;

  const _Secao(this.titulo);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            gradient: _gradient,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }
}
