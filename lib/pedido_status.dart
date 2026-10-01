import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PedidoStatus {
  static const aguardando = 'aguardando';
  static const aceito = 'aceito';
  static const aCaminho = 'a_caminho';
  static const aguardandoCodigo = 'aguardando_codigo';
  static const emAndamento = 'em_andamento';
  static const aguardandoConclusao = 'aguardando_conclusao';
  static const concluido = 'concluido';
  static const cancelado = 'cancelado';

  // Pedidos antigos usavam "confirmado". Para eles, tratamos como "aceito".
  static String normalizar(String status) =>
      status == 'confirmado' ? aceito : status;

  static String nome(String status) {
    switch (normalizar(status)) {
      case aceito:
        return 'Aceito';
      case aCaminho:
        return 'A caminho';
      case aguardandoCodigo:
        return 'Aguardando código';
      case emAndamento:
        return 'Em andamento';
      case aguardandoConclusao:
        return 'Aguardando confirmação';
      case concluido:
        return 'Concluído';
      case cancelado:
        return 'Cancelado';
      default:
        return 'Aguardando';
    }
  }

  static Color cor(String status) {
    switch (normalizar(status)) {
      case aceito:
        return const Color(0xFF0077B6);
      case aCaminho:
        return const Color(0xFF5C6BC0);
      case aguardandoCodigo:
        return const Color(0xFF8E5BC7);
      case emAndamento:
        return const Color(0xFF00A896);
      case aguardandoConclusao:
        return const Color(0xFF0088A9);
      case concluido:
        return const Color(0xFF4CAF50);
      case cancelado:
        return const Color(0xFFE53E3E);
      default:
        return const Color(0xFFFF9800);
    }
  }

  static IconData icone(String status) {
    switch (normalizar(status)) {
      case aCaminho:
        return Icons.directions_car_rounded;
      case aguardandoCodigo:
        return Icons.pin_rounded;
      case emAndamento:
        return Icons.handyman_rounded;
      case aguardandoConclusao:
        return Icons.verified_outlined;
      case concluido:
        return Icons.check_circle_rounded;
      case cancelado:
        return Icons.cancel_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  static bool podeCancelar(String status) => {
    aguardando,
    aceito,
    aCaminho,
    aguardandoCodigo,
  }.contains(normalizar(status));

  static bool codigoVisivelParaCliente(String status) =>
      {aceito, aCaminho, aguardandoCodigo}.contains(normalizar(status));

  static bool pertenceAoFiltro(String status, String filtro) {
    final atual = normalizar(status);
    switch (filtro) {
      case 'Aguardando':
        return atual == aguardando;
      case 'Ativos':
        return {
          aceito,
          aCaminho,
          aguardandoCodigo,
          emAndamento,
          aguardandoConclusao,
        }.contains(atual);
      case 'Concluídos':
        return atual == concluido;
      case 'Cancelados':
        return atual == cancelado;
      default:
        return true;
    }
  }
}

class CronometroPedido extends StatefulWidget {
  final Timestamp iniciadoEm;

  const CronometroPedido({super.key, required this.iniciadoEm});

  @override
  State<CronometroPedido> createState() => _CronometroPedidoState();
}

class ProgressoPedido extends StatelessWidget {
  final String status;

  const ProgressoPedido({super.key, required this.status});

  int get _etapa {
    switch (PedidoStatus.normalizar(status)) {
      case PedidoStatus.aceito:
        return 1;
      case PedidoStatus.aCaminho:
      case PedidoStatus.aguardandoCodigo:
        return 2;
      case PedidoStatus.emAndamento:
        return 3;
      case PedidoStatus.aguardandoConclusao:
      case PedidoStatus.concluido:
        return 4;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    const nomes = ['Pedido', 'Aceito', 'Chegada', 'Em curso', 'Conclusão'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 3, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(nomes.length, (index) {
          final concluida = index <= _etapa;
          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    if (index > 0)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: concluida
                              ? const Color(0xFF00B4C8)
                              : const Color(0xFFDCE6ED),
                        ),
                      ),
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: concluida
                            ? const Color(0xFF00B4C8)
                            : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: concluida
                              ? const Color(0xFF00B4C8)
                              : const Color(0xFFB7C6D2),
                          width: 2,
                        ),
                      ),
                    ),
                    if (index < nomes.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: index < _etapa
                              ? const Color(0xFF00B4C8)
                              : const Color(0xFFDCE6ED),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  nomes[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: concluida ? FontWeight.w700 : FontWeight.w500,
                    color: concluida
                        ? const Color(0xFF0077B6)
                        : const Color(0xFF8DA0B0),
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

class _CronometroPedidoState extends State<CronometroPedido> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _tempo {
    var duracao = DateTime.now().difference(widget.iniciadoEm.toDate());
    if (duracao.isNegative) duracao = Duration.zero;
    final horas = duracao.inHours.toString().padLeft(2, '0');
    final minutos = (duracao.inMinutes % 60).toString().padLeft(2, '0');
    final segundos = (duracao.inSeconds % 60).toString().padLeft(2, '0');
    return '$horas:$minutos:$segundos';
  }

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.timer_outlined, size: 18, color: Color(0xFF0077B6)),
      const SizedBox(width: 7),
      Text(
        _tempo,
        style: const TextStyle(
          color: Color(0xFF0077B6),
          fontWeight: FontWeight.w900,
          letterSpacing: 0.7,
        ),
      ),
    ],
  );
}
