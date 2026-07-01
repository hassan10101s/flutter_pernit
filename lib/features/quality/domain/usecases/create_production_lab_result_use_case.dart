import '../../../../core/errors/api_result.dart';
import '../entities/production_lab_result.dart';
import '../repos/production_quality_repository.dart';

class CreateProductionLabResultUseCase {
  final ProductionQualityRepository _repository;

  CreateProductionLabResultUseCase(this._repository);

  Future<ApiResult<ProductionLabResult>> call({
    required int sampleId,
    required int parameterId,
    required String value,
  }) {
    return _repository.createResult(
      sampleId: sampleId,
      parameterId: parameterId,
      value: value,
    );
  }
}
