import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../firebase_options.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // If the message has a notification payload, FCM handles display — skip.
  if (message.notification == null && message.data.isNotEmpty) {
    final data = message.data;
    final id =
        int.tryParse(data['id'] ?? '') ?? DateTime.now().millisecondsSinceEpoch;

    final plugin = FlutterLocalNotificationsPlugin();
    await plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings(
          '@drawable/ic_stat_notification',
        ),
      ),
    );

    await plugin.show(
      id,
      data['title'] ?? '',
      data['message'] ?? '',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'pernit_notifications',
          'Pernit Notifications',
          channelDescription: 'Notifications from Pernit ERP system',
          importance: Importance.high,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          icon: '@drawable/ic_stat_notification',
        ),
      ),
    );
  }
}
