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
  String get menuCommercial => 'الطلبات';

  @override
  String get menuSettings => 'الإعدادات';

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
}
