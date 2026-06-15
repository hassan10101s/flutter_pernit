// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Pernit ERP';

  @override
  String get loginTitle => 'Welcome back';

  @override
  String get loginSubtitle =>
      'Sign in to continue to the Pernit ERP workspace.';

  @override
  String get usernameLabel => 'Username';

  @override
  String get usernameHint => 'Enter your username';

  @override
  String get passwordLabel => 'Password';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get loginButton => 'Log in';

  @override
  String get loggingInButton => 'Signing in';

  @override
  String get usernameRequired => 'Username is required.';

  @override
  String get passwordRequired => 'Password is required.';

  @override
  String get failureNetwork => 'Check your internet connection and try again.';

  @override
  String get failureUnauthorized => 'The username or password is incorrect.';

  @override
  String get failureForbidden =>
      'You do not have permission to access this area.';

  @override
  String get failureValidation => 'Please review the highlighted fields.';

  @override
  String get failureServer => 'The server could not complete the request.';

  @override
  String get failureTimeout => 'The request took too long. Please try again.';

  @override
  String get failureConfigurationMissing =>
      'The API URL is not configured for this build.';

  @override
  String get failureUnknown => 'Something went wrong. Please try again.';

  @override
  String get homeTitle => 'Home';

  @override
  String get homeEmptyTitle => 'Pernit ERP';

  @override
  String get homeEmptySubtitle => 'The workspace is ready for the next module.';

  @override
  String get homeLogoutTooltip => 'Log out';

  @override
  String homeGreeting(String name) {
    return 'Hello, $name';
  }

  @override
  String homeGroupLabel(String groups) {
    return 'Groups: $groups';
  }

  @override
  String get homeNoGroups => 'No groups assigned';

  @override
  String get menuOverview => 'Overview';

  @override
  String get menuInventory => 'Inventory';

  @override
  String get menuQuality => 'Quality';

  @override
  String get menuProduction => 'Production';

  @override
  String get menuCommercial => 'Orders';

  @override
  String get menuSettings => 'Settings';

  @override
  String get overviewTitle => 'Workspace';

  @override
  String get overviewSubtitle =>
      'Available sections are based on the user groups returned by login.';

  @override
  String modulePlaceholder(String module) {
    return '$module screen placeholder';
  }

  @override
  String get settingsTitle => 'Admin settings';

  @override
  String get settingsSubtitle =>
      'Core setup items stay here and are shown only to admin groups.';

  @override
  String get settingsUnits => 'Units';

  @override
  String get settingsSop => 'SOP';

  @override
  String get settingsSopDetails => 'SOP details';

  @override
  String get settingsWarehouses => 'Warehouses';

  @override
  String get settingsUsers => 'Users';

  @override
  String get settingsProfiles => 'Profiles';

  @override
  String get settingsProducts => 'Products';

  @override
  String get settingsRawMaterials => 'Raw materials';

  @override
  String get settingsProductCategories => 'Product categories';

  @override
  String get settingsRawMaterialCategories => 'Raw material categories';

  @override
  String get settingsFormulas => 'Formulas';

  @override
  String get settingsFormulaDetails => 'Formula details';

  @override
  String get settingsProductionRules => 'Production rules';

  @override
  String get settingsLabParameters => 'Lab parameters';

  @override
  String get settingsPhysicalLabs => 'Physical labs';

  @override
  String get settingsAnalysisParameters => 'Analysis parameters';

  @override
  String get settingsReferenceMethods => 'Reference methods';

  @override
  String get settingsPredictiveResults => 'Predictive results';

  @override
  String get settingsSuppliers => 'Suppliers';

  @override
  String get settingsCustomers => 'Customers';

  @override
  String get settingsAdminOnlyNote =>
      'This area is visible for System Admin/Admin only.';
}
