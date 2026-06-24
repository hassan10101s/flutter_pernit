import '../../../../core/config/env_config.dart';
import '../../../../core/errors/api_error_handler.dart';
import '../../../../core/errors/api_result.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/failure_code.dart';
import '../../../../core/screen_records/pernit_screen_record.dart';
import '../../domain/repos/screen_record_repository.dart';
import '../datasources/screen_record_remote_data_source.dart';
import 'screen_record_repository_dependencies.dart';

class EndpointScreenRecordRepository implements ScreenRecordRepository {
  final String endpoint;
  final ScreenRecordRemoteDataSource? _remoteDataSource;
  final ApiErrorHandler? _apiErrorHandler;
  final EnvConfig? _envConfig;
  final List<PernitScreenRecord> _records;

  EndpointScreenRecordRepository({
    required this.endpoint,
    required List<PernitScreenRecord> initialRecords,
    ScreenRecordRepositoryDependencies? dependencies,
    ScreenRecordRemoteDataSource? remoteDataSource,
    ApiErrorHandler? apiErrorHandler,
    EnvConfig? envConfig,
  }) : _remoteDataSource = remoteDataSource ?? dependencies?.remoteDataSource,
       _apiErrorHandler = apiErrorHandler ?? dependencies?.apiErrorHandler,
       _envConfig = envConfig ?? dependencies?.envConfig,
       _records = [...initialRecords];

  @override
  Future<ApiResult<List<PernitScreenRecord>>> fetchRecords() async {
    if (!_canUseRemote) {
      return ApiSuccess([..._records]);
    }

    try {
      final records = await _remoteDataSource!.fetchRecords(endpoint);
      _records
        ..clear()
        ..addAll(records.map(_recordFromJson));
      return ApiSuccess([..._records]);
    } on Object catch (error) {
      return ApiFailure(_apiErrorHandler!.handle(error));
    }
  }

  @override
  Future<ApiResult<List<PernitScreenRecord>>> addRecord(
    PernitScreenRecord record,
  ) async {
    if (!_canUseRemote) {
      _records.add(record);
      return ApiSuccess([..._records]);
    }

    try {
      final created = await _remoteDataSource!.createRecord(
        endpoint,
        record.fields,
      );
      final parsed = created.isEmpty ? record : _recordFromJson(created);
      _records.add(parsed);
      return ApiSuccess([..._records]);
    } on Object catch (error) {
      return ApiFailure(_apiErrorHandler!.handle(error));
    }
  }

  @override
  Future<ApiResult<List<PernitScreenRecord>>> updateRecord(
    int index,
    PernitScreenRecord record,
  ) async {
    if (index < 0 || index >= _records.length) {
      return ApiSuccess([..._records]);
    }

    if (!_canUseRemote) {
      _records[index] = record;
      return ApiSuccess([..._records]);
    }

    final id = _records[index].fields['id'];
    if (id == null || id.trim().isEmpty) {
      return const ApiFailure(
        Failure(code: FailureCode.validation, messageKey: 'failureValidation'),
      );
    }

    try {
      final updated = await _remoteDataSource!.updateRecord(
        endpoint,
        id,
        record.fields,
      );
      _records[index] = updated.isEmpty ? record : _recordFromJson(updated);
      return ApiSuccess([..._records]);
    } on Object catch (error) {
      return ApiFailure(_apiErrorHandler!.handle(error));
    }
  }

  @override
  Future<ApiResult<List<PernitScreenRecord>>> deleteRecord(int index) async {
    if (index < 0 || index >= _records.length) {
      return ApiSuccess([..._records]);
    }

    if (!_canUseRemote) {
      _records.removeAt(index);
      return ApiSuccess([..._records]);
    }

    final id = _records[index].fields['id'];
    if (id == null || id.trim().isEmpty) {
      return const ApiFailure(
        Failure(code: FailureCode.validation, messageKey: 'failureValidation'),
      );
    }

    try {
      await _remoteDataSource!.deleteRecord(endpoint, id);
      _records.removeAt(index);
      return ApiSuccess([..._records]);
    } on Object catch (error) {
      return ApiFailure(_apiErrorHandler!.handle(error));
    }
  }

  bool get _canUseRemote {
    return _remoteDataSource != null &&
        _apiErrorHandler != null &&
        (_envConfig?.hasApiBaseUrl ?? false);
  }

  PernitScreenRecord _recordFromJson(Map<String, dynamic> json) {
    final fields = {
      for (final entry in json.entries)
        if (entry.value != null) entry.key: entry.value.toString(),
    };

    return PernitScreenRecord.api(
      title: _titleFromFields(fields),
      fields: fields,
    );
  }

  String _titleFromFields(Map<String, String> fields) {
    for (final key in const [
      'title',
      'name',
      'short_code',
      'sample_no',
      'order_no',
      'document_number',
      'id',
    ]) {
      final value = fields[key];
      if (value != null && value.trim().isNotEmpty) {
        return value;
      }
    }

    return fields.values
            .where((value) => value.trim().isNotEmpty)
            .firstOrNull ??
        endpoint;
  }
}
