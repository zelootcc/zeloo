import 'local_atendimento.dart';

/// Aplica uma alteração à versão mais recente da lista dentro da transação.
List<Map<String, dynamic>> atualizarListaPrivada(
  List<dynamic> atual, {
  required String campo,
  required String novoId,
  Map<String, dynamic>? adicionar,
  String? remover,
  String? principal,
}) {
  if (!{'enderecos', 'cartoes'}.contains(campo)) {
    throw ArgumentError('Lista inválida.');
  }
  final itens = atual
      .map((item) => Map<String, dynamic>.from(item as Map))
      .toList();
  if (adicionar != null) {
    final campos = campo == 'cartoes'
        ? ['bandeira', 'ultimos4']
        : ['apelido', 'logradouro'];
    final dados = <String, dynamic>{};
    for (final chave in campos) {
      final valor = adicionar[chave];
      if (valor is! String || valor.trim().isEmpty || valor.length > 300) {
        throw ArgumentError('Preencha os dados corretamente.');
      }
      dados[chave] = valor.trim();
    }
    if (campo == 'cartoes' &&
        !RegExp(r'^\d{4}$').hasMatch(dados['ultimos4'] as String)) {
      throw ArgumentError('Informe somente os quatro últimos dígitos.');
    }
    // Metadados opcionais mantêm compatibilidade com os cartões antigos.
    if (campo == 'cartoes') {
      for (final chave in ['titular', 'validade']) {
        final valor = adicionar[chave];
        if (valor != null) {
          if (valor is! String || valor.trim().isEmpty || valor.length > 80) {
            throw ArgumentError('Dados do cartão inválidos.');
          }
          dados[chave] = valor.trim();
        }
      }
      if (adicionar['demonstracao'] == true) dados['demonstracao'] = true;
    }
    if (campo == 'enderecos') {
      final local = dadosLocalAtendimento(adicionar);
      // Mantém os endereços antigos com os mesmos campos.
      if (adicionar.containsKey('complemento')) dados['complemento'] = local['complemento'];
      if (local.containsKey('latitude')) {
        dados['latitude'] = local['latitude'];
        dados['longitude'] = local['longitude'];
      }
    }
    itens.add({...dados, 'id': novoId, 'principal': itens.isEmpty});
  }
  if (remover != null) itens.removeWhere((item) => item['id'] == remover);
  if (principal != null && itens.any((item) => item['id'] == principal)) {
    for (final item in itens) {
      item['principal'] = item['id'] == principal;
    }
  }
  if (itens.isNotEmpty && !itens.any((item) => item['principal'] == true)) {
    itens.first['principal'] = true;
  }
  return itens;
}
