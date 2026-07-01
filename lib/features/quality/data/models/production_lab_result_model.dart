import '../../domain/entities/production_lab_result.dart';

class ProductionLabResultModel {
  final int id;
  final int sampleId;
  final String? sampleNo;
  final int parameterId;
  final String? parameterName;
  final String value;
  final int? measuredById;
  final String? measuredByName;
  final String? measuredAtRaw;
  final bool isWithinRange;
  final String createdAtRaw;

  const ProductionLabResultModel({
    required this.id,
    required this.sampleId,
    this.sampleNo,
    required this.parameterId,
    this.parameterName,
    required this.value,
    this.measuredById,
    this.measuredByName,
    this.measuredAtRaw,
    this.isWithinRange = false,
    required this.createdAtRaw,
  });

  factory ProductionLabResultModel.fromJson(Map<String, dynamic> json) {
    final sample = json['sample'];
    final int sampleId;
    if (sample is Map<String, dynamic>) {
      sampleId = sample['id'] as int;
    } else {
      sampleId = (sample as num?)?.toInt() ?? 0;
    }

    final parameter = json['parameter'];
    final int parameterId;
    String? parameterName;
    if (parameter is Map<String, dynamic>) {
      parameterId = parameter['id'] as int;
      parameterName = parameter['name'] as String?;
    } else {
      parameterId = (parameter as num?)?.toInt() ?? 0;
    }

    final measuredBy = json['measured_by'];
    final int? measuredById;
    String? measuredByName;
    if (measuredBy is Map<String, dynamic>) {
      measuredById = measuredBy['id'] as int?;
      measuredByName = measuredBy['name'] as String?;
    } else if (measuredBy is num) {
      measuredById = measuredBy.toInt();
    } else {
      measuredById = null;
    }

    return ProductionLabResultModel(
      id: (json['id'] as num).toInt(),
      sampleId: sampleId,
      sampleNo: json['sample_no'] as String?,
      parameterId: parameterId,
      parameterName: parameterName,
      value: json['value'] as String? ?? '',
      measuredById: measuredById,
      measuredByName: measuredByName,
      measuredAtRaw: json['measured_at'] as String?,
      isWithinRange: json['is_within_range'] == true,
      createdAtRaw: json['created_at'] as String? ?? '',
    );
  }

  ProductionLabResult toEntity() {
    return ProductionLabResult(
      id: id,
      sampleId: sampleId,
      sampleNo: sampleNo,
      parameterId: parameterId,
      parameterName: parameterName,
      value: value,
      measuredById: measuredById,
      measuredByName: measuredByName,
      measuredAt: measuredAtRaw != null
          ? DateTime.tryParse(measuredAtRaw!)
          : null,
      isWithinRange: isWithinRange,
      createdAt: DateTime.tryParse(createdAtRaw) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'sample': sampleId, 'parameter': parameterId, 'value': value};
  }

  static List<ProductionLabResult> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .map(
          (e) => ProductionLabResultModel.fromJson(
            e as Map<String, dynamic>,
          ).toEntity(),
        )
        .toList();
  }
}
