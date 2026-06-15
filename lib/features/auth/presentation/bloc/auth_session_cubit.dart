import '../../../../core/bloc/safe_cubit.dart';
import '../../../../core/errors/api_result.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/usecases/restore_session_use_case.dart';
import 'auth_session_state.dart';

class AuthSessionCubit extends SafeCubit<AuthSessionState> {
  final RestoreSessionUseCase _restoreSessionUseCase;

  AuthSessionCubit(this._restoreSessionUseCase)
    : super(const AuthSessionInitial());

  Future<void> checkSession() async {
    if (state is AuthSessionChecking) {
      return;
    }

    safeEmit(const AuthSessionChecking());
    final result = await _restoreSessionUseCase();

    switch (result) {
      case ApiSuccess<AuthSession>(data: final session):
        safeEmit(AuthSessionAuthenticated(session));
      case ApiFailure<AuthSession>():
        safeEmit(const AuthSessionUnauthenticated());
    }
  }
}
