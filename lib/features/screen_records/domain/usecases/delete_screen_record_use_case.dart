import '../../../../core/errors/api_result.dart';
import '../../../../core/screen_records/pernit_screen_record.dart';
import '../repos/screen_record_repository.dart';

class DeleteScreenRecordUseCase {
  final ScreenRecordRepository _repository;

  const DeleteScreenRecordUseCase(this._repository);

  Future<ApiResult<List<PernitScreenRecord>>> call(int index) {
    return _repository.deleteRecord(index);
  }
}
