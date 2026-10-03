import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

class ErroLocalizacao implements Exception {
  final String mensagem;
  const ErroLocalizacao(this.mensagem);
}

class LocalizacaoService {
  // Captura uma vez ao tocar no botão. Não acompanha a pessoa em segundo plano.
  static Future<Map<String, dynamic>> atual() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const ErroLocalizacao(
        'Ative a localização do celular e tente novamente.',
      );
    }
    var permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
    }
    if (permissao == LocationPermission.deniedForever) {
      throw const ErroLocalizacao(
        'Permita a localização nas configurações do aplicativo ou digite o endereço.',
      );
    }
    if (permissao != LocationPermission.whileInUse &&
        permissao != LocationPermission.always) {
      throw const ErroLocalizacao(
        'Localização não autorizada. Você pode digitar o endereço.',
      );
    }
    final Position posicao;
    try {
      posicao = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
    } on TimeoutException {
      throw const ErroLocalizacao(
        'Não foi possível localizar a tempo. Tente novamente ou digite o endereço.',
      );
    }
    var endereco = '';
    // A tradução das coordenadas usa o serviço nativo do Android/iOS.
    // Se ele falhar, preservamos o ponto e pedimos o endereço por escrito.
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)) {
      try {
        final locais = await Geocoding()
            .placemarkFromCoordinates(posicao.latitude, posicao.longitude)
            .timeout(const Duration(seconds: 8));
        if (locais.isNotEmpty) {
          final local = locais.first;
          endereco =
              [
                    local.street,
                    local.subLocality,
                    local.locality,
                    local.administrativeArea,
                    local.postalCode,
                  ]
                  .whereType<String>()
                  .where((parte) => parte.trim().isNotEmpty)
                  .join(', ');
        }
      } catch (_) {
        // Sem conversão disponível, o usuário ainda pode confirmar o endereço.
      }
    }
    return {
      'logradouro': endereco,
      'latitude': posicao.latitude,
      'longitude': posicao.longitude,
    };
  }
}
