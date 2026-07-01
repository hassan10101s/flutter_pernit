import 'dart:async';

import '../../../../core/bloc/safe_cubit.dart';
import '../../../../core/errors/api_result.dart';
import '../../../../core/network/websocket/notification_web_socket_service.dart';
import '../../../../core/network/websocket/ws_notification_event.dart';
import '../../domain/entities/notification_page.dart';
import '../../domain/usecases/get_unread_count_use_case.dart';
import '../../domain/usecases/load_notifications_use_case.dart';
import '../../domain/usecases/mark_all_notifications_read_use_case.dart';
import '../../domain/usecases/mark_notification_read_use_case.dart';
import 'notification_state.dart';

class NotificationCubit extends SafeCubit<NotificationState> {
  final LoadNotificationsUseCase _loadUseCase;
  final GetUnreadCountUseCase _unreadCountUseCase;
  final MarkNotificationReadUseCase _markReadUseCase;
  final MarkAllNotificationsReadUseCase _markAllReadUseCase;
  final NotificationWebSocketService _wsService;
  StreamSubscription<WsNotificationEvent>? _eventSub;

  NotificationCubit(
    this._loadUseCase,
    this._unreadCountUseCase,
    this._markReadUseCase,
    this._markAllReadUseCase,
    this._wsService,
  ) : super(const NotificationInitial()) {
    _eventSub = _wsService.events.listen(_onEvent);
    load();
  }

  int _currentPage = 1;
  bool _hasMore = true;

  void load() {
    safeEmit(const NotificationLoading());
    _currentPage = 1;
    _hasMore = true;
    _fetchNotifications();
    _fetchUnreadCount();
  }

  void loadMore() {
    if (state is! NotificationLoaded || !_hasMore) return;
    safeEmit((state as NotificationLoaded).copyWith(isLoadingMore: true));
    _currentPage++;
    _fetchNotifications(append: true);
  }

  Future<void> markRead(int id) async {
    final result = await _markReadUseCase.call(id);
    if (result is ApiSuccess) {
      _handleLocalReadConfirmed(id, true);
    } else if (result is ApiFailure) {
      _handleLocalReadConfirmed(id, false);
    }
  }

  Future<void> markAllRead() async {
    final result = await _markAllReadUseCase.call();
    if (result is ApiSuccess) {
      _handleLocalAllReadConfirmed();
    }
  }

  void refresh() => load();

  Future<void> _fetchNotifications({bool append = false}) async {
    final result = await _loadUseCase.call(page: _currentPage);
    switch (result) {
      case ApiSuccess<NotificationPage>(data: final page):
        _hasMore = page.hasMore;
        final current = state;
        if (current is NotificationLoaded && append) {
          safeEmit(
            NotificationLoaded(
              notifications: [...current.notifications, ...page.items],
              unreadCount: current.unreadCount,
              totalCount: page.totalCount,
            ),
          );
        } else {
          safeEmit(
            NotificationLoaded(
              notifications: page.items,
              unreadCount: current is NotificationLoaded
                  ? current.unreadCount
                  : 0,
              totalCount: page.totalCount,
            ),
          );
        }
      case ApiFailure<NotificationPage>(failure: final failure):
        if (append) {
          _currentPage--;
          final current = state;
          if (current is NotificationLoaded) {
            safeEmit(current.copyWith(isLoadingMore: false));
          }
          return;
        }
        final current = state;
        if (current is NotificationLoaded) return;
        safeEmit(NotificationError(failure));
    }
  }

  Future<void> _fetchUnreadCount() async {
    final result = await _unreadCountUseCase.call();
    if (result case ApiSuccess<int>(data: final count)) {
      final current = state;
      if (current is NotificationLoaded) {
        safeEmit(current.copyWith(unreadCount: count));
      }
    }
  }

  void _onEvent(WsNotificationEvent event) {
    switch (event) {
      case NewNotificationEvent e:
        _handleNewNotification(e);
      case ReadConfirmed e:
        _handleReadConfirmed(e);
      case AllReadConfirmed e:
        _handleAllReadConfirmed(e);
      case UnreadCountEvent e:
        _handleUnreadCountFromWs(e);
      case InitialNotifications _ || NotificationsListEvent _:
        break;
    }
  }

  void _handleNewNotification(NewNotificationEvent e) {
    final current = state;
    if (current is NotificationLoaded) {
      if (current.notifications.any((n) => n.id == e.notification.id)) return;
      safeEmit(
        NotificationLoaded(
          notifications: [e.notification, ...current.notifications],
          unreadCount: current.unreadCount + 1,
          totalCount: current.totalCount + 1,
        ),
      );
    }
  }

  void _handleReadConfirmed(ReadConfirmed e) {
    _handleLocalReadConfirmed(e.notificationId, e.success);
  }

  void _handleLocalReadConfirmed(int notificationId, bool success) {
    final current = state;
    if (current is! NotificationLoaded) return;
    final updated = current.notifications.map((n) {
      if (n.id == notificationId) {
        return n.copyWith(isRead: true, readAt: DateTime.now());
      }
      return n;
    }).toList();
    final decrement = success && current.unreadCount > 0 ? 1 : 0;
    safeEmit(
      NotificationLoaded(
        notifications: updated,
        unreadCount: current.unreadCount - decrement,
        totalCount: current.totalCount,
      ),
    );
  }

  void _handleAllReadConfirmed(AllReadConfirmed e) {
    _handleLocalAllReadConfirmed();
  }

  void _handleLocalAllReadConfirmed() {
    final current = state;
    if (current is! NotificationLoaded) return;
    final updated = current.notifications
        .map((n) => n.copyWith(isRead: true, readAt: DateTime.now()))
        .toList();
    safeEmit(
      NotificationLoaded(
        notifications: updated,
        unreadCount: 0,
        totalCount: current.totalCount,
      ),
    );
  }

  void _handleUnreadCountFromWs(UnreadCountEvent e) {
    final current = state;
    if (current is NotificationLoaded) {
      safeEmit(current.copyWith(unreadCount: e.count));
    }
  }

  @override
  Future<void> close() {
    _eventSub?.cancel();
    return super.close();
  }
}
