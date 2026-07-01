import 'package:equatable/equatable.dart';

class ProductionQualityCheck extends Equatable {
  final int id;
  final String status;
  final String? comments;
  final int receivedProductId;
  final String? productionOrderCode;
  final int? checkedById;
  final String? checkedByName;
  final DateTime createdAt;

  const ProductionQualityCheck({
    required this.id,
    required this.status,
    this.comments,
    required this.receivedProductId,
    this.productionOrderCode,
    this.checkedById,
    this.checkedByName,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    status,
    comments,
    receivedProductId,
    productionOrderCode,
    checkedById,
    checkedByName,
    createdAt,
  ];
}

class ProductionQualityCheckPage extends Equatable {
  final List<ProductionQualityCheck> items;
  final int totalCount;
  final int page;
  final bool hasMore;

  const ProductionQualityCheckPage({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.hasMore,
  });

  ProductionQualityCheckPage copyWith({
    List<ProductionQualityCheck>? items,
    int? totalCount,
    int? page,
    bool? hasMore,
  }) {
    return ProductionQualityCheckPage(
      items: items ?? this.items,
      totalCount: totalCount ?? this.totalCount,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [items, totalCount, page, hasMore];
}
