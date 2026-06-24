import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_pernit/core/errors/api_result.dart';
import 'package:flutter_pernit/core/errors/failure.dart';
import 'package:flutter_pernit/core/errors/failure_code.dart';
import 'package:flutter_pernit/core/network/websocket/notification_web_socket_service.dart';
import 'package:flutter_pernit/core/network/websocket/ws_connection_status.dart';
import 'package:flutter_pernit/core/network/websocket/ws_notification_event.dart';
import 'package:flutter_pernit/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_pernit/features/auth/domain/entities/auth_user.dart';
import 'package:flutter_pernit/features/auth/domain/entities/login_credentials.dart';
import 'package:flutter_pernit/features/auth/domain/repos/auth_repository.dart';
import 'package:flutter_pernit/features/auth/domain/usecases/restore_session_use_case.dart';
import 'package:flutter_pernit/features/auth/presentation/bloc/auth_session_cubit.dart';
import 'package:flutter_pernit/features/auth/presentation/bloc/auth_session_state.dart';

void main() {
  const session = AuthSession(
    accessToken: 'access',
    refreshToken: 'refresh',
    user: AuthUser(
      id: 1,
      username: 'admin',
      email: 'admin@example.com',
      firstName: 'Ahmed',
      lastName: 'Hassan',
      groups: ['Standard User'],
    ),
  );

  test('checkSession restores authenticated session', () async {
    final cubit = AuthSessionCubit(
      RestoreSessionUseCase(_FakeAuthRepository(ApiSuccess(session))),
      _FakeWsService(),
    );
    final states = <AuthSessionState>[];
    final subscription = cubit.stream.listen(states.add);

    await cubit.checkSession();
    await Future<void>.delayed(Duration.zero);

    expect(states, const [
      AuthSessionChecking(),
      AuthSessionAuthenticated(session),
    ]);

    await subscription.cancel();
    await cubit.close();
  });

  test('checkSession emits unauthenticated when restore fails', () async {
    const failure = Failure(
      code: FailureCode.unauthorized,
      messageKey: 'failureUnauthorized',
    );
    final cubit = AuthSessionCubit(
      RestoreSessionUseCase(_FakeAuthRepository(const ApiFailure(failure))),
      _FakeWsService(),
    );
    final states = <AuthSessionState>[];
    final subscription = cubit.stream.listen(states.add);

    await cubit.checkSession();
    await Future<void>.delayed(Duration.zero);

    expect(states, const [AuthSessionChecking(), AuthSessionUnauthenticated()]);

    await subscription.cancel();
    await cubit.close();
  });
}

class _FakeWsService implements NotificationWebSocketService {
  @override
  Future<void> connect() async {}

  @override
  void disconnect() {}

  @override
  void dispose() {}

  @override
  Stream<WsNotificationEvent> get events => const Stream.empty();

  @override
  Stream<WsConnectionStatus> get connectionStatus => const Stream.empty();

  @override
  WsConnectionStatus get currentStatus => WsConnectionStatus.disconnected;

  @override
  void manualReconnect() {}

  @override
  void markRead(int notificationId) {}

  @override
  void markAllRead() {}

  @override
  void getUnreadCount() {}

  @override
  void getNotifications({int limit = 20, int offset = 0}) {}
}

class _FakeAuthRepository implements AuthRepository {
  final ApiResult<AuthSession> restoreResult;

  const _FakeAuthRepository(this.restoreResult);

  @override
  Future<ApiResult<AuthSession>> login(LoginCredentials credentials) {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {}

  @override
  Future<ApiResult<AuthSession>> restoreSession() async {
    return restoreResult;
  }
}
