import '../../domain/entities/login_credentials.dart';

class LoginRequestModel {
  final String username;
  final String password;

  const LoginRequestModel({required this.username, required this.password});

  factory LoginRequestModel.fromCredentials(LoginCredentials credentials) {
    return LoginRequestModel(
      username: credentials.username.trim(),
      password: credentials.password,
    );
  }

  Map<String, dynamic> toJson() {
    return {'username': username, 'password': password};
  }
}
