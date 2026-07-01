import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/inventory_workflow.dart';
import '../../domain/entities/raw_material_entry_lookup.dart';

enum ProductInventoryAction { addingProductStock }

sealed class ProductInventoryState extends Equatable {
  final List<ProductStockItem> productStock;
  final int stockTotalCount;
  final int stockPage;
  final bool stockHasNextPage;
  final bool stockWasTruncated;
  final List<LookupOption> products;
  final List<LookupOption> warehouses;
  final DateTime? lastLoadedAt;

  const ProductInventoryState({
    this.productStock = const [],
    this.stockTotalCount = 0,
    this.stockPage = 1,
    this.stockHasNextPage = false,
    this.stockWasTruncated = false,
    this.products = const [],
    this.warehouses = const [],
    this.lastLoadedAt,
  });

  ProductInventoryAction? get action => null;

  @override
  List<Object?> get props => [
    productStock,
    stockTotalCount,
    stockPage,
    stockHasNextPage,
    stockWasTruncated,
    products,
    warehouses,
    lastLoadedAt,
  ];
}

final class ProductInventoryInitial extends ProductInventoryState {
  const ProductInventoryInitial();
}

final class ProductInventoryLoading extends ProductInventoryState {
  const ProductInventoryLoading({
    super.productStock,
    super.products,
    super.warehouses,
    super.lastLoadedAt,
  });
}

final class ProductInventoryLoaded extends ProductInventoryState {
  const ProductInventoryLoaded({
    required super.productStock,
    required super.stockTotalCount,
    required super.stockPage,
    required super.stockHasNextPage,
    required super.stockWasTruncated,
    required super.products,
    required super.warehouses,
    required super.lastLoadedAt,
  });
}

final class ProductInventoryLoadingMore extends ProductInventoryState {
  const ProductInventoryLoadingMore({
    required super.productStock,
    required super.stockTotalCount,
    required super.stockPage,
    required super.stockHasNextPage,
    required super.stockWasTruncated,
    required super.products,
    required super.warehouses,
    super.lastLoadedAt,
  });

  @override
  List<Object?> get props => [...super.props];
}

final class ProductInventoryWorking extends ProductInventoryState {
  @override
  final ProductInventoryAction action;

  const ProductInventoryWorking({
    required this.action,
    required super.productStock,
    required super.stockTotalCount,
    required super.stockPage,
    required super.stockHasNextPage,
    required super.stockWasTruncated,
    required super.products,
    required super.warehouses,
    super.lastLoadedAt,
  });

  @override
  List<Object?> get props => [...super.props, action];
}

final class ProductInventoryError extends ProductInventoryState {
  final Failure failure;

  const ProductInventoryError({
    required this.failure,
    required super.productStock,
    required super.stockTotalCount,
    required super.stockPage,
    required super.stockHasNextPage,
    required super.stockWasTruncated,
    required super.products,
    required super.warehouses,
    super.lastLoadedAt,
  });

  @override
  List<Object?> get props => [...super.props, failure];
}
