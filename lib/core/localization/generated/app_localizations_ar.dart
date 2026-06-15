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
}
