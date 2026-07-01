import '../../../../core/errors/api_result.dart';
import '../entities/production_lab_result.dart';
import '../repos/production_quality_repository.dart';

class LoadProductionLabResultsUseCase {
  final ProductionQualityRepository _repository;

  LoadProductionLabResultsUseCase(this._repository);

  Future<ApiResult<ProductionLabResultPage>> call({required int page}) {
    return _repository.loadResults(page: page);
  }
}
