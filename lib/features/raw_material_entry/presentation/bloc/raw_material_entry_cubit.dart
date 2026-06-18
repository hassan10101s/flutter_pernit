import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/api_result.dart';
import '../../domain/entities/raw_material_entry.dart';
import '../../domain/entities/raw_material_entry_lookup.dart';
import '../../domain/repos/raw_material_entry_repository.dart';
import 'raw_material_entry_state.dart';

class RawMaterialEntryCubit extends Cubit<RawMaterialEntryState> {
  final RawMaterialEntryRepository _repository;

  RawMaterialEntryCubit(this._repository)
    : super(const RawMaterialEntryInitial());

  Future<void> load({RawMaterialEntryStatus? status}) async {
    emit(
      RawMaterialEntryLoading(
        selectedStatus: status,
        entries: state.entries,
        lookups: state.lookups,
      ),
    );

    final entriesFuture = _repository.fetchEntries(status: status);
    final lookupsFuture = _repository.fetchLookups();

    final entriesResult = await entriesFuture;
    final lookupsResult = await lookupsFuture;

    switch ((entriesResult, lookupsResult)) {
      case (
        ApiSuccess<List<RawMaterialEntry>>(data: final entries),
        ApiSuccess<RawMaterialEntryLookups>(data: final lookups),
      ):
        if (entries.isEmpty) {
          emit(RawMaterialEntryEmpty(selectedStatus: status, lookups: lookups));
          return;
        }

        emit(
          RawMaterialEntryLoaded(
            selectedStatus: status,
            entries: entries,
            lookups: lookups,
          ),
        );
      case (ApiFailure<List<RawMaterialEntry>>(failure: final failure), _):
        emit(
          RawMaterialEntryError(
            failure: failure,
            selectedStatus: status,
            entries: state.entries,
            lookups: state.lookups,
          ),
        );
      case (_, ApiFailure<RawMaterialEntryLookups>(failure: final failure)):
        emit(
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
    emit(
      RawMaterialEntryLookupsRefreshing(
        selectedStatus: state.selectedStatus,
        entries: state.entries,
        lookups: state.lookups,
      ),
    );

    final result = await _repository.fetchLookups();
    switch (result) {
      case ApiSuccess<RawMaterialEntryLookups>(data: final lookups):
        _emitDataState(entries: state.entries, lookups: lookups);
      case ApiFailure<RawMaterialEntryLookups>(failure: final failure):
        emit(
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
    emit(
      RawMaterialEntrySubmitting(
        selectedStatus: state.selectedStatus,
        entries: state.entries,
        lookups: state.lookups,
      ),
    );

    final result = await _repository.createEntry(draft);
    switch (result) {
      case ApiSuccess<RawMaterialEntry>(data: final createdEntry):
        emit(
          RawMaterialEntrySubmitSuccess(
            createdEntry: createdEntry,
            selectedStatus: state.selectedStatus,
            entries: [createdEntry, ...state.entries],
            lookups: state.lookups,
          ),
        );
        await load(status: state.selectedStatus);
      case ApiFailure<RawMaterialEntry>(failure: final failure):
        emit(
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
      emit(
        RawMaterialEntryEmpty(
          selectedStatus: state.selectedStatus,
          lookups: lookups,
        ),
      );
      return;
    }

    emit(
      RawMaterialEntryLoaded(
        selectedStatus: state.selectedStatus,
        entries: entries,
        lookups: lookups,
      ),
    );
  }
}
