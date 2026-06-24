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

  /// Must be called once before any notification is shown.
  Future<void> init() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
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
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      await android.requestNotificationsPermission();
    }
  }

  /// Shows a system-level notification using data from a domain [notification].
  Future<void> showNotification(domain.Notification notification) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      icon: '@mipmap/ic_launcher',
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
