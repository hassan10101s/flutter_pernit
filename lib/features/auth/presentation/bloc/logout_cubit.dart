import '../../../../core/bloc/safe_cubit.dart';
import '../../domain/usecases/logout_use_case.dart';
import 'logout_state.dart';

class LogoutCubit extends SafeCubit<LogoutState> {
  final LogoutUseCase _logoutUseCase;

  LogoutCubit(this._logoutUseCase) : super(const LogoutInitial());

  Future<void> logout() async {
    if (state is LogoutSubmitting) {
      return;
    }

    safeEmit(const LogoutSubmitting());
    await _logoutUseCase();
    safeEmit(const LogoutSuccess());
  }
}
