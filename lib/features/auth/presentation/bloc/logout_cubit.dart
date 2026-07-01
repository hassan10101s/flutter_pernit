import '../../../../core/bloc/safe_cubit.dart';
import '../../../../core/notifications/notification_lifecycle_coordinator.dart';
import '../../domain/usecases/logout_use_case.dart';
import '../bloc/auth_session_cubit.dart';
import 'logout_state.dart';

class LogoutCubit extends SafeCubit<LogoutState> {
  final LogoutUseCase _logoutUseCase;
  final AuthSessionCubit _authSessionCubit;
  final NotificationLifecycleCoordinator _coordinator;

  LogoutCubit(this._logoutUseCase, this._authSessionCubit, this._coordinator)
    : super(const LogoutInitial());

  Future<void> logout() async {
    if (state is LogoutSubmitting) {
      return;
    }

    safeEmit(const LogoutSubmitting());
    await _coordinator.unregisterCurrentDevice();
    await _logoutUseCase();
    _coordinator.disconnectAndClearIntent();
    _authSessionCubit.unauthenticate();
    safeEmit(const LogoutSuccess());
  }
}
