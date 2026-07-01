import '../../../../core/errors/api_result.dart';
import '../repos/notifications_repository.dart';

class MarkNotificationReadUseCase {
  final NotificationsRepository _repository;

  const MarkNotificationReadUseCase(this._repository);

  Future<ApiResult<void>> call(int notificationId) {
    return _repository.markRead(notificationId);
  }
}
