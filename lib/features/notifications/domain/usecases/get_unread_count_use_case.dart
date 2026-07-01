import '../../../../core/errors/api_result.dart';
import '../repos/notifications_repository.dart';

class GetUnreadCountUseCase {
  final NotificationsRepository _repository;

  const GetUnreadCountUseCase(this._repository);

  Future<ApiResult<int>> call() {
    return _repository.getUnreadCount();
  }
}
