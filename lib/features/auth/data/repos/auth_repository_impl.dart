import 'dart:convert';

import '../../../../core/auth/token_manager.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/errors/api_error_handler.dart';
import '../../../../core/errors/api_result.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/failure_code.dart';
import '../../../../core/network/connection_checker.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/login_credentials.dart';
import '../../domain/repos/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final TokenStore _tokenManager;
  final ConnectionChecker _connectionChecker;
  final ApiErrorHandler _apiErrorHandler;
  final EnvConfig _envConfig;

  const AuthRepositoryImpl(
    this._remoteDataSource,
    this._tokenManager,
    this._connectionChecker,
    this._apiErrorHandler,
    this._envConfig,
  );

  @override
  Future<ApiResult<AuthSession>> login(LoginCredentials credentials) async {
    if (!_envConfig.hasApiBaseUrl) {
      return const ApiFailure(
        Failure(
          code: FailureCode.unknown,
          messageKey: 'failureConfigurationMissing',
        ),
      );
    }

    final hasConnection = await _connectionChecker.hasConnection;
    if (!hasConnection) {
      return const ApiFailure(
        Failure(
          code: FailureCode.internetRequired,
          messageKey: 'failureNetwork',
        ),
      );
    }

    try {
      final response = await _remoteDataSource.login(
        LoginRequestModel.fromCredentials(credentials),
      );
      final session = response.toEntity();
      await _saveSession(session);
      return ApiSuccess(session);
    } on Object catch (error) {
      return ApiFailure(_apiErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<AuthSession>> restoreSession() async {
    final storedValues = await Future.wait<String?>([
      _tokenManager.readRefreshToken(),
      _tokenManager.readAccessToken(),
      _tokenManager.readUserJson(),
    ]);
    final refreshToken = storedValues[0];
    final accessToken = storedValues[1];
    final user = _readStoredUser(storedValues[2]);

    if (refreshToken == null || refreshToken.isEmpty || user == null) {
      await _tokenManager.clearTokens();
      return const ApiFailure(
        Failure(
          code: FailureCode.unauthorized,
          messageKey: 'failureUnauthorized',
        ),
      );
    }

    if (accessToken != null && accessToken.isNotEmpty) {
      return ApiSuccess(
        AuthSession(
          accessToken: accessToken,
          refreshToken: refreshToken,
          user: user,
        ),
      );
    }

    if (!_envConfig.hasApiBaseUrl) {
      return const ApiFailure(
        Failure(
          code: FailureCode.unknown,
          messageKey: 'failureConfigurationMissing',
        ),
      );
    }

    final hasConnection = await _connectionChecker.hasConnection;
    if (!hasConnection) {
      return const ApiFailure(
        Failure(
          code: FailureCode.internetRequired,
          messageKey: 'failureNetwork',
        ),
      );
    }

    return _refreshStoredSession(refreshToken: refreshToken, user: user);
  }

  @override
  Future<void> logout() async {
    final refreshToken = await _tokenManager.readRefreshToken();

    try {
      final canCallLogoutApi =
          _envConfig.hasApiBaseUrl &&
          refreshToken != null &&
          refreshToken.isNotEmpty &&
          await _connectionChecker.hasConnection;

      if (canCallLogoutApi) {
        await _remoteDataSource.logout(refreshToken);
      }
    } on Object {
      // Logout must complete locally even when the backend logout call fails.
    } finally {
      await _tokenManager.clearTokens();
    }
  }

  Future<void> _saveSession(AuthSession session) async {
    await _tokenManager.saveTokens(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
    );
    await _tokenManager.saveUserJson(
      jsonEncode(AuthUserModel.fromEntity(session.user).toJson()),
    );
  }

  AuthUser? _readStoredUser(String? userJson) {
    if (userJson == null || userJson.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(userJson);
      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      return AuthUserModel.fromJson(decoded).toEntity();
    } on FormatException {
      return null;
    }
  }

  Future<ApiResult<AuthSession>> _refreshStoredSession({
    required String refreshToken,
    required AuthUser user,
  }) async {
    try {
      final tokenPair = await _remoteDataSource.refreshToken(refreshToken);
      if (!tokenPair.isComplete) {
        await _tokenManager.clearTokens();
        return const ApiFailure(
          Failure(
            code: FailureCode.unauthorized,
            messageKey: 'failureUnauthorized',
          ),
        );
      }

      final session = AuthSession(
        accessToken: tokenPair.accessToken,
        refreshToken: tokenPair.refreshToken,
        user: user,
      );
      await _tokenManager.saveTokens(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      );
      return ApiSuccess(session);
    } on Object catch (error) {
      final failure = _apiErrorHandler.handle(error);
      if (failure.code == FailureCode.unauthorized) {
        await _tokenManager.clearTokens();
      }
      return ApiFailure(failure);
    }
  }
}
