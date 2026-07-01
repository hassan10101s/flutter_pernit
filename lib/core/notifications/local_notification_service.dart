import 'dart:collection';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../features/notifications/domain/entities/notification.dart'
    as domain;

/// Handles system-level (status-bar) local notifications.
///
/// Initialised once at app startup via [init] and then called from the
/// Notification Cubit whenever a new WebSocket event arrives.
class LocalNotificationService {
  LocalNotificationService();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'pernit_notifications';
  static const String _channelName = 'Pernit Notifications';
  static const String _channelDescription =
      'Notifications from Pernit ERP system';

  /// Dedup window in milliseconds: suppresses the same notification.id
  /// if shown again within this window (prevents WS + FCM duplicate).
  static const int _dedupWindowMs = 3000;
  final _recentIds = HashMap<int, int>();

  /// Must be called once before any notification is shown.
  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@drawable/ic_stat_notification',
    );

    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _plugin.initialize(settings);
  }

  /// Requests notification permission on Android 13+ (API 33).
  /// On older Android versions and iOS (handled in [init]) this is a no-op.
  Future<void> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      await android.requestNotificationsPermission();
    }
  }

  /// Shows a system-level notification using data from a domain [notification].
  ///
  /// Skips if the same [notification.id] was shown within [_dedupWindowMs]
  /// (prevents WS + FCM duplication for the same event).
  Future<void> showNotification(domain.Notification notification) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final lastShown = _recentIds[notification.id];
    if (lastShown != null && (now - lastShown) < _dedupWindowMs) return;
    _recentIds[notification.id] = now;

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@drawable/ic_stat_notification',
    );

    const darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
    );

    await _plugin.show(
      notification.id,
      notification.title,
      notification.message,
      details,
    );
  }
}
