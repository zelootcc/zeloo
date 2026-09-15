import 'package:flutter/material.dart';

import 'firebase_service.dart';

const _gradient = LinearGradient(
  colors: [Color(0xFF00C6D7), Color(0xFF0077B6)],
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
);

class MeusServicosScreen extends StatefulWidget {
  const MeusServicosScreen({super.key});

  @override
  State<MeusServicosScreen> createState() => _MeusServicosScreenState();
}

class _MeusServicosScreenState extends State<MeusServicosScreen> {
  Future<void> _adicionarServico() async {
    final tituloCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final precoCtrl = TextEditingController();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const Text(
                'Novo Serviço',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 20),
              const _LabelModal('Título *'),
              const SizedBox(height: 8),
              _CampoModal(
                controller: tituloCtrl,
                hint: 'Ex.: Instalação Elétrica',
              ),
              const SizedBox(height: 14),
              const _LabelModal('Descrição'),
              const SizedBox(height: 8),
              _CampoModal(
                controller: descCtrl,
                hint: 'Descreva o serviço oferecido',
                maxLines: 3,
              ),
              const SizedBox(height: 14),
              const _LabelModal('Valor por hora (R\$)'),
              const SizedBox(height: 8),
              _CampoModal(
                controller: precoCtrl,
                hint: 'Ex.: 80',
                tipo: TextInputType.number,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    final titulo = tituloCtrl.text.trim();
                    final preco = double.tryParse(
                      precoCtrl.text.trim().replaceAll(',', '.'),
                    );

                    if (titulo.isEmpty) return;

                    if (preco == null || preco < 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Digite um valor válido.'),
                        ),
                      );
                      return;
                    }

                    try {
                      final profissional =
                          await FirebaseService.dadosProfissional();
                      final dados = profissional?.data() ?? {};
                      final categoria = dados['area']?.toString() ?? 'Serviço';

                      await FirebaseService.adicionarServico(
                        titulo: titulo,
                        descricao: descCtrl.text.trim(),
                        preco: preco,
                        categoria: categoria,
                      );

                      if (ctx.mounted) Navigator.pop(ctx);
                    } catch (e) {
                      if (!ctx.mounted) return;

                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(content: Text('Erro ao adicionar: $e')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0077B6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Adicionar Serviço',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );

    tituloCtrl.dispose();
    descCtrl.dispose();
    precoCtrl.dispose();
  }

  Future<void> _remover(String id) async {
    try {
      await FirebaseService.removerServico(id);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao remover serviço: $e')),
      );
    }
  }

  Future<void> _alternarAtivo(String id, bool ativo) async {
    try {
      await FirebaseService.atualizarServico(id, {'ativo': !ativo});
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao atualizar serviço: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: StreamBuilder(
        stream: FirebaseService.meusServicos(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Não foi possível carregar seus serviços.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final servicos = snapshot.data?.docs ?? [];

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 140,
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
                    padding: const EdgeInsets.fromLTRB(24, 56, 24, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Meus Serviços',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Gerencie o que você oferece',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              if (servicos.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text('Você ainda não possui serviços cadastrados.'),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final doc = servicos[index];
                        final dados = doc.data() as Map<String, dynamic>;

                        return _CardServico(
                          dados: dados,
                          onRemover: () => _remover(doc.id),
                          onToggleAtivo: () => _alternarAtivo(
                            doc.id,
                            dados['ativo'] == true,
                          ),
                        );
                      },
                      childCount: servicos.length,
                    ),
                  ),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: _adicionarServico,
                      icon: const Icon(
                        Icons.add_rounded,
                        color: Color(0xFF0077B6),
                      ),
                      label: const Text(
                        'Adicionar Serviço',
                        style: TextStyle(
                          color: Color(0xFF0077B6),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        backgroundColor: Colors.white,
                        side: const BorderSide(
                          color: Color(0xFF00C6D7),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CardServico extends StatelessWidget {
  final Map<String, dynamic> dados;
  final VoidCallback onRemover;
  final VoidCallback onToggleAtivo;

  const _CardServico({
    required this.dados,
    required this.onRemover,
    required this.onToggleAtivo,
  });

  String _texto(dynamic valor, [String padrao = 'Não informado']) {
    if (valor == null || valor.toString().trim().isEmpty) return padrao;
    return valor.toString();
  }

  @override
  Widget build(BuildContext context) {
    final titulo = _texto(dados['titulo'], 'Serviço');
    final descricao = _texto(dados['descricao'], 'Sem descrição');
    final preco = dados['preco'] is num
        ? (dados['preco'] as num).toDouble()
        : double.tryParse(
              _texto(dados['preco'], '0').replaceAll(',', '.'),
            ) ??
            0;
    final ativo = dados['ativo'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF00B4D8).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.handyman_rounded,
              color: Color(0xFF0077B6),
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        titulo,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: Color(0xFF1A1A2E),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: ativo
                            ? const Color(0xFF4CAF50).withOpacity(0.12)
                            : Colors.grey.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        ativo ? 'Ativo' : 'Inativo',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: ativo ? const Color(0xFF4CAF50) : Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  descricao,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                const SizedBox(height: 8),
                Text(
                  'R\$ ${preco.toStringAsFixed(2)}/h',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0077B6),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    GestureDetector(
                      onTap: onToggleAtivo,
                      child: Text(
                        ativo ? 'Desativar' : 'Ativar',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF0077B6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: onRemover,
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        color: Color(0xFFE53E3E),
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LabelModal extends StatelessWidget {
  final String text;

  const _LabelModal(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _CampoModal extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType tipo;
  final int maxLines;

  const _CampoModal({
    required this.controller,
    required this.hint,
    this.tipo = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: tipo,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        filled: true,
        fillColor: const Color(0xFFF4F7FB),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Color(0xFF00C6D7),
            width: 2,
          ),
        ),
      ),
    );
  }
}
