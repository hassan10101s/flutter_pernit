// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'بيرنت ERP';

  @override
  String get loginTitle => 'مرحبًا بعودتك';

  @override
  String get loginSubtitle => 'سجّل الدخول للمتابعة إلى مساحة عمل بيرنت ERP.';

  @override
  String get usernameLabel => 'اسم المستخدم';

  @override
  String get usernameHint => 'أدخل اسم المستخدم';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get passwordHint => 'أدخل كلمة المرور';

  @override
  String get loginButton => 'تسجيل الدخول';

  @override
  String get loggingInButton => 'جار تسجيل الدخول';

  @override
  String get usernameRequired => 'اسم المستخدم مطلوب.';

  @override
  String get passwordRequired => 'كلمة المرور مطلوبة.';

  @override
  String get failureNetwork => 'تحقق من اتصال الإنترنت ثم حاول مرة أخرى.';

  @override
  String get failureUnauthorized => 'اسم المستخدم أو كلمة المرور غير صحيحة.';

  @override
  String get failureForbidden => 'ليس لديك صلاحية للوصول إلى هذه المنطقة.';

  @override
  String get failureValidation => 'راجع الحقول المحددة.';

  @override
  String get failureServer => 'تعذر على الخادم إكمال الطلب.';

  @override
  String get failureTimeout => 'استغرق الطلب وقتًا طويلًا. حاول مرة أخرى.';

  @override
  String get failureConfigurationMissing =>
      'رابط واجهة البرمجة غير مضبوط لهذا الإصدار.';

  @override
  String get failureNotFound => 'المورد المطلوب غير موجود.';

  @override
  String get failureConflict =>
      'تتعارض هذه العملية مع الحالة الحالية. يرجى التحديث والمحاولة مرة أخرى.';

  @override
  String get failureUnknown => 'حدث خطأ غير متوقع. حاول مرة أخرى.';

  @override
  String get homeTitle => 'الرئيسية';

  @override
  String get homeEmptyTitle => 'بيرنت ERP';

  @override
  String get homeEmptySubtitle => 'مساحة العمل جاهزة لإضافة الوحدة التالية.';

  @override
  String get homeLogoutTooltip => 'تسجيل الخروج';

  @override
  String homeGreeting(String name) {
    return 'مرحبًا، $name';
  }

  @override
  String homeGroupLabel(String groups) {
    return 'المجموعات: $groups';
  }

  @override
  String get homeNoGroups => 'لا توجد مجموعات';

  @override
  String get menuOverview => 'الرئيسية';

  @override
  String get menuInventory => 'المخزن';

  @override
  String get menuQuality => 'الجودة';

  @override
  String get menuProduction => 'الإنتاج';

  @override
  String get menuCommercial => 'دخول الخامات';

  @override
  String get menuSettings => 'الإعدادات';

  @override
  String get notificationTitle => 'الإشعارات';

  @override
  String get notificationMarkAllRead => 'تحديد الكل كمقروء';

  @override
  String get notificationEmpty => 'لا توجد إشعارات';

  @override
  String get notificationMarkRead => 'تحديد كمقروء';

  @override
  String get notificationJustNow => 'الآن';

  @override
  String notificationTimeAgo(int count) {
    return 'قبل $count د';
  }

  @override
  String get notificationReference => 'عرض التفاصيل';

  @override
  String get notificationRetry => 'إعادة المحاولة';

  @override
  String get overviewTitle => 'مساحة العمل';

  @override
  String get overviewSubtitle =>
      'الأقسام المتاحة تعتمد على المجموعات الراجعة من تسجيل الدخول.';

  @override
  String modulePlaceholder(String module) {
    return 'واجهة $module التجريبية';
  }

  @override
  String get settingsTitle => 'إعدادات المدير';

  @override
  String get settingsSubtitle =>
      'العناصر الأساسية مثل الوحدات وSOP تبقى هنا وتظهر للمدير فقط.';

  @override
  String get settingsUnits => 'الوحدات';

  @override
  String get settingsSop => 'SOP';

  @override
  String get settingsSopDetails => 'تفاصيل SOP';

  @override
  String get settingsWarehouses => 'المخازن';

  @override
  String get settingsUsers => 'المستخدمون';

  @override
  String get settingsProfiles => 'الملفات الشخصية';

  @override
  String get settingsProducts => 'المنتجات';

  @override
  String get settingsRawMaterials => 'المواد الخام';

  @override
  String get settingsProductCategories => 'تصنيفات المنتجات';

  @override
  String get settingsRawMaterialCategories => 'تصنيفات المواد الخام';

  @override
  String get settingsFormulas => 'التركيبات';

  @override
  String get settingsFormulaDetails => 'تفاصيل التركيبات';

  @override
  String get settingsProductionRules => 'قواعد الإنتاج';

  @override
  String get settingsLabParameters => 'معاملات المختبر';

  @override
  String get settingsPhysicalLabs => 'المختبرات الفيزيائية';

  @override
  String get settingsAnalysisParameters => 'معاملات التحليل';

  @override
  String get settingsReferenceMethods => 'طرق المرجع';

  @override
  String get settingsPredictiveResults => 'النتائج التنبؤية';

  @override
  String get settingsSuppliers => 'الموردون';

  @override
  String get settingsCustomers => 'العملاء';

  @override
  String get settingsAdminOnlyNote =>
      'هذه المنطقة تظهر فقط لمجموعات System Admin/Admin.';

  @override
  String get settingsBasicsSectionTitle => 'الإعدادات الأساسية';

  @override
  String get settingsBasicsSectionSubtitle =>
      'شاشات الإعداد التي تحدد بيانات ERP المرجعية القابلة لإعادة الاستخدام.';

  @override
  String get settingsUnitsSectionTitle => 'الوحدات';

  @override
  String get settingsUnitsSectionSubtitle =>
      'وحدات القياس المستخدمة في المنتجات والمواد الخام ونطاقات المختبر والتركيبات.';

  @override
  String get screenRecordsTitle => 'السجلات الحالية';

  @override
  String get screenActionsTitle => 'الإجراءات';

  @override
  String get screenAddAction => 'إضافة';

  @override
  String get screenEditAction => 'تعديل';

  @override
  String get screenDeleteAction => 'حذف';

  @override
  String get screenCloseAction => 'إغلاق';

  @override
  String get screenCancelAction => 'إلغاء';

  @override
  String get screenSaveAction => 'حفظ';

  @override
  String get screenNameField => 'الاسم';

  @override
  String get screenCodeField => 'الكود';

  @override
  String get screenDetailsField => 'التفاصيل';

  @override
  String get screenNoRecords => 'لا توجد سجلات متاحة بعد.';

  @override
  String screenDialogSubtitle(String screen) {
    return 'راجع سجلات $screen الحالية ثم أضف أو عدل أو احذف من عمود الإجراءات.';
  }

  @override
  String screenAddDialogTitle(String screen) {
    return 'إضافة $screen';
  }

  @override
  String screenEditDialogTitle(String screen) {
    return 'تعديل $screen';
  }

  @override
  String get screenDeleteConfirmTitle => 'حذف السجل';

  @override
  String screenDeleteConfirmMessage(String record) {
    return 'حذف $record؟ هذا الإجراء يحتاج تأكيد.';
  }

  @override
  String get qualityScreensSubtitle =>
      'شاشات الجودة مفصولة لمراجعة كل تدفق فحص وعينة ونتيجة على حدة.';

  @override
  String get qualityLabSamplesRawMaterials => 'عينات مختبر المواد الخام';

  @override
  String get qualityLabResultsRawMaterials => 'نتائج مختبر المواد الخام';

  @override
  String get qualityPhysicalLabResultsRawMaterials =>
      'نتائج المختبر الفيزيائي للمواد الخام';

  @override
  String get qualityChecksRawMaterials => 'قرارات جودة المواد الخام';

  @override
  String get qualityChecksProduction => 'قرارات جودة الإنتاج';

  @override
  String get productionScreensSubtitle =>
      'شاشات الإنتاج مفصولة لبقاء الأوامر والتفاصيل ومتابعة المختبر واضحة.';

  @override
  String get productionOrders => 'أوامر الإنتاج';

  @override
  String get productionOrderDetails => 'تفاصيل أوامر الإنتاج';

  @override
  String get productionLabSamples => 'عينات مختبر الإنتاج';

  @override
  String get productionLabResults => 'نتائج مختبر الإنتاج';

  @override
  String get productionReserveMaterials => 'حجز المواد';

  @override
  String rawWorkflowBatch(int id) {
    return 'دفعة #$id';
  }

  @override
  String get rawWorkflowSupplierWeight => 'وزن المورد';

  @override
  String get rawWorkflowWarehouse => 'المخزن';

  @override
  String get rawWorkflowLoadMore => 'تحميل المزيد';

  @override
  String get rawWorkflowRefresh => 'تحديث';

  @override
  String get rawQualityTitle => 'جودة الخامات';

  @override
  String get rawQualitySubtitle =>
      'تابع كل دفعة مستلمة من أخذ العينة حتى قرار الجودة النهائي.';

  @override
  String rawQualityQueueCount(int count) {
    return '$count دفعة داخل مسار الجودة';
  }

  @override
  String get rawQualityEmpty => 'لا توجد دفعات تحتاج إجراء من الجودة حاليًا.';

  @override
  String get rawQualityTakeSample => 'أخذ عينة';

  @override
  String get rawQualityEnterAnalysis => 'إدخال التحاليل';

  @override
  String get rawQualityReviewAnalysis => 'مراجعة التحاليل';

  @override
  String get rawQualityAwaitingInventory => 'مقبولة — بانتظار المخزن';

  @override
  String get rawQualityRejected => 'مرفوضة';

  @override
  String get rawQualityTakingSample => 'جارٍ أخذ العينة…';

  @override
  String get rawQualitySampleSuccess => 'تم إنشاء العينة بنجاح.';

  @override
  String get rawQualitySamplingTab => 'أخذ العينات';

  @override
  String get rawQualityAnalysisTab => 'إدخال التحاليل';

  @override
  String get rawQualityDecisionTab => 'قرار الجودة';

  @override
  String rawQualitySamplingCount(int count) {
    return '$count دفعة متاحة لأخذ العينات';
  }

  @override
  String rawQualitySamplesCount(int count) {
    return '$count عينة';
  }

  @override
  String rawQualityDecisionCount(int count) {
    return '$count دفعة جاهزة للقرار';
  }

  @override
  String get rawQualitySamplingEmpty =>
      'لا توجد دفعات مستلمة متاحة لأخذ العينات.';

  @override
  String get rawQualityAnalysisEmpty => 'لا توجد عينات متاحة لإدخال التحاليل.';

  @override
  String get rawQualityDecisionEmpty => 'لا توجد دفعات جاهزة لقرار الجودة.';

  @override
  String rawQualitySampleCount(int count) {
    return 'تم أخذ $count عينة';
  }

  @override
  String get rawQualityTakeAnotherSample => 'أخذ عينة';

  @override
  String get rawQualityEditAnalysis => 'تعديل التحليل';

  @override
  String get rawAnalysisTitle => 'استكمال تحاليل العينة';

  @override
  String rawAnalysisSampleNumber(String number) {
    return 'العينة $number';
  }

  @override
  String get rawAnalysisChemical => 'التحاليل الكيميائية';

  @override
  String get rawAnalysisPhysical => 'التحاليل الفيزيائية';

  @override
  String get rawAnalysisValue => 'القيمة المقاسة';

  @override
  String get rawAnalysisSop => 'إجراء التشغيل SOP';

  @override
  String get rawAnalysisSelectSop => 'اختر SOP';

  @override
  String rawAnalysisNormalRange(String min, String max) {
    return 'الطبيعي: $min – $max';
  }

  @override
  String rawAnalysisReference(String value) {
    return 'المرجع: $value';
  }

  @override
  String rawAnalysisRejectReference(String value) {
    return 'الرفض عند: $value';
  }

  @override
  String get rawAnalysisRequired => 'أدخل نتيجة تحليل واحدة على الأقل.';

  @override
  String get rawAnalysisInvalidValue => 'أدخل قيمة رقمية صحيحة.';

  @override
  String get rawAnalysisAtLeastOne => 'أدخل نتيجة واحدة على الأقل قبل الحفظ.';

  @override
  String get rawAnalysisSopNotConfigured => 'لم يتم تحديد SOP لهذا البرامتر';

  @override
  String get rawAnalysisSaveAll => 'حفظ التحاليل';

  @override
  String get rawAnalysisSaveSuccess => 'تم حفظ تحاليل العينة.';

  @override
  String rawAnalysisResultsSummary(int count) {
    return '$count نتيجة تحليل';
  }

  @override
  String get rawQualityDecisionTitle => 'قرار الجودة';

  @override
  String get rawQualityDecisionHint => 'ملاحظات القرار — اختياري';

  @override
  String get rawQualityAccept => 'قبول الدفعة';

  @override
  String get rawQualityReject => 'رفض الدفعة';

  @override
  String get rawQualityAcceptConfirm =>
      'قبول هذه الدفعة وإرسالها للمخزن لتسجيل الوزن النهائي؟';

  @override
  String get rawQualityRejectConfirm =>
      'رفض هذه الدفعة؟ لن تظهر ضمن الدفعات المتاحة للإدخال بالمخزن.';

  @override
  String get rawQualityDecisionSuccess => 'تم حفظ قرار الجودة.';

  @override
  String get rawInventoryTitle => 'إدخال الخامات المقبولة';

  @override
  String get rawInventorySubtitle =>
      'تظهر هنا الدفعات المعتمدة من الجودة فقط. أدخل وزن الميزان الفعلي لإغلاق الاستلام.';

  @override
  String rawInventoryQueueCount(int count) {
    return '$count دفعة مقبولة بانتظار الوزن النهائي';
  }

  @override
  String get rawInventoryEmpty =>
      'لا توجد دفعات مقبولة بانتظار الإدخال إلى المخزن.';

  @override
  String get rawInventoryEnterStock => 'إدخال المخزن';

  @override
  String get rawInventoryActualWeight => 'وزن الميزان الفعلي';

  @override
  String get rawInventoryWeightRequired => 'أدخل وزنًا فعليًا أكبر من صفر.';

  @override
  String rawInventoryVariance(String value) {
    return 'الفرق عن وزن المورد: $value';
  }

  @override
  String get rawInventoryConfirm =>
      'تأكيد الوزن الفعلي وإضافة هذه الدفعة إلى المخزون؟';

  @override
  String get rawInventorySuccess =>
      'تم إغلاق الدفعة وإضافتها للمخزون باستخدام وزن الميزان الفعلي.';

  @override
  String get rawInventoryCurrentTab => 'المخزون الحالي';

  @override
  String get rawInventoryReceivingTab => 'استقبال الخام';

  @override
  String get rawInventoryFinishedProductTab => 'منتج نهائي';

  @override
  String rawInventoryCurrentCount(int count) {
    return '$count سجل مخزون خامات';
  }

  @override
  String rawInventoryProductCount(int count) {
    return '$count سجل مخزون منتج نهائي';
  }

  @override
  String get rawInventoryCurrentEmpty => 'لا يوجد مخزون خامات مسجل حاليًا.';

  @override
  String rawInventoryItemsCount(int count) {
    return '$count صنف';
  }

  @override
  String rawInventoryReserved(String value) {
    return 'المحجوز: $value';
  }

  @override
  String get rawInventoryScaleImage => 'صورة الميزان (إجباري)';

  @override
  String get rawInventoryScaleImageHint => 'أضف صورة واضحة للوزن المقاس';

  @override
  String get rawInventoryImageRequired =>
      'صورة الميزان مطلوبة قبل إدخال الخام إلى المخزن.';

  @override
  String get rawInventoryTakePhoto => 'التقاط صورة';

  @override
  String get rawInventoryChoosePhoto => 'اختيار من المعرض';

  @override
  String get rawInventoryAddProductTitle => 'إضافة مخزون منتج نهائي';

  @override
  String get rawInventoryProduct => 'المنتج النهائي';

  @override
  String get rawInventoryProductQuantity => 'الكمية المضافة';

  @override
  String get rawInventoryAddProduct => 'إضافة للمخزون';

  @override
  String get rawInventoryProductRequired =>
      'اختر المنتج والمخزن ثم أدخل كمية أكبر من صفر.';

  @override
  String get rawInventoryAddProductConfirm =>
      'تأكيد إضافة كمية المنتج النهائي إلى المخزن المحدد؟';

  @override
  String get rawInventoryProductSuccess => 'تمت إضافة مخزون المنتج النهائي.';

  @override
  String get rawInventoryProductEmpty =>
      'لا يوجد مخزون منتجات نهائية مسجل حاليًا.';

  @override
  String get commonConfirm => 'تأكيد';

  @override
  String get entryTitle => 'دخول الخامات';

  @override
  String get entrySubtitle =>
      'تسجيل الخامات الواردة وربط كل بيان بمصدره من النظام.';

  @override
  String get entryForm => 'بيانات الدخول';

  @override
  String get entryRawMaterial => 'الخامة';

  @override
  String get entryRawMaterialHint => 'اختر الخامة من البيانات';

  @override
  String get rawMaterialHint => 'اختر الخامة من البيانات';

  @override
  String get entryPurchaseOrderDetail => 'تفصيل أمر الشراء';

  @override
  String get entryPurchaseOrderDetailHint => 'اختر بند أمر الشراء';

  @override
  String get entryWarehouse => 'المخزن';

  @override
  String get entryWarehouseHint => 'اختر مخزن الاستلام';

  @override
  String get entryDriver => 'السائق';

  @override
  String get entryDriverHint => 'اختر أو اكتب اسم السائق';

  @override
  String get entryVehicleNo => 'رقم السيارة';

  @override
  String get entryVehicleNoHint => 'مثال: أ ب ج 123';

  @override
  String get entryQuantity => 'كمية المورد';

  @override
  String get entryQuantityHint => 'أدخل الكمية';

  @override
  String get entryLotNo => 'رقم اللوط';

  @override
  String get entryLotNoHint => 'اختياري';

  @override
  String get entryExpiryDate => 'تاريخ الصلاحية';

  @override
  String get entryExpiryDateHint => 'YYYY-MM-DD';

  @override
  String get entrySubmit => 'تسجيل دخول الخامة';

  @override
  String get entryRefreshLookups => 'تحديث بيانات الاختيار';

  @override
  String get entryRequiredFields =>
      'اختر بند أمر الشراء والخامة والمخزن وأدخل وزن المورد.';

  @override
  String get entryInvalidDate => 'تاريخ الصلاحية يجب أن يكون بصيغة YYYY-MM-DD.';

  @override
  String get entryAllStatuses => 'الكل';

  @override
  String get entryPendingFilter => 'قيد الانتظار';

  @override
  String get entryApprovedFilter => 'معتمدة';

  @override
  String get entryRejectedFilter => 'مرفوضة';

  @override
  String get entryLast24Hours => 'آخر 24 ساعة';

  @override
  String get entryYesterday => 'أمس';

  @override
  String get entryCustomDate => 'تاريخ مخصص';

  @override
  String get entryIntake => 'الاستلام';

  @override
  String get entryProduction => 'الإنتاج';

  @override
  String get entryQuality => 'الجودة';

  @override
  String get entrySupplierWeight => 'وزن المورد';

  @override
  String get entryIdLabel => 'المعرف';

  @override
  String get entryDateLabel => 'التاريخ';

  @override
  String get entryEmptyTitle => 'لا توجد خامات واردة';

  @override
  String get entryEmptyMessage => 'لا توجد سجلات مطابقة للحالة الحالية.';

  @override
  String get entryErrorTitle => 'تعذر تحميل دخول الخامات';

  @override
  String get entryRetry => 'إعادة المحاولة';

  @override
  String get entrySubmitSuccess => 'تم تسجيل دخول الخامة.';

  @override
  String get entryTotalEntries => 'إجمالي السجلات';

  @override
  String get entryWaitingQuality => 'في الجودة';

  @override
  String get entryStocked => 'دخل المخزن';

  @override
  String get entryRejected => 'مرفوض';

  @override
  String get entrySupplier => 'المورد';

  @override
  String get entryNoSupplier => 'بدون مورد';

  @override
  String get entryNoWarehouse => 'بدون مخزن';

  @override
  String get entryAcceptedQuantity => 'مقبول';

  @override
  String get entryAvailableQuantity => 'متاح';

  @override
  String get entryMeasuredQuantity => 'مقاس';

  @override
  String get entrySampled => 'عينة';

  @override
  String get entryLabDone => 'مختبر';

  @override
  String get entryQcDone => 'جودة';

  @override
  String get entryStock => 'مخزن';

  @override
  String get entryMetaSeparator => ': ';

  @override
  String entryIdPrefix(String code) {
    return '#$code';
  }

  @override
  String entryDateFormat(String label, String separator, String date) {
    return '$label$separator$date';
  }

  @override
  String entryIdFormat(String label, String separator, String code) {
    return '$label$separator#$code';
  }

  @override
  String entryQuantityValue(String value, String unit) {
    return '$value $unit';
  }

  @override
  String get cardStepperArrived => 'وصلت';

  @override
  String get cardStepperSampled => 'تم أخذ عينة';

  @override
  String get cardStepperLab => 'مختبر';

  @override
  String get cardStepperQc => 'جودة';

  @override
  String get cardStepperDecision => 'القرار';

  @override
  String get cardStepperRejected => 'مرفوضة';

  @override
  String get cardStepperApproved => 'معتمدة';

  @override
  String get cardStepperPending => 'قيد الانتظار';

  @override
  String get cardStepperProcessing => 'قيد المعالجة';

  @override
  String cardStepperBy(String name) {
    return 'بواسطة: $name';
  }

  @override
  String cardStepperDetailArrived(String driver) {
    return 'بواسطة: $driver';
  }

  @override
  String get separatorDot => ' • ';

  @override
  String get logoutTitle => 'تسجيل الخروج';
}
