import '../../../../core/bloc/safe_cubit.dart';
import '../../../../core/errors/api_result.dart';
import '../../../../core/network/websocket/notification_web_socket_service.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/usecases/restore_session_use_case.dart';
import 'auth_session_state.dart';

class AuthSessionCubit extends SafeCubit<AuthSessionState> {
  final RestoreSessionUseCase _restoreSessionUseCase;
  final NotificationWebSocketService _wsService;

  AuthSessionCubit(this._restoreSessionUseCase, this._wsService)
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
        _wsService.connect();
      case ApiFailure<AuthSession>():
        safeEmit(const AuthSessionUnauthenticated());
    }
  }

  void authenticate(AuthSession session) {
    safeEmit(AuthSessionAuthenticated(session));
    _wsService.connect();
  }

  void unauthenticate() {
    _wsService.disconnect();
    safeEmit(const AuthSessionUnauthenticated());
  }
}
