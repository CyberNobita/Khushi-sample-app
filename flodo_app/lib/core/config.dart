import 'package:flutter/foundation.dart';

class AppConfig {
  const AppConfig._();

  static const String _productionApiBaseUrl =
      'https://khushi.sbpgm.com/api/v1';

  static String get apiBaseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) {
      return fromEnv;
    }

    if (kIsWeb) {
      return _productionApiBaseUrl;
    }

    return _productionApiBaseUrl;
  }
}
