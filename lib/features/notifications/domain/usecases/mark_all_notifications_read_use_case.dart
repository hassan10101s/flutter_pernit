import '../../../../core/errors/api_result.dart';
import '../repos/notifications_repository.dart';

class MarkAllNotificationsReadUseCase {
  final NotificationsRepository _repository;

  const MarkAllNotificationsReadUseCase(this._repository);

  Future<ApiResult<void>> call() {
    return _repository.markAllRead();
  }
}
