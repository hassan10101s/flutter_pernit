import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pernit/features/notifications/data/models/notification_model.dart';

void main() {
  group('NotificationModel', () {
    test('fromJson parses full notification correctly', () {
      final json = {
        'id': 42,
        'title': 'Test Title',
        'message': 'Test Message',
        'notification_type': 'success',
        'reference_type': 'production_order',
        'reference_id': 'PO-001',
        'is_read': false,
        'created_at': '2025-06-15T10:30:00Z',
        'metadata': {'key': 'value'},
      };

      final model = NotificationModel.fromJson(json);

      expect(model.id, 42);
      expect(model.title, 'Test Title');
      expect(model.message, 'Test Message');
      expect(model.notificationType, 'success');
      expect(model.referenceType, 'production_order');
      expect(model.referenceId, 'PO-001');
      expect(model.isRead, false);
      expect(model.createdAt, DateTime.utc(2025, 6, 15, 10, 30));
      expect(model.metadata, {'key': 'value'});
    });

    test('fromJson handles string id', () {
      final json = {
        'id': '99',
        'title': 'Test',
        'message': 'Message',
        'notification_type': 'info',
        'created_at': '2025-06-15T10:30:00Z',
      };

      final model = NotificationModel.fromJson(json);

      expect(model.id, 99);
    });

    test('fromJson uses type fallback', () {
      final json = {
        'id': 1,
        'title': 'Test',
        'message': 'Message',
        'type': 'warning',
        'created_at': '2025-06-15T10:30:00Z',
      };

      final model = NotificationModel.fromJson(json);

      expect(model.notificationType, 'warning');
    });

    test('fromJson handles missing optional fields with defaults', () {
      final json = {
        'id': 1,
        'title': 'Test',
        'message': 'Message',
        'notification_type': 'info',
        'created_at': '2025-06-15T10:30:00Z',
      };

      final model = NotificationModel.fromJson(json);

      expect(model.referenceType, isNull);
      expect(model.referenceId, isNull);
      expect(model.isRead, false);
      expect(model.readAt, isNull);
      expect(model.metadata, isNull);
    });

    test('toEntity maps fields correctly', () {
      final model = NotificationModel(
        id: 1,
        title: 'Test',
        message: 'Message',
        notificationType: 'success',
        referenceType: 'production_order',
        referenceId: 'PO-001',
        isRead: true,
        createdAt: DateTime(2025, 6, 15),
      );

      final entity = model.toEntity();

      expect(entity.id, 1);
      expect(entity.title, 'Test');
      expect(entity.message, 'Message');
      expect(entity.isRead, true);
      expect(entity.referenceId, 'PO-001');
    });
  });
}
