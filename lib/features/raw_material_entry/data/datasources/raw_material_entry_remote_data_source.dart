import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../domain/entities/raw_material_entry.dart';
import '../../domain/entities/raw_material_entry_lookup.dart';
import '../models/raw_material_entry_lookup_model.dart';
import '../models/raw_material_entry_model.dart';

abstract class RawMaterialEntryRemoteDataSource {
  Future<List<RawMaterialEntryModel>> fetchEntries({
    RawMaterialEntryStatus? status,
  });

  Future<List<LookupOptionModel>> fetchRawMaterials({String? search});

  Future<List<LookupOptionModel>> fetchWarehouses({String? search});

  Future<List<LookupOptionModel>> fetchPurchaseOrderDetails({String? search});

  Future<List<LookupOptionModel>> fetchDrivers({String? search});

  Future<RawMaterialEntryModel> createEntry(RawMaterialEntryDraft draft);
}

class DioRawMaterialEntryRemoteDataSource
    implements RawMaterialEntryRemoteDataSource {
  final Dio _dio;

  const DioRawMaterialEntryRemoteDataSource(this._dio);

  @override
  Future<List<RawMaterialEntryModel>> fetchEntries({
    RawMaterialEntryStatus? status,
  }) async {
    final response = await _dio.get<dynamic>(
      ApiConstants.receivedRawMaterials,
      queryParameters: {
        'ordering': '-created_at',
        if (status != null) 'status': status.apiValue,
      },
    );

    return _modelsFromPayload(response.data, RawMaterialEntryModel.fromJson);
  }

  @override
  Future<List<LookupOptionModel>> fetchRawMaterials({String? search}) async {
    final response = await _dio.get<dynamic>(
      ApiConstants.rawMaterials,
      queryParameters: _lookupQuery(search, ordering: 'name'),
    );

    return _modelsFromPayload(response.data, LookupOptionModel.rawMaterial);
  }

  @override
  Future<List<LookupOptionModel>> fetchWarehouses({String? search}) async {
    final response = await _dio.get<dynamic>(
      ApiConstants.warehouses,
      queryParameters: _lookupQuery(search, ordering: 'name'),
    );

    return _modelsFromPayload(response.data, LookupOptionModel.warehouse);
  }

  @override
  Future<List<LookupOptionModel>> fetchPurchaseOrderDetails({
    String? search,
  }) async {
    final response = await _dio.get<dynamic>(
      ApiConstants.purchaseOrderDetails,
      queryParameters: _lookupQuery(search, ordering: 'raw_material__name'),
    );

    return _modelsFromPayload(
      response.data,
      LookupOptionModel.purchaseOrderDetail,
    );
  }

  @override
  Future<List<LookupOptionModel>> fetchDrivers({String? search}) async {
    final response = await _dio.get<dynamic>(
      ApiConstants.allDrivers,
      queryParameters: _lookupQuery(search),
    );
    final values = _listFromPayload(response.data);

    return [
      for (var index = 0; index < values.length; index += 1)
        LookupOptionModel.driver(values[index], fallbackIndex: index),
    ];
  }

  @override
  Future<RawMaterialEntryModel> createEntry(RawMaterialEntryDraft draft) async {
    final response = await _dio.post<dynamic>(
      ApiConstants.receivedRawMaterials,
      data: _draftToJson(draft),
    );

    final payload = response.data;
    if (payload is Map<String, dynamic>) {
      return RawMaterialEntryModel.fromJson(payload);
    }

    return RawMaterialEntryModel.fromJson(_draftToJson(draft));
  }

  Map<String, Object?> _lookupQuery(String? search, {String? ordering}) {
    final normalizedSearch = search?.trim();
    final query = <String, Object?>{};
    if (ordering != null) {
      query['ordering'] = ordering;
    }
    if (normalizedSearch != null && normalizedSearch.isNotEmpty) {
      query['search'] = normalizedSearch;
    }
    return query;
  }

  Map<String, dynamic> _draftToJson(RawMaterialEntryDraft draft) {
    final expiryDate = draft.expiryDate;
    return {
      'raw_material': draft.rawMaterialId,
      if (draft.purchaseOrderDetailId != null)
        'purchase_order': draft.purchaseOrderDetailId,
      if (draft.warehouseId != null) 'warehouse': draft.warehouseId,
      'quantity_from_supplier': draft.quantityFromSupplier.toString(),
      if (_hasText(draft.vehicleNo)) 'vehicle_no': draft.vehicleNo!.trim(),
      if (_hasText(draft.driverName)) 'driver_name': draft.driverName!.trim(),
      if (_hasText(draft.lotNo)) 'lot_no': draft.lotNo!.trim(),
      if (expiryDate != null)
        'expiry_date':
            '${expiryDate.year.toString().padLeft(4, '0')}-'
            '${expiryDate.month.toString().padLeft(2, '0')}-'
            '${expiryDate.day.toString().padLeft(2, '0')}',
    };
  }

  bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }

  List<T> _modelsFromPayload<T>(
    Object? payload,
    T Function(Map<String, dynamic> json) fromJson,
  ) {
    return [
      for (final value in _listFromPayload(payload))
        if (value is Map<String, dynamic>) fromJson(value),
    ];
  }

  List<dynamic> _listFromPayload(Object? payload) {
    if (payload is List<dynamic>) {
      return payload;
    }

    if (payload is Map<String, dynamic>) {
      final values =
          payload['results'] ??
          payload['data'] ??
          payload['items'] ??
          payload['drivers'];
      if (values is List<dynamic>) {
        return values;
      }

      return [payload];
    }

    return const [];
  }
}
