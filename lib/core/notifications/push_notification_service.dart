import 'package:firebase_messaging/firebase_messaging.dart';

class PushNotificationService {
  PushNotificationService();

  Future<NotificationSettings> requestPermission() {
    return FirebaseMessaging.instance.requestPermission();
  }

  Future<String?> getToken() {
    return FirebaseMessaging.instance.getToken();
  }

  Future<void> deleteToken() {
    return FirebaseMessaging.instance.deleteToken();
  }

  Stream<String> get onTokenRefresh =>
      FirebaseMessaging.instance.onTokenRefresh;

  Stream<RemoteMessage> get onMessage => FirebaseMessaging.onMessage;

  Stream<RemoteMessage> get onMessageOpenedApp =>
      FirebaseMessaging.onMessageOpenedApp;

  Future<RemoteMessage?> getInitialMessage() {
    return FirebaseMessaging.instance.getInitialMessage();
  }
}
