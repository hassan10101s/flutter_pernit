import '../../domain/entities/raw_material_entry.dart';
import '../../domain/entities/raw_material_workflow.dart';

class RawMaterialEntryModel extends RawMaterialEntry {
  const RawMaterialEntryModel({
    required super.id,
    required super.rawMaterialId,
    required super.purchaseOrderDetailId,
    required super.warehouseId,
    required super.rawMaterialName,
    required super.supplierName,
    required super.quantityFromSupplier,
    required super.unitName,
    required super.warehouseName,
    required super.status,
    required super.isSampled,
    required super.isLabDone,
    required super.isQcDone,
    required super.isInStock,
    required super.acceptedQuantity,
    required super.rejectedQuantity,
    required super.availableQuantity,
    required super.measuredQuantity,
    required super.vehicleNo,
    required super.driverName,
    required super.lotNo,
    required super.expiryDate,
    required super.createdAt,
    super.updatedAt,
    super.metadata,
  });

  factory RawMaterialEntryModel.fromJson(Map<String, dynamic> json) {
    final rawMaterialName =
        _readString(json['raw_material_name']) ??
        _readString(json['raw_material']) ??
        'Raw material';

    return RawMaterialEntryModel(
      id: _readInt(json['id']) ?? 0,
      rawMaterialId: _readInt(json['raw_material']),
      purchaseOrderDetailId: _readInt(
        json['purchase_order'] ?? json['purchase_order_detail'],
      ),
      warehouseId: _readInt(json['warehouse']),
      rawMaterialName: rawMaterialName,
      supplierName: _readString(json['supplier_name']),
      quantityFromSupplier: _readDouble(json['quantity_from_supplier']) ?? 0,
      unitName: _readString(json['unit_name']),
      warehouseName: _readString(json['warehouse_name']),
      status: RawMaterialEntryStatus.fromApiValue(_readString(json['status'])),
      isSampled: _readBool(json['is_sampled']),
      isLabDone: _readBool(json['is_lab_done']),
      isQcDone: _readBool(json['is_qc_done']),
      isInStock: _readBool(json['is_in_stock']),
      acceptedQuantity: _readDouble(json['accepted_quantity']),
      rejectedQuantity: _readDouble(json['rejected_quantity']),
      availableQuantity: _readDouble(json['available_quantity']),
      measuredQuantity: _readDouble(json['measured_quantity']),
      vehicleNo: _readString(json['vehicle_no']),
      driverName: _readString(json['driver_name']),
      lotNo: _readString(json['lot_no']),
      expiryDate: _readDate(json['expiry_date']),
      createdAt: _readDate(json['created_at']),
      updatedAt: _readDate(json['updated_at']),
      metadata: _parseMetadata(_readMap(json['metadata'])),
    );
  }

  RawMaterialEntry toEntity() {
    return RawMaterialEntry(
      id: id,
      rawMaterialId: rawMaterialId,
      purchaseOrderDetailId: purchaseOrderDetailId,
      warehouseId: warehouseId,
      rawMaterialName: rawMaterialName,
      supplierName: supplierName,
      quantityFromSupplier: quantityFromSupplier,
      unitName: unitName,
      warehouseName: warehouseName,
      status: status,
      isSampled: isSampled,
      isLabDone: isLabDone,
      isQcDone: isQcDone,
      isInStock: isInStock,
      acceptedQuantity: acceptedQuantity,
      rejectedQuantity: rejectedQuantity,
      availableQuantity: availableQuantity,
      measuredQuantity: measuredQuantity,
      vehicleNo: vehicleNo,
      driverName: driverName,
      lotNo: lotNo,
      expiryDate: expiryDate,
      createdAt: createdAt,
      updatedAt: updatedAt,
      metadata: metadata,
    );
  }
}

EntryMetadata? _parseMetadata(Map<String, dynamic>? json) {
  if (json == null || json.isEmpty) return null;

  final samplingHistory = <SamplingRecord>[];
  final samplingJson = _readList(json['sampling_history']);
  for (final item in samplingJson) {
    if (item is Map<String, dynamic>) {
      final takenAt = DateTime.tryParse(
        _readString(item['taken_at']) ?? '',
      );
      if (takenAt == null) continue;
      samplingHistory.add(
        SamplingRecord(
          id: _readInt(item['id']) ?? 0,
          takenBy: _readString(item['taken_by']) ?? '-',
          takenAt: takenAt,
          sampleNo: _readString(item['sample_no']) ?? '-',
        ),
      );
    }
  }

  final qcHistory = <QcRecord>[];
  final qcJson = _readList(json['qc_history']);
  for (final item in qcJson) {
    if (item is Map<String, dynamic>) {
      final timestamp = DateTime.tryParse(
        _readString(item['timestamp']) ?? '',
      );
      if (timestamp == null) continue;
      qcHistory.add(
        QcRecord(
          qcId: _readInt(item['qc_id']) ?? 0,
          checkedByName: _readString(item['checked_by_name']) ?? '-',
          qcStatus: _readString(item['qc_status']) ?? '-',
          timestamp: timestamp,
          comments: _readString(item['comments']),
        ),
      );
    }
  }

  if (samplingHistory.isEmpty && qcHistory.isEmpty) return null;

  return EntryMetadata(
    samplingHistory: samplingHistory,
    qcHistory: qcHistory,
  );
}

Map<String, dynamic> _readMap(Object? value) {
  return value is Map<String, dynamic> ? value : const {};
}

List<dynamic> _readList(Object? value) {
  return value is List<dynamic> ? value : const [];
}

int? _readInt(Object? value) {
  if (value is int) {
    return value;
  }
  return int.tryParse(value?.toString() ?? '');
}

double? _readDouble(Object? value) {
  if (value is num) {
    return value.toDouble();
  }
  return double.tryParse(value?.toString() ?? '');
}

String? _readString(Object? value) {
  final normalized = value?.toString().trim();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }
  return normalized;
}

bool _readBool(Object? value) {
  if (value is bool) {
    return value;
  }

  final normalized = value?.toString().trim().toLowerCase();
  return normalized == 'true' || normalized == '1' || normalized == 'yes';
}

DateTime? _readDate(Object? value) {
  final normalized = _readString(value);
  if (normalized == null) {
    return null;
  }
  return DateTime.tryParse(normalized);
}
