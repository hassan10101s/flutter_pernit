import '../../../../core/errors/api_result.dart';
import '../../../../core/screen_records/pernit_screen_record.dart';
import '../repos/screen_record_repository.dart';

class LoadScreenRecordsUseCase {
  final ScreenRecordRepository _repository;

  const LoadScreenRecordsUseCase(this._repository);

  Future<ApiResult<List<PernitScreenRecord>>> call() {
    return _repository.fetchRecords();
  }
}
