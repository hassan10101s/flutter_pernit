import '../../domain/entities/auth_session.dart';
import '../../domain/entities/auth_user.dart';

class LoginResponseModel {
  final String accessToken;
  final String refreshToken;
  final AuthUserModel user;

  const LoginResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      accessToken: json['access_token'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
      user: AuthUserModel.fromJson(
        json['user'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }

  AuthSession toEntity() {
    return AuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: user.toEntity(),
    );
  }
}

class AuthUserModel {
  final int id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final List<String> groups;

  const AuthUserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.groups,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    final groupsJson = json['groups'];
    return AuthUserModel(
      id: json['id'] as int? ?? 0,
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      groups: groupsJson is List
          ? groupsJson.map((item) => '$item').toList()
          : const [],
    );
  }

  AuthUser toEntity() {
    return AuthUser(
      id: id,
      username: username,
      email: email,
      firstName: firstName,
      lastName: lastName,
      groups: groups,
    );
  }
}
