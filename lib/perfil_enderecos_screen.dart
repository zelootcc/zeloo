import 'package:flutter/material.dart';
import 'perfil_editar_screen.dart';

class _Endereco {
  String apelido;
  String logradouro;
  bool principal;

  _Endereco({
    required this.apelido,
    required this.logradouro,
    this.principal = false,
  });
}

class PerfilEnderecosScreen extends StatefulWidget {
  const PerfilEnderecosScreen({super.key});

  @override
  State<PerfilEnderecosScreen> createState() => _PerfilEnderecosScreenState();
}

class _PerfilEnderecosScreenState extends State<PerfilEnderecosScreen> {
  final List<_Endereco> _enderecos = [
    _Endereco(
      apelido: 'Casa',
      logradouro: 'Rua das Flores, 123 - Centro',
      principal: true,
    ),
  ];

  void _adicionarEndereco() {
    final apelidoCtrl = TextEditingController();
    final logradouroCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _ModalEndereco(
        apelidoCtrl: apelidoCtrl,
        logradouroCtrl: logradouroCtrl,
        onSalvar: () {
          if (apelidoCtrl.text.trim().isEmpty ||
              logradouroCtrl.text.trim().isEmpty)
            return;
          setState(() {
            _enderecos.add(
              _Endereco(
                apelido: apelidoCtrl.text.trim(),
                logradouro: logradouroCtrl.text.trim(),
              ),
            );
          });
          Navigator.pop(ctx);
        },
      ),
    );
  }

  void _remover(int index) {
    setState(() => _enderecos.removeAt(index));
  }

  void _tornarPrincipal(int index) {
    setState(() {
      for (var e in _enderecos) {
        e.principal = false;
      }
      _enderecos[index].principal = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBarGradiente(
  titulo: 'Configurações',
  subtitulo: 'Gerencie suas preferências',
),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 8),
            ..._enderecos.asMap().entries.map(
              (e) => _CardEndereco(
                endereco: e.value,
                onRemover: () => _remover(e.key),
                onTornarPrincipal: () => _tornarPrincipal(e.key),
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _adicionarEndereco,
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
                      'Adicionar local',
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

class _CardEndereco extends StatelessWidget {
  final _Endereco endereco;
  final VoidCallback onRemover;
  final VoidCallback onTornarPrincipal;

  const _CardEndereco({
    required this.endereco,
    required this.onRemover,
    required this.onTornarPrincipal,
  });

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: Color(0xFF4CAF50),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      endereco.apelido,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    if (endereco.principal) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Principal',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  endereco.logradouro,
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    if (!endereco.principal)
                      GestureDetector(
                        onTap: onTornarPrincipal,
                        child: Text(
                          'Tornar principal',
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFF0077B6),
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

class _ModalEndereco extends StatelessWidget {
  final TextEditingController apelidoCtrl;
  final TextEditingController logradouroCtrl;
  final VoidCallback onSalvar;

  const _ModalEndereco({
    required this.apelidoCtrl,
    required this.logradouroCtrl,
    required this.onSalvar,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
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
            const Text(
              'Novo endereço',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Apelido',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _CampoModal(controller: apelidoCtrl, hint: 'Ex: Casa, Trabalho'),
            const SizedBox(height: 16),
            const Text(
              'Endereço',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            _CampoModal(
              controller: logradouroCtrl,
              hint: 'Rua, número - Bairro',
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onSalvar,
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
                    'Salvar',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CampoModal extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const _CampoModal({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
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
          borderSide: const BorderSide(color: Color(0xFF00C6D7), width: 2),
        ),
      ),
    );
  }
}