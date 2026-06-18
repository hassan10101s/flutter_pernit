import '../../../../core/config/env_config.dart';
import '../../../../core/errors/api_error_handler.dart';
import '../../../../core/errors/api_result.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/failure_code.dart';
import '../../../../core/network/connection_checker.dart';
import '../../domain/entities/raw_material_entry.dart';
import '../../domain/entities/raw_material_entry_lookup.dart';
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
