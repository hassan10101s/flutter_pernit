import 'package:equatable/equatable.dart';

sealed class LogoutState extends Equatable {
  const LogoutState();

  @override
  List<Object?> get props => [];
}

final class LogoutInitial extends LogoutState {
  const LogoutInitial();
}

final class LogoutSubmitting extends LogoutState {
  const LogoutSubmitting();
}

final class LogoutSuccess extends LogoutState {
  const LogoutSuccess();
}
