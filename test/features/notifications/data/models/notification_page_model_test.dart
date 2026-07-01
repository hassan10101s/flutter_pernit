import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pernit/features/notifications/data/models/notification_page_model.dart';

void main() {
  group('NotificationPageModel', () {
    test('fromJson parses paginated response with results/count/next', () {
      final json = {
        'count': 30,
        'next': 'http://example.com/notifications/?page=2',
        'previous': null,
        'results': [
          {
            'id': 1,
            'title': 'First',
            'message': 'First message',
            'notification_type': 'info',
            'created_at': '2025-06-15T10:30:00Z',
          },
        ],
      };

      final page = NotificationPageModel.fromJson(json);

      expect(page.items.length, 1);
      expect(page.items[0].id, 1);
      expect(page.totalCount, 30);
      expect(page.hasMore, true);
    });

    test('fromJson parses paginated response with no next', () {
      final json = {
        'count': 1,
        'next': null,
        'previous': null,
        'results': [
          {
            'id': 1,
            'title': 'Only',
            'message': 'Only message',
            'notification_type': 'info',
            'created_at': '2025-06-15T10:30:00Z',
          },
        ],
      };

      final page = NotificationPageModel.fromJson(json);

      expect(page.items.length, 1);
      expect(page.totalCount, 1);
      expect(page.hasMore, false);
    });

    test('fromJson uses fallback notifications key', () {
      final json = {
        'count': 5,
        'next': null,
        'notifications': [
          {
            'id': 1,
            'title': 'Fallback',
            'message': 'Fallback message',
            'notification_type': 'info',
            'created_at': '2025-06-15T10:30:00Z',
          },
        ],
      };

      final page = NotificationPageModel.fromJson(json);

      expect(page.items.length, 1);
      expect(page.items[0].id, 1);
    });

    test('fromJson throws on unexpected format', () {
      expect(
        () => NotificationPageModel.fromJson({'unexpected': true}),
        throwsArgumentError,
      );
    });

    test('fromJson handles empty results', () {
      final json = {
        'count': 0,
        'next': null,
        'previous': null,
        'results': <dynamic>[],
      };

      final page = NotificationPageModel.fromJson(json);

      expect(page.items, isEmpty);
      expect(page.totalCount, 0);
      expect(page.hasMore, false);
    });
  });
}
