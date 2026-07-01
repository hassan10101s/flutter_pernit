import '../../../../core/errors/api_error_handler.dart';
import '../../../../core/errors/api_result.dart';
import '../../domain/entities/notification_page.dart';
import '../../domain/repos/notifications_repository.dart';
import '../datasources/notification_remote_data_source.dart';
import '../models/push_device_registration_model.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationRemoteDataSource _remoteDataSource;
  final ApiErrorHandler _apiErrorHandler;

  const NotificationsRepositoryImpl(
    this._remoteDataSource,
    this._apiErrorHandler,
  );

  @override
  Future<ApiResult<NotificationPage>> getNotifications({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final pageModel = await _remoteDataSource.getNotifications(
        page: page,
        pageSize: pageSize,
      );
      return ApiSuccess(
        NotificationPage(
          items: pageModel.items.map((m) => m.toEntity()).toList(),
          totalCount: pageModel.totalCount,
          hasMore: pageModel.hasMore,
        ),
      );
    } on Object catch (error) {
      return ApiFailure(_apiErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<int>> getUnreadCount() async {
    try {
      final count = await _remoteDataSource.getUnreadCount();
      return ApiSuccess(count);
    } on Object catch (error) {
      return ApiFailure(_apiErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<void>> markRead(int notificationId) async {
    try {
      await _remoteDataSource.markRead(notificationId);
      return const ApiSuccess(null);
    } on Object catch (error) {
      return ApiFailure(_apiErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<void>> markAllRead() async {
    try {
      await _remoteDataSource.markAllRead();
      return const ApiSuccess(null);
    } on Object catch (error) {
      return ApiFailure(_apiErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<void>> registerPushDevice({
    required String token,
    required String platform,
    required String environment,
    required String locale,
    required String timezone,
  }) async {
    try {
      await _remoteDataSource.registerPushDevice(
        PushDeviceRegistrationRequest(
          token: token,
          platform: platform,
          environment: environment,
          locale: locale,
          timezone: timezone,
        ),
      );
      return const ApiSuccess(null);
    } on Object catch (error) {
      return ApiFailure(_apiErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<void>> unregisterPushDevice(String token) async {
    try {
      await _remoteDataSource.unregisterPushDevice(token);
      return const ApiSuccess(null);
    } on Object catch (error) {
      return ApiFailure(_apiErrorHandler.handle(error));
    }
  }
}
