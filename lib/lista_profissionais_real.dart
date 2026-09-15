import 'package:flutter/material.dart';

import 'agendamento_screen.dart';
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
    busca.addListener(_atualizarBusca);
  }

  void _atualizarBusca() {
    setState(() {
      query = busca.text.toLowerCase().trim();
    });
  }

  @override
  void dispose() {
    busca.removeListener(_atualizarBusca);
    busca.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      body: StreamBuilder(
        stream: FirebaseService.profissionais(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Erro ao carregar profissionais.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final lista = (snapshot.data?.docs ?? [])
              .map(
                (doc) => ProfissionalModel.fromFirestore(
                  doc.id,
                  doc.data(),
                ),
              )
              .where((profissional) {
                final nome = profissional.nome.toLowerCase();
                final especialidade = profissional.especialidade.toLowerCase();

                final correspondeFiltro = filtro == 'Todos' ||
                    especialidade == filtro.toLowerCase();

                final correspondeBusca = query.isEmpty ||
                    nome.contains(query) ||
                    especialidade.contains(query) ||
                    profissional.cidade.toLowerCase().contains(query);

                return correspondeFiltro && correspondeBusca;
              })
              .toList();

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
                      hintText: 'Buscar por nome, serviço ou cidade',
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
                        onSelected: (_) {
                          setState(() => filtro = item);
                        },
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
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
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
        ),
        onTap: profissional.disponivel
            ? () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AgendamentoScreen(
                      profissional: profissional,
                    ),
                  ),
                )
            : null,
      ),
    );
  }
}
