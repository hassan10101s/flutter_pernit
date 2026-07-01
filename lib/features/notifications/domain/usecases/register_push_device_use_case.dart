import '../../../../core/errors/api_result.dart';
import '../repos/notifications_repository.dart';

class RegisterPushDeviceUseCase {
  final NotificationsRepository _repository;

  const RegisterPushDeviceUseCase(this._repository);

  Future<ApiResult<void>> call({
    required String token,
    required String platform,
    required String environment,
    required String locale,
    required String timezone,
  }) {
    return _repository.registerPushDevice(
      token: token,
      platform: platform,
      environment: environment,
      locale: locale,
      timezone: timezone,
    );
  }
}
