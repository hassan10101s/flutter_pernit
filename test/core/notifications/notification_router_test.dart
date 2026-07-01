import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pernit/core/notifications/notification_router.dart';

void main() {
  group('NotificationRouter', () {
    test('starts with no pending intent', () {
      final router = NotificationRouter();
      expect(router.hasPendingIntent, false);
      expect(router.consumePendingIntent(), isNull);
    });

    test('handleNotificationTap stores pending intent', () {
      final router = NotificationRouter();
      router.handleNotificationTap({'id': '42'});

      expect(router.hasPendingIntent, true);
    });

    test('consumePendingIntent returns and clears the intent', () {
      final router = NotificationRouter();
      router.handleNotificationTap({'id': '42'});

      final intent = router.consumePendingIntent();

      expect(intent, isNotNull);
      expect(intent!.routeName, '/notifications');
      expect(router.hasPendingIntent, false);
      expect(router.consumePendingIntent(), isNull);
    });

    test('clearPendingIntent clears without consuming', () {
      final router = NotificationRouter();
      router.handleNotificationTap({'id': '42'});

      router.clearPendingIntent();

      expect(router.hasPendingIntent, false);
      expect(router.consumePendingIntent(), isNull);
    });
  });
}
