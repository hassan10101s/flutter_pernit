import '../../../../core/errors/api_result.dart';
import '../entities/production_lab_sample.dart';
import '../entities/production_lab_result.dart';
import '../entities/production_quality_check.dart';

abstract class ProductionQualityRepository {
  Future<ApiResult<ProductionLabSamplePage>> loadSamples({required int page});

  Future<ApiResult<ProductionLabSample>> createSample(
    int productionOrderId, {
    String? quantityTaken,
  });

  Future<ApiResult<ProductionLabResultPage>> loadResults({required int page});

  Future<ApiResult<ProductionLabResult>> createResult({
    required int sampleId,
    required int parameterId,
    required String value,
  });

  Future<ApiResult<ProductionQualityCheckPage>> loadChecks({required int page});
}
