import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/auth_session.dart';

sealed class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

final class LoginInitial extends LoginState {
  const LoginInitial();
}

final class LoginSubmitting extends LoginState {
  const LoginSubmitting();
}

final class LoginSuccess extends LoginState {
  final AuthSession session;

  const LoginSuccess(this.session);

  @override
  List<Object?> get props => [session];
}

final class LoginFailure extends LoginState {
  final Failure failure;

  const LoginFailure(this.failure);

  @override
  List<Object?> get props => [failure];
}
