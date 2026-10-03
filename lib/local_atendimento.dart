// Uma cópia do endereço fica no pedido, mesmo se o cliente apagar o local salvo.
Map<String, dynamic> dadosLocalAtendimento(Map<String, dynamic> local) {
  final endereco = local['logradouro'];
  final complemento = local['complemento'] ?? '';
  if (endereco is! String ||
      endereco.trim().length < 5 ||
      endereco.length > 300 ||
      complemento is! String ||
      complemento.length > 150) {
    throw ArgumentError('Informe o endereço completo do atendimento.');
  }
  final dados = <String, dynamic>{
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
