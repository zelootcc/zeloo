import 'package:flutter/material.dart';
import 'mock_data_profissional.dart';

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
  late final TextEditingController _nomeCtrl;
  late final TextEditingController _especialidadeCtrl;
  late final TextEditingController _regiaoCtrl;
  late final TextEditingController _disponibilidadeCtrl;
  late final TextEditingController _pagamentoCtrl;
  late final TextEditingController _descricaoCtrl;
  late final TextEditingController _precoCtrl;

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _nomeCtrl = TextEditingController(text: ProfissionalLogado.nome);
    _especialidadeCtrl =
        TextEditingController(text: ProfissionalLogado.especialidade);
    _regiaoCtrl = TextEditingController(text: ProfissionalLogado.regiao);
    _disponibilidadeCtrl =
        TextEditingController(text: ProfissionalLogado.disponibilidade);
    _pagamentoCtrl = TextEditingController(text: ProfissionalLogado.pagamento);
    _descricaoCtrl = TextEditingController(text: ProfissionalLogado.descricao);
    _precoCtrl =
        TextEditingController(text: ProfissionalLogado.precoHora.toInt().toString());
  }

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _especialidadeCtrl.dispose();
    _regiaoCtrl.dispose();
    _disponibilidadeCtrl.dispose();
    _pagamentoCtrl.dispose();
    _descricaoCtrl.dispose();
    _precoCtrl.dispose();
    super.dispose();
  }

  void _salvar() {
    if (_nomeCtrl.text.trim().isEmpty || _especialidadeCtrl.text.trim().isEmpty) {
      _snack('Preencha os campos obrigatórios.', erro: true);
      return;
    }
    setState(() => _loading = true);
    Future.delayed(const Duration(milliseconds: 1200), () {
      ProfissionalLogado.nome = _nomeCtrl.text.trim();
      ProfissionalLogado.especialidade = _especialidadeCtrl.text.trim();
      ProfissionalLogado.regiao = _regiaoCtrl.text.trim();
      ProfissionalLogado.disponibilidade = _disponibilidadeCtrl.text.trim();
      ProfissionalLogado.pagamento = _pagamentoCtrl.text.trim();
      ProfissionalLogado.descricao = _descricaoCtrl.text.trim();
      ProfissionalLogado.precoHora =
          double.tryParse(_precoCtrl.text.trim()) ?? ProfissionalLogado.precoHora;
      setState(() => _loading = false);
      _snack('Perfil atualizado com sucesso!');
      Navigator.pop(context);
    });
  }

  void _snack(String msg, {bool erro = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor:
            erro ? const Color(0xFFE53E3E) : const Color(0xFF4CAF50),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final iniciais = ProfissionalLogado.nome
        .trim()
        .split(' ')
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.chevron_left_rounded,
                  color: Colors.white, size: 28),
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
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      Stack(
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(24),
                              border:
                                  Border.all(color: Colors.white38, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                iniciais,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 26,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: const Color(0xFF00C6D7), width: 1.5),
                              ),
                              child: const Icon(Icons.edit_rounded,
                                  size: 14, color: Color(0xFF0077B6)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Crie seu perfil profissional',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '(*) campos obrigatórios',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
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
                  _Secao('Informações Básicas'),
                  const SizedBox(height: 14),
                  _Label('Nome de preferência *'),
                  const SizedBox(height: 8),
                  _Campo(
                    controller: _nomeCtrl,
                    hint: 'Como quer ser chamado',
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 16),
                  _Label('Área de atuação *'),
                  const SizedBox(height: 8),
                  _Campo(
                    controller: _especialidadeCtrl,
                    hint: 'Ex.: Mecânico, Eletricista, Encanador...',
                    icon: Icons.work_outline_rounded,
                  ),
                  const SizedBox(height: 16),
                  _Label('Região de atendimento *'),
                  const SizedBox(height: 8),
                  _Campo(
                    controller: _regiaoCtrl,
                    hint: 'Ex.: São José dos Campos (SP) - Jd. Satélite',
                    icon: Icons.location_on_outlined,
                  ),
                  const SizedBox(height: 28),

                  _Secao('Sobre o Trabalho'),
                  const SizedBox(height: 14),
                  _Label('Disponibilidade *'),
                  const SizedBox(height: 8),
                  _Campo(
                    controller: _disponibilidadeCtrl,
                    hint: 'Ex.: Segunda - Sexta; 08:00 - 19:00',
                    icon: Icons.schedule_outlined,
                  ),
                  const SizedBox(height: 16),
                  _Label('Opções de Pagamento *'),
                  const SizedBox(height: 8),
                  _Campo(
                    controller: _pagamentoCtrl,
                    hint: 'Ex.: PIX, Dinheiro, Cartões, Boleto...',
                    icon: Icons.payments_outlined,
                  ),
                  const SizedBox(height: 16),
                  _Label('Valor por hora (R\$)'),
                  const SizedBox(height: 8),
                  _Campo(
                    controller: _precoCtrl,
                    hint: 'Ex.: 80',
                    icon: Icons.attach_money_rounded,
                    tipo: TextInputType.number,
                  ),
                  const SizedBox(height: 16),
                  _Label('Descrição / Bio'),
                  const SizedBox(height: 8),
                  _CampoMultilinha(
                    controller: _descricaoCtrl,
                    hint:
                        'Conte um pouco sobre sua experiência e habilidades...',
                  ),
                  const SizedBox(height: 28),

                  _Secao('Portfólio'),
                  const SizedBox(height: 14),
                  Text(
                    'Adicione até 10 imagens do seu trabalho',
                    style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 12),
                  _PortfolioGrid(),
                  const SizedBox(height: 36),

                  _BotaoSalvar(loading: _loading, onTap: _salvar),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
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
            gradient: const LinearGradient(
              colors: [Color(0xFF00C6D7), Color(0xFF0077B6)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
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

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Color(0xFF1A1A2E),
      ),
    );
  }
}

class _Campo extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType tipo;

  const _Campo({
    required this.controller,
    required this.hint,
    required this.icon,
    this.tipo = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: tipo,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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

class _CampoMultilinha extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const _CampoMultilinha({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.all(16),
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

class _PortfolioGrid extends StatefulWidget {
  @override
  State<_PortfolioGrid> createState() => _PortfolioGridState();
}

class _PortfolioGridState extends State<_PortfolioGrid> {
  final int _maxFotos = 10;

  // Simula lista de fotos (strings de placeholder)
  final List<String> _fotos = [];

  void _adicionarFoto() {
    if (_fotos.length >= _maxFotos) return;
    setState(() => _fotos.add('foto_${_fotos.length + 1}'));
  }

  void _removerFoto(int index) {
    setState(() => _fotos.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: _fotos.length + (_fotos.length < _maxFotos ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _fotos.length) {
          // Botão adicionar
          return GestureDetector(
            onTap: _adicionarFoto,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: const Color(0xFF00C6D7).withOpacity(0.4),
                    width: 1.5),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_rounded,
                      color: Colors.grey[400], size: 28),
                  const SizedBox(height: 4),
                  Text(
                    '${_fotos.length}/$_maxFotos',
                    style: TextStyle(fontSize: 10, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
          );
        }
        // Foto adicionada (placeholder)
        return Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF00C6D7).withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Icon(Icons.image_rounded,
                    color: Color(0xFF0077B6), size: 32),
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () => _removerFoto(index),
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE53E3E),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close_rounded,
                      color: Colors.white, size: 14),
                ),
              ),
            ),
          ],
        );
      },
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
        height: 54,
        decoration: BoxDecoration(
          gradient: loading ? null : const LinearGradient(
            colors: [Color(0xFF00C6D7), Color(0xFF0077B6)],
          ),
          color: loading ? Colors.grey[300] : null,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5),
                )
              : const Text(
                  'Continuar',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }
}
