import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_pernit/core/network/api_constants.dart';
import 'package:flutter_pernit/features/raw_material_entry/data/datasources/raw_material_entry_remote_data_source.dart';
import 'package:flutter_pernit/features/raw_material_entry/domain/entities/raw_material_entry.dart';
import 'package:flutter_pernit/features/raw_material_entry/domain/entities/raw_material_entry_lookup.dart';

void main() {
  test('fetches received raw materials with status filter', () async {
    final adapter = _RecordingAdapter(
      payloads: {
        ApiConstants.receivedRawMaterials: {
          'count': 1,
          'results': [
            {
              'id': 1,
              'raw_material': 3,
              'raw_material_name': 'Yellow Corn',
              'status': 'arrived',
              'quantity_from_supplier': '12.00',
            },
          ],
        },
      },
    );
    final dataSource = DioRawMaterialEntryRemoteDataSource(_dioWith(adapter));

    final entries = await dataSource.fetchEntries(
      status: RawMaterialEntryStatus.arrived,
    );

    expect(adapter.requests.single.path, ApiConstants.receivedRawMaterials);
    expect(adapter.requests.single.queryParameters, {
      'ordering': '-created_at',
      'status': 'arrived',
    });
    expect(entries.single.rawMaterialName, 'Yellow Corn');
  });

  test('fetches lookup data from each autocomplete endpoint', () async {
    final adapter = _RecordingAdapter(
      payloads: {
        ApiConstants.rawMaterials: {
          'results': [
            {'id': 3, 'short_code': 'RM-3', 'name': 'Yellow Corn'},
          ],
        },
        ApiConstants.warehouses: {
          'results': [
            {'id': 2, 'name': 'Main Warehouse'},
          ],
        },
        ApiConstants.purchaseOrderDetails: {
          'results': [
            {
              'id': 5,
              'purchase_order': 9,
              'raw_material_name': 'Yellow Corn',
              'supplier_name': 'Delta Supply',
            },
          ],
        },
        ApiConstants.allDrivers: {
          'results': [
            {'driver_name': 'Hassan'},
          ],
        },
      },
    );
    final dataSource = DioRawMaterialEntryRemoteDataSource(_dioWith(adapter));

    final rawMaterials = await dataSource.fetchRawMaterials(search: 'corn');
    final warehouses = await dataSource.fetchWarehouses(search: 'main');
    final details = await dataSource.fetchPurchaseOrderDetails(search: 'corn');
    final drivers = await dataSource.fetchDrivers(search: 'has');

    expect(rawMaterials.single.label, 'RM-3 - Yellow Corn');
    expect(warehouses.single.label, 'Main Warehouse');
    expect(details.single.supplierName, 'Delta Supply');
    expect(drivers.single.label, 'Hassan');
    expect(adapter.requests.map((request) => request.path), [
      ApiConstants.rawMaterials,
      ApiConstants.warehouses,
      ApiConstants.purchaseOrderDetails,
      ApiConstants.allDrivers,
    ]);
  });

  test(
    'posts raw material entry draft to received raw materials endpoint',
    () async {
      final adapter = _RecordingAdapter(
        payloads: {
          ApiConstants.receivedRawMaterials: {
            'id': 44,
            'raw_material': 3,
            'raw_material_name': 'Yellow Corn',
            'quantity_from_supplier': '14.00',
            'status': 'arrived',
          },
        },
      );
      final dataSource = DioRawMaterialEntryRemoteDataSource(_dioWith(adapter));

      final entry = await dataSource.createEntry(
        const RawMaterialEntryDraft(
          rawMaterialId: 3,
          purchaseOrderDetailId: 22,
          warehouseId: 4,
          quantityFromSupplier: 14,
          vehicleNo: 'TRK-8',
          driverName: 'Hassan',
          lotNo: 'LOT-1',
          expiryDate: null,
        ),
      );

      expect(adapter.requests.single.path, ApiConstants.receivedRawMaterials);
      expect(adapter.requests.single.method, 'POST');
      expect(adapter.requests.single.data, {
        'raw_material': 3,
        'purchase_order': 22,
        'warehouse': 4,
        'quantity_from_supplier': '14.0',
        'vehicle_no': 'TRK-8',
        'driver_name': 'Hassan',
        'lot_no': 'LOT-1',
      });
      expect(entry.id, 44);
    },
  );
}

Dio _dioWith(HttpClientAdapter adapter) {
  return Dio(BaseOptions(baseUrl: 'https://pernit.test'))
    ..httpClientAdapter = adapter;
}

class _RecordingAdapter implements HttpClientAdapter {
  final Map<String, Object?> payloads;
  final requests = <RequestOptions>[];

  _RecordingAdapter({required this.payloads});

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode(payloads[options.path] ?? const {}),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
