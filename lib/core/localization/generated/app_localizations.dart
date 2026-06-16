import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Pernit ERP'**
  String get appTitle;

  /// No description provided for @loginTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome back'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue to the Pernit ERP workspace.'**
  String get loginSubtitle;

  /// No description provided for @usernameLabel.
  ///
  /// In en, this message translates to:
  /// **'Username'**
  String get usernameLabel;

  /// No description provided for @usernameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your username'**
  String get usernameHint;

  /// No description provided for @passwordLabel.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get passwordLabel;

  /// No description provided for @passwordHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// No description provided for @loginButton.
  ///
  /// In en, this message translates to:
  /// **'Log in'**
  String get loginButton;

  /// No description provided for @loggingInButton.
  ///
  /// In en, this message translates to:
  /// **'Signing in'**
  String get loggingInButton;

  /// No description provided for @usernameRequired.
  ///
  /// In en, this message translates to:
  /// **'Username is required.'**
  String get usernameRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In en, this message translates to:
  /// **'Password is required.'**
  String get passwordRequired;

  /// No description provided for @failureNetwork.
  ///
  /// In en, this message translates to:
  /// **'Check your internet connection and try again.'**
  String get failureNetwork;

  /// No description provided for @failureUnauthorized.
  ///
  /// In en, this message translates to:
  /// **'The username or password is incorrect.'**
  String get failureUnauthorized;

  /// No description provided for @failureForbidden.
  ///
  /// In en, this message translates to:
  /// **'You do not have permission to access this area.'**
  String get failureForbidden;

  /// No description provided for @failureValidation.
  ///
  /// In en, this message translates to:
  /// **'Please review the highlighted fields.'**
  String get failureValidation;

  /// No description provided for @failureServer.
  ///
  /// In en, this message translates to:
  /// **'The server could not complete the request.'**
  String get failureServer;

  /// No description provided for @failureTimeout.
  ///
  /// In en, this message translates to:
  /// **'The request took too long. Please try again.'**
  String get failureTimeout;

  /// No description provided for @failureConfigurationMissing.
  ///
  /// In en, this message translates to:
  /// **'The API URL is not configured for this build.'**
  String get failureConfigurationMissing;

  /// No description provided for @failureUnknown.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get failureUnknown;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get homeTitle;

  /// No description provided for @homeEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Pernit ERP'**
  String get homeEmptyTitle;

  /// No description provided for @homeEmptySubtitle.
  ///
  /// In en, this message translates to:
  /// **'The workspace is ready for the next module.'**
  String get homeEmptySubtitle;

  /// No description provided for @homeLogoutTooltip.
  ///
  /// In en, this message translates to:
  /// **'Log out'**
  String get homeLogoutTooltip;

  /// No description provided for @homeGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello, {name}'**
  String homeGreeting(String name);

  /// No description provided for @homeGroupLabel.
  ///
  /// In en, this message translates to:
  /// **'Groups: {groups}'**
  String homeGroupLabel(String groups);

  /// No description provided for @homeNoGroups.
  ///
  /// In en, this message translates to:
  /// **'No groups assigned'**
  String get homeNoGroups;

  /// No description provided for @menuOverview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get menuOverview;

  /// No description provided for @menuInventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get menuInventory;

  /// No description provided for @menuQuality.
  ///
  /// In en, this message translates to:
  /// **'Quality'**
  String get menuQuality;

  /// No description provided for @menuProduction.
  ///
  /// In en, this message translates to:
  /// **'Production'**
  String get menuProduction;

  /// No description provided for @menuCommercial.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get menuCommercial;

  /// No description provided for @menuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menuSettings;

  /// No description provided for @overviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Workspace'**
  String get overviewTitle;

  /// No description provided for @overviewSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Available sections are based on the user groups returned by login.'**
  String get overviewSubtitle;

  /// No description provided for @modulePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'{module} screen placeholder'**
  String modulePlaceholder(String module);

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin settings'**
  String get settingsTitle;

  /// No description provided for @settingsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Core setup items stay here and are shown only to admin groups.'**
  String get settingsSubtitle;

  /// No description provided for @settingsUnits.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get settingsUnits;

  /// No description provided for @settingsSop.
  ///
  /// In en, this message translates to:
  /// **'SOP'**
  String get settingsSop;

  /// No description provided for @settingsSopDetails.
  ///
  /// In en, this message translates to:
  /// **'SOP details'**
  String get settingsSopDetails;

  /// No description provided for @settingsWarehouses.
  ///
  /// In en, this message translates to:
  /// **'Warehouses'**
  String get settingsWarehouses;

  /// No description provided for @settingsUsers.
  ///
  /// In en, this message translates to:
  /// **'Users'**
  String get settingsUsers;

  /// No description provided for @settingsProfiles.
  ///
  /// In en, this message translates to:
  /// **'Profiles'**
  String get settingsProfiles;

  /// No description provided for @settingsProducts.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get settingsProducts;

  /// No description provided for @settingsRawMaterials.
  ///
  /// In en, this message translates to:
  /// **'Raw materials'**
  String get settingsRawMaterials;

  /// No description provided for @settingsProductCategories.
  ///
  /// In en, this message translates to:
  /// **'Product categories'**
  String get settingsProductCategories;

  /// No description provided for @settingsRawMaterialCategories.
  ///
  /// In en, this message translates to:
  /// **'Raw material categories'**
  String get settingsRawMaterialCategories;

  /// No description provided for @settingsFormulas.
  ///
  /// In en, this message translates to:
  /// **'Formulas'**
  String get settingsFormulas;

  /// No description provided for @settingsFormulaDetails.
  ///
  /// In en, this message translates to:
  /// **'Formula details'**
  String get settingsFormulaDetails;

  /// No description provided for @settingsProductionRules.
  ///
  /// In en, this message translates to:
  /// **'Production rules'**
  String get settingsProductionRules;

  /// No description provided for @settingsLabParameters.
  ///
  /// In en, this message translates to:
  /// **'Lab parameters'**
  String get settingsLabParameters;

  /// No description provided for @settingsPhysicalLabs.
  ///
  /// In en, this message translates to:
  /// **'Physical labs'**
  String get settingsPhysicalLabs;

  /// No description provided for @settingsAnalysisParameters.
  ///
  /// In en, this message translates to:
  /// **'Analysis parameters'**
  String get settingsAnalysisParameters;

  /// No description provided for @settingsReferenceMethods.
  ///
  /// In en, this message translates to:
  /// **'Reference methods'**
  String get settingsReferenceMethods;

  /// No description provided for @settingsPredictiveResults.
  ///
  /// In en, this message translates to:
  /// **'Predictive results'**
  String get settingsPredictiveResults;

  /// No description provided for @settingsSuppliers.
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get settingsSuppliers;

  /// No description provided for @settingsCustomers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get settingsCustomers;

  /// No description provided for @settingsAdminOnlyNote.
  ///
  /// In en, this message translates to:
  /// **'This area is visible for System Admin/Admin only.'**
  String get settingsAdminOnlyNote;

  String get settingsBasicsSectionTitle;

  String get settingsBasicsSectionSubtitle;

  String get settingsUnitsSectionTitle;

  String get settingsUnitsSectionSubtitle;

  String get screenRecordsTitle;

  String get screenActionsTitle;

  String get screenAddAction;

  String get screenEditAction;

  String get screenDeleteAction;

  String get screenCloseAction;

  String get screenCancelAction;

  String get screenSaveAction;

  String get screenNameField;

  String get screenCodeField;

  String get screenDetailsField;

  String get screenNoRecords;

  String screenDialogSubtitle(String screen);

  String screenAddDialogTitle(String screen);

  String screenEditDialogTitle(String screen);

  String get screenDeleteConfirmTitle;

  String screenDeleteConfirmMessage(String record);

  String get qualityScreensSubtitle;

  String get qualityLabSamplesRawMaterials;

  String get qualityLabResultsRawMaterials;

  String get qualityPhysicalLabResultsRawMaterials;

  String get qualityChecksRawMaterials;

  String get qualityChecksProduction;

  String get productionScreensSubtitle;

  String get productionOrders;

  String get productionOrderDetails;

  String get productionLabSamples;

  String get productionLabResults;

  String get productionReserveMaterials;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
