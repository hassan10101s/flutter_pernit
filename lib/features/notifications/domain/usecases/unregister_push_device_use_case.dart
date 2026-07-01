import '../../../../core/errors/api_result.dart';
import '../repos/notifications_repository.dart';

class UnregisterPushDeviceUseCase {
  final NotificationsRepository _repository;

  const UnregisterPushDeviceUseCase(this._repository);

  Future<ApiResult<void>> call(String token) {
    return _repository.unregisterPushDevice(token);
  }
}
