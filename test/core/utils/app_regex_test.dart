import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pernit/core/utils/app_regex.dart';

void main() {
  test('email validator accepts valid email only', () {
    expect(AppRegex.isEmailValid('admin@example.com'), isTrue);
    expect(AppRegex.isEmailValid('admin'), isFalse);
  });

  test('strong password validator requires mixed password characters', () {
    expect(AppRegex.isPasswordStrong('Admin@123'), isTrue);
    expect(AppRegex.isPasswordStrong('password'), isFalse);
  });

  test('egyptian mobile validator accepts supported prefixes', () {
    expect(AppRegex.isEgyptianMobileNumber('01012345678'), isTrue);
    expect(AppRegex.isEgyptianMobileNumber('01312345678'), isFalse);
  });
}
