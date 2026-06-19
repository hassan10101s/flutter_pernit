import '../../../../core/config/env_config.dart';
import '../../../../core/errors/api_error_handler.dart';
import '../../../../core/errors/api_result.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/failure_code.dart';
import '../../../../core/network/connection_checker.dart';
import '../../domain/entities/raw_material_entry.dart';
import '../../domain/entities/raw_material_entry_lookup.dart';
import '../../domain/entities/inventory_workflow.dart';
import '../../domain/entities/raw_material_workflow.dart';
import '../../domain/repos/raw_material_entry_repository.dart';
import '../datasources/raw_material_entry_remote_data_source.dart';

class RawMaterialEntryRepositoryImpl implements RawMaterialEntryRepository {
  final RawMaterialEntryRemoteDataSource _remoteDataSource;
  final ConnectionChecker _connectionChecker;
  final ApiErrorHandler _apiErrorHandler;
  final EnvConfig _envConfig;

  const RawMaterialEntryRepositoryImpl(
    this._remoteDataSource,
    this._connectionChecker,
    this._apiErrorHandler,
    this._envConfig,
  );

  @override
  Future<ApiResult<List<RawMaterialEntry>>> fetchEntries({
    RawMaterialEntryStatus? status,
  }) async {
    final guard = await _ensureReady<List<RawMaterialEntry>>();
    if (guard != null) {
      return guard;
    }

    try {
      final models = await _remoteDataSource.fetchEntries(status: status);
      return ApiSuccess([for (final model in models) model.toEntity()]);
    } on Object catch (error) {
      return ApiFailure(_apiErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<List<LookupOption>>> fetchRawMaterials({
    String? search,
  }) async {
    return _fetchLookup(
      () => _remoteDataSource.fetchRawMaterials(search: search),
    );
  }

  @override
  Future<ApiResult<List<LookupOption>>> fetchProducts({String? search}) async {
    return _fetchLookup(() => _remoteDataSource.fetchProducts(search: search));
  }

  @override
  Future<ApiResult<List<LookupOption>>> fetchWarehouses({
    String? search,
  }) async {
    return _fetchLookup(
      () => _remoteDataSource.fetchWarehouses(search: search),
    );
  }

  @override
  Future<ApiResult<List<LookupOption>>> fetchPurchaseOrderDetails({
    String? search,
  }) async {
    return _fetchLookup(
      () => _remoteDataSource.fetchPurchaseOrderDetails(search: search),
    );
  }

  @override
  Future<ApiResult<List<LookupOption>>> fetchDrivers({String? search}) async {
    return _fetchLookup(() => _remoteDataSource.fetchDrivers(search: search));
  }

  @override
  Future<ApiResult<RawMaterialEntryLookups>> fetchLookups() async {
    final guard = await _ensureReady<RawMaterialEntryLookups>();
    if (guard != null) {
      return guard;
    }

    try {
      final results = await Future.wait([
        _remoteDataSource.fetchRawMaterials(),
        _remoteDataSource.fetchWarehouses(),
        _remoteDataSource.fetchPurchaseOrderDetails(),
        _remoteDataSource.fetchDrivers(),
      ]);

      return ApiSuccess(
        RawMaterialEntryLookups(
          rawMaterials: results[0],
          warehouses: results[1],
          purchaseOrderDetails: results[2],
          drivers: results[3],
        ),
      );
    } on Object catch (error) {
      return ApiFailure(_apiErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<RawMaterialEntry>> createEntry(
    RawMaterialEntryDraft draft,
  ) async {
    final guard = await _ensureReady<RawMaterialEntry>();
    if (guard != null) {
      return guard;
    }

    if (!draft.isValid) {
      return const ApiFailure(
        Failure(code: FailureCode.validation, messageKey: 'failureValidation'),
      );
    }

    try {
      final model = await _remoteDataSource.createEntry(draft);
      return ApiSuccess(model.toEntity());
    } on Object catch (error) {
      return ApiFailure(_apiErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<RawMaterialEntryPage>> fetchWorkflowEntries({
    RawMaterialEntryStatus? status,
    bool? isInStock,
    required int page,
  }) async {
    final guard = await _ensureReady<RawMaterialEntryPage>();
    if (guard != null) {
      return guard;
    }

    try {
      final model = await _remoteDataSource.fetchWorkflowEntries(
        status: status,
        isInStock: isInStock,
        page: page,
      );
      return ApiSuccess(model.toEntity());
    } on Object catch (error) {
      return ApiFailure(_apiErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<RawMaterialSample>> takeSample(int batchId) async {
    final guard = await _ensureReady<RawMaterialSample>();
    if (guard != null) {
      return guard;
    }
    if (batchId <= 0) {
      return const ApiFailure(
        Failure(code: FailureCode.validation, messageKey: 'failureValidation'),
      );
    }

    try {
      return ApiSuccess(await _remoteDataSource.takeSample(batchId));
    } on Object catch (error) {
      return ApiFailure(_apiErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<RawMaterialSamplePage>> fetchSamples({
    int? batchId,
    required int page,
  }) async {
    final guard = await _ensureReady<RawMaterialSamplePage>();
    if (guard != null) {
      return guard;
    }

    try {
      return ApiSuccess(
        await _remoteDataSource.fetchSamples(batchId: batchId, page: page),
      );
    } on Object catch (error) {
      return ApiFailure(_apiErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<RawMaterialAnalysisWorkspace>> fetchAnalysisWorkspace(
    int sampleId,
  ) async {
    final guard = await _ensureReady<RawMaterialAnalysisWorkspace>();
    if (guard != null) {
      return guard;
    }

    try {
      return ApiSuccess(
        await _remoteDataSource.fetchAnalysisWorkspace(sampleId),
      );
    } on Object catch (error) {
      return ApiFailure(_apiErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<RawMaterialAnalysisWorkspace>> submitAnalysis({
    required int sampleId,
    required RawMaterialAnalysisSubmission submission,
  }) async {
    final guard = await _ensureReady<RawMaterialAnalysisWorkspace>();
    if (guard != null) {
      return guard;
    }
    if (sampleId <= 0) {
      return const ApiFailure(
        Failure(code: FailureCode.validation, messageKey: 'failureValidation'),
      );
    }

    try {
      return ApiSuccess(
        await _remoteDataSource.submitAnalysis(sampleId, submission),
      );
    } on Object catch (error) {
      return ApiFailure(_apiErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<bool>> submitQualityDecision({
    required int batchId,
    required RawMaterialQualityDecision decision,
    String? comments,
  }) async {
    final guard = await _ensureReady<bool>();
    if (guard != null) {
      return guard;
    }

    try {
      await _remoteDataSource.submitQualityDecision(
        batchId: batchId,
        decision: decision,
        comments: comments,
      );
      return const ApiSuccess(true);
    } on Object catch (error) {
      return ApiFailure(_apiErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<bool>> recordActualWeight({
    required int batchId,
    required double measuredQuantity,
    required String measuredImagePath,
  }) async {
    final guard = await _ensureReady<bool>();
    if (guard != null) {
      return guard;
    }
    if (batchId <= 0 ||
        measuredQuantity <= 0 ||
        measuredImagePath.trim().isEmpty) {
      return const ApiFailure(
        Failure(code: FailureCode.validation, messageKey: 'failureValidation'),
      );
    }

    try {
      await _remoteDataSource.recordActualWeight(
        batchId: batchId,
        measuredQuantity: measuredQuantity,
        measuredImagePath: measuredImagePath,
      );
      return const ApiSuccess(true);
    } on Object catch (error) {
      return ApiFailure(_apiErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<RawMaterialStockPage>> fetchRawMaterialStock({
    required int page,
  }) async {
    final guard = await _ensureReady<RawMaterialStockPage>();
    if (guard != null) {
      return guard;
    }

    try {
      return ApiSuccess(
        await _remoteDataSource.fetchRawMaterialStock(page: page),
      );
    } on Object catch (error) {
      return ApiFailure(_apiErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<List<ProductStockItem>>> fetchProductStock() async {
    final guard = await _ensureReady<List<ProductStockItem>>();
    if (guard != null) {
      return guard;
    }

    try {
      return ApiSuccess(await _remoteDataSource.fetchProductStock());
    } on Object catch (error) {
      return ApiFailure(_apiErrorHandler.handle(error));
    }
  }

  @override
  Future<ApiResult<ProductStockItem>> addProductStock(
    ProductStockDraft draft,
  ) async {
    final guard = await _ensureReady<ProductStockItem>();
    if (guard != null) {
      return guard;
    }
    if (!draft.isValid) {
      return const ApiFailure(
        Failure(code: FailureCode.validation, messageKey: 'failureValidation'),
      );
    }

    try {
      return ApiSuccess(await _remoteDataSource.addProductStock(draft));
    } on Object catch (error) {
      return ApiFailure(_apiErrorHandler.handle(error));
    }
  }

  Future<ApiResult<List<LookupOption>>> _fetchLookup(
    Future<List<LookupOption>> Function() request,
  ) async {
    final guard = await _ensureReady<List<LookupOption>>();
    if (guard != null) {
      return guard;
    }

    try {
      return ApiSuccess(await request());
    } on Object catch (error) {
      return ApiFailure(_apiErrorHandler.handle(error));
    }
  }

  Future<ApiFailure<T>?> _ensureReady<T>() async {
    if (!_envConfig.hasApiBaseUrl) {
      return const ApiFailure(
        Failure(
          code: FailureCode.unknown,
          messageKey: 'failureConfigurationMissing',
        ),
      );
    }

    final hasConnection = await _connectionChecker.hasConnection;
    if (!hasConnection) {
      return const ApiFailure(
        Failure(
          code: FailureCode.internetRequired,
          messageKey: 'failureNetwork',
        ),
      );
    }

    return null;
  }
}
