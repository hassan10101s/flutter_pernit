import '../../../../core/bloc/safe_cubit.dart';
import '../../domain/usecases/logout_use_case.dart';
import 'auth_session_cubit.dart';
import 'logout_state.dart';

class LogoutCubit extends SafeCubit<LogoutState> {
  final LogoutUseCase _logoutUseCase;
  final AuthSessionCubit _authSessionCubit;

  LogoutCubit(this._logoutUseCase, this._authSessionCubit)
    : super(const LogoutInitial());

  Future<void> logout() async {
    if (state is LogoutSubmitting) {
      return;
    }

    safeEmit(const LogoutSubmitting());
    await _logoutUseCase();
    _authSessionCubit.unauthenticate();
    safeEmit(const LogoutSuccess());
  }
}
