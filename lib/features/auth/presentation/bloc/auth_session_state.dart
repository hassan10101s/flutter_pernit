import 'package:equatable/equatable.dart';

import '../../domain/entities/auth_session.dart';

sealed class AuthSessionState extends Equatable {
  const AuthSessionState();

  @override
  List<Object?> get props => [];
}

final class AuthSessionInitial extends AuthSessionState {
  const AuthSessionInitial();
}

final class AuthSessionChecking extends AuthSessionState {
  const AuthSessionChecking();
}

final class AuthSessionAuthenticated extends AuthSessionState {
  final AuthSession session;

  const AuthSessionAuthenticated(this.session);

  @override
  List<Object?> get props => [session];
}

final class AuthSessionUnauthenticated extends AuthSessionState {
  const AuthSessionUnauthenticated();
}
