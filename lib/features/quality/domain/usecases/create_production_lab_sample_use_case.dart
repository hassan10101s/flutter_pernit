import '../../../../core/errors/api_result.dart';
import '../entities/production_lab_sample.dart';
import '../repos/production_quality_repository.dart';

class CreateProductionLabSampleUseCase {
  final ProductionQualityRepository _repository;

  CreateProductionLabSampleUseCase(this._repository);

  Future<ApiResult<ProductionLabSample>> call(
    int productionOrderId, {
    String? quantityTaken,
  }) {
    return _repository.createSample(
      productionOrderId,
      quantityTaken: quantityTaken,
    );
  }
}
