import 'dart:async';

import '../../../../core/bloc/safe_cubit.dart';
import '../../../../core/network/websocket/notification_web_socket_service.dart';
import '../../../../core/network/websocket/ws_notification_event.dart';
import 'notification_state.dart';

class NotificationCubit extends SafeCubit<NotificationState> {
  final NotificationWebSocketService _wsService;
  StreamSubscription<WsNotificationEvent>? _eventSub;

  NotificationCubit(this._wsService)
      : super(const NotificationInitial()) {
    _eventSub = _wsService.events.listen(_onEvent);
    load();
  }

  int? _pendingUnreadCount;

  void load() {
    safeEmit(const NotificationLoading());
    _pendingUnreadCount = null;
    _wsService.getNotifications();
    _wsService.getUnreadCount();
  }

  void loadMore() {
    final current = state;
    if (current is NotificationLoaded && !current.isLoadingMore) {
      safeEmit(current.copyWith(isLoadingMore: true));
      _wsService.getNotifications(offset: current.notifications.length);
    }
  }

  void markRead(int id) => _wsService.markRead(id);

  void markAllRead() => _wsService.markAllRead();

  void refresh() => load();

  void _onEvent(WsNotificationEvent event) {
    switch (event) {
      case InitialNotifications e:
        _handleInitial(e);
      case NotificationsListEvent e:
        _handleNotificationsList(e);
      case UnreadCountEvent e:
        _handleUnreadCount(e);
      case NewNotificationEvent e:
        _handleNewNotification(e);
      case ReadConfirmed e:
        _handleReadConfirmed(e);
      case AllReadConfirmed e:
        _handleAllReadConfirmed(e);
    }
  }

  void _handleInitial(InitialNotifications e) {
    safeEmit(NotificationLoaded(
      notifications: e.notifications,
      unreadCount: e.unreadCount,
      totalCount: e.notifications.length,
    ));
    _pendingUnreadCount = null;
  }

  void _handleNotificationsList(NotificationsListEvent e) {
    final current = state;
    if (current is NotificationLoading) {
      final unread = _pendingUnreadCount;
      safeEmit(NotificationLoaded(
        notifications: e.notifications,
        unreadCount: unread ?? 0,
        totalCount: e.count,
      ));
      _pendingUnreadCount = null;
    } else if (current is NotificationLoaded && current.isLoadingMore) {
      safeEmit(NotificationLoaded(
        notifications: [...current.notifications, ...e.notifications],
        unreadCount: current.unreadCount,
        totalCount: e.count,
      ));
    }
  }

  void _handleUnreadCount(UnreadCountEvent e) {
    final current = state;
    if (current is NotificationLoaded) {
      safeEmit(current.copyWith(unreadCount: e.count));
    } else if (current is NotificationLoading) {
      _pendingUnreadCount = e.count;
    }
  }

  void _handleNewNotification(NewNotificationEvent e) {
    final current = state;
    if (current is NotificationLoaded) {
      safeEmit(NotificationLoaded(
        notifications: [e.notification, ...current.notifications],
        unreadCount: current.unreadCount + 1,
        totalCount: current.totalCount + 1,
      ));
    }
  }

  void _handleReadConfirmed(ReadConfirmed e) {
    final current = state;
    if (current is! NotificationLoaded) return;
    final updated = current.notifications.map((n) {
      if (n.id == e.notificationId) {
        return n.copyWith(isRead: true, readAt: DateTime.now());
      }
      return n;
    }).toList();
    final decrement = e.success && current.unreadCount > 0 ? 1 : 0;
    safeEmit(NotificationLoaded(
      notifications: updated,
      unreadCount: current.unreadCount - decrement,
      totalCount: current.totalCount,
    ));
  }

  void _handleAllReadConfirmed(AllReadConfirmed e) {
    final current = state;
    if (current is! NotificationLoaded) return;
    final updated = current.notifications
        .map((n) => n.copyWith(isRead: true, readAt: DateTime.now()))
        .toList();
    safeEmit(NotificationLoaded(
      notifications: updated,
      unreadCount: 0,
      totalCount: current.totalCount,
    ));
  }

  @override
  Future<void> close() {
    _eventSub?.cancel();
    return super.close();
  }
}
