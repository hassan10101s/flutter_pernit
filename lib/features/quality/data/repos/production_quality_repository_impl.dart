import '../../../../core/errors/api_error_handler.dart';
import '../../../../core/errors/api_result.dart';
import '../../domain/entities/production_lab_sample.dart';
import '../../domain/entities/production_lab_result.dart';
import '../../domain/entities/production_quality_check.dart';
import '../../domain/repos/production_quality_repository.dart';
import '../datasources/production_quality_remote_data_source.dart';
import '../models/production_lab_sample_model.dart';
import '../models/production_lab_result_model.dart';
import '../models/production_quality_check_model.dart';

class ProductionQualityRepositoryImpl implements ProductionQualityRepository {
  final ProductionQualityRemoteDataSource _dataSource;
  final ApiErrorHandler _errorHandler;

  ProductionQualityRepositoryImpl(this._dataSource, this._errorHandler);

  @override
  Future<ApiResult<ProductionLabSamplePage>> loadSamples({
    required int page,
  }) async {
    try {
      final payload = await _dataSource.fetchSamples(page: page);
      final items = ProductionLabSampleModel.listFromJson(payload.rawItems);
      return ApiSuccess(
        ProductionLabSamplePage(
          items: items,
          totalCount: payload.totalCount,
          page: page,
          hasMore: payload.hasMore,
        ),
      );
    } catch (e) {
      return ApiFailure(_errorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<ProductionLabSample>> createSample(
    int productionOrderId, {
    String? quantityTaken,
  }) async {
    try {
      final model = await _dataSource.createSample(
        productionOrderId: productionOrderId,
        quantityTaken: quantityTaken,
      );
      return ApiSuccess(model.toEntity());
    } catch (e) {
      return ApiFailure(_errorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<ProductionLabResultPage>> loadResults({
    required int page,
  }) async {
    try {
      final payload = await _dataSource.fetchResults(page: page);
      final items = ProductionLabResultModel.listFromJson(payload.rawItems);
      return ApiSuccess(
        ProductionLabResultPage(
          items: items,
          totalCount: payload.totalCount,
          page: page,
          hasMore: payload.hasMore,
        ),
      );
    } catch (e) {
      return ApiFailure(_errorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<ProductionLabResult>> createResult({
    required int sampleId,
    required int parameterId,
    required String value,
  }) async {
    try {
      final model = await _dataSource.createResult(
        sampleId: sampleId,
        parameterId: parameterId,
        value: value,
      );
      return ApiSuccess(model.toEntity());
    } catch (e) {
      return ApiFailure(_errorHandler.handle(e));
    }
  }

  @override
  Future<ApiResult<ProductionQualityCheckPage>> loadChecks({
    required int page,
  }) async {
    try {
      final payload = await _dataSource.fetchChecks(page: page);
      final items = ProductionQualityCheckModel.listFromJson(payload.rawItems);
      return ApiSuccess(
        ProductionQualityCheckPage(
          items: items,
          totalCount: payload.totalCount,
          page: page,
          hasMore: payload.hasMore,
        ),
      );
    } catch (e) {
      return ApiFailure(_errorHandler.handle(e));
    }
  }
}
