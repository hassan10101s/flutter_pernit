import '../../../../core/errors/api_result.dart';
import '../../../../core/screen_records/pernit_screen_record.dart';
import '../../domain/repos/screen_record_repository.dart';

class StaticScreenRecordRepository implements ScreenRecordRepository {
  final List<PernitScreenRecord> _records;

  StaticScreenRecordRepository(List<PernitScreenRecord> initialRecords)
    : _records = [...initialRecords];

  @override
  Future<ApiResult<List<PernitScreenRecord>>> fetchRecords() async {
    return ApiSuccess([..._records]);
  }

  @override
  Future<ApiResult<List<PernitScreenRecord>>> addRecord(
    PernitScreenRecord record,
  ) async {
    _records.add(record);
    return ApiSuccess([..._records]);
  }

  @override
  Future<ApiResult<List<PernitScreenRecord>>> updateRecord(
    int index,
    PernitScreenRecord record,
  ) async {
    if (index < 0 || index >= _records.length) {
      return ApiSuccess([..._records]);
    }

    _records[index] = record;
    return ApiSuccess([..._records]);
  }

  @override
  Future<ApiResult<List<PernitScreenRecord>>> deleteRecord(int index) async {
    if (index < 0 || index >= _records.length) {
      return ApiSuccess([..._records]);
    }

    _records.removeAt(index);
    return ApiSuccess([..._records]);
  }
}
