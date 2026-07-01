import 'package:equatable/equatable.dart';

class ProductionLabSample extends Equatable {
  final int id;
  final int productionOrderId;
  final String? productionOrderCode;
  final String? quantityTaken;
  final String status;
  final int? takenById;
  final String? takenByName;
  final DateTime? takenAt;
  final DateTime createdAt;

  const ProductionLabSample({
    required this.id,
    required this.productionOrderId,
    this.productionOrderCode,
    this.quantityTaken,
    required this.status,
    this.takenById,
    this.takenByName,
    this.takenAt,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    productionOrderId,
    productionOrderCode,
    quantityTaken,
    status,
    takenById,
    takenByName,
    takenAt,
    createdAt,
  ];
}

class ProductionLabSamplePage extends Equatable {
  final List<ProductionLabSample> items;
  final int totalCount;
  final int page;
  final bool hasMore;

  const ProductionLabSamplePage({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.hasMore,
  });

  ProductionLabSamplePage copyWith({
    List<ProductionLabSample>? items,
    int? totalCount,
    int? page,
    bool? hasMore,
  }) {
    return ProductionLabSamplePage(
      items: items ?? this.items,
      totalCount: totalCount ?? this.totalCount,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [items, totalCount, page, hasMore];
}
