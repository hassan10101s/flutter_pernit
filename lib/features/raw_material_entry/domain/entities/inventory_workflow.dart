import 'package:equatable/equatable.dart';

class RawMaterialStockItem extends Equatable {
  final int id;
  final int rawMaterialId;
  final String rawMaterialName;
  final int warehouseId;
  final String warehouseName;
  final double quantity;
  final double reservedQuantity;
  final double? available;
  final String? unitName;

  const RawMaterialStockItem({
    required this.id,
    required this.rawMaterialId,
    required this.rawMaterialName,
    required this.warehouseId,
    required this.warehouseName,
    required this.quantity,
    required this.reservedQuantity,
    this.available,
    required this.unitName,
  });

  double get availableQuantity => available ?? quantity - reservedQuantity;

  @override
  List<Object?> get props => [
    id,
    rawMaterialId,
    rawMaterialName,
    warehouseId,
    warehouseName,
    quantity,
    reservedQuantity,
    available,
    unitName,
  ];
}

class RawMaterialStockPage extends Equatable {
  final List<RawMaterialStockItem> items;
  final int totalCount;
  final int page;
  final bool hasNextPage;

  const RawMaterialStockPage({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.hasNextPage,
  });

  @override
  List<Object?> get props => [items, totalCount, page, hasNextPage];
}

class ProductStockItem extends Equatable {
  final int id;
  final int productId;
  final String productName;
  final int warehouseId;
  final String warehouseName;
  final double quantity;
  final double reservedQuantity;
  final double? available;
  final String? unitName;

  const ProductStockItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.warehouseId,
    required this.warehouseName,
    required this.quantity,
    required this.reservedQuantity,
    this.available,
    required this.unitName,
  });

  double get availableQuantity => available ?? quantity - reservedQuantity;

  @override
  List<Object?> get props => [
    id,
    productId,
    productName,
    warehouseId,
    warehouseName,
    quantity,
    reservedQuantity,
    available,
    unitName,
  ];
}

class ProductStockPage extends Equatable {
  final List<ProductStockItem> items;
  final int totalCount;
  final int page;
  final bool hasNextPage;

  const ProductStockPage({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.hasNextPage,
  });

  @override
  List<Object?> get props => [items, totalCount, page, hasNextPage];
}

class ProductStockDraft extends Equatable {
  final int productId;
  final int warehouseId;
  final double quantity;

  const ProductStockDraft({
    required this.productId,
    required this.warehouseId,
    required this.quantity,
  });

  bool get isValid => productId > 0 && warehouseId > 0 && quantity > 0;

  @override
  List<Object?> get props => [productId, warehouseId, quantity];
}
