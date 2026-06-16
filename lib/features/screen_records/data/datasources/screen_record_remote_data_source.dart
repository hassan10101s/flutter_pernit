import 'package:dio/dio.dart';

abstract class ScreenRecordRemoteDataSource {
  Future<List<Map<String, dynamic>>> fetchRecords(String endpoint);

  Future<Map<String, dynamic>> createRecord(
    String endpoint,
    Map<String, String> fields,
  );

  Future<Map<String, dynamic>> updateRecord(
    String endpoint,
    String id,
    Map<String, String> fields,
  );

  Future<void> deleteRecord(String endpoint, String id);
}

class DioScreenRecordRemoteDataSource implements ScreenRecordRemoteDataSource {
  final Dio _dio;

  const DioScreenRecordRemoteDataSource(this._dio);

  @override
  Future<List<Map<String, dynamic>>> fetchRecords(String endpoint) async {
    final response = await _dio.get<dynamic>(endpoint);
    final payload = response.data;

    if (payload is List<dynamic>) {
      return _mapsFromList(payload);
    }

    if (payload is Map<String, dynamic>) {
      final results = payload['results'] ?? payload['data'];
      if (results is List<dynamic>) {
        return _mapsFromList(results);
      }

      return [payload];
    }

    return const [];
  }

  @override
  Future<Map<String, dynamic>> createRecord(
    String endpoint,
    Map<String, String> fields,
  ) async {
    final response = await _dio.post<dynamic>(endpoint, data: fields);
    return _mapFromPayload(response.data);
  }

  @override
  Future<Map<String, dynamic>> updateRecord(
    String endpoint,
    String id,
    Map<String, String> fields,
  ) async {
    final response = await _dio.put<dynamic>(
      _recordEndpoint(endpoint, id),
      data: fields,
    );
    return _mapFromPayload(response.data);
  }

  @override
  Future<void> deleteRecord(String endpoint, String id) async {
    await _dio.delete<void>(_recordEndpoint(endpoint, id));
  }

  List<Map<String, dynamic>> _mapsFromList(List<dynamic> values) {
    return [
      for (final value in values)
        if (value is Map<String, dynamic>) value,
    ];
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

  String _recordEndpoint(String endpoint, String id) {
    final normalizedEndpoint = endpoint.endsWith('/') ? endpoint : '$endpoint/';
    return '$normalizedEndpoint$id/';
  }
}
