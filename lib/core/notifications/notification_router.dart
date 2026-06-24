import '../routing/routes.dart';

class PendingRouteIntent {
  final String routeName;
  final Map<String, String>? arguments;

  const PendingRouteIntent({
    required this.routeName,
    this.arguments,
  });
}

class NotificationRouter {
  PendingRouteIntent? _pendingIntent;

  void handleNotificationTap(Map<String, String> data) {
    _pendingIntent = const PendingRouteIntent(
      routeName: Routes.notifications,
    );
  }

  PendingRouteIntent? consumePendingIntent() {
    final intent = _pendingIntent;
    _pendingIntent = null;
    return intent;
  }

  bool get hasPendingIntent => _pendingIntent != null;
}
