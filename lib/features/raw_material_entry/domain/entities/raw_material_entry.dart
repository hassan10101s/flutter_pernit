import 'package:equatable/equatable.dart';

import 'raw_material_workflow.dart';

enum RawMaterialEntryStatus {
  arrived('arrived'),
  sampleTaken('sample_taken'),
  labPending('lab_pending'),
  qcPending('qc_pending'),
  approved('approved'),
  rejected('rejected');

  final String apiValue;

  const RawMaterialEntryStatus(this.apiValue);

  static RawMaterialEntryStatus fromApiValue(String? value) {
    final normalized = value?.trim().toLowerCase();
    return RawMaterialEntryStatus.values.firstWhere(
      (status) => status.apiValue == normalized,
      orElse: () => RawMaterialEntryStatus.arrived,
    );
  }

  bool get isClosed {
    return this == RawMaterialEntryStatus.approved ||
        this == RawMaterialEntryStatus.rejected;
  }
}

class RawMaterialEntry extends Equatable {
  final int id;
  final int? rawMaterialId;
  final int? purchaseOrderDetailId;
  final int? warehouseId;
  final String rawMaterialName;
  final String? supplierName;
  final double quantityFromSupplier;
  final String? unitName;
  final String? warehouseName;
  final RawMaterialEntryStatus status;
  final bool isSampled;
  final bool isLabDone;
  final bool isQcDone;
  final bool isInStock;
  final double? acceptedQuantity;
  final double? rejectedQuantity;
  final double? availableQuantity;
  final double? measuredQuantity;
  final String? vehicleNo;
  final String? driverName;
  final String? lotNo;
  final DateTime? expiryDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final EntryMetadata? metadata;

  const RawMaterialEntry({
    required this.id,
    required this.rawMaterialId,
    required this.purchaseOrderDetailId,
    required this.warehouseId,
    required this.rawMaterialName,
    required this.supplierName,
    required this.quantityFromSupplier,
    required this.unitName,
    required this.warehouseName,
    required this.status,
    required this.isSampled,
    required this.isLabDone,
    required this.isQcDone,
    required this.isInStock,
    required this.acceptedQuantity,
    required this.rejectedQuantity,
    required this.availableQuantity,
    required this.measuredQuantity,
    required this.vehicleNo,
    required this.driverName,
    required this.lotNo,
    required this.expiryDate,
    required this.createdAt,
    this.updatedAt,
    this.metadata,
  });

  String get entryCode {
    final prefix = rawMaterialName.toUpperCase().contains('VITAMIN')
        ? 'PV'
        : 'SB';
    final year = createdAt?.year.toString() ?? DateTime.now().year.toString();
    return '$prefix-$year-${id.toString().padLeft(3, '0')}';
  }

  @override
  List<Object?> get props => [
    id,
    rawMaterialId,
    purchaseOrderDetailId,
    warehouseId,
    rawMaterialName,
    supplierName,
    quantityFromSupplier,
    unitName,
    warehouseName,
    status,
    isSampled,
    isLabDone,
    isQcDone,
    isInStock,
    acceptedQuantity,
    rejectedQuantity,
    availableQuantity,
    measuredQuantity,
    vehicleNo,
    driverName,
    lotNo,
    expiryDate,
    createdAt,
    updatedAt,
    metadata,
  ];
}
