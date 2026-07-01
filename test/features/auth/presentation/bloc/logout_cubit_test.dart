import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pernit/core/config/env_config.dart';
import 'package:flutter_pernit/core/errors/api_result.dart';
import 'package:flutter_pernit/core/network/websocket/notification_web_socket_service.dart';
import 'package:flutter_pernit/core/network/websocket/ws_connection_status.dart';
import 'package:flutter_pernit/core/network/websocket/ws_notification_event.dart';
import 'package:flutter_pernit/core/notifications/notification_lifecycle_coordinator.dart';
import 'package:flutter_pernit/core/notifications/notification_router.dart';
import 'package:flutter_pernit/core/notifications/push_notification_service.dart';
import 'package:flutter_pernit/features/auth/domain/entities/auth_session.dart';
import 'package:flutter_pernit/features/auth/domain/entities/login_credentials.dart';
import 'package:flutter_pernit/features/auth/domain/repos/auth_repository.dart';
import 'package:flutter_pernit/features/auth/domain/usecases/logout_use_case.dart';
import 'package:flutter_pernit/core/errors/failure.dart';
import 'package:flutter_pernit/core/errors/failure_code.dart';
import 'package:flutter_pernit/features/auth/domain/usecases/restore_session_use_case.dart';
import 'package:flutter_pernit/features/auth/presentation/bloc/auth_session_cubit.dart';
import 'package:flutter_pernit/features/auth/presentation/bloc/logout_cubit.dart';
import 'package:flutter_pernit/features/auth/presentation/bloc/logout_state.dart';
import 'package:flutter_pernit/features/notifications/domain/entities/notification_page.dart';
import 'package:flutter_pernit/features/notifications/domain/repos/notifications_repository.dart';
import 'package:flutter_pernit/features/notifications/domain/usecases/register_push_device_use_case.dart';
import 'package:flutter_pernit/features/notifications/domain/usecases/unregister_push_device_use_case.dart';

void main() {
  late LogoutCubit cubit;
  late _FakeLogoutUseCase logoutUseCase;
  late _FakeAuthSessionCubit authSessionCubit;
  late _FakeNotificationLifecycleCoordinator coordinator;

  setUp(() {
    logoutUseCase = _FakeLogoutUseCase();
    authSessionCubit = _FakeAuthSessionCubit();
    coordinator = _FakeNotificationLifecycleCoordinator();
    cubit = LogoutCubit(logoutUseCase, authSessionCubit, coordinator);
  });

  tearDown(() {
    cubit.close();
  });

  group('logout', () {
    test('calls unregister before logout and disconnects after', () async {
      final states = <LogoutState>[];
      final sub = cubit.stream.listen(states.add);

      await cubit.logout();
      await Future<void>.delayed(Duration.zero);

      expect(
        coordinator.unregisterCalled,
        true,
        reason: 'unregisterCurrentDevice should be called first',
      );
      expect(
        logoutUseCase.callCount,
        1,
        reason: 'logoutUseCase should be called after unregister',
      );
      expect(
        coordinator.disconnectCalled,
        true,
        reason: 'disconnectAndClearIntent should be called after logout',
      );
      expect(
        authSessionCubit.unauthenticateCalled,
        true,
        reason: 'unauthenticate should be called at the end',
      );

      expect(states.length, greaterThanOrEqualTo(2));
      expect(states[0], isA<LogoutSubmitting>());
      expect(states.last, isA<LogoutSuccess>());

      await sub.cancel();
    });

    test('does nothing when already submitting', () async {
      final states = <LogoutState>[];
      final sub = cubit.stream.listen(states.add);

      cubit.logout();
      cubit.logout();
      await Future<void>.delayed(Duration.zero);

      expect(
        logoutUseCase.callCount,
        1,
        reason: 'second logout call should be ignored',
      );

      await sub.cancel();
    });
  });
}

class _FakeLogoutUseCase extends LogoutUseCase {
  _FakeLogoutUseCase() : super(_FakeAuthRepository());

  int callCount = 0;

  @override
  Future<void> call() async {
    callCount++;
  }
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<ApiResult<AuthSession>> login(LoginCredentials credentials) async {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<AuthSession>> restoreSession() async {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {}
}

class _FakeAuthSessionCubit extends AuthSessionCubit {
  _FakeAuthSessionCubit() : super(_FakeRestoreSessionUseCase());

  bool unauthenticateCalled = false;

  @override
  void unauthenticate() {
    unauthenticateCalled = true;
  }
}

class _FakeRestoreSessionUseCase extends RestoreSessionUseCase {
  _FakeRestoreSessionUseCase() : super(_FakeAuthRepository());

  @override
  Future<ApiResult<AuthSession>> call() async {
    return const ApiFailure(Failure(code: FailureCode.server, messageKey: ''));
  }
}

// ignore: unused_element
class _FakeNotificationLifecycleCoordinator
    extends NotificationLifecycleCoordinator {
  _FakeNotificationLifecycleCoordinator()
    : super(
        _FakePushNotificationService(),
        _FakeRegisterPushDeviceUseCase(),
        _FakeUnregisterPushDeviceUseCase(),
        _FakeNotificationWebSocketService(),
        _FakeNotificationRouter(),
        EnvConfig.instance,
      );

  bool unregisterCalled = false;
  bool disconnectCalled = false;

  @override
  Future<void> unregisterCurrentDevice() async {
    unregisterCalled = true;
  }

  @override
  void disconnectAndClearIntent() {
    disconnectCalled = true;
  }
}

class _FakePushNotificationService extends PushNotificationService {
  @override
  Future<String?> getToken() async => null;

  @override
  Future<NotificationSettings> requestPermission() async {
    throw UnimplementedError();
  }
}

class _FakeRegisterPushDeviceUseCase extends RegisterPushDeviceUseCase {
  _FakeRegisterPushDeviceUseCase() : super(_FakeNotificationsRepository());

  @override
  Future<ApiResult<void>> call({
    required String token,
    required String platform,
    required String environment,
    required String locale,
    required String timezone,
  }) async {
    return const ApiSuccess(null);
  }
}

class _FakeUnregisterPushDeviceUseCase extends UnregisterPushDeviceUseCase {
  _FakeUnregisterPushDeviceUseCase() : super(_FakeNotificationsRepository());

  @override
  Future<ApiResult<void>> call(String token) async {
    return const ApiSuccess(null);
  }
}

class _FakeNotificationsRepository implements NotificationsRepository {
  @override
  Future<ApiResult<NotificationPage>> getNotifications({
    int page = 1,
    int pageSize = 20,
  }) async {
    return ApiSuccess(
      NotificationPage(items: [], totalCount: 0, hasMore: false),
    );
  }

  @override
  Future<ApiResult<int>> getUnreadCount() async {
    return const ApiSuccess(0);
  }

  @override
  Future<ApiResult<void>> markRead(int notificationId) async {
    return const ApiSuccess(null);
  }

  @override
  Future<ApiResult<void>> markAllRead() async {
    return const ApiSuccess(null);
  }

  @override
  Future<ApiResult<void>> registerPushDevice({
    required String token,
    required String platform,
    required String environment,
    required String locale,
    required String timezone,
  }) async {
    return const ApiSuccess(null);
  }

  @override
  Future<ApiResult<void>> unregisterPushDevice(String token) async {
    return const ApiSuccess(null);
  }
}

class _FakeNotificationWebSocketService
    implements NotificationWebSocketService {
  @override
  Stream<WsNotificationEvent> get events => const Stream.empty();

  @override
  Stream<WsConnectionStatus> get connectionStatus => const Stream.empty();

  @override
  WsConnectionStatus get currentStatus => WsConnectionStatus.disconnected;

  @override
  Future<void> connect() async {}

  @override
  void disconnect() {}

  @override
  void dispose() {}

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

class _FakeNotificationRouter extends NotificationRouter {}
