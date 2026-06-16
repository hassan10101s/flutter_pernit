import '../../../../core/errors/api_result.dart';
import '../../../../core/screen_records/pernit_screen_record.dart';

abstract class ScreenRecordRepository {
  Future<ApiResult<List<PernitScreenRecord>>> fetchRecords();

  Future<ApiResult<List<PernitScreenRecord>>> addRecord(
    PernitScreenRecord record,
  );

  Future<ApiResult<List<PernitScreenRecord>>> updateRecord(
    int index,
    PernitScreenRecord record,
  );

  Future<ApiResult<List<PernitScreenRecord>>> deleteRecord(int index);
}
