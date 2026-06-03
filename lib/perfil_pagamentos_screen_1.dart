import 'package:flutter/material.dart';

class _Cartao {
  String bandeira;
  String ultimos4;
  bool principal;

  _Cartao({required this.bandeira, required this.ultimos4, this.principal = false});
}

class PerfilPagamentosScreen extends StatefulWidget {
  const PerfilPagamentosScreen({super.key});

  @override
  State<PerfilPagamentosScreen> createState() => _PerfilPagamentosScreenState();
}

class _PerfilPagamentosScreenState extends State<PerfilPagamentosScreen> {
  final List<_Cartao> _cartoes = [
    _Cartao(bandeira: 'Visa', ultimos4: '1234', principal: true),
    _Cartao(bandeira: 'Mastercard', ultimos4: '1234'),
  ];

  void _adicionarCartao() {
    final numeroCtrl = TextEditingController();
    final bandeiraCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
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
              const Text(
                'Adicionar cartão',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF1A1A2E)),
              ),
              const SizedBox(height: 20),
              const Text('Bandeira', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _CampoModal(controller: bandeiraCtrl, hint: 'Ex: Visa, Mastercard'),
              const SizedBox(height: 16),
              const Text('Número do cartão', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              _CampoModal(
                controller: numeroCtrl,
                hint: '**** **** **** 0000',
                tipo: TextInputType.number,
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  if (bandeiraCtrl.text.trim().isEmpty || numeroCtrl.text.trim().isEmpty) return;
                  final numero = numeroCtrl.text.replaceAll(' ', '').replaceAll('*', '');
                  final ultimos = numero.length >= 4
                      ? numero.substring(numero.length - 4)
                      : numero.padLeft(4, '0');
                  setState(() {
                    _cartoes.add(_Cartao(bandeira: bandeiraCtrl.text.trim(), ultimos4: ultimos));
                  });
                  Navigator.pop(ctx);
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00C6D7), Color(0xFF0077B6)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text(
                      'Adicionar',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _remover(int index) {
    setState(() => _cartoes.removeAt(index));
  }

  void _tornarPrincipal(int index) {
    setState(() {
      for (var c in _cartoes) {
        c.principal = false;
      }
      _cartoes[index].principal = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: _AppBarGradiente(titulo: 'Configurações', subtitulo: 'Gerencie suas preferências'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 8),
            ..._cartoes.asMap().entries.map((e) => _CardCartao(
                  cartao: e.value,
                  onRemover: () => _remover(e.key),
                  onTornarPrincipal: () => _tornarPrincipal(e.key),
                )),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _adicionarCartao,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFF00C6D7).withOpacity(0.4),
                    width: 1.5,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_rounded, color: Color(0xFF0077B6), size: 20),
                    SizedBox(width: 6),
                    Text(
                      'Adicionar Cartão',
                      style: TextStyle(
                        color: Color(0xFF0077B6),
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
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

class _CardCartao extends StatelessWidget {
  final _Cartao cartao;
  final VoidCallback onRemover;
  final VoidCallback onTornarPrincipal;

  const _CardCartao({
    required this.cartao,
    required this.onRemover,
    required this.onTornarPrincipal,
  });

  IconData get _icone {
    switch (cartao.bandeira.toLowerCase()) {
      case 'visa':
        return Icons.credit_card_rounded;
      case 'mastercard':
        return Icons.credit_card_rounded;
      default:
        return Icons.credit_card_rounded;
    }
  }

  Color get _cor {
    switch (cartao.bandeira.toLowerCase()) {
      case 'visa':
        return const Color(0xFF1A1F71);
      case 'mastercard':
        return const Color(0xFFEB001B);
      default:
        return const Color(0xFF0077B6);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _cor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(_icone, color: _cor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      cartao.bandeira,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    if (cartao.principal) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0077B6).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Principal',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0077B6),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  '**** **** **** ${cartao.ultimos4}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                if (!cartao.principal) ...[
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: onTornarPrincipal,
                    child: const Text(
                      'Tornar principal',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF0077B6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          GestureDetector(
            onTap: onRemover,
            child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFE53E3E), size: 20),
          ),
        ],
      ),
    );
  }
}

class _CampoModal extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType tipo;

  const _CampoModal({
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
        fillColor: const Color(0xFFF4F7FB),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF00C6D7), width: 2),
        ),
      ),
    );
  }
}

class _AppBarGradiente extends StatelessWidget implements PreferredSizeWidget {
  final String titulo;
  final String subtitulo;

  const _AppBarGradiente({required this.titulo, required this.subtitulo});

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
                icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 28),
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
