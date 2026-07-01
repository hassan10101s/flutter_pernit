import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';

import 'app/app.dart';
import 'core/di/dependency_injection.dart';
import 'core/network/websocket/notification_web_socket_service.dart';
import 'core/notifications/fcm_background_handler.dart';
import 'core/notifications/local_notification_service.dart';
import 'core/notifications/notification_event_listener.dart';
import 'core/notifications/notification_lifecycle_coordinator.dart';
import 'core/notifications/notification_payload.dart';
import 'core/notifications/notification_router.dart';
import 'core/notifications/push_notification_service.dart';
import 'core/routing/navigator_key.dart';
import 'core/routing/routes.dart';
import 'features/auth/presentation/bloc/auth_session_cubit.dart';
import 'features/auth/presentation/bloc/auth_session_state.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  configureDependencies();

  final localNotifications = sl<LocalNotificationService>();
  await localNotifications.init();
  await localNotifications.requestPermission();

  NotificationEventListener(
    sl<NotificationWebSocketService>(),
    sl<LocalNotificationService>(),
  );

  final pushService = sl<PushNotificationService>();

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  final coordinator = sl<NotificationLifecycleCoordinator>();

  // Foreground FCM: show local notification with dedup (LocalNotificationService
  // already dedupes by id within 3s window).
  pushService.onMessage.listen((message) {
    final payload = NotificationPayload.fromRemoteMessage(message);
    if (payload != null) {
      localNotifications.showNotification(payload.toEntity());
    }
  });

  // App opened from notification tap
  pushService.onMessageOpenedApp.listen((message) {
    final data = Map<String, String>.from(message.data);
    final authState = sl<AuthSessionCubit>().state;
    if (authState is AuthSessionAuthenticated) {
      navigatorKey.currentState?.pushNamed(Routes.notifications);
    } else {
      sl<NotificationRouter>().handleNotificationTap(data);
    }
  });

  // Auth lifecycle
  final authCubit = sl<AuthSessionCubit>();
  authCubit.stream.listen((state) async {
    if (state is AuthSessionAuthenticated) {
      await coordinator.registerCurrentDevice();
      coordinator.startTokenRefreshListener();
      sl<NotificationWebSocketService>().connect();
    } else if (state is AuthSessionUnauthenticated) {
      coordinator.stopTokenRefreshListener();
      coordinator.disconnectAndClearIntent();
    }
  });

  // Handle initial message (app opened from terminated state)
  final initialMessage = await pushService.getInitialMessage();
  if (initialMessage != null) {
    final payload = NotificationPayload.fromRemoteMessage(initialMessage);
    if (payload != null) {
      sl<NotificationRouter>().handleNotificationTap(
        Map<String, String>.from(initialMessage.data),
      );
    }
  }

  // Consume pending intent once authenticated
  authCubit.stream.where((state) => state is AuthSessionAuthenticated).listen((
    _,
  ) async {
    final intent = sl<NotificationRouter>().consumePendingIntent();
    if (intent != null) {
      await Future.microtask(() {});
      navigatorKey.currentState?.pushNamed(intent.routeName);
    }
  });

  runApp(const PernitApp());
}
