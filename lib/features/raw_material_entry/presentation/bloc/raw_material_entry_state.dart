import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/raw_material_entry.dart';
import '../../domain/entities/raw_material_entry_lookup.dart';

sealed class RawMaterialEntryState extends Equatable {
  final RawMaterialEntryStatus? selectedStatus;
  final List<RawMaterialEntry> entries;
  final RawMaterialEntryLookups lookups;

  const RawMaterialEntryState({
    this.selectedStatus,
    this.entries = const [],
    this.lookups = RawMaterialEntryLookups.empty,
  });

  @override
  List<Object?> get props => [selectedStatus, entries, lookups];
}

final class RawMaterialEntryInitial extends RawMaterialEntryState {
  const RawMaterialEntryInitial();
}

final class RawMaterialEntryLoading extends RawMaterialEntryState {
  const RawMaterialEntryLoading({
    required super.selectedStatus,
    super.entries,
    super.lookups,
  });
}

final class RawMaterialEntryLoaded extends RawMaterialEntryState {
  const RawMaterialEntryLoaded({
    required super.selectedStatus,
    required super.entries,
    required super.lookups,
  });
}

final class RawMaterialEntryEmpty extends RawMaterialEntryState {
  const RawMaterialEntryEmpty({
    required super.selectedStatus,
    required super.lookups,
  });
}

final class RawMaterialEntryError extends RawMaterialEntryState {
  final Failure failure;

  const RawMaterialEntryError({
    required this.failure,
    required super.selectedStatus,
    super.entries,
    super.lookups,
  });

  @override
  List<Object?> get props => [...super.props, failure];
}

final class RawMaterialEntryLookupsRefreshing extends RawMaterialEntryState {
  const RawMaterialEntryLookupsRefreshing({
    required super.selectedStatus,
    required super.entries,
    required super.lookups,
  });
}

final class RawMaterialEntrySubmitting extends RawMaterialEntryState {
  const RawMaterialEntrySubmitting({
    required super.selectedStatus,
    required super.entries,
    required super.lookups,
  });
}

final class RawMaterialEntrySubmitSuccess extends RawMaterialEntryState {
  final RawMaterialEntry createdEntry;

  const RawMaterialEntrySubmitSuccess({
    required this.createdEntry,
    required super.selectedStatus,
    required super.entries,
    required super.lookups,
  });

  @override
  List<Object?> get props => [...super.props, createdEntry];
}

final class RawMaterialEntrySubmitError extends RawMaterialEntryState {
  final Failure failure;

  const RawMaterialEntrySubmitError({
    required this.failure,
    required super.selectedStatus,
    required super.entries,
    required super.lookups,
  });

  @override
  List<Object?> get props => [...super.props, failure];
}
