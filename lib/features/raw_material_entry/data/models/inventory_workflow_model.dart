import '../../domain/entities/inventory_workflow.dart';

class RawMaterialStockPageModel extends RawMaterialStockPage {
  const RawMaterialStockPageModel({
    required super.items,
    required super.totalCount,
    required super.page,
    required super.hasNextPage,
  });

  factory RawMaterialStockPageModel.fromJson(
    Object? payload, {
    required int page,
  }) {
    final values = _listFromPayload(payload);
    return RawMaterialStockPageModel(
      items: [
        for (final value in values)
          if (value is Map<String, dynamic>)
            RawMaterialStockItem(
              id: _readInt(value['id']) ?? 0,
              rawMaterialId: _readInt(value['raw_material']) ?? 0,
              rawMaterialName:
                  _readString(value['raw_material_name']) ?? 'Raw material',
              warehouseId: _readInt(value['warehouse']) ?? 0,
              warehouseName:
                  _readString(value['warehouse_name']) ?? 'Warehouse',
              quantity: _readDouble(value['quantity']) ?? 0,
              reservedQuantity: _readDouble(value['reserved_quantity']) ?? 0,
              unitName: _readString(value['parameter_name']),
            ),
      ],
      totalCount: payload is Map<String, dynamic>
          ? _readInt(payload['count']) ?? values.length
          : values.length,
      page: page,
      hasNextPage:
          payload is Map<String, dynamic> &&
          _readString(payload['next']) != null,
    );
  }
}

class ProductStockItemModel extends ProductStockItem {
  const ProductStockItemModel({
    required super.id,
    required super.productId,
    required super.productName,
    required super.warehouseId,
    required super.warehouseName,
    required super.quantity,
    required super.reservedQuantity,
    required super.unitName,
  });

  factory ProductStockItemModel.fromJson(Map<String, dynamic> json) {
    return ProductStockItemModel(
      id: _readInt(json['id']) ?? 0,
      productId: _readInt(json['product']) ?? 0,
      productName: _readString(json['product_name']) ?? 'Product',
      warehouseId: _readInt(json['warehouse']) ?? 0,
      warehouseName: _readString(json['warehouse_name']) ?? 'Warehouse',
      quantity: _readDouble(json['quantity']) ?? 0,
      reservedQuantity: _readDouble(json['reserved_quantity']) ?? 0,
      unitName: _readString(json['unit_name']),
    );
  }
}

List<dynamic> _listFromPayload(Object? payload) {
  if (payload is List<dynamic>) {
    return payload;
  }
  if (payload is Map<String, dynamic>) {
    final values = payload['results'];
    if (values is List<dynamic>) {
      return values;
    }
  }
  return const [];
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
  if (normalized == null || normalized.isEmpty || normalized == 'null') {
    return null;
  }
  return normalized;
}
