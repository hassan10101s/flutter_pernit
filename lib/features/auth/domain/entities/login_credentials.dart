import 'package:equatable/equatable.dart';

class LoginCredentials extends Equatable {
  final String username;
  final String password;

  const LoginCredentials({required this.username, required this.password});

  @override
  List<Object?> get props => [username, password];
}
