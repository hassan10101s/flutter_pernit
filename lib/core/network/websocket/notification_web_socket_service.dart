import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../features/notifications/domain/entities/notification.dart';
import '../../auth/token_manager.dart';
import '../../config/env_config.dart';
import 'ws_connection_status.dart';
import 'ws_notification_event.dart';

class NotificationWebSocketService {
  final EnvConfig _envConfig;
  final TokenManager _tokenManager;

  NotificationWebSocketService(this._envConfig, this._tokenManager);

  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  Timer? _healthCheckTimer;
  int _reconnectAttempt = 0;
  bool _disposed = false;
  WsConnectionStatus _connectionStatus = WsConnectionStatus.disconnected;
  final _pendingQueue = <Map<String, dynamic>>[];

  final _eventController = StreamController<WsNotificationEvent>.broadcast();
  final _statusController = StreamController<WsConnectionStatus>.broadcast();

  Stream<WsNotificationEvent> get events => _eventController.stream;
  Stream<WsConnectionStatus> get connectionStatus => _statusController.stream;

  WsConnectionStatus get currentStatus => _connectionStatus;

  Future<void> connect() async {
    if (_disposed) return;
    _setStatus(WsConnectionStatus.connecting);

    try {
      final token = await _tokenManager.readAccessToken();
      if (token == null || token.isEmpty) {
        _setStatus(WsConnectionStatus.disconnected);
        return;
      }

      var baseUrl = _envConfig.wsBaseUrl.trim();
      if (baseUrl.isEmpty) {
        baseUrl = _envConfig.apiBaseUrl
            .trim()
            .replaceFirst('https://', 'wss://')
            .replaceFirst('http://', 'ws://');
      }
      if (!baseUrl.startsWith('ws://') && !baseUrl.startsWith('wss://')) {
        baseUrl = 'ws://$baseUrl';
      }
      final uri = Uri.parse('$baseUrl/ws/notifications/').replace(
        queryParameters: {'token': token},
      );

      _channel = WebSocketChannel.connect(uri);

      _channel!.stream.listen(
        _onData,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );

      _reconnectAttempt = 0;
      _setStatus(WsConnectionStatus.connected);
      _drainQueue();
      _startHealthCheck();
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void disconnect() {
    _cancelTimers();
    _drainHealthCheck();
    _channel?.sink.close();
    _channel = null;
    _pendingQueue.clear();
    _setStatus(WsConnectionStatus.disconnected);
  }

  void manualReconnect() {
    _reconnectAttempt = 0;
    disconnect();
    connect();
  }

  void markRead(int notificationId) {
    _sendAction({
      'action': 'mark_read',
      'notification_id': notificationId,
    });
  }

  void markAllRead() {
    _sendAction({'action': 'mark_all_read'});
  }

  void getUnreadCount() {
    _sendAction({'action': 'get_unread_count'});
  }

  void getNotifications({int limit = 20, int offset = 0}) {
    _sendAction({
      'action': 'get_notifications',
      'limit': limit,
      'offset': offset,
    });
  }

  void dispose() {
    _disposed = true;
    _cancelTimers();
    _drainHealthCheck();
    _channel?.sink.close();
    _channel = null;
    _pendingQueue.clear();
    _eventController.close();
    _statusController.close();
  }

  void _onData(dynamic raw) {
    try {
      final json = jsonDecode(raw as String) as Map<String, dynamic>;
      _parseMessage(json);
    } catch (_) {}
  }

  void _parseMessage(Map<String, dynamic> json) {
    final type = json['type'] as String?;

    switch (type) {
      case 'initial':
        final unreadCount = json['unread_count'] as int? ?? 0;
        final notifications = _parseNotifications(json['notifications']);
        _eventController.add(
          InitialNotifications(
            unreadCount: unreadCount,
            notifications: notifications,
          ),
        );

      case 'new_notification':
        final notificationData = json['notification'] as Map<String, dynamic>?;
        if (notificationData != null) {
          _eventController.add(
            NewNotificationEvent(
              notification: Notification.fromJson(notificationData),
            ),
          );
        }

      case 'read_confirmed':
        final notificationId = json['id'] as int? ?? 0;
        final success = json['success'] as bool? ?? false;
        final notificationData = json['notification'] as Map<String, dynamic>?;
        _eventController.add(
          ReadConfirmed(
            notificationId: notificationId,
            success: success,
            notification: notificationData != null
                ? Notification.fromJson(notificationData)
                : null,
          ),
        );

      case 'all_read_confirmed':
        final count = json['count'] as int? ?? 0;
        final unreadCount = json['unread_count'] as int? ?? 0;
        _eventController.add(
          AllReadConfirmed(count: count, unreadCount: unreadCount),
        );

      case 'unread_count':
        final count = json['count'] as int? ?? 0;
        _eventController.add(UnreadCountEvent(count: count));

      case 'notifications_list':
        final notifications = _parseNotifications(json['notifications']);
        final count = json['count'] as int? ?? 0;
        _eventController.add(
          NotificationsListEvent(notifications: notifications, count: count),
        );
    }
  }

  List<Notification> _parseNotifications(dynamic data) {
    if (data is! List) return [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(Notification.fromJson)
        .toList();
  }

  void _onError(Object error) {
    _channel = null;
    _scheduleReconnect();
  }

  void _onDone() {
    _channel = null;
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    _cancelTimers();

    _setStatus(WsConnectionStatus.disconnected);
    _reconnectAttempt++;

    if (_reconnectAttempt > 5) {
      _setStatus(WsConnectionStatus.degraded);
      return;
    }

    final baseDelay = min(pow(2, _reconnectAttempt).toInt() * 1000, 30000);
    final jitter = Random().nextDouble() * 0.5 * baseDelay;
    final delay = baseDelay + jitter;

    _reconnectTimer = Timer(Duration(milliseconds: delay.ceil()), () {
      if (!_disposed) connect();
    });
  }

  void _sendAction(Map<String, dynamic> action) {
    if (_channel != null && _connectionStatus == WsConnectionStatus.connected) {
      try {
        _channel!.sink.add(jsonEncode(action));
      } catch (_) {
        _pendingQueue.add(action);
      }
    } else {
      _pendingQueue.add(action);
    }
  }

  void _drainQueue() {
    for (final action in _pendingQueue) {
      try {
        _channel!.sink.add(jsonEncode(action));
      } catch (_) {}
    }
    _pendingQueue.clear();
  }

  void _startHealthCheck() {
    _drainHealthCheck();
    _healthCheckTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) {
        if (_connectionStatus == WsConnectionStatus.connected) {
          _sendAction({'action': 'ping'});
        }
      },
    );
  }

  void _drainHealthCheck() {
    _healthCheckTimer?.cancel();
    _healthCheckTimer = null;
  }

  void _cancelTimers() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  void _setStatus(WsConnectionStatus status) {
    _connectionStatus = status;
    _statusController.add(status);
  }
}
