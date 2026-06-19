import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/inventory_workflow.dart';
import '../../domain/entities/raw_material_entry.dart';
import '../../domain/entities/raw_material_entry_lookup.dart';

enum RawMaterialInventoryAction { recordingWeight, addingProductStock }

sealed class RawMaterialInventoryState extends Equatable {
  final List<RawMaterialEntry> entries;
  final int totalCount;
  final int page;
  final bool hasNextPage;
  final List<RawMaterialStockItem> stockItems;
  final int stockTotalCount;
  final int stockPage;
  final bool stockHasNextPage;
  final List<ProductStockItem> productStock;
  final List<LookupOption> products;
  final List<LookupOption> warehouses;
  final int? activeBatchId;

  const RawMaterialInventoryState({
    this.entries = const [],
    this.totalCount = 0,
    this.page = 1,
    this.hasNextPage = false,
    this.stockItems = const [],
    this.stockTotalCount = 0,
    this.stockPage = 1,
    this.stockHasNextPage = false,
    this.productStock = const [],
    this.products = const [],
    this.warehouses = const [],
    this.activeBatchId,
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
    productStock,
    products,
    warehouses,
    activeBatchId,
  ];
}

final class RawMaterialInventoryInitial extends RawMaterialInventoryState {
  const RawMaterialInventoryInitial();
}

final class RawMaterialInventoryLoading extends RawMaterialInventoryState {
  const RawMaterialInventoryLoading({
    super.entries,
    super.stockItems,
    super.productStock,
    super.products,
    super.warehouses,
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
    required super.productStock,
    required super.products,
    required super.warehouses,
  });
}

final class RawMaterialInventoryLoadingMore extends RawMaterialInventoryState {
  @override
  final bool loadingStock;

  const RawMaterialInventoryLoadingMore({
    required this.loadingStock,
    required super.entries,
    required super.totalCount,
    required super.page,
    required super.hasNextPage,
    required super.stockItems,
    required super.stockTotalCount,
    required super.stockPage,
    required super.stockHasNextPage,
    required super.productStock,
    required super.products,
    required super.warehouses,
  });

  @override
  List<Object?> get props => [...super.props, loadingStock];
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
    required super.productStock,
    required super.products,
    required super.warehouses,
    super.activeBatchId,
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
    required super.productStock,
    required super.products,
    required super.warehouses,
    super.activeBatchId,
  });

  @override
  List<Object?> get props => [...super.props, failure];
}
