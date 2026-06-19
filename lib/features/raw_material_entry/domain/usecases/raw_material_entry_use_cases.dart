import '../../../../core/errors/api_result.dart';
import '../entities/raw_material_entry.dart';
import '../entities/raw_material_entry_lookup.dart';
import '../repos/raw_material_entry_repository.dart';

class LoadRawMaterialEntriesUseCase {
  final RawMaterialEntryRepository _repository;

  const LoadRawMaterialEntriesUseCase(this._repository);

  Future<ApiResult<List<RawMaterialEntry>>> call({
    RawMaterialEntryStatus? status,
  }) {
    return _repository.fetchEntries(status: status);
  }
}

class LoadRawMaterialEntryLookupsUseCase {
  final RawMaterialEntryRepository _repository;

  const LoadRawMaterialEntryLookupsUseCase(this._repository);

  Future<ApiResult<RawMaterialEntryLookups>> call() {
    return _repository.fetchLookups();
  }
}

class CreateRawMaterialEntryUseCase {
  final RawMaterialEntryRepository _repository;

  const CreateRawMaterialEntryUseCase(this._repository);

  Future<ApiResult<RawMaterialEntry>> call(RawMaterialEntryDraft draft) {
    return _repository.createEntry(draft);
  }
}
