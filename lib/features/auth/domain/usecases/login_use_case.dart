import '../../../../core/errors/api_result.dart';
import '../entities/auth_session.dart';
import '../entities/login_credentials.dart';
import '../repos/auth_repository.dart';
import '../validators/login_validator.dart';

class LoginUseCase {
  final AuthRepository _repository;
  final LoginValidator _validator;

  const LoginUseCase(this._repository, this._validator);

  Future<ApiResult<AuthSession>> call(LoginCredentials credentials) async {
    final validationFailure = _validator.validate(credentials);
    if (validationFailure != null) {
      return ApiFailure(validationFailure);
    }

    return _repository.login(credentials);
  }
}
