class AppRegex {
  const AppRegex._();

  static bool isEmailValid(String email) {
    return RegExp(
      r'^.+@[a-zA-Z]+\.{1}[a-zA-Z]+(\.{0,1}[a-zA-Z]+)$',
    ).hasMatch(email);
  }

  static bool isPasswordStrong(String password) {
    return RegExp(
      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
    ).hasMatch(password);
  }

  static bool isEgyptianMobileNumber(String phoneNumber) {
    return RegExp(r'^(010|011|012|015)[0-9]{8}$').hasMatch(phoneNumber);
  }

  static bool hasLowerCase(String value) {
    return RegExp(r'^(?=.*[a-z])').hasMatch(value);
  }

  static bool hasUpperCase(String value) {
    return RegExp(r'^(?=.*[A-Z])').hasMatch(value);
  }

  static bool hasNumber(String value) {
    return RegExp(r'^(?=.*?[0-9])').hasMatch(value);
  }

  static bool hasSpecialCharacter(String value) {
    return RegExp(r'^(?=.*?[#?!@$%^&*-])').hasMatch(value);
  }

  static bool hasMinLength(String value, {int minLength = 8}) {
    return value.length >= minLength;
  }
}
