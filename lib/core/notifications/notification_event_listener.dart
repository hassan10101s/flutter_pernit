import 'dart:async';

import '../network/websocket/notification_web_socket_service.dart';
import '../network/websocket/ws_notification_event.dart';
import 'local_notification_service.dart';

/// Subscribes to [NotificationWebSocketService.events] and shows a
/// system-level (status-bar) notification whenever a [NewNotificationEvent]
/// arrives.
///
/// This decouples system notifications from the screen-scoped
/// [NotificationCubit], so that local notifications fire regardless of which
/// screen the user is on.
class NotificationEventListener {
  final NotificationWebSocketService _wsService;
  final LocalNotificationService _localNotificationService;
  StreamSubscription<WsNotificationEvent>? _sub;

  NotificationEventListener(this._wsService, this._localNotificationService) {
    _sub = _wsService.events.listen(_onEvent);
  }

  void _onEvent(WsNotificationEvent event) {
    if (event is NewNotificationEvent) {
      _localNotificationService.showNotification(event.notification);
    }
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
  }
}
