import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_pernit/core/network/api_constants.dart';
import 'package:flutter_pernit/features/raw_material_entry/data/datasources/raw_material_entry_remote_data_source.dart';
import 'package:flutter_pernit/features/raw_material_entry/domain/entities/raw_material_entry.dart';
import 'package:flutter_pernit/features/raw_material_entry/domain/entities/raw_material_entry_lookup.dart';
import 'package:flutter_pernit/features/raw_material_entry/domain/entities/raw_material_workflow.dart';

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

  test(
    'loads paginated quality workflow entries with server filters',
    () async {
      final adapter = _RecordingAdapter(
        payloads: {
          ApiConstants.receivedRawMaterials: {
            'count': 2,
            'next': 'https://pernit.test/page=2',
            'results': [
              {
                'id': 8,
                'raw_material_name': 'Corn',
                'quantity_from_supplier': '10',
                'status': 'approved',
              },
            ],
          },
        },
      );
      final dataSource = DioRawMaterialEntryRemoteDataSource(_dioWith(adapter));

      final page = await dataSource.fetchWorkflowEntries(
        status: RawMaterialEntryStatus.approved,
        isInStock: false,
        page: 1,
      );

      expect(adapter.requests.single.queryParameters, {
        'ordering': '-updated_at',
        'page': 1,
        'status': 'approved',
        'is_in_stock': false,
      });
      expect(page.totalCount, 2);
      expect(page.hasNextPage, isTrue);
      expect(page.entries.single.id, 8);
    },
  );

  test('creates a sample and loads the combined analysis workspace', () async {
    final adapter = _RecordingAdapter(
      payloads: {
        ApiConstants.rawMaterialLabSamples: {
          'id': 15,
          'received_raw_material': 8,
          'sample_no': 'SMPL-8',
          'status': 'pending',
        },
        ApiConstants.rawMaterialAnalysisWorkspace(15): _workspacePayload,
      },
    );
    final dataSource = DioRawMaterialEntryRemoteDataSource(_dioWith(adapter));

    final sample = await dataSource.takeSample(8);
    final workspace = await dataSource.fetchAnalysisWorkspace(sample.id);

    expect(adapter.requests.first.method, 'POST');
    expect(adapter.requests.first.data, {'received_raw_material': 8});
    expect(workspace.chemicalParameters.single.name, 'Moisture');
    expect(workspace.physicalParameters.single.name, 'Color');
    expect(workspace.sops.single.documentNumber, 'SOP-1');
  });

  test('submits chemical and physical results in one request', () async {
    final adapter = _RecordingAdapter(
      payloads: {
        ApiConstants.rawMaterialAnalysisWorkspace(15): {
          ..._workspacePayload,
          'is_complete': true,
        },
      },
    );
    final dataSource = DioRawMaterialEntryRemoteDataSource(_dioWith(adapter));

    final workspace = await dataSource.submitAnalysis(
      15,
      const RawMaterialAnalysisSubmission(
        chemicalResults: [
          ChemicalAnalysisResultDraft(parameterId: 2, value: 11.5),
        ],
        physicalResults: [
          PhysicalAnalysisResultDraft(parameterId: 4, value: 'Golden'),
        ],
      ),
    );

    expect(adapter.requests.single.data, {
      'chemical_results': [
        {'parameter': 2, 'value': 11.5},
      ],
      'physical_results': [
        {'physical_parameter': 4, 'value': 'Golden'},
      ],
    });
    expect(workspace.isComplete, isTrue);
  });

  test('posts quality decision and actual scale weight', () async {
    final adapter = _RecordingAdapter(
      payloads: {
        ApiConstants.rawMaterialQualityChecks: const {},
        ApiConstants.recordAcceptedRawMaterialQuantity(8): const {},
      },
    );
    final dataSource = DioRawMaterialEntryRemoteDataSource(_dioWith(adapter));
    final tempDirectory = await Directory.systemTemp.createTemp(
      'pernit-scale-test',
    );
    final image = File('${tempDirectory.path}/scale.jpg');
    await image.writeAsBytes([1, 2, 3]);

    try {
      await dataSource.submitQualityDecision(
        batchId: 8,
        decision: RawMaterialQualityDecision.accepted,
        comments: 'All results reviewed',
      );
      await dataSource.recordActualWeight(
        batchId: 8,
        measuredQuantity: 9.75,
        measuredImagePath: image.path,
      );

      expect(adapter.requests.first.data, {
        'received_raw_material': 8,
        'status': 'accepted',
        'comments': 'All results reviewed',
      });
      final form = adapter.requests.last.data as FormData;
      expect(form.fields.single.key, 'measured_quantity');
      expect(form.fields.single.value, '9.75');
      expect(form.files.single.key, 'measured_image');
    } finally {
      await tempDirectory.delete(recursive: true);
    }
  });
}

const _workspacePayload = {
  'sample': {'id': 15, 'sample_no': 'SMPL-8', 'status': 'pending'},
  'batch': {
    'id': 8,
    'status': 'lab_pending',
    'raw_material_id': 1,
    'raw_material_name': 'Corn',
    'supplier_weight': '10',
    'unit': 'Ton',
    'warehouse_name': 'Main',
  },
  'chemical_parameters': [
    {
      'id': 2,
      'name': 'Moisture',
      'unit': '%',
      'normal_min': '10',
      'normal_max': '13',
      'rejected_min': '8',
      'rejected_max': '15',
      'value': null,
      'sop': null,
      'sop_name': null,
      'sop_document_number': null,
      'is_within_range': null,
    },
  ],
  'physical_parameters': [
    {
      'id': 4,
      'name': 'Color',
      'reference': 'Golden',
      'rejected_reference': 'Dark',
      'value': null,
    },
  ],
  'sops': [
    {
      'id': 3,
      'title': 'Moisture method',
      'document_number': 'SOP-1',
      'reference_method': 'Oven',
    },
  ],
  'is_complete': false,
};

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
    await requestStream?.drain<void>();
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
