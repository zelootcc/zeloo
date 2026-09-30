import 'package:flutter/material.dart';

import 'firebase_service.dart';
import 'dados_profissionais.dart';
import 'campos_profissionais.dart';

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
  List<String> _areas = [];
  Map<String, HorarioAtendimento> _horarios = {};
  String? _avisoAntigo;
  bool _erroCarregamento = false;
  final _regiaoCtrl = TextEditingController();
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
    setState(() {
      _loading = true;
      _erroCarregamento = false;
    });
    try {
      final documento = await FirebaseService.dadosProfissional();

      if (documento == null || !documento.exists) {
        throw Exception('Perfil profissional não encontrado.');
      }

      final dados = documento.data()!;
      if (!mounted) return;

      _nomeCtrl.text = dados['nome']?.toString() ?? '';
      final antigas = lerAreas(dados);
      _areas = antigas.where(areasAtuacao.contains).take(3).toList();
      _horarios = lerHorarios(dados);
      final avisos = <String>[];
      if (antigas.any((area) => !areasAtuacao.contains(area)) ||
          antigas.length > 3) {
        avisos.add(
          'Áreas anteriores: ${antigas.join(', ')}. Escolha até 3 opções da lista.',
        );
      }
      if (_horarios.isEmpty && dados['disponibilidade'] != null) {
        avisos.add(
          'Disponibilidade anterior: ${dados['disponibilidade']}. Defina os dias e horários abaixo.',
        );
      }
      _avisoAntigo = avisos.isEmpty ? null : avisos.join('\n');
      _regiaoCtrl.text = dados['regiao']?.toString() ?? '';
      _pagamentoCtrl.text = dados['pagamento']?.toString() ?? '';
      _descricaoCtrl.text = dados['descricao']?.toString() ?? '';
      _precoCtrl.text = dados['precoHora']?.toString() ?? '';
    } catch (e) {
      if (mounted) {
        _erroCarregamento = true;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao carregar perfil: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _salvar() async {
    if (_salvando) return;
    if (_nomeCtrl.text.trim().isEmpty) {
      _snack('Informe seu nome de preferência.', erro: true);
      return;
    }
    if (!areasValidas(_areas)) {
      _snack('Selecione de 1 a 3 áreas da lista.', erro: true);
      return;
    }

    final erroHorario = validarHorarios(_horarios);
    if (erroHorario != null) {
      _snack(erroHorario, erro: true);
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
        ...dadosAtuacao(_areas, _horarios),
        'regiao': _regiaoCtrl.text.trim(),
        'cidade': _regiaoCtrl.text.trim(),
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
    _regiaoCtrl.dispose();
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

    if (_erroCarregamento) {
      return Scaffold(
        appBar: AppBar(title: const Text('Editar perfil profissional')),
        body: Center(
          child: TextButton(
            onPressed: _carregarDados,
            child: const Text('Não foi possível carregar. Tentar novamente'),
          ),
        ),
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
                  if (_avisoAntigo != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(_avisoAntigo!),
                    ),
                  SeletorAreas(
                    selecionadas: _areas,
                    onChanged: (v) => setState(() => _areas = v),
                  ),
                  const SizedBox(height: 16),
                  _campo(
                    'Região de atendimento',
                    _regiaoCtrl,
                    Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 12),
                  const _Secao('Sobre o Trabalho'),
                  const SizedBox(height: 14),
                  SeletorHorarios(
                    horarios: _horarios,
                    onChanged: (v) => setState(() => _horarios = v),
                  ),
                  const SizedBox(height: 16),
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
