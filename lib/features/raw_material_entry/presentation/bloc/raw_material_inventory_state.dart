import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/inventory_workflow.dart';
import '../../domain/entities/raw_material_entry.dart';

enum RawMaterialInventoryAction { recordingWeight }

sealed class RawMaterialInventoryState extends Equatable {
  final List<RawMaterialEntry> entries;
  final int totalCount;
  final int page;
  final bool hasNextPage;
  final List<RawMaterialStockItem> stockItems;
  final int stockTotalCount;
  final int stockPage;
  final bool stockHasNextPage;
  final bool stockWasTruncated;
  final int? activeBatchId;
  final DateTime? lastLoadedAt;

  const RawMaterialInventoryState({
    this.entries = const [],
    this.totalCount = 0,
    this.page = 1,
    this.hasNextPage = false,
    this.stockItems = const [],
    this.stockTotalCount = 0,
    this.stockPage = 1,
    this.stockHasNextPage = false,
    this.stockWasTruncated = false,
    this.activeBatchId,
    this.lastLoadedAt,
  });

  RawMaterialInventoryAction? get action => null;

  bool get loadingStock => false;

  @override
  List<Object?> get props => [
    entries,
    totalCount,
    page,
    hasNextPage,
    stockItems,
    stockTotalCount,
    stockPage,
    stockHasNextPage,
    stockWasTruncated,
    activeBatchId,
    lastLoadedAt,
  ];
}

final class RawMaterialInventoryInitial extends RawMaterialInventoryState {
  const RawMaterialInventoryInitial();
}

final class RawMaterialInventoryLoading extends RawMaterialInventoryState {
  const RawMaterialInventoryLoading({
    super.entries,
    super.stockItems,
    super.lastLoadedAt,
  });
}

final class RawMaterialInventoryLoaded extends RawMaterialInventoryState {
  const RawMaterialInventoryLoaded({
    required super.entries,
    required super.totalCount,
    required super.page,
    required super.hasNextPage,
    required super.stockItems,
    required super.stockTotalCount,
    required super.stockPage,
    required super.stockHasNextPage,
    required super.stockWasTruncated,
    required super.lastLoadedAt,
  });
}

final class RawMaterialInventoryLoadingMore extends RawMaterialInventoryState {
  const RawMaterialInventoryLoadingMore({
    required super.entries,
    required super.totalCount,
    required super.page,
    required super.hasNextPage,
    required super.stockItems,
    required super.stockTotalCount,
    required super.stockPage,
    required super.stockHasNextPage,
    required super.stockWasTruncated,
    super.lastLoadedAt,
  });
}

final class RawMaterialInventoryWorking extends RawMaterialInventoryState {
  @override
  final RawMaterialInventoryAction action;

  const RawMaterialInventoryWorking({
    required this.action,
    required super.entries,
    required super.totalCount,
    required super.page,
    required super.hasNextPage,
    required super.stockItems,
    required super.stockTotalCount,
    required super.stockPage,
    required super.stockHasNextPage,
    required super.stockWasTruncated,
    super.activeBatchId,
    super.lastLoadedAt,
  });

  @override
  List<Object?> get props => [...super.props, action];
}

final class RawMaterialInventoryError extends RawMaterialInventoryState {
  final Failure failure;

  const RawMaterialInventoryError({
    required this.failure,
    required super.entries,
    required super.totalCount,
    required super.page,
    required super.hasNextPage,
    required super.stockItems,
    required super.stockTotalCount,
    required super.stockPage,
    required super.stockHasNextPage,
    required super.stockWasTruncated,
    super.activeBatchId,
    super.lastLoadedAt,
  });

  @override
  List<Object?> get props => [...super.props, failure];
}
