import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_pernit/features/raw_material_entry/data/models/raw_material_entry_lookup_model.dart';
import 'package:flutter_pernit/features/raw_material_entry/data/models/raw_material_entry_model.dart';
import 'package:flutter_pernit/features/raw_material_entry/domain/entities/raw_material_entry.dart';

void main() {
  test('maps received raw material json to entry entity', () {
    final model = RawMaterialEntryModel.fromJson(const {
      'id': 7,
      'raw_material': 3,
      'raw_material_name': 'Yellow Corn',
      'purchase_order': 12,
      'supplier_name': 'Delta Supply',
      'quantity_from_supplier': '20.50',
      'unit_name': 'ton',
      'warehouse': 5,
      'warehouse_name': 'Main Warehouse',
      'status': 'qc_pending',
      'is_sampled': true,
      'is_lab_done': true,
      'is_qc_done': false,
      'is_in_stock': false,
      'accepted_quantity': '10.00',
      'rejected_quantity': '1.50',
      'available_quantity': '8.00',
      'measured_quantity': '19.50',
      'vehicle_no': 'TRK-1',
      'driver_name': 'Hassan',
      'lot_no': 'LOT-9',
      'expiry_date': '2026-10-12',
      'created_at': '2026-06-01T08:30:00Z',
    });

    final entry = model.toEntity();

    expect(entry.id, 7);
    expect(entry.rawMaterialId, 3);
    expect(entry.purchaseOrderDetailId, 12);
    expect(entry.rawMaterialName, 'Yellow Corn');
    expect(entry.status, RawMaterialEntryStatus.qcPending);
    expect(entry.quantityFromSupplier, 20.5);
    expect(entry.acceptedQuantity, 10);
    expect(entry.expiryDate, DateTime(2026, 10, 12));
  });

  test('maps purchase order detail lookup with supplier and availability', () {
    final option = LookupOptionModel.purchaseOrderDetail(const {
      'id': 22,
      'purchase_order': 8,
      'supplier_name': 'Delta Supply',
      'raw_material': 3,
      'raw_material_name': 'Yellow Corn',
      'available': '18.00',
      'unit_name': 'ton',
    });

    expect(option.id, 22);
    expect(option.label, '8 - Yellow Corn');
    expect(option.supplierName, 'Delta Supply');
    expect(option.rawMaterialName, 'Yellow Corn');
    expect(option.unitName, 'ton');
    expect(option.availableQuantity, '18.00');
  });
}
