import 'package:flutter/widgets.dart';

import '../../domain/entities/raw_material_entry.dart';

class RawMaterialEntryCopy {
  final bool isArabic;

  const RawMaterialEntryCopy._(this.isArabic);

  factory RawMaterialEntryCopy.of(BuildContext context) {
    return RawMaterialEntryCopy._(
      Localizations.localeOf(context).languageCode.toLowerCase() == 'ar',
    );
  }

  String get title => isArabic ? 'دخول الخامات' : 'Raw material entry';

  String get designTitle => 'Raw Material Received';

  String get subtitle => isArabic
      ? 'تسجيل الخامات الواردة وربط كل بيان بمصدره من النظام.'
      : 'Register received raw materials with API-backed parameter data.';

  String get entryForm => isArabic ? 'بيانات الدخول' : 'Entry details';

  String get rawMaterial => isArabic ? 'الخامة' : 'Raw material';

  String get rawMaterialHint =>
      isArabic ? 'اختر الخامة من البيانات' : 'Choose a raw material';

  String get purchaseOrderDetail =>
      isArabic ? 'تفصيل أمر الشراء' : 'Purchase order detail';

  String get purchaseOrderDetailHint =>
      isArabic ? 'اختر بند أمر الشراء' : 'Choose a purchase order line';

  String get warehouse => isArabic ? 'المخزن' : 'Warehouse';

  String get warehouseHint =>
      isArabic ? 'اختر مخزن الاستلام' : 'Choose receiving warehouse';

  String get driver => isArabic ? 'السائق' : 'Driver';

  String get driverHint =>
      isArabic ? 'اختر أو اكتب اسم السائق' : 'Choose or type driver name';

  String get vehicleNo => isArabic ? 'رقم السيارة' : 'Vehicle no.';

  String get vehicleNoHint => isArabic ? 'مثال: أ ب ج 123' : 'Truck plate';

  String get quantity => isArabic ? 'كمية المورد' : 'Supplier quantity';

  String get quantityHint => isArabic ? 'أدخل الكمية' : 'Enter quantity';

  String get lotNo => isArabic ? 'رقم اللوط' : 'Lot no.';

  String get lotNoHint => isArabic ? 'اختياري' : 'Optional';

  String get expiryDate => isArabic ? 'تاريخ الصلاحية' : 'Expiry date';

  String get expiryDateHint => 'YYYY-MM-DD';

  String get submit => isArabic ? 'تسجيل دخول الخامة' : 'Create entry';

  String get refreshLookups =>
      isArabic ? 'تحديث بيانات الاختيار' : 'Refresh lookup data';

  String get requiredFieldsMessage => isArabic
      ? 'اختر بند أمر الشراء والخامة والمخزن وأدخل وزن المورد.'
      : 'Choose the purchase line, raw material, warehouse, and supplier weight.';

  String get invalidDateMessage => isArabic
      ? 'تاريخ الصلاحية يجب أن يكون بصيغة YYYY-MM-DD.'
      : 'Expiry date must use YYYY-MM-DD.';

  String get allStatuses => isArabic ? 'الكل' : 'All';

  String get pendingFilter => 'Pending';

  String get approvedFilter => 'Approved';

  String get rejectedFilter => 'Rejected';

  String get last24Hours => 'Last 24 h';

  String get yesterday => 'Yesterday';

  String get customDate => 'Custom Date';

  String get intake => 'In-Take';

  String get inventory => 'Inventory';

  String get production => 'Production';

  String get quality => 'Quality';

  String get supplierWeight => 'Supplier Weight';

  String get idLabel => 'ID';

  String get dateLabel => 'Date';

  String get emptyTitle =>
      isArabic ? 'لا توجد خامات واردة' : 'No received materials';

  String get emptyMessage => isArabic
      ? 'لا توجد سجلات مطابقة للحالة الحالية.'
      : 'No entries match the selected status yet.';

  String get errorTitle =>
      isArabic ? 'تعذر تحميل دخول الخامات' : 'Could not load entries';

  String get retry => isArabic ? 'إعادة المحاولة' : 'Retry';

  String get submitSuccess =>
      isArabic ? 'تم تسجيل دخول الخامة.' : 'Raw material entry created.';

  String get totalEntries => isArabic ? 'إجمالي السجلات' : 'Total entries';

  String get waitingQuality => isArabic ? 'في الجودة' : 'In quality';

  String get stocked => isArabic ? 'دخل المخزن' : 'In stock';

  String get rejected => isArabic ? 'مرفوض' : 'Rejected';

  String get supplier => isArabic ? 'المورد' : 'Supplier';

  String get noSupplier => isArabic ? 'بدون مورد' : 'No supplier';

  String get noWarehouse => isArabic ? 'بدون مخزن' : 'No warehouse';

  String get acceptedQuantity => isArabic ? 'مقبول' : 'Accepted';

  String get rejectedQuantity => isArabic ? 'مرفوض' : 'Rejected';

  String get availableQuantity => isArabic ? 'متاح' : 'Available';

  String get measuredQuantity => isArabic ? 'مقاس' : 'Measured';

  String get sampled => isArabic ? 'عينة' : 'Sample';

  String get labDone => isArabic ? 'مختبر' : 'Lab';

  String get qcDone => isArabic ? 'جودة' : 'QC';

  String get inStock => isArabic ? 'مخزن' : 'Stock';

  String statusLabel(RawMaterialEntryStatus status) {
    return switch (status) {
      RawMaterialEntryStatus.arrived => isArabic ? 'وصلت' : 'Arrived',
      RawMaterialEntryStatus.sampleTaken =>
        isArabic ? 'تم أخذ عينة' : 'Sample taken',
      RawMaterialEntryStatus.labPending =>
        isArabic ? 'بانتظار المختبر' : 'Lab pending',
      RawMaterialEntryStatus.qcPending =>
        isArabic ? 'بانتظار الجودة' : 'QC pending',
      RawMaterialEntryStatus.approved => isArabic ? 'معتمدة' : 'Approved',
      RawMaterialEntryStatus.rejected => isArabic ? 'مرفوضة' : 'Rejected',
    };
  }

  String designStatusLabel(RawMaterialEntryStatus status) {
    return switch (status) {
      RawMaterialEntryStatus.approved => approvedFilter,
      RawMaterialEntryStatus.rejected => rejectedFilter,
      _ => pendingFilter,
    };
  }

  String quantityValue(double? value, {String? unitName}) {
    if (value == null) {
      return '-';
    }

    final normalized = value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2);
    if (unitName == null || unitName.trim().isEmpty) {
      return normalized;
    }
    return '$normalized $unitName';
  }

  String dateValue(DateTime? date) {
    if (date == null) {
      return '-';
    }
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }
}
