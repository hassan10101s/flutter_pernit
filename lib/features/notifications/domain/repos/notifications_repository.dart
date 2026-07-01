import '../../../../core/errors/api_result.dart';
import '../entities/notification_page.dart';

abstract class NotificationsRepository {
  Future<ApiResult<NotificationPage>> getNotifications({
    int page = 1,
    int pageSize = 20,
  });

  Future<ApiResult<int>> getUnreadCount();

  Future<ApiResult<void>> markRead(int notificationId);

  Future<ApiResult<void>> markAllRead();

  Future<ApiResult<void>> registerPushDevice({
    required String token,
    required String platform,
    required String environment,
    required String locale,
    required String timezone,
  });

  Future<ApiResult<void>> unregisterPushDevice(String token);
}
