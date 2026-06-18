import '../../domain/entities/raw_material_entry_lookup.dart';

class LookupOptionModel extends LookupOption {
  const LookupOptionModel({
    required super.id,
    required super.label,
    super.subtitle,
    super.metadata,
  });

  factory LookupOptionModel.rawMaterial(Map<String, dynamic> json) {
    final name = _firstString(json, const ['name', 'raw_material_name']);
    final shortCode = _firstString(json, const ['short_code', 'code']);
    final baseUnit = _firstString(json, const ['base_unit_name', 'unit_name']);
    final category = _firstString(json, const ['category_name']);

    return LookupOptionModel(
      id: _readInt(json['id']) ?? 0,
      label: _joinLabel(shortCode, name ?? 'Raw material'),
      subtitle: _joinSubtitle([category, baseUnit]),
      metadata: _cleanMetadata({
        'shortCode': shortCode,
        'unitName': baseUnit,
        'categoryName': category,
      }),
    );
  }

  factory LookupOptionModel.warehouse(Map<String, dynamic> json) {
    return LookupOptionModel(
      id: _readInt(json['id']) ?? 0,
      label: _firstString(json, const ['name']) ?? 'Warehouse',
      subtitle: _firstString(json, const ['location']),
    );
  }

  factory LookupOptionModel.purchaseOrderDetail(Map<String, dynamic> json) {
    final rawMaterialName = _firstString(json, const ['raw_material_name']);
    final supplierName = _firstString(json, const ['supplier_name']);
    final unitName = _firstString(json, const ['unit_name']);
    final availableQuantity = _firstString(json, const [
      'available',
      'available_quantity',
      'remaining_quantity',
    ]);
    final quantity = _firstString(json, const ['quantity']);

    return LookupOptionModel(
      id: _readInt(json['id']) ?? 0,
      label: _joinLabel(
        _firstString(json, const ['purchase_order']),
        rawMaterialName ?? 'Purchase order detail',
      ),
      subtitle: _joinSubtitle([
        supplierName,
        if (availableQuantity != null)
          'Available $availableQuantity${unitName == null ? '' : ' $unitName'}'
        else if (quantity != null)
          'Quantity $quantity${unitName == null ? '' : ' $unitName'}',
      ]),
      metadata: _cleanMetadata({
        'rawMaterialId': _firstString(json, const ['raw_material']),
        'rawMaterialName': rawMaterialName,
        'supplierName': supplierName,
        'unitName': unitName,
        'availableQuantity': availableQuantity,
      }),
    );
  }

  factory LookupOptionModel.driver(Object value, {required int fallbackIndex}) {
    if (value is Map<String, dynamic>) {
      final name = _firstString(value, const [
        'driver_name',
        'name',
        'title',
        'value',
      ]);
      return LookupOptionModel(
        id: _readInt(value['id']) ?? _stableId(name, fallbackIndex),
        label: name ?? 'Driver',
      );
    }

    final name = value.toString().trim();
    return LookupOptionModel(
      id: _stableId(name.isEmpty ? null : name, fallbackIndex),
      label: name.isEmpty ? 'Driver' : name,
    );
  }
}

int? _readInt(Object? value) {
  if (value is int) {
    return value;
  }
  return int.tryParse(value?.toString() ?? '');
}

String? _firstString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key]?.toString().trim();
    if (value != null && value.isNotEmpty && value != 'null') {
      return value;
    }
  }
  return null;
}

String _joinLabel(String? prefix, String label) {
  if (prefix == null || prefix.trim().isEmpty) {
    return label;
  }
  return '$prefix - $label';
}

String? _joinSubtitle(List<String?> parts) {
  final cleanParts = [
    for (final part in parts)
      if (part != null && part.trim().isNotEmpty) part.trim(),
  ];
  if (cleanParts.isEmpty) {
    return null;
  }
  return cleanParts.join(' | ');
}

Map<String, String> _cleanMetadata(Map<String, String?> values) {
  return {
    for (final entry in values.entries)
      if (entry.value != null && entry.value!.trim().isNotEmpty)
        entry.key: entry.value!.trim(),
  };
}

int _stableId(String? value, int fallbackIndex) {
  if (value == null || value.isEmpty) {
    return fallbackIndex + 1;
  }

  var hash = 0;
  for (final codeUnit in value.codeUnits) {
    hash = 0x1fffffff & (hash + codeUnit);
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    hash = hash ^ (hash >> 6);
  }
  return hash == 0 ? fallbackIndex + 1 : hash;
}
