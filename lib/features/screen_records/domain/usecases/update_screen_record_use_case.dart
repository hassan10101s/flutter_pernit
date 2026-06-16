import '../../../../core/errors/api_result.dart';
import '../../../../core/screen_records/pernit_screen_record.dart';
import '../repos/screen_record_repository.dart';

class UpdateScreenRecordUseCase {
  final ScreenRecordRepository _repository;

  const UpdateScreenRecordUseCase(this._repository);

  Future<ApiResult<List<PernitScreenRecord>>> call(
    int index,
    PernitScreenRecord record,
  ) {
    return _repository.updateRecord(index, record);
  }
}
