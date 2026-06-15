import '../../../../core/errors/api_result.dart';
import '../entities/auth_session.dart';
import '../repos/auth_repository.dart';

class RestoreSessionUseCase {
  final AuthRepository _repository;

  const RestoreSessionUseCase(this._repository);

  Future<ApiResult<AuthSession>> call() {
    return _repository.restoreSession();
  }
}
