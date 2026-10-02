import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'firebase_service.dart';
import 'pedido_status.dart';
import 'relatorio_ganhos.dart';
import 'zeloo_ui.dart';

class RelatoriosProfissionalScreen extends StatelessWidget {
  const RelatoriosProfissionalScreen({super.key});

  String _dinheiro(double valor) =>
      'R\$ ${valor.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFF4F7FB),
    appBar: const AppBarZeloo(
      titulo: 'Relatórios',
      subtitulo: 'Acompanhe seus serviços e ganhos',
    ),
    body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseService.meusPedidosProfissional(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(
            child: Text('Não foi possível calcular os relatórios.'),
          );
        }

        final ganhos = <GanhoServico>[];
        for (final doc in snapshot.data?.docs ?? []) {
          final dados = doc.data();
          if (PedidoStatus.normalizar(dados['status']?.toString() ?? '') !=
              PedidoStatus.concluido) {
            continue;
          }
          final data =
              dados['concluidoEm'] as Timestamp? ??
              dados['atualizadoEm'] as Timestamp?;
          final valor = (dados['valor'] as num?)?.toDouble();
          if (data != null && valor != null) {
            ganhos.add(GanhoServico(valor: valor, concluidoEm: data.toDate()));
          }
        }
        final resumo = ResumoGanhos.calcular(ganhos);

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: zelooGradiente,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: zelooAzul.withValues(alpha: 0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ganhos nos últimos 7 dias',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    _dinheiro(resumo.totalUltimosSeteDias),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${resumo.servicosUltimosSeteDias} serviço${resumo.servicosUltimosSeteDias == 1 ? '' : 's'} concluído${resumo.servicosUltimosSeteDias == 1 ? '' : 's'}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MetricaCard(
                    titulo: 'Total do mês',
                    valor: _dinheiro(resumo.totalMes),
                    detalhe: '${resumo.servicosMes} serviços',
                    icon: Icons.account_balance_wallet_rounded,
                    cor: const Color(0xFF4CAF50),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricaCard(
                    titulo: 'Média por serviço',
                    valor: _dinheiro(resumo.mediaPorServicoMes),
                    detalhe: 'neste mês',
                    icon: Icons.calculate_rounded,
                    cor: const Color(0xFFFF9800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _MetricaCard(
              titulo: 'Média diária no mês',
              valor: _dinheiro(resumo.mediaDiariaMes),
              detalhe: 'total do mês dividido pelos dias decorridos',
              icon: Icons.calendar_month_rounded,
              cor: const Color(0xFF8E5BC7),
            ),
            const SizedBox(height: 22),
            const Text(
              'Resumo da última semana',
              style: TextStyle(
                color: zelooTexto,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            _GraficoSemana(valores: resumo.valoresPorDia),
            const SizedBox(height: 14),
            const Text(
              'O relatório considera o valor dos pedidos marcados como concluídos.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF718496),
                fontSize: 11,
                height: 1.35,
              ),
            ),
          ],
        );
      },
    ),
  );
}

class _MetricaCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final String detalhe;
  final IconData icon;
  final Color cor;

  const _MetricaCard({
    required this.titulo,
    required this.valor,
    required this.detalhe,
    required this.icon,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: painelZeloo(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: cor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: cor, size: 21),
        ),
        const SizedBox(height: 12),
        Text(
          titulo,
          style: const TextStyle(color: Color(0xFF718496), fontSize: 11),
        ),
        const SizedBox(height: 4),
        Text(
          valor,
          style: const TextStyle(
            color: zelooTexto,
            fontSize: 17,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          detalhe,
          style: const TextStyle(color: Color(0xFF8DA0B0), fontSize: 10),
        ),
      ],
    ),
  );
}

class _GraficoSemana extends StatelessWidget {
  final List<double> valores;

  const _GraficoSemana({required this.valores});

  @override
  Widget build(BuildContext context) {
    final hoje = DateTime.now();
    final maximo = math.max(1.0, valores.fold<double>(0, math.max));
    const dias = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];
    return Container(
      height: 190,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      decoration: painelZeloo(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
          final data = hoje.subtract(Duration(days: 6 - index));
          final altura = 105 * (valores[index] / maximo);
          final destaque = index == 6;
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  valores[index] == 0 ? '' : valores[index].toStringAsFixed(0),
                  style: const TextStyle(
                    color: Color(0xFF718496),
                    fontSize: 8,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 22,
                  height: math.max(5, altura),
                  decoration: BoxDecoration(
                    gradient: destaque ? zelooGradiente : null,
                    color: destaque ? null : const Color(0xFFBDEAF0),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  '${dias[data.weekday % 7]}\n${data.day}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: destaque ? zelooAzul : const Color(0xFF718496),
                    fontSize: 9,
                    fontWeight: destaque ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
