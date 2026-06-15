import 'package:dio/dio.dart';

import '../auth/auth_interceptor.dart';
import '../config/env_config.dart';

class SecureDioFactory {
  final EnvConfig _envConfig;
  final AuthInterceptor _authInterceptor;

  const SecureDioFactory(this._envConfig, this._authInterceptor);

  Dio create() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _envConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: const {'Accept': 'application/json'},
      ),
    );
    dio.interceptors.add(_authInterceptor);
    return dio;
  }
}
