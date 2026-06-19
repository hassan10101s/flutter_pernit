import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../../domain/entities/raw_material_entry.dart';
import '../../domain/entities/raw_material_entry_lookup.dart';
import '../../domain/entities/inventory_workflow.dart';
import '../../domain/entities/raw_material_workflow.dart';
import '../models/inventory_workflow_model.dart';
import '../models/raw_material_entry_lookup_model.dart';
import '../models/raw_material_entry_model.dart';
import '../models/raw_material_workflow_model.dart';

abstract class RawMaterialEntryRemoteDataSource {
  Future<List<RawMaterialEntryModel>> fetchEntries({
    RawMaterialEntryStatus? status,
  });

  Future<List<LookupOptionModel>> fetchRawMaterials({String? search});

  Future<List<LookupOptionModel>> fetchProducts({String? search});

  Future<List<LookupOptionModel>> fetchWarehouses({String? search});

  Future<List<LookupOptionModel>> fetchPurchaseOrderDetails({String? search});

  Future<List<LookupOptionModel>> fetchDrivers({String? search});

  Future<RawMaterialEntryModel> createEntry(RawMaterialEntryDraft draft);

  Future<RawMaterialEntryPageModel> fetchWorkflowEntries({
    RawMaterialEntryStatus? status,
    bool? isInStock,
    required int page,
  });

  Future<RawMaterialSampleModel> takeSample(int batchId);

  Future<RawMaterialSamplePageModel> fetchSamples({
    int? batchId,
    required int page,
  });

  Future<RawMaterialAnalysisWorkspaceModel> fetchAnalysisWorkspace(
    int sampleId,
  );

  Future<RawMaterialAnalysisWorkspaceModel> submitAnalysis(
    int sampleId,
    RawMaterialAnalysisSubmission submission,
  );

  Future<void> submitQualityDecision({
    required int batchId,
    required RawMaterialQualityDecision decision,
    String? comments,
  });

  Future<void> recordActualWeight({
    required int batchId,
    required double measuredQuantity,
    required String measuredImagePath,
  });

  Future<RawMaterialStockPageModel> fetchRawMaterialStock({required int page});

  Future<List<ProductStockItemModel>> fetchProductStock();

  Future<ProductStockItemModel> addProductStock(ProductStockDraft draft);
}

class DioRawMaterialEntryRemoteDataSource
    implements RawMaterialEntryRemoteDataSource {
  final Dio _dio;
  CancelToken? _entriesCancelToken;
  CancelToken? _workflowEntriesCancelToken;
  CancelToken? _sampleCancelToken;
  CancelToken? _workspaceCancelToken;
  CancelToken? _rawStockCancelToken;
  CancelToken? _productStockCancelToken;

  DioRawMaterialEntryRemoteDataSource(this._dio);

  @override
  Future<List<RawMaterialEntryModel>> fetchEntries({
    RawMaterialEntryStatus? status,
  }) async {
    _entriesCancelToken?.cancel();
    _entriesCancelToken = CancelToken();
    final response = await _dio.get<dynamic>(
      ApiConstants.receivedRawMaterials,
      queryParameters: {
        'ordering': '-created_at',
        if (status != null) 'status': status.apiValue,
      },
      cancelToken: _entriesCancelToken,
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
  Future<List<LookupOptionModel>> fetchProducts({String? search}) async {
    final response = await _dio.get<dynamic>(
      ApiConstants.products,
      queryParameters: _lookupQuery(search, ordering: 'name'),
    );

    return _modelsFromPayload(response.data, LookupOptionModel.product);
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

  @override
  Future<RawMaterialEntryPageModel> fetchWorkflowEntries({
    RawMaterialEntryStatus? status,
    bool? isInStock,
    required int page,
  }) async {
    _workflowEntriesCancelToken?.cancel();
    _workflowEntriesCancelToken = CancelToken();
    final response = await _dio.get<dynamic>(
      ApiConstants.receivedRawMaterials,
      queryParameters: {
        'ordering': '-updated_at',
        'page': page,
        'status': ?status?.apiValue,
        'is_in_stock': ?isInStock,
      },
      cancelToken: _workflowEntriesCancelToken,
    );

    return RawMaterialEntryPageModel.fromJson(response.data, page: page);
  }

  @override
  Future<RawMaterialSampleModel> takeSample(int batchId) async {
    final response = await _dio.post<dynamic>(
      ApiConstants.rawMaterialLabSamples,
      data: {'received_raw_material': batchId},
    );
    return RawMaterialSampleModel.fromJson(_mapFromPayload(response.data));
  }

  @override
  Future<RawMaterialSamplePageModel> fetchSamples({
    int? batchId,
    required int page,
  }) async {
    _sampleCancelToken?.cancel();
    _sampleCancelToken = CancelToken();
    final response = await _dio.get<dynamic>(
      ApiConstants.rawMaterialLabSamples,
      queryParameters: {
        'ordering': '-created_at',
        'page': page,
        'received_raw_material': ?batchId,
      },
      cancelToken: _sampleCancelToken,
    );
    return RawMaterialSamplePageModel.fromJson(response.data, page: page);
  }

  @override
  Future<RawMaterialAnalysisWorkspaceModel> fetchAnalysisWorkspace(
    int sampleId,
  ) async {
    _workspaceCancelToken?.cancel();
    _workspaceCancelToken = CancelToken();
    final response = await _dio.get<dynamic>(
      ApiConstants.rawMaterialAnalysisWorkspace(sampleId),
      cancelToken: _workspaceCancelToken,
    );
    return RawMaterialAnalysisWorkspaceModel.fromJson(
      _mapFromPayload(response.data),
    );
  }

  @override
  Future<RawMaterialAnalysisWorkspaceModel> submitAnalysis(
    int sampleId,
    RawMaterialAnalysisSubmission submission,
  ) async {
    final response = await _dio.post<dynamic>(
      ApiConstants.rawMaterialAnalysisWorkspace(sampleId),
      data: {
        'chemical_results': [
          for (final result in submission.chemicalResults)
            {'parameter': result.parameterId, 'value': result.value},
        ],
        'physical_results': [
          for (final result in submission.physicalResults)
            {'physical_parameter': result.parameterId, 'value': result.value},
        ],
      },
    );
    return RawMaterialAnalysisWorkspaceModel.fromJson(
      _mapFromPayload(response.data),
    );
  }

  @override
  Future<void> submitQualityDecision({
    required int batchId,
    required RawMaterialQualityDecision decision,
    String? comments,
  }) async {
    await _dio.post<dynamic>(
      ApiConstants.rawMaterialQualityChecks,
      data: {
        'received_raw_material': batchId,
        'status': decision.apiValue,
        if (_hasText(comments)) 'comments': comments!.trim(),
      },
    );
  }

  @override
  Future<void> recordActualWeight({
    required int batchId,
    required double measuredQuantity,
    required String measuredImagePath,
  }) async {
    await _dio.post<dynamic>(
      ApiConstants.recordAcceptedRawMaterialQuantity(batchId),
      data: FormData.fromMap({
        'measured_quantity': measuredQuantity.toString(),
        'measured_image': await MultipartFile.fromFile(measuredImagePath),
      }),
    );
  }

  @override
  Future<RawMaterialStockPageModel> fetchRawMaterialStock({
    required int page,
  }) async {
    _rawStockCancelToken?.cancel();
    _rawStockCancelToken = CancelToken();
    final response = await _dio.get<dynamic>(
      ApiConstants.rawMaterialInventory,
      queryParameters: {
        'ordering': 'warehouse__name,raw_material__name',
        'page': page,
      },
      cancelToken: _rawStockCancelToken,
    );
    return RawMaterialStockPageModel.fromJson(response.data, page: page);
  }

  @override
  Future<List<ProductStockItemModel>> fetchProductStock() async {
    _productStockCancelToken?.cancel();
    _productStockCancelToken = CancelToken();
    final response = await _dio.get<dynamic>(
      ApiConstants.productInventory,
      queryParameters: {
        'ordering': 'warehouse__name,product__name',
        'page_size': 100,
      },
      cancelToken: _productStockCancelToken,
    );
    return _modelsFromPayload(response.data, ProductStockItemModel.fromJson);
  }

  @override
  Future<ProductStockItemModel> addProductStock(ProductStockDraft draft) async {
    final response = await _dio.post<dynamic>(
      ApiConstants.addProductStock,
      data: {
        'product': draft.productId,
        'warehouse': draft.warehouseId,
        'quantity': draft.quantity.toString(),
      },
    );
    return ProductStockItemModel.fromJson(_mapFromPayload(response.data));
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

  Map<String, dynamic> _mapFromPayload(Object? payload) {
    if (payload is Map<String, dynamic>) {
      final data = payload['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      return payload;
    }
    return const {};
  }
}
