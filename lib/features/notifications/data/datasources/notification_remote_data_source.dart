import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../models/notification_page_model.dart';
import '../models/push_device_registration_model.dart';

abstract class NotificationRemoteDataSource {
  Future<NotificationPageModel> getNotifications({
    int page = 1,
    int pageSize = 20,
  });

  Future<int> getUnreadCount();

  Future<void> markRead(int notificationId);

  Future<void> markAllRead();

  Future<PushDeviceRegistrationResponse> registerPushDevice(
    PushDeviceRegistrationRequest request,
  );

  Future<void> unregisterPushDevice(String token);
}

class DioNotificationRemoteDataSource implements NotificationRemoteDataSource {
  final Dio _dio;

  const DioNotificationRemoteDataSource(this._dio);

  @override
  Future<NotificationPageModel> getNotifications({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiConstants.notifications,
      queryParameters: {
        'page': page,
        'page_size': pageSize,
        'ordering': '-created_at',
      },
    );

    final data = response.data;
    if (data == null) {
      return const NotificationPageModel(
        items: [],
        totalCount: 0,
        hasMore: false,
      );
    }

    return NotificationPageModel.fromJson(data);
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await _dio.get<dynamic>(
      ApiConstants.notificationsUnreadCount,
    );
    final data = response.data;
    if (data is int) return data;
    if (data is Map) {
      return (data['unread_count'] as int?) ?? (data['count'] as int?) ?? 0;
    }
    return 0;
  }

  @override
  Future<void> markRead(int notificationId) async {
    await _dio.post<dynamic>(ApiConstants.notificationMarkRead(notificationId));
  }

  @override
  Future<void> markAllRead() async {
    await _dio.post<dynamic>(ApiConstants.notificationsMarkAllRead);
  }

  @override
  Future<PushDeviceRegistrationResponse> registerPushDevice(
    PushDeviceRegistrationRequest request,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      ApiConstants.notificationDevices,
      data: request.toJson(),
    );
    return PushDeviceRegistrationResponse.fromJson(response.data ?? const {});
  }

  @override
  Future<void> unregisterPushDevice(String token) async {
    await _dio.post<dynamic>(
      ApiConstants.notificationDevicesUnregister,
      data: {'token': token},
    );
  }
}
