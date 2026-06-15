import 'package:dio/dio.dart';

import '../network/api_constants.dart';
import 'token_manager.dart';

class AuthInterceptor extends Interceptor {
  final TokenManager _tokenManager;

  AuthInterceptor(this._tokenManager);

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.path == ApiConstants.login) {
      handler.next(options);
      return;
    }

    final accessToken = await _tokenManager.readAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }
}
