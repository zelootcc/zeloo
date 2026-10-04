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
    final campos = <String, dynamic>{
      'rua': '',
      'numero': '',
      'bairro': '',
      'cidade': '',
      'estado': '',
      'cep': '',
      'complemento': '',
    };
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
          campos.addAll({
            'rua': local.thoroughfare ?? '',
            'numero': local.subThoroughfare ?? '',
            'bairro': local.subLocality ?? '',
            'cidade':
                (local.locality?.isNotEmpty == true
                    ? local.locality
                    : local.subAdministrativeArea) ??
                '',
            'estado': _uf(local.administrativeArea ?? ''),
            'cep': _cep(local.postalCode ?? ''),
          });
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
      ...campos,
      'logradouro': endereco,
      'latitude': posicao.latitude,
      'longitude': posicao.longitude,
    };
  }

  static String _cep(String valor) {
    final digitos = valor.replaceAll(RegExp(r'\D'), '');
    return digitos.length == 8
        ? '${digitos.substring(0, 5)}-${digitos.substring(5)}'
        : '';
  }

  static String _uf(String valor) {
    if (valor.trim().length == 2) return valor.trim().toUpperCase();
    const estados = {
      'acre': 'AC',
      'alagoas': 'AL',
      'amapá': 'AP',
      'amazonas': 'AM',
      'bahia': 'BA',
      'ceará': 'CE',
      'distrito federal': 'DF',
      'espírito santo': 'ES',
      'goiás': 'GO',
      'maranhão': 'MA',
      'mato grosso': 'MT',
      'mato grosso do sul': 'MS',
      'minas gerais': 'MG',
      'pará': 'PA',
      'paraíba': 'PB',
      'paraná': 'PR',
      'pernambuco': 'PE',
      'piauí': 'PI',
      'rio de janeiro': 'RJ',
      'rio grande do norte': 'RN',
      'rio grande do sul': 'RS',
      'rondônia': 'RO',
      'roraima': 'RR',
      'santa catarina': 'SC',
      'são paulo': 'SP',
      'sergipe': 'SE',
      'tocantins': 'TO',
    };
    return estados[valor.trim().toLowerCase()] ?? '';
  }
}
