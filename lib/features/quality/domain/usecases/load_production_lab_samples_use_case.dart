import '../../../../core/errors/api_result.dart';
import '../entities/production_lab_sample.dart';
import '../repos/production_quality_repository.dart';

class LoadProductionLabSamplesUseCase {
  final ProductionQualityRepository _repository;

  LoadProductionLabSamplesUseCase(this._repository);

  Future<ApiResult<ProductionLabSamplePage>> call({required int page}) {
    return _repository.loadSamples(page: page);
  }
}
