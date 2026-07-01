import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_pernit/core/notifications/notification_payload.dart';

void main() {
  group('NotificationPayload', () {
    test('fromMap parses valid data correctly', () {
      final data = {
        'id': '42',
        'title': 'Test Title',
        'message': 'Test Message',
        'notification_type': 'success',
        'reference_type': 'production_order',
        'reference_id': 'REF-001',
        'created_at': '2025-06-15T10:30:00Z',
      };

      final payload = NotificationPayload.fromMap(data);

      expect(payload, isNotNull);
      expect(payload!.id, 42);
      expect(payload.title, 'Test Title');
      expect(payload.message, 'Test Message');
      expect(payload.notificationType.name, 'success');
      expect(payload.referenceType?.name, 'productionOrder');
      expect(payload.referenceId, 'REF-001');
      expect(payload.createdAt, DateTime.utc(2025, 6, 15, 10, 30));
    });

    test('fromMap returns null when id is missing', () {
      final data = <String, dynamic>{};
      expect(NotificationPayload.fromMap(data), isNull);
    });

    test('fromMap returns null when id is not a valid int', () {
      final data = {'id': 'not-a-number'};
      expect(NotificationPayload.fromMap(data), isNull);
    });

    test('fromMap handles missing optional fields', () {
      final data = {'id': '1', 'title': 'Test', 'message': 'Message'};

      final payload = NotificationPayload.fromMap(data);

      expect(payload, isNotNull);
      expect(payload!.id, 1);
      expect(payload.title, 'Test');
      expect(payload.message, 'Message');
      expect(payload.notificationType.name, 'info');
      expect(payload.referenceType, isNull);
      expect(payload.referenceId, isNull);
    });

    test('fromMap handles default notification type', () {
      final data = {
        'id': '1',
        'title': 'Test',
        'message': 'Message',
        'notification_type': 'unknown_type',
      };

      final payload = NotificationPayload.fromMap(data);

      expect(payload, isNotNull);
      expect(payload!.notificationType.name, 'info');
    });

    test('toEntity returns correct domain notification', () {
      final data = {
        'id': '10',
        'title': 'Entity Test',
        'message': 'Entity Body',
        'notification_type': 'warning',
        'created_at': '2025-06-15T10:30:00Z',
      };

      final payload = NotificationPayload.fromMap(data);
      final entity = payload!.toEntity();

      expect(entity.id, 10);
      expect(entity.title, 'Entity Test');
      expect(entity.message, 'Entity Body');
      expect(entity.notificationType.name, 'warning');
      expect(entity.isRead, false);
    });
  });
}
