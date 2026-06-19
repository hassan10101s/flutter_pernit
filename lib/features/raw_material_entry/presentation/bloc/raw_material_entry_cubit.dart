import '../../../../core/bloc/safe_cubit.dart';
import '../../../../core/errors/api_result.dart';
import '../../domain/entities/raw_material_entry.dart';
import '../../domain/entities/raw_material_entry_lookup.dart';
import '../../domain/usecases/raw_material_entry_use_cases.dart';
import 'raw_material_entry_state.dart';

class RawMaterialEntryCubit extends SafeCubit<RawMaterialEntryState> {
  final LoadRawMaterialEntriesUseCase _loadEntries;
  final LoadRawMaterialEntryLookupsUseCase _loadLookups;
  final CreateRawMaterialEntryUseCase _createEntry;

  RawMaterialEntryCubit(this._loadEntries, this._loadLookups, this._createEntry)
    : super(const RawMaterialEntryInitial());

  Future<void> load({RawMaterialEntryStatus? status}) async {
    safeEmit(
      RawMaterialEntryLoading(
        selectedStatus: status,
        entries: state.entries,
        lookups: state.lookups,
      ),
    );

    final entriesFuture = _loadEntries(status: status);
    final lookupsFuture = _loadLookups();

    final entriesResult = await entriesFuture;
    final lookupsResult = await lookupsFuture;

    switch ((entriesResult, lookupsResult)) {
      case (
        ApiSuccess<List<RawMaterialEntry>>(data: final entries),
        ApiSuccess<RawMaterialEntryLookups>(data: final lookups),
      ):
        if (entries.isEmpty) {
          safeEmit(
            RawMaterialEntryEmpty(selectedStatus: status, lookups: lookups),
          );
          return;
        }

        safeEmit(
          RawMaterialEntryLoaded(
            selectedStatus: status,
            entries: entries,
            lookups: lookups,
          ),
        );
      case (ApiFailure<List<RawMaterialEntry>>(failure: final failure), _):
        safeEmit(
          RawMaterialEntryError(
            failure: failure,
            selectedStatus: status,
            entries: state.entries,
            lookups: state.lookups,
          ),
        );
      case (_, ApiFailure<RawMaterialEntryLookups>(failure: final failure)):
        safeEmit(
          RawMaterialEntryError(
            failure: failure,
            selectedStatus: status,
            entries: state.entries,
            lookups: state.lookups,
          ),
        );
    }
  }

  Future<void> selectStatus(RawMaterialEntryStatus? status) {
    return load(status: status);
  }

  Future<void> refreshLookups() async {
    safeEmit(
      RawMaterialEntryLookupsRefreshing(
        selectedStatus: state.selectedStatus,
        entries: state.entries,
        lookups: state.lookups,
      ),
    );

    final result = await _loadLookups();
    switch (result) {
      case ApiSuccess<RawMaterialEntryLookups>(data: final lookups):
        _emitDataState(entries: state.entries, lookups: lookups);
      case ApiFailure<RawMaterialEntryLookups>(failure: final failure):
        safeEmit(
          RawMaterialEntryError(
            failure: failure,
            selectedStatus: state.selectedStatus,
            entries: state.entries,
            lookups: state.lookups,
          ),
        );
    }
  }

  Future<void> submit(RawMaterialEntryDraft draft) async {
    safeEmit(
      RawMaterialEntrySubmitting(
        selectedStatus: state.selectedStatus,
        entries: state.entries,
        lookups: state.lookups,
      ),
    );

    final result = await _createEntry(draft);
    switch (result) {
      case ApiSuccess<RawMaterialEntry>(data: final createdEntry):
        safeEmit(
          RawMaterialEntrySubmitSuccess(
            createdEntry: createdEntry,
            selectedStatus: state.selectedStatus,
            entries: [createdEntry, ...state.entries],
            lookups: state.lookups,
          ),
        );
        await load(status: state.selectedStatus);
      case ApiFailure<RawMaterialEntry>(failure: final failure):
        safeEmit(
          RawMaterialEntrySubmitError(
            failure: failure,
            selectedStatus: state.selectedStatus,
            entries: state.entries,
            lookups: state.lookups,
          ),
        );
    }
  }

  void _emitDataState({
    required List<RawMaterialEntry> entries,
    required RawMaterialEntryLookups lookups,
  }) {
    if (entries.isEmpty) {
      safeEmit(
        RawMaterialEntryEmpty(
          selectedStatus: state.selectedStatus,
          lookups: lookups,
        ),
      );
      return;
    }

    safeEmit(
      RawMaterialEntryLoaded(
        selectedStatus: state.selectedStatus,
        entries: entries,
        lookups: lookups,
      ),
    );
  }
}
