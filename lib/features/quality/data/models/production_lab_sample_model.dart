import '../../domain/entities/production_lab_sample.dart';

class ProductionLabSampleModel {
  final int id;
  final int productionOrderId;
  final String? productionOrderCode;
  final String? quantityTaken;
  final String status;
  final int? takenById;
  final String? takenByName;
  final String? takenAtRaw;
  final String createdAtRaw;

  const ProductionLabSampleModel({
    required this.id,
    required this.productionOrderId,
    this.productionOrderCode,
    this.quantityTaken,
    required this.status,
    this.takenById,
    this.takenByName,
    this.takenAtRaw,
    required this.createdAtRaw,
  });

  factory ProductionLabSampleModel.fromJson(Map<String, dynamic> json) {
    final order = json['production_order'];
    final int orderId;
    String? orderCode;
    if (order is Map<String, dynamic>) {
      orderId = order['id'] as int;
    } else {
      orderId = (order as num?)?.toInt() ?? 0;
    }
    orderCode = json['production_order_code'] as String?;

    final takenBy = json['taken_by'];
    final int? takenById;
    String? takenByName;
    if (takenBy is Map<String, dynamic>) {
      takenById = takenBy['id'] as int?;
      takenByName = takenBy['name'] as String?;
    } else if (takenBy is num) {
      takenById = takenBy.toInt();
    } else {
      takenById = null;
    }

    return ProductionLabSampleModel(
      id: (json['id'] as num).toInt(),
      productionOrderId: orderId,
      productionOrderCode: orderCode,
      quantityTaken: json['quantity_taken'] as String?,
      status: json['status'] as String? ?? 'pending',
      takenById: takenById,
      takenByName: takenByName,
      takenAtRaw: json['taken_at'] as String?,
      createdAtRaw: json['created_at'] as String? ?? '',
    );
  }

  ProductionLabSample toEntity() {
    return ProductionLabSample(
      id: id,
      productionOrderId: productionOrderId,
      productionOrderCode: productionOrderCode,
      quantityTaken: quantityTaken,
      status: status,
      takenById: takenById,
      takenByName: takenByName,
      takenAt: takenAtRaw != null ? DateTime.tryParse(takenAtRaw!) : null,
      createdAt: DateTime.tryParse(createdAtRaw) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'production_order': productionOrderId,
      if (quantityTaken != null && quantityTaken!.trim().isNotEmpty)
        'quantity_taken': quantityTaken!.trim(),
    };
  }

  static List<ProductionLabSample> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .map(
          (e) => ProductionLabSampleModel.fromJson(
            e as Map<String, dynamic>,
          ).toEntity(),
        )
        .toList();
  }
}
