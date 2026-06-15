import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pernit/core/errors/failure_code.dart';
import 'package:flutter_pernit/features/auth/domain/entities/login_credentials.dart';
import 'package:flutter_pernit/features/auth/domain/validators/login_validator.dart';

void main() {
  const validator = LoginValidator();

  test('returns field errors when username and password are empty', () {
    final failure = validator.validate(
      const LoginCredentials(username: '', password: ''),
    );

    expect(failure?.code, FailureCode.validation);
    expect(failure?.fieldErrors['username'], ['usernameRequired']);
    expect(failure?.fieldErrors['password'], ['passwordRequired']);
  });

  test('returns no failure when credentials are present', () {
    final failure = validator.validate(
      const LoginCredentials(username: 'admin', password: 'secret'),
    );

    expect(failure, isNull);
  });
}
