import 'dart:async';

import '../../features/notifications/domain/usecases/register_push_device_use_case.dart';
import '../../features/notifications/domain/usecases/unregister_push_device_use_case.dart';
import '../config/env_config.dart';
import '../network/websocket/notification_web_socket_service.dart';
import 'notification_router.dart';
import 'push_notification_service.dart';

/// Centralises FCM registration, token refresh, unregister, and
/// WebSocket lifecycle tied to auth state.
class NotificationLifecycleCoordinator {
  final PushNotificationService _pushService;
  final RegisterPushDeviceUseCase _registerUseCase;
  final UnregisterPushDeviceUseCase _unregisterUseCase;
  final NotificationWebSocketService _wsService;
  final NotificationRouter _notificationRouter;
  final EnvConfig _envConfig;

  NotificationLifecycleCoordinator(
    this._pushService,
    this._registerUseCase,
    this._unregisterUseCase,
    this._wsService,
    this._notificationRouter,
    this._envConfig,
  );

  StreamSubscription<String>? _tokenRefreshSub;

  Future<void> registerCurrentDevice() async {
    await _pushService.requestPermission();
    final token = await _pushService.getToken();
    if (token != null) {
      await _registerUseCase.call(
        token: token,
        platform: 'android',
        environment: _envConfig.environmentName,
        locale: 'ar',
        timezone: _detectTimezone(),
      );
    }
  }

  Future<void> unregisterCurrentDevice() async {
    final token = await _pushService.getToken();
    if (token != null) {
      await _unregisterUseCase.call(token);
    }
  }

  void startTokenRefreshListener() {
    _tokenRefreshSub?.cancel();
    _tokenRefreshSub = _pushService.onTokenRefresh.listen((newToken) async {
      await _registerUseCase.call(
        token: newToken,
        platform: 'android',
        environment: _envConfig.environmentName,
        locale: 'ar',
        timezone: _detectTimezone(),
      );
    });
  }

  void stopTokenRefreshListener() {
    _tokenRefreshSub?.cancel();
    _tokenRefreshSub = null;
  }

  void disconnectAndClearIntent() {
    _wsService.disconnect();
    _notificationRouter.clearPendingIntent();
  }

  String _detectTimezone() {
    try {
      final offset = DateTime.now().timeZoneOffset;
      final hours = offset.inHours;
      final minutes = offset.inMinutes.remainder(60).abs();
      final sign = hours >= 0 ? '+' : '-';
      return 'UTC$sign${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';
    } catch (_) {
      return 'UTC+00:00';
    }
  }
}
