import '../../domain/entities/production_quality_check.dart';

class ProductionQualityCheckModel {
  final int id;
  final String status;
  final String? comments;
  final int receivedProductId;
  final String? productionOrderCode;
  final int? checkedById;
  final String? checkedByName;
  final String createdAtRaw;

  const ProductionQualityCheckModel({
    required this.id,
    required this.status,
    this.comments,
    required this.receivedProductId,
    this.productionOrderCode,
    this.checkedById,
    this.checkedByName,
    required this.createdAtRaw,
  });

  factory ProductionQualityCheckModel.fromJson(Map<String, dynamic> json) {
    final checkedBy = json['checked_by'];
    final int? checkedById;
    String? checkedByName;
    if (checkedBy is Map<String, dynamic>) {
      checkedById = checkedBy['id'] as int?;
      checkedByName = checkedBy['name'] as String?;
    } else if (checkedBy is num) {
      checkedById = checkedBy.toInt();
    } else {
      checkedById = null;
    }

    return ProductionQualityCheckModel(
      id: (json['id'] as num).toInt(),
      status: json['status'] as String? ?? 'pending',
      comments: json['comments'] as String?,
      receivedProductId: (json['received_product'] as num?)?.toInt() ?? 0,
      productionOrderCode: json['production_order_code'] as String?,
      checkedById: checkedById,
      checkedByName: checkedByName,
      createdAtRaw: json['created_at'] as String? ?? '',
    );
  }

  ProductionQualityCheck toEntity() {
    return ProductionQualityCheck(
      id: id,
      status: status,
      comments: comments,
      receivedProductId: receivedProductId,
      productionOrderCode: productionOrderCode,
      checkedById: checkedById,
      checkedByName: checkedByName,
      createdAt: DateTime.tryParse(createdAtRaw) ?? DateTime.now(),
    );
  }

  static List<ProductionQualityCheck> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .map(
          (e) => ProductionQualityCheckModel.fromJson(
            e as Map<String, dynamic>,
          ).toEntity(),
        )
        .toList();
  }
}
