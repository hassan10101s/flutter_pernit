import 'package:dio/dio.dart';

import '../config/env_config.dart';

class PublicDioFactory {
  final EnvConfig _envConfig;

  const PublicDioFactory(this._envConfig);

  Dio create() {
    return Dio(
      BaseOptions(
        baseUrl: _envConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: const {'Accept': 'application/json'},
      ),
    );
  }
}
