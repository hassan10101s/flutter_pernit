import 'package:dio/dio.dart';

import '../../../../core/network/api_constants.dart';
import '../models/production_lab_sample_model.dart';
import '../models/production_lab_result_model.dart';

abstract class ProductionQualityRemoteDataSource {
  Future<ProductionLabSamplePagePayload> fetchSamples({required int page});

  Future<ProductionLabSampleModel> createSample({
    required int productionOrderId,
    String? quantityTaken,
  });

  Future<ProductionLabResultPagePayload> fetchResults({required int page});

  Future<ProductionLabResultModel> createResult({
    required int sampleId,
    required int parameterId,
    required String value,
  });

  Future<ProductionQualityCheckPagePayload> fetchChecks({required int page});

  Future<List<Map<String, dynamic>>> fetchAnalysisParameters();

  Future<List<Map<String, dynamic>>> fetchProductionOrders({String? search});
}

class ProductionLabSamplePagePayload {
  final List<dynamic> rawItems;
  final int totalCount;
  final int page;
  final bool hasMore;

  const ProductionLabSamplePagePayload({
    required this.rawItems,
    required this.totalCount,
    required this.page,
    required this.hasMore,
  });
}

class ProductionLabResultPagePayload {
  final List<dynamic> rawItems;
  final int totalCount;
  final int page;
  final bool hasMore;

  const ProductionLabResultPagePayload({
    required this.rawItems,
    required this.totalCount,
    required this.page,
    required this.hasMore,
  });
}

class ProductionQualityCheckPagePayload {
  final List<dynamic> rawItems;
  final int totalCount;
  final int page;
  final bool hasMore;

  const ProductionQualityCheckPagePayload({
    required this.rawItems,
    required this.totalCount,
    required this.page,
    required this.hasMore,
  });
}

class DioProductionQualityRemoteDataSource
    implements ProductionQualityRemoteDataSource {
  final Dio _dio;

  DioProductionQualityRemoteDataSource(this._dio);

  CancelToken? _samplesCancelToken;
  CancelToken? _resultsCancelToken;
  CancelToken? _checksCancelToken;
  CancelToken? _paramsCancelToken;
  CancelToken? _ordersCancelToken;

  @override
  Future<ProductionLabSamplePagePayload> fetchSamples({
    required int page,
  }) async {
    _samplesCancelToken?.cancel();
    _samplesCancelToken = CancelToken();
    final response = await _dio.get<dynamic>(
      ApiConstants.productionLabSamples,
      queryParameters: {'ordering': '-created_at', 'page': page},
      cancelToken: _samplesCancelToken,
    );

    return _parsePage(response.data, page: page);
  }

  @override
  Future<ProductionLabSampleModel> createSample({
    required int productionOrderId,
    String? quantityTaken,
  }) async {
    final data = <String, dynamic>{'production_order': productionOrderId};
    if (quantityTaken != null && quantityTaken.trim().isNotEmpty) {
      data['quantity_taken'] = quantityTaken.trim();
    }

    final response = await _dio.post<dynamic>(
      ApiConstants.productionLabSamples,
      data: data,
    );

    final payload = response.data;
    if (payload is Map<String, dynamic>) {
      return ProductionLabSampleModel.fromJson(payload);
    }
    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      message: 'Unexpected response format for createSample',
    );
  }

  @override
  Future<ProductionLabResultPagePayload> fetchResults({
    required int page,
  }) async {
    _resultsCancelToken?.cancel();
    _resultsCancelToken = CancelToken();
    final response = await _dio.get<dynamic>(
      ApiConstants.productionLabResults,
      queryParameters: {'ordering': '-created_at', 'page': page},
      cancelToken: _resultsCancelToken,
    );

    return _parsePageOfResults(response.data, page: page);
  }

  @override
  Future<ProductionLabResultModel> createResult({
    required int sampleId,
    required int parameterId,
    required String value,
  }) async {
    final response = await _dio.post<dynamic>(
      ApiConstants.productionLabResults,
      data: {'sample': sampleId, 'parameter': parameterId, 'value': value},
    );

    final payload = response.data;
    if (payload is Map<String, dynamic>) {
      return ProductionLabResultModel.fromJson(payload);
    }
    throw DioException(
      requestOptions: response.requestOptions,
      response: response,
      message: 'Unexpected response format for createResult',
    );
  }

  @override
  Future<ProductionQualityCheckPagePayload> fetchChecks({
    required int page,
  }) async {
    _checksCancelToken?.cancel();
    _checksCancelToken = CancelToken();
    final response = await _dio.get<dynamic>(
      ApiConstants.productionQualityChecks,
      queryParameters: {'ordering': '-created_at', 'page': page},
      cancelToken: _checksCancelToken,
    );

    return _parsePageOfChecks(response.data, page: page);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAnalysisParameters() async {
    _paramsCancelToken?.cancel();
    _paramsCancelToken = CancelToken();
    final response = await _dio.get<dynamic>(
      ApiConstants.productionAnalysisParameters,
      cancelToken: _paramsCancelToken,
    );

    return _listFromPayload(response.data);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchProductionOrders({
    String? search,
  }) async {
    _ordersCancelToken?.cancel();
    _ordersCancelToken = CancelToken();
    final response = await _dio.get<dynamic>(
      ApiConstants.productionOrders,
      queryParameters: {
        'ordering': '-created_at',
        if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
      },
      cancelToken: _ordersCancelToken,
    );

    return _listFromPayload(response.data);
  }

  ProductionLabSamplePagePayload _parsePage(Object? data, {required int page}) {
    if (data is! Map<String, dynamic>) {
      return ProductionLabSamplePagePayload(
        rawItems: const [],
        totalCount: 0,
        page: page,
        hasMore: false,
      );
    }

    final results = data['results'];
    final rawItems = results is List<dynamic> ? results : <dynamic>[];
    final totalCount = (data['count'] as num?)?.toInt() ?? 0;
    final next = data['next'];
    final hasMore = next is String && next.isNotEmpty;

    return ProductionLabSamplePagePayload(
      rawItems: rawItems,
      totalCount: totalCount,
      page: page,
      hasMore: hasMore,
    );
  }

  ProductionLabResultPagePayload _parsePageOfResults(
    Object? data, {
    required int page,
  }) {
    if (data is! Map<String, dynamic>) {
      return ProductionLabResultPagePayload(
        rawItems: const [],
        totalCount: 0,
        page: page,
        hasMore: false,
      );
    }

    final results = data['results'];
    final rawItems = results is List<dynamic> ? results : <dynamic>[];
    final totalCount = (data['count'] as num?)?.toInt() ?? 0;
    final next = data['next'];
    final hasMore = next is String && next.isNotEmpty;

    return ProductionLabResultPagePayload(
      rawItems: rawItems,
      totalCount: totalCount,
      page: page,
      hasMore: hasMore,
    );
  }

  ProductionQualityCheckPagePayload _parsePageOfChecks(
    Object? data, {
    required int page,
  }) {
    if (data is! Map<String, dynamic>) {
      return ProductionQualityCheckPagePayload(
        rawItems: const [],
        totalCount: 0,
        page: page,
        hasMore: false,
      );
    }

    final results = data['results'];
    final rawItems = results is List<dynamic> ? results : <dynamic>[];
    final totalCount = (data['count'] as num?)?.toInt() ?? 0;
    final next = data['next'];
    final hasMore = next is String && next.isNotEmpty;

    return ProductionQualityCheckPagePayload(
      rawItems: rawItems,
      totalCount: totalCount,
      page: page,
      hasMore: hasMore,
    );
  }

  List<Map<String, dynamic>> _listFromPayload(Object? payload) {
    if (payload is List<dynamic>) {
      return payload.whereType<Map<String, dynamic>>().toList(growable: false);
    }

    if (payload is Map<String, dynamic>) {
      final results = payload['results'];
      if (results is List<dynamic>) {
        return results.whereType<Map<String, dynamic>>().toList(
          growable: false,
        );
      }
    }

    return const [];
  }
}
