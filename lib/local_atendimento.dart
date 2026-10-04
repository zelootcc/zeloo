// Uma cópia do endereço fica no pedido, mesmo se o cliente apagar o local salvo.
Map<String, dynamic> dadosLocalAtendimento(Map<String, dynamic> local) {
  final separado = <String, dynamic>{};
  var endereco = local['logradouro'];
  if (local.containsKey('rua')) {
    for (final chave in [
      'rua',
      'numero',
      'bairro',
      'cidade',
      'estado',
      'cep',
    ]) {
      final valor = local[chave];
      if (valor is! String || valor.trim().isEmpty || valor.length > 120) {
        throw ArgumentError('Preencha rua, número, bairro, cidade, UF e CEP.');
      }
      separado[chave] = valor.trim();
    }
    separado['estado'] = (separado['estado'] as String).toUpperCase();
    final cep = (separado['cep'] as String).replaceAll(RegExp(r'\D'), '');
    if (!RegExp(r'^\d{8}$').hasMatch(cep) ||
        !RegExp(
          r'^(AC|AL|AP|AM|BA|CE|DF|ES|GO|MA|MT|MS|MG|PA|PB|PR|PE|PI|RJ|RN|RS|RO|RR|SC|SP|SE|TO)$',
        ).hasMatch(separado['estado'] as String)) {
      throw ArgumentError('Informe um CEP com 8 dígitos e uma UF válida.');
    }
    separado['cep'] = '${cep.substring(0, 5)}-${cep.substring(5)}';
    endereco =
        '${separado['rua']}, ${separado['numero']} — ${separado['bairro']}, '
        '${separado['cidade']} / ${separado['estado']} — CEP ${separado['cep']}';
  }
  final complemento = local['complemento'] ?? '';
  if (endereco is! String ||
      endereco.trim().length < 5 ||
      endereco.length > 300 ||
      complemento is! String ||
      complemento.length > 150) {
    throw ArgumentError('Informe o endereço completo do atendimento.');
  }
  final dados = <String, dynamic>{
    ...separado,
    'logradouro': endereco.trim(),
    'complemento': complemento.trim(),
  };
  final latitude = local['latitude'];
  final longitude = local['longitude'];
  if (latitude != null || longitude != null) {
    if (latitude is! num ||
        longitude is! num ||
        !latitude.isFinite ||
        !longitude.isFinite ||
        latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      throw ArgumentError('Coordenadas inválidas.');
    }
    dados['latitude'] = latitude.toDouble();
    dados['longitude'] = longitude.toDouble();
  }
  return dados;
}

Uri mapaLocalAtendimento(Map<String, dynamic> local) =>
    Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': local['latitude'] is num && local['longitude'] is num
          ? '${local['latitude']},${local['longitude']}'
          : local['logradouro'].toString(),
    });
