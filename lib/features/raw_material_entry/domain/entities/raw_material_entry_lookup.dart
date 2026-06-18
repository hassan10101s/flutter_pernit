import 'package:equatable/equatable.dart';

class LookupOption extends Equatable {
  final int id;
  final String label;
  final String? subtitle;
  final Map<String, String> metadata;

  const LookupOption({
    required this.id,
    required this.label,
    this.subtitle,
    this.metadata = const {},
  });

  String? get rawMaterialName => metadata['rawMaterialName'];

  String? get supplierName => metadata['supplierName'];

  String? get unitName => metadata['unitName'];

  String? get availableQuantity => metadata['availableQuantity'];

  @override
  List<Object?> get props => [id, label, subtitle, metadata];
}

class RawMaterialEntryLookups extends Equatable {
  final List<LookupOption> rawMaterials;
  final List<LookupOption> warehouses;
  final List<LookupOption> purchaseOrderDetails;
  final List<LookupOption> drivers;

  const RawMaterialEntryLookups({
    this.rawMaterials = const [],
    this.warehouses = const [],
    this.purchaseOrderDetails = const [],
    this.drivers = const [],
  });

  static const empty = RawMaterialEntryLookups();

  bool get hasRequiredEntryData {
    return rawMaterials.isNotEmpty && warehouses.isNotEmpty;
  }

  @override
  List<Object?> get props => [
    rawMaterials,
    warehouses,
    purchaseOrderDetails,
    drivers,
  ];
}

class RawMaterialEntryDraft extends Equatable {
  final int rawMaterialId;
  final int? purchaseOrderDetailId;
  final int? warehouseId;
  final double quantityFromSupplier;
  final String? vehicleNo;
  final String? driverName;
  final String? lotNo;
  final DateTime? expiryDate;

  const RawMaterialEntryDraft({
    required this.rawMaterialId,
    required this.purchaseOrderDetailId,
    required this.warehouseId,
    required this.quantityFromSupplier,
    required this.vehicleNo,
    required this.driverName,
    required this.lotNo,
    required this.expiryDate,
  });

  bool get isValid {
    return rawMaterialId > 0 && quantityFromSupplier > 0;
  }

  @override
  List<Object?> get props => [
    rawMaterialId,
    purchaseOrderDetailId,
    warehouseId,
    quantityFromSupplier,
    vehicleNo,
    driverName,
    lotNo,
    expiryDate,
  ];
}
