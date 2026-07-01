import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pernit/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:flutter_pernit/features/notifications/data/models/notification_page_model.dart';
import 'package:flutter_pernit/features/notifications/data/models/push_device_registration_model.dart';

void main() {
  late Dio dio;
  late DioNotificationRemoteDataSource dataSource;
  late _MockAdapter mockAdapter;

  setUp(() {
    mockAdapter = _MockAdapter();
    dio = Dio()..httpClientAdapter = mockAdapter;
    dataSource = DioNotificationRemoteDataSource(dio);
  });

  group('getNotifications', () {
    test('parses paginated response with results/count/next', () async {
      mockAdapter.responseData = {
        'count': 30,
        'next': 'http://example.com/notifications/?page=2',
        'previous': null,
        'results': [
          {
            'id': 1,
            'title': 'Test',
            'message': 'Test message',
            'notification_type': 'info',
            'created_at': '2025-06-15T10:30:00Z',
          },
        ],
      };

      final page = await dataSource.getNotifications();

      expect(page, isA<NotificationPageModel>());
      expect(page.items.length, 1);
      expect(page.totalCount, 30);
      expect(page.hasMore, true);
    });

    test('parses paginated response with no more pages', () async {
      mockAdapter.responseData = {
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

      final page = await dataSource.getNotifications();

      expect(page.hasMore, false);
    });

    test('returns empty page on null response', () async {
      mockAdapter.responseData = null;

      final page = await dataSource.getNotifications();

      expect(page.items, isEmpty);
      expect(page.totalCount, 0);
      expect(page.hasMore, false);
    });

    test('throws on network error', () async {
      mockAdapter.shouldThrow = true;

      expect(() => dataSource.getNotifications(), throwsA(isA<DioException>()));
    });

    test('passes correct query parameters', () async {
      mockAdapter.responseData = {
        'count': 0,
        'next': null,
        'previous': null,
        'results': <dynamic>[],
      };

      await dataSource.getNotifications(page: 2, pageSize: 50);

      final options = mockAdapter.lastRequestOptions;
      expect(options, isNotNull);
      expect(options!.queryParameters['page'], 2);
      expect(options.queryParameters['page_size'], 50);
      expect(options.queryParameters['ordering'], '-created_at');
    });
  });

  group('getUnreadCount', () {
    test('parses int response', () async {
      mockAdapter.responseData = 5;

      final count = await dataSource.getUnreadCount();

      expect(count, 5);
    });

    test('parses map response with unread_count', () async {
      mockAdapter.responseData = {'unread_count': 3};

      final count = await dataSource.getUnreadCount();

      expect(count, 3);
    });

    test('parses map response with count key', () async {
      mockAdapter.responseData = {'count': 7};

      final count = await dataSource.getUnreadCount();

      expect(count, 7);
    });

    test('returns 0 on empty map', () async {
      mockAdapter.responseData = <String, dynamic>{};

      final count = await dataSource.getUnreadCount();

      expect(count, 0);
    });
  });

  group('markRead', () {
    test('succeeds', () async {
      mockAdapter.responseData = <String, dynamic>{};

      await expectLater(dataSource.markRead(42), completes);
    });
  });

  group('markAllRead', () {
    test('succeeds', () async {
      mockAdapter.responseData = <String, dynamic>{};

      await expectLater(dataSource.markAllRead(), completes);
    });
  });

  group('registerPushDevice', () {
    test('sends request and parses response without raw token', () async {
      mockAdapter.responseData = {
        'id': 'dev-001',
        'token_preview': 'fcm-t***',
        'platform': 'android',
        'is_active': true,
      };

      final request = PushDeviceRegistrationRequest(
        token: 'fcm-token-123',
        platform: 'android',
        environment: 'dev',
        locale: 'ar',
        timezone: 'UTC+02:00',
      );

      final response = await dataSource.registerPushDevice(request);

      expect(response.id, 'dev-001');
      expect(response.tokenPreview, 'fcm-t***');
      expect(response.platform, 'android');
      expect(response.isActive, true);
    });
  });

  group('unregisterPushDevice', () {
    test('succeeds', () async {
      mockAdapter.responseData = <String, dynamic>{};

      await expectLater(
        dataSource.unregisterPushDevice('token-123'),
        completes,
      );
    });
  });
}

class _MockAdapter implements HttpClientAdapter {
  dynamic responseData;
  bool shouldThrow = false;
  RequestOptions? lastRequestOptions;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<dynamic>? cancelFuture,
  ) async {
    lastRequestOptions = options;

    if (shouldThrow) {
      throw DioException(requestOptions: options);
    }

    final body = responseData != null
        ? utf8.encoder.convert(jsonEncode(responseData))
        : utf8.encoder.convert('null');

    return ResponseBody.fromBytes(
      body,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
      statusMessage: 'OK',
    );
  }

  @override
  void close({bool force = false}) {}
}
