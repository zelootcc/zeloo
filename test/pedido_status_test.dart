import 'package:aplicativo_zeloo/pedido_status.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pedido avança pelos grupos exibidos ao cliente e profissional', () {
    expect(
      PedidoStatus.pertenceAoFiltro(PedidoStatus.aguardando, 'Aguardando'),
      isTrue,
    );
    expect(
      PedidoStatus.pertenceAoFiltro(PedidoStatus.aCaminho, 'Ativos'),
      isTrue,
    );
    expect(
      PedidoStatus.pertenceAoFiltro(PedidoStatus.emAndamento, 'Ativos'),
      isTrue,
    );
    expect(
      PedidoStatus.pertenceAoFiltro(PedidoStatus.concluido, 'Concluídos'),
      isTrue,
    );
  });

  test(
    'código aparece somente antes do início e pedido antigo é compatível',
    () {
      expect(PedidoStatus.normalizar('confirmado'), PedidoStatus.aceito);
      expect(
        PedidoStatus.codigoVisivelParaCliente(PedidoStatus.aceito),
        isTrue,
      );
      expect(
        PedidoStatus.codigoVisivelParaCliente(PedidoStatus.aguardandoCodigo),
        isTrue,
      );
      expect(
        PedidoStatus.codigoVisivelParaCliente(PedidoStatus.emAndamento),
        isFalse,
      );
      expect(PedidoStatus.podeCancelar(PedidoStatus.emAndamento), isFalse);
    },
  );

  test(
    'chat permanece disponível durante o atendimento e fecha ao encerrar',
    () {
      expect(PedidoStatus.chatDisponivel(PedidoStatus.aguardando), isTrue);
      expect(PedidoStatus.chatDisponivel(PedidoStatus.aCaminho), isTrue);
      expect(PedidoStatus.chatDisponivel(PedidoStatus.emAndamento), isTrue);
      expect(
        PedidoStatus.chatDisponivel(PedidoStatus.aguardandoConclusao),
        isTrue,
      );
      expect(PedidoStatus.chatDisponivel(PedidoStatus.concluido), isFalse);
      expect(PedidoStatus.chatDisponivel(PedidoStatus.cancelado), isFalse);
    },
  );
}
