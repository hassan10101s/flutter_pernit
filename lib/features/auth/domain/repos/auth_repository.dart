import '../../../../core/errors/api_result.dart';
import '../entities/auth_session.dart';
import '../entities/login_credentials.dart';

abstract class AuthRepository {
  Future<ApiResult<AuthSession>> login(LoginCredentials credentials);

  Future<ApiResult<AuthSession>> restoreSession();

  Future<void> logout();
}
