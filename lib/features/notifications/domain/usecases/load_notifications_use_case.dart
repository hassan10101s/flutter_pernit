import '../../../../core/errors/api_result.dart';
import '../entities/notification_page.dart';
import '../repos/notifications_repository.dart';

class LoadNotificationsUseCase {
  final NotificationsRepository _repository;

  const LoadNotificationsUseCase(this._repository);

  Future<ApiResult<NotificationPage>> call({int page = 1, int pageSize = 20}) {
    return _repository.getNotifications(page: page, pageSize: pageSize);
  }
}
