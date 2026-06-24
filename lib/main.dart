import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'core/di/dependency_injection.dart';
import 'core/network/websocket/notification_web_socket_service.dart';
import 'core/notifications/fcm_background_handler.dart';
import 'core/notifications/local_notification_service.dart';
import 'core/notifications/notification_event_listener.dart';
import 'core/notifications/notification_router.dart';
import 'core/routing/navigator_key.dart';
import 'core/routing/routes.dart';
import 'features/auth/presentation/bloc/auth_session_cubit.dart';
import 'features/auth/presentation/bloc/auth_session_state.dart';
import 'features/notifications/domain/entities/notification.dart' as domain;
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  configureDependencies();

  final localNotifications = sl<LocalNotificationService>();
  await localNotifications.init();
  await localNotifications.requestPermission();

  NotificationEventListener(
    sl<NotificationWebSocketService>(),
    sl<LocalNotificationService>(),
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  FirebaseMessaging.onMessage.listen((message) {
    final data = message.data;
    final id = int.tryParse(data['id'] ?? '') ??
        DateTime.now().millisecondsSinceEpoch;
    localNotifications.showNotification(domain.Notification(
      id: id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      notificationType: domain.NotificationType.fromJson(
        data['notification_type'] ?? 'info',
      ),
      createdAt: DateTime.now(),
    ));
  });

  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    final data = Map<String, String>.from(message.data);
    final authState = sl<AuthSessionCubit>().state;
    if (authState is AuthSessionAuthenticated) {
      navigatorKey.currentState?.pushNamed(Routes.notifications);
    } else {
      sl<NotificationRouter>().handleNotificationTap(data);
    }
  });

  sl<AuthSessionCubit>().stream
    .where((state) => state is AuthSessionAuthenticated)
    .listen((_) async {
      final intent = sl<NotificationRouter>().consumePendingIntent();
      if (intent != null) {
        await Future.microtask(() {});
        navigatorKey.currentState?.pushNamed(intent.routeName);
      }
    });

  runApp(const PernitApp());
}
