import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pernit/core/errors/api_result.dart';
import 'package:flutter_pernit/core/errors/failure.dart';
import 'package:flutter_pernit/core/errors/failure_code.dart';
import 'package:flutter_pernit/core/network/websocket/notification_web_socket_service.dart';
import 'package:flutter_pernit/core/network/websocket/ws_connection_status.dart';
import 'package:flutter_pernit/core/network/websocket/ws_notification_event.dart';
import 'package:flutter_pernit/features/notifications/domain/entities/notification.dart';
import 'package:flutter_pernit/features/notifications/domain/entities/notification_page.dart';
import 'package:flutter_pernit/features/notifications/domain/repos/notifications_repository.dart';
import 'package:flutter_pernit/features/notifications/domain/usecases/get_unread_count_use_case.dart';
import 'package:flutter_pernit/features/notifications/domain/usecases/load_notifications_use_case.dart';
import 'package:flutter_pernit/features/notifications/domain/usecases/mark_all_notifications_read_use_case.dart';
import 'package:flutter_pernit/features/notifications/domain/usecases/mark_notification_read_use_case.dart';
import 'package:flutter_pernit/features/notifications/presentation/bloc/notification_cubit.dart';
import 'package:flutter_pernit/features/notifications/presentation/bloc/notification_state.dart';

void main() {
  late NotificationCubit cubit;
  late _FakeLoadNotificationsUseCase loadUseCase;
  late _FakeGetUnreadCountUseCase unreadCountUseCase;
  late _FakeMarkNotificationReadUseCase markReadUseCase;
  late _FakeMarkAllNotificationsReadUseCase markAllReadUseCase;
  late _FakeWsService wsService;

  setUp(() {
    loadUseCase = _FakeLoadNotificationsUseCase();
    unreadCountUseCase = _FakeGetUnreadCountUseCase();
    markReadUseCase = _FakeMarkNotificationReadUseCase();
    markAllReadUseCase = _FakeMarkAllNotificationsReadUseCase();
    wsService = _FakeWsService();
    cubit = NotificationCubit(
      loadUseCase,
      unreadCountUseCase,
      markReadUseCase,
      markAllReadUseCase,
      wsService,
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  group('load', () {
    test('loads notifications and emits loaded state', () async {
      final notification = Notification(
        id: 1,
        title: 'Test',
        message: 'Test message',
        notificationType: NotificationType.info,
        createdAt: DateTime(2025, 6, 15),
      );
      loadUseCase.page = NotificationPage(
        items: [notification],
        totalCount: 1,
        hasMore: false,
      );
      unreadCountUseCase.count = 3;

      final states = await _collectStates(cubit, cubit.load);

      expect(states.length, greaterThanOrEqualTo(2));
      expect(states[0], isA<NotificationLoading>());
      final loaded = states.whereType<NotificationLoaded>().last;
      expect(loaded.notifications.length, 1);
      expect(loaded.notifications[0].id, 1);
      expect(loaded.totalCount, 1);
      expect(loaded.isLoadingMore, false);
    });

    test('emits error when load fails', () async {
      loadUseCase.shouldThrow = true;

      final states = await _collectStates(cubit, cubit.load);

      expect(states.any((s) => s is NotificationError), true);
    });
  });

  group('WebSocket events', () {
    test('new notification from WS adds to list', () async {
      loadUseCase.page = const NotificationPage(
        items: [],
        totalCount: 0,
        hasMore: false,
      );
      unreadCountUseCase.count = 0;

      await _collectStates(cubit, cubit.load);

      wsService._emitEvent(
        NewNotificationEvent(
          notification: Notification(
            id: 2,
            title: 'Live',
            message: 'Live message',
            notificationType: NotificationType.info,
            createdAt: DateTime(2025, 6, 15),
          ),
        ),
      );

      await Future<void>.delayed(Duration.zero);

      final state = cubit.state;
      if (state is NotificationLoaded) {
        expect(state.notifications.length, 1);
        expect(state.notifications[0].id, 2);
        expect(state.unreadCount, 1);
      } else {
        fail('Expected NotificationLoaded');
      }
    });

    test('WS duplicate notification id is ignored', () async {
      final notification = Notification(
        id: 1,
        title: 'Existing',
        message: 'Existing message',
        notificationType: NotificationType.info,
        createdAt: DateTime(2025, 6, 15),
      );
      loadUseCase.page = NotificationPage(
        items: [notification],
        totalCount: 1,
        hasMore: false,
      );
      unreadCountUseCase.count = 0;

      await _collectStates(cubit, cubit.load);

      wsService._emitEvent(
        NewNotificationEvent(
          notification: Notification(
            id: 1,
            title: 'Duplicate',
            message: 'Should be ignored',
            notificationType: NotificationType.info,
            createdAt: DateTime(2025, 6, 15),
          ),
        ),
      );

      await Future<void>.delayed(Duration.zero);

      final state = cubit.state;
      if (state is NotificationLoaded) {
        expect(state.notifications.length, 1);
        expect(state.notifications[0].title, 'Existing');
        expect(state.unreadCount, 0);
      } else {
        fail('Expected NotificationLoaded');
      }
    });

    test('read confirmed from WS updates notification', () async {
      loadUseCase.page = NotificationPage(
        items: [
          Notification(
            id: 1,
            title: 'Test',
            message: 'Test',
            notificationType: NotificationType.info,
            createdAt: DateTime(2025, 6, 15),
          ),
        ],
        totalCount: 1,
        hasMore: false,
      );
      unreadCountUseCase.count = 1;

      await _collectStates(cubit, cubit.load);

      wsService._emitEvent(ReadConfirmed(notificationId: 1, success: true));

      await Future<void>.delayed(Duration.zero);

      final state = cubit.state;
      if (state is NotificationLoaded) {
        expect(state.notifications[0].isRead, true);
        expect(state.unreadCount, 0);
      } else {
        fail('Expected NotificationLoaded');
      }
    });
  });

  group('mark read', () {
    test('mark read via use case updates local state', () async {
      loadUseCase.page = NotificationPage(
        items: [
          Notification(
            id: 1,
            title: 'Test',
            message: 'Test',
            notificationType: NotificationType.info,
            createdAt: DateTime(2025, 6, 15),
          ),
        ],
        totalCount: 1,
        hasMore: false,
      );
      unreadCountUseCase.count = 1;

      await _collectStates(cubit, cubit.load);

      await cubit.markRead(1);

      final state = cubit.state;
      if (state is NotificationLoaded) {
        expect(state.notifications[0].isRead, true);
      } else {
        fail('Expected NotificationLoaded');
      }
    });
  });

  group('mark all read', () {
    test('mark all read clears unread count', () async {
      loadUseCase.page = NotificationPage(
        items: [
          Notification(
            id: 1,
            title: 'Test',
            message: 'Test',
            notificationType: NotificationType.info,
            createdAt: DateTime(2025, 6, 15),
          ),
        ],
        totalCount: 1,
        hasMore: false,
      );
      unreadCountUseCase.count = 1;

      await _collectStates(cubit, cubit.load);

      await cubit.markAllRead();

      final state = cubit.state;
      if (state is NotificationLoaded) {
        expect(state.unreadCount, 0);
      } else {
        fail('Expected NotificationLoaded');
      }
    });
  });

  group('loadMore', () {
    test(
      'loadMore appends notifications and uses hasMore from response',
      () async {
        final firstPage = Notification(
          id: 1,
          title: 'First',
          message: 'A',
          notificationType: NotificationType.info,
          createdAt: DateTime(2025, 6, 15),
        );
        loadUseCase.page = NotificationPage(
          items: [firstPage],
          totalCount: 2,
          hasMore: true,
        );
        unreadCountUseCase.count = 0;

        await _collectStates(cubit, cubit.load);

        loadUseCase.page = NotificationPage(
          items: [
            Notification(
              id: 2,
              title: 'Second',
              message: 'B',
              notificationType: NotificationType.info,
              createdAt: DateTime(2025, 6, 15),
            ),
          ],
          totalCount: 2,
          hasMore: false,
        );

        cubit.loadMore();
        await Future<void>.delayed(Duration.zero);

        final state = cubit.state;
        if (state is NotificationLoaded) {
          expect(state.notifications.length, 2);
          expect(state.isLoadingMore, false);
        } else {
          fail('Expected NotificationLoaded');
        }
      },
    );

    test('loadMore failure restores page and resets isLoadingMore', () async {
      loadUseCase.page = const NotificationPage(
        items: [],
        totalCount: 0,
        hasMore: true,
      );
      unreadCountUseCase.count = 0;

      await _collectStates(cubit, cubit.load);

      loadUseCase.shouldThrow = true;
      cubit.loadMore();
      await Future<void>.delayed(Duration.zero);

      final state = cubit.state;
      if (state is NotificationLoaded) {
        expect(state.isLoadingMore, false);
      } else {
        fail('Expected NotificationLoaded');
      }
    });
  });
}

Future<List<NotificationState>> _collectStates(
  NotificationCubit cubit,
  void Function() action,
) async {
  final states = <NotificationState>[];
  final sub = cubit.stream.listen(states.add);
  action();
  await Future<void>.delayed(Duration.zero);
  await sub.cancel();
  return states;
}

class _FakeLoadNotificationsUseCase extends LoadNotificationsUseCase {
  _FakeLoadNotificationsUseCase() : super(_FakeNotificationsRepository());

  NotificationPage page = const NotificationPage(
    items: [],
    totalCount: 0,
    hasMore: false,
  );
  bool shouldThrow = false;

  @override
  Future<ApiResult<NotificationPage>> call({
    int page = 1,
    int pageSize = 20,
  }) async {
    if (shouldThrow) {
      return const ApiFailure(
        Failure(code: FailureCode.server, messageKey: 'failureServer'),
      );
    }
    return ApiSuccess(this.page);
  }
}

class _FakeGetUnreadCountUseCase extends GetUnreadCountUseCase {
  _FakeGetUnreadCountUseCase() : super(_FakeNotificationsRepository());

  int count = 0;
  bool shouldThrow = false;

  @override
  Future<ApiResult<int>> call() async {
    if (shouldThrow) {
      return const ApiFailure(
        Failure(code: FailureCode.server, messageKey: 'failureServer'),
      );
    }
    return ApiSuccess(count);
  }
}

class _FakeMarkNotificationReadUseCase extends MarkNotificationReadUseCase {
  _FakeMarkNotificationReadUseCase() : super(_FakeNotificationsRepository());

  @override
  Future<ApiResult<void>> call(int notificationId) async {
    return const ApiSuccess(null);
  }
}

class _FakeMarkAllNotificationsReadUseCase
    extends MarkAllNotificationsReadUseCase {
  _FakeMarkAllNotificationsReadUseCase()
    : super(_FakeNotificationsRepository());

  @override
  Future<ApiResult<void>> call() async {
    return const ApiSuccess(null);
  }
}

class _FakeNotificationsRepository implements NotificationsRepository {
  @override
  Future<ApiResult<NotificationPage>> getNotifications({
    int page = 1,
    int pageSize = 20,
  }) async {
    return const ApiSuccess(
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

class _FakeWsService implements NotificationWebSocketService {
  final _eventController = StreamController<WsNotificationEvent>.broadcast();

  @override
  Stream<WsNotificationEvent> get events => _eventController.stream;

  @override
  Stream<WsConnectionStatus> get connectionStatus => const Stream.empty();

  @override
  WsConnectionStatus get currentStatus => WsConnectionStatus.disconnected;

  @override
  Future<void> connect() async {}

  @override
  void disconnect() {}

  @override
  void dispose() {
    _eventController.close();
  }

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

  void _emitEvent(WsNotificationEvent event) {
    _eventController.add(event);
  }
}
