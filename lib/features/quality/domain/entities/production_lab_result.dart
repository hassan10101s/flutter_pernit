import 'package:equatable/equatable.dart';

class ProductionLabResult extends Equatable {
  final int id;
  final int sampleId;
  final String? sampleNo;
  final int parameterId;
  final String? parameterName;
  final String value;
  final int? measuredById;
  final String? measuredByName;
  final DateTime? measuredAt;
  final bool isWithinRange;
  final DateTime createdAt;

  const ProductionLabResult({
    required this.id,
    required this.sampleId,
    this.sampleNo,
    required this.parameterId,
    this.parameterName,
    required this.value,
    this.measuredById,
    this.measuredByName,
    this.measuredAt,
    this.isWithinRange = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    sampleId,
    sampleNo,
    parameterId,
    parameterName,
    value,
    measuredById,
    measuredByName,
    measuredAt,
    isWithinRange,
    createdAt,
  ];
}

class ProductionLabResultPage extends Equatable {
  final List<ProductionLabResult> items;
  final int totalCount;
  final int page;
  final bool hasMore;

  const ProductionLabResultPage({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.hasMore,
  });

  ProductionLabResultPage copyWith({
    List<ProductionLabResult>? items,
    int? totalCount,
    int? page,
    bool? hasMore,
  }) {
    return ProductionLabResultPage(
      items: items ?? this.items,
      totalCount: totalCount ?? this.totalCount,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
    );
  }

  @override
  List<Object?> get props => [items, totalCount, page, hasMore];
}
