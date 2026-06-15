import '../../../../core/auth/token_manager.dart';
import '../../../../core/config/env_config.dart';
import '../../../../core/errors/api_error_handler.dart';
import '../../../../core/errors/api_result.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/failure_code.dart';
import '../../../../core/network/connection_checker.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/login_credentials.dart';
import '../../domain/repos/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../models/login_request_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final TokenManager _tokenManager;
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
      await _tokenManager.saveTokens(
        accessToken: session.accessToken,
        refreshToken: session.refreshToken,
      );
      return ApiSuccess(session);
    } on Object catch (error) {
      return ApiFailure(_apiErrorHandler.handle(error));
    }
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
}
