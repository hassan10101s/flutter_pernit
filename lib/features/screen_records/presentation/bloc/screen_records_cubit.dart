import '../../../../core/bloc/safe_cubit.dart';
import '../../../../core/errors/api_result.dart';
import '../../../../core/screen_records/pernit_screen_record.dart';
import '../../domain/repos/screen_record_repository.dart';
import '../../domain/usecases/add_screen_record_use_case.dart';
import '../../domain/usecases/delete_screen_record_use_case.dart';
import '../../domain/usecases/load_screen_records_use_case.dart';
import '../../domain/usecases/update_screen_record_use_case.dart';
import 'screen_records_state.dart';

abstract class ScreenRecordsCubit extends SafeCubit<ScreenRecordsState> {
  final LoadScreenRecordsUseCase _loadRecords;
  final AddScreenRecordUseCase _addRecord;
  final UpdateScreenRecordUseCase _updateRecord;
  final DeleteScreenRecordUseCase _deleteRecord;

  ScreenRecordsCubit(ScreenRecordRepository repository)
    : _loadRecords = LoadScreenRecordsUseCase(repository),
      _addRecord = AddScreenRecordUseCase(repository),
      _updateRecord = UpdateScreenRecordUseCase(repository),
      _deleteRecord = DeleteScreenRecordUseCase(repository),
      super(const ScreenRecordsInitial());

  Future<void> load() async {
    safeEmit(ScreenRecordsLoading(records: state.records));

    final result = await _loadRecords();
    _emitResult(result);
  }

  Future<void> addRecord(PernitScreenRecord record) async {
    final result = await _addRecord(record);
    _emitResult(result);
  }

  Future<void> updateRecord(int index, PernitScreenRecord record) async {
    final result = await _updateRecord(index, record);
    _emitResult(result);
  }

  Future<void> deleteRecord(int index) async {
    final result = await _deleteRecord(index);
    _emitResult(result);
  }

  void _emitResult(ApiResult<List<PernitScreenRecord>> result) {
    switch (result) {
      case ApiSuccess<List<PernitScreenRecord>>(data: final records):
        safeEmit(ScreenRecordsLoaded(records: records));
      case ApiFailure<List<PernitScreenRecord>>(failure: final failure):
        safeEmit(ScreenRecordsError(failure: failure, records: state.records));
    }
  }
}
