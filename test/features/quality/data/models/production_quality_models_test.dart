import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pernit/features/quality/data/models/production_lab_result_model.dart';
import 'package:flutter_pernit/features/quality/data/models/production_lab_sample_model.dart';
import 'package:flutter_pernit/features/quality/data/models/production_quality_check_model.dart';

void main() {
  group('ProductionLabResultModel', () {
    test('fromJson reads value and sample_no', () {
      final json = {
        'id': 1,
        'sample': 10,
        'sample_no': 'S-001',
        'parameter': {'id': 5, 'name': 'pH'},
        'value': '7.2',
        'measured_by': 3,
        'measured_at': '2026-07-01T14:30:00Z',
        'is_within_range': true,
        'created_at': '2026-07-01T14:30:00Z',
      };

      final model = ProductionLabResultModel.fromJson(json);

      expect(model.id, 1);
      expect(model.sampleId, 10);
      expect(model.sampleNo, 'S-001');
      expect(model.parameterId, 5);
      expect(model.parameterName, 'pH');
      expect(model.value, '7.2');
      expect(model.isWithinRange, true);
    });

    test('toJson does not contain measured_value', () {
      final model = ProductionLabResultModel(
        id: 1,
        sampleId: 10,
        sampleNo: 'S-001',
        parameterId: 5,
        parameterName: 'pH',
        value: '7.2',
        measuredById: 3,
        measuredAtRaw: '2026-07-01T14:30:00Z',
        isWithinRange: true,
        createdAtRaw: '2026-07-01T14:30:00Z',
      );

      final json = model.toJson();

      expect(json, containsPair('sample', 10));
      expect(json, containsPair('parameter', 5));
      expect(json, containsPair('value', '7.2'));
      expect(json, isNot(contains('measured_value')));
      expect(json, isNot(contains('notes')));
    });

    test('toJson does not send notes', () {
      final model = ProductionLabResultModel(
        id: 1,
        sampleId: 10,
        sampleNo: 'S-001',
        parameterId: 5,
        parameterName: 'pH',
        value: '7.2',
        isWithinRange: true,
        createdAtRaw: '2026-07-01T14:30:00Z',
      );

      final json = model.toJson();

      expect(json, isNot(contains('notes')));
    });
  });

  group('ProductionLabSampleModel', () {
    test(
      'fromJson reads production_order_code and does not use sample_number',
      () {
        final json = {
          'id': 1,
          'production_order': 100,
          'production_order_code': 'PO-001',
          'status': 'pending',
          'created_at': '2026-07-01T14:30:00Z',
        };

        final model = ProductionLabSampleModel.fromJson(json);

        expect(model.id, 1);
        expect(model.productionOrderId, 100);
        expect(model.productionOrderCode, 'PO-001');
        expect(model.productionOrderCode, 'PO-001');
      },
    );

    test('toJson sends production_order only', () {
      final model = ProductionLabSampleModel(
        id: 1,
        productionOrderId: 100,
        productionOrderCode: 'PO-001',
        status: 'pending',
        createdAtRaw: '2026-07-01T14:30:00Z',
      );

      final json = model.toJson();

      expect(json, containsPair('production_order', 100));
      expect(json, isNot(contains('notes')));
      expect(json, isNot(contains('sample_number')));
    });

    test('toJson includes quantity_taken when present', () {
      final model = ProductionLabSampleModel(
        id: 1,
        productionOrderId: 100,
        productionOrderCode: 'PO-001',
        quantityTaken: '5.0',
        status: 'pending',
        createdAtRaw: '2026-07-01T14:30:00Z',
      );

      final json = model.toJson();

      expect(json, containsPair('production_order', 100));
      expect(json, containsPair('quantity_taken', '5.0'));
    });

    test('toJson omits quantity_taken when absent', () {
      final model = ProductionLabSampleModel(
        id: 1,
        productionOrderId: 100,
        productionOrderCode: 'PO-001',
        status: 'pending',
        createdAtRaw: '2026-07-01T14:30:00Z',
      );

      final json = model.toJson();

      expect(json, containsPair('production_order', 100));
      expect(json, isNot(contains('quantity_taken')));
    });
  });

  group('ProductionQualityCheckModel', () {
    test('fromJson reads comments field', () {
      final json = {
        'id': 1,
        'status': 'release',
        'comments': 'All tests passed',
        'received_product': 50,
        'production_order_code': 'PO-001',
        'checked_by': 3,
        'created_at': '2026-07-01T14:30:00Z',
      };

      final model = ProductionQualityCheckModel.fromJson(json);

      expect(model.id, 1);
      expect(model.status, 'release');
      expect(model.comments, 'All tests passed');
      expect(model.receivedProductId, 50);
      expect(model.productionOrderCode, 'PO-001');
    });

    test('toEntity maps comments correctly', () {
      final model = ProductionQualityCheckModel(
        id: 1,
        status: 'accepted',
        comments: 'Sample OK',
        receivedProductId: 50,
        productionOrderCode: 'PO-001',
        checkedById: 3,
        checkedByName: 'User',
        createdAtRaw: '2026-07-01T14:30:00Z',
      );

      final entity = model.toEntity();

      expect(entity.comments, 'Sample OK');
      expect(entity.receivedProductId, 50);
      expect(entity.productionOrderCode, 'PO-001');
    });

    test('handles null comments', () {
      final json = {
        'id': 1,
        'status': 'release',
        'comments': null,
        'received_product': 50,
        'created_at': '2026-07-01T14:30:00Z',
      };

      final model = ProductionQualityCheckModel.fromJson(json);

      expect(model.comments, isNull);
    });
  });
}
