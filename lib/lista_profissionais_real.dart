import 'package:flutter/material.dart';

import 'firebase_service.dart';
import 'profissional_model.dart';

class ListaProfissionaisRealScreen extends StatefulWidget {
  final String? filtroEspecialidade;

  const ListaProfissionaisRealScreen({
    super.key,
    this.filtroEspecialidade,
  });

  @override
  State<ListaProfissionaisRealScreen> createState() =>
      _ListaProfissionaisRealScreenState();
}

class _ListaProfissionaisRealScreenState
    extends State<ListaProfissionaisRealScreen> {
  final busca = TextEditingController();
  String query = '';
  late String filtro;

  static const filtros = [
    'Todos',
    'Eletricista',
    'Encanador',
    'Limpeza',
    'Mecânico',
    'Pintor',
    'Jardineiro',
    'Marceneiro',
    'Serviços Gerais',
  ];

  @override
  void initState() {
    super.initState();
    filtro = widget.filtroEspecialidade ?? 'Todos';
    busca.addListener(() {
      setState(() => query = busca.text.toLowerCase().trim());
    });
  }

  @override
  void dispose() {
    busca.dispose();
    super.dispose();
  }

  ProfissionalModel converter(
    String id,
    Map<String, dynamic> dados,
  ) {
    final valor = dados['precoHora'] ?? dados['valorHora'] ?? dados['preco'];
    final preco = valor is num
        ? valor.toDouble()
        : double.tryParse(
              valor?.toString().replaceAll(',', '.') ?? '',
            ) ??
            0;

    final disponibilidade =
        dados['disponibilidade']?.toString().toLowerCase() ?? '';

    final disponivel = dados['disponivel'] is bool
        ? dados['disponivel'] as bool
        : disponibilidade.isEmpty ||
            (!disponibilidade.contains('ocupado') &&
                !disponibilidade.contains('indispon'));

    final avaliacao = dados['avaliacao'] is num
        ? (dados['avaliacao'] as num).toDouble()
        : 0.0;

    final totalAvaliacoes = dados['totalAvaliacoes'] is num
        ? (dados['totalAvaliacoes'] as num).toInt()
        : 0;

    return ProfissionalModel(
      id: id,
      nome: dados['nome']?.toString() ?? 'Profissional',
      especialidade: dados['area']?.toString() ??
          dados['especialidade']?.toString() ??
          'Serviço',
      avaliacao: avaliacao,
      totalAvaliacoes: totalAvaliacoes,
      cidade: dados['regiao']?.toString() ??
          dados['cidade']?.toString() ??
          'Não informado',
      descricao: dados['descricao']?.toString() ??
          dados['descricaoProfissional']?.toString() ??
          'Profissional cadastrado na Zeloo.',
      precoHora: preco,
      disponivel: disponivel,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: StreamBuilder(
        stream: FirebaseService.profissionais(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar profissionais.\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final lista = (snapshot.data?.docs ?? [])
              .map((doc) => converter(doc.id, doc.data()))
              .where((profissional) {
            final nome = profissional.nome.toLowerCase();
            final especialidade = profissional.especialidade.toLowerCase();

            return (filtro == 'Todos' ||
                    especialidade == filtro.toLowerCase()) &&
                (query.isEmpty ||
                    nome.contains(query) ||
                    especialidade.contains(query));
          }).toList();

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 190,
                pinned: true,
                backgroundColor: const Color(0xFF0077B6),
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: const FlexibleSpaceBar(
                  title: Text('Profissionais'),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextField(
                    controller: busca,
                    decoration: InputDecoration(
                      hintText: 'Buscar por nome ou especialidade',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 52,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: filtros.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, index) {
                      final item = filtros[index];

                      return ChoiceChip(
                        label: Text(item),
                        selected: filtro == item,
                        onSelected: (_) => setState(() => filtro = item),
                      );
                    },
                  ),
                ),
              ),
              if (lista.isEmpty)
                const SliverFillRemaining(
                  child: Center(
                    child: Text('Nenhum profissional encontrado.'),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, index) => _CardProfissional(
                        profissional: lista[index],
                      ),
                      childCount: lista.length,
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

class _CardProfissional extends StatelessWidget {
  final ProfissionalModel profissional;

  const _CardProfissional({required this.profissional});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: const CircleAvatar(
          child: Icon(Icons.person),
        ),
        title: Text(
          profissional.nome,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${profissional.especialidade}\n${profissional.cidade}',
        ),
        trailing: Text(
          profissional.disponivel ? 'Disponível' : 'Ocupado',
          style: TextStyle(
            color: profissional.disponivel ? Colors.green : Colors.grey,
          ),
        ),      ),
    );
  }
}
