import 'package:dio/dio.dart';

import '../network/api_constants.dart';
import 'refresh_mutex.dart';
import 'token_pair.dart';
import 'token_manager.dart';
import 'token_refresh_gateway.dart';

class AuthInterceptor extends Interceptor {
  static const _authRetryExtraKey = 'authRetry';

  final TokenManager _tokenManager;
  final TokenRefreshGateway _tokenRefreshGateway;
  final RefreshMutex _refreshMutex;
  Dio? _dio;

  AuthInterceptor(
    this._tokenManager,
    this._tokenRefreshGateway,
    this._refreshMutex,
  );

  void attach(Dio dio) {
    _dio = dio;
  }

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (_isPublicAuthEndpoint(options.path)) {
      handler.next(options);
      return;
    }

    final accessToken = await _tokenManager.readAccessToken();
    if (accessToken != null && accessToken.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final response = err.response;
    final requestOptions = err.requestOptions;
    final alreadyRetried = requestOptions.extra[_authRetryExtraKey] == true;

    if (response?.statusCode != 401 ||
        alreadyRetried ||
        _dio == null ||
        _isPublicAuthEndpoint(requestOptions.path)) {
      handler.next(err);
      return;
    }

    final refreshToken = await _tokenManager.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      await _tokenManager.clearTokens();
      handler.next(err);
      return;
    }

    final tokenPair = await _refreshTokens(refreshToken);
    if (tokenPair == null || !tokenPair.isComplete) {
      await _tokenManager.clearTokens();
      handler.next(err);
      return;
    }

    try {
      final retryOptions = requestOptions.copyWith(
        headers: {
          ...requestOptions.headers,
          'Authorization': 'Bearer ${tokenPair.accessToken}',
        },
        extra: {...requestOptions.extra, _authRetryExtraKey: true},
      );
      final retryResponse = await _dio!.fetch<dynamic>(retryOptions);
      handler.resolve(retryResponse);
    } on DioException catch (retryError) {
      handler.next(retryError);
    } on Object {
      handler.next(err);
    }
  }

  Future<TokenPair?> _refreshTokens(String refreshToken) async {
    try {
      return _refreshMutex.run(() async {
        final tokenPair = await _tokenRefreshGateway.refreshToken(refreshToken);
        if (!tokenPair.isComplete) {
          return null;
        }

        await _tokenManager.saveTokens(
          accessToken: tokenPair.accessToken,
          refreshToken: tokenPair.refreshToken,
        );
        return tokenPair;
      });
    } on Object {
      return null;
    }
  }

  bool _isPublicAuthEndpoint(String path) {
    return path.endsWith(ApiConstants.login) ||
        path.endsWith(ApiConstants.logout) ||
        path.endsWith(ApiConstants.tokenRefresh) ||
        path.endsWith(ApiConstants.tokenVerify);
  }
}
