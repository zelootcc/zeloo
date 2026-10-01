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
}
