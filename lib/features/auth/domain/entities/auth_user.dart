import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final List<String> groups;

  const AuthUser({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.groups,
  });

  String get displayName {
    final fullName = '$firstName $lastName'.trim();
    return fullName.isEmpty ? username : fullName;
  }

  @override
  List<Object?> get props => [id, username, email, firstName, lastName, groups];
}
