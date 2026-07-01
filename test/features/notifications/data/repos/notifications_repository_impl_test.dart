import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_pernit/core/errors/api_error_handler.dart';
import 'package:flutter_pernit/core/errors/api_result.dart';
import 'package:flutter_pernit/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:flutter_pernit/features/notifications/data/models/notification_page_model.dart';
import 'package:flutter_pernit/features/notifications/data/models/push_device_registration_model.dart';
import 'package:flutter_pernit/features/notifications/data/repos/notifications_repository_impl.dart';
import 'package:flutter_pernit/features/notifications/domain/entities/notification_page.dart';
import 'package:flutter_pernit/features/notifications/domain/repos/notifications_repository.dart';

void main() {
  late NotificationsRepository repository;
  late _FakeNotificationRemoteDataSource remoteDataSource;

  setUp(() {
    remoteDataSource = _FakeNotificationRemoteDataSource();
    repository = NotificationsRepositoryImpl(
      remoteDataSource,
      const ApiErrorHandler(),
    );
  });

  group('getNotifications', () {
    test('returns success with notification page', () async {
      remoteDataSource.pageModel = const NotificationPageModel(
        items: [],
        totalCount: 1,
        hasMore: false,
      );

      final result = await repository.getNotifications();

      expect(result, isA<ApiSuccess<NotificationPage>>());
      final data = (result as ApiSuccess<NotificationPage>).data;
      expect(data.items.length, 0);
      expect(data.totalCount, 1);
      expect(data.hasMore, false);
    });

    test('returns failure when data source throws', () async {
      remoteDataSource.shouldThrow = true;

      final result = await repository.getNotifications();

      expect(result, isA<ApiFailure<NotificationPage>>());
    });
  });

  group('getUnreadCount', () {
    test('returns success with count', () async {
      remoteDataSource.unreadCount = 5;

      final result = await repository.getUnreadCount();

      expect(result, isA<ApiSuccess<int>>());
      expect((result as ApiSuccess<int>).data, 5);
    });
  });

  group('markRead', () {
    test('returns success', () async {
      final result = await repository.markRead(1);

      expect(result, isA<ApiSuccess<void>>());
      expect(remoteDataSource.markedReadIds, contains(1));
    });
  });

  group('markAllRead', () {
    test('returns success', () async {
      final result = await repository.markAllRead();

      expect(result, isA<ApiSuccess<void>>());
      expect(remoteDataSource.markAllReadCalled, true);
    });
  });

  group('registerPushDevice', () {
    test('returns success', () async {
      final result = await repository.registerPushDevice(
        token: 'token-123',
        platform: 'android',
        environment: 'dev',
        locale: 'ar',
        timezone: 'UTC+02:00',
      );

      expect(result, isA<ApiSuccess<void>>());
      expect(remoteDataSource.registeredToken, 'token-123');
      expect(remoteDataSource.registeredPlatform, 'android');
      expect(remoteDataSource.registeredEnvironment, 'dev');
      expect(remoteDataSource.registeredLocale, 'ar');
      expect(remoteDataSource.registeredTimezone, 'UTC+02:00');
    });
  });

  group('unregisterPushDevice', () {
    test('returns success', () async {
      final result = await repository.unregisterPushDevice('token-123');

      expect(result, isA<ApiSuccess<void>>());
      expect(remoteDataSource.unregisteredToken, 'token-123');
    });
  });
}

class _FakeNotificationRemoteDataSource
    implements NotificationRemoteDataSource {
  NotificationPageModel pageModel = const NotificationPageModel(
    items: [],
    totalCount: 0,
    hasMore: false,
  );
  int unreadCount = 0;
  bool shouldThrow = false;
  bool markAllReadCalled = false;
  List<int> markedReadIds = [];
  String? registeredToken;
  String? registeredPlatform;
  String? registeredEnvironment;
  String? registeredLocale;
  String? registeredTimezone;
  String? unregisteredToken;

  @override
  Future<NotificationPageModel> getNotifications({
    int page = 1,
    int pageSize = 20,
  }) async {
    if (shouldThrow) throw DioException(requestOptions: RequestOptions());
    return pageModel;
  }

  @override
  Future<int> getUnreadCount() async {
    if (shouldThrow) throw DioException(requestOptions: RequestOptions());
    return unreadCount;
  }

  @override
  Future<void> markRead(int notificationId) async {
    if (shouldThrow) throw DioException(requestOptions: RequestOptions());
    markedReadIds.add(notificationId);
  }

  @override
  Future<void> markAllRead() async {
    if (shouldThrow) throw DioException(requestOptions: RequestOptions());
    markAllReadCalled = true;
  }

  @override
  Future<PushDeviceRegistrationResponse> registerPushDevice(
    PushDeviceRegistrationRequest request,
  ) async {
    if (shouldThrow) throw DioException(requestOptions: RequestOptions());
    registeredToken = request.token;
    registeredPlatform = request.platform;
    registeredEnvironment = request.environment;
    registeredLocale = request.locale;
    registeredTimezone = request.timezone;
    return PushDeviceRegistrationResponse(
      id: 'dev-1',
      platform: request.platform,
      isActive: true,
    );
  }

  @override
  Future<void> unregisterPushDevice(String token) async {
    if (shouldThrow) throw DioException(requestOptions: RequestOptions());
    unregisteredToken = token;
  }
}
