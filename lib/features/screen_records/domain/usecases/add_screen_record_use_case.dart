import '../../../../core/errors/api_result.dart';
import '../../../../core/screen_records/pernit_screen_record.dart';
import '../repos/screen_record_repository.dart';

class AddScreenRecordUseCase {
  final ScreenRecordRepository _repository;

  const AddScreenRecordUseCase(this._repository);

  Future<ApiResult<List<PernitScreenRecord>>> call(PernitScreenRecord record) {
    return _repository.addRecord(record);
  }
}
