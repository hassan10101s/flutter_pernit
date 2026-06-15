import '../../../../core/errors/failure.dart';
import '../../../../core/errors/failure_code.dart';
import '../entities/login_credentials.dart';

class LoginValidator {
  const LoginValidator();

  Failure? validate(LoginCredentials credentials) {
    final fieldErrors = <String, List<String>>{};

    if (credentials.username.trim().isEmpty) {
      fieldErrors['username'] = const ['usernameRequired'];
    }

    if (credentials.password.isEmpty) {
      fieldErrors['password'] = const ['passwordRequired'];
    }

    if (fieldErrors.isEmpty) {
      return null;
    }

    return Failure(
      code: FailureCode.validation,
      messageKey: 'failureValidation',
      fieldErrors: fieldErrors,
    );
  }
}
