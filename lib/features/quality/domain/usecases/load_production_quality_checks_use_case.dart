import '../../../../core/errors/api_result.dart';
import '../entities/production_quality_check.dart';
import '../repos/production_quality_repository.dart';

class LoadProductionQualityChecksUseCase {
  final ProductionQualityRepository _repository;

  LoadProductionQualityChecksUseCase(this._repository);

  Future<ApiResult<ProductionQualityCheckPage>> call({required int page}) {
    return _repository.loadChecks(page: page);
  }
}
