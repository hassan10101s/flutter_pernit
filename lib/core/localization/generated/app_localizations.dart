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
  /// **'Raw entry'**
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

  /// No description provided for @settingsBasicsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Core setup'**
  String get settingsBasicsSectionTitle;

  /// No description provided for @settingsBasicsSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Foundational setup screens that define reusable ERP reference data.'**
  String get settingsBasicsSectionSubtitle;

  /// No description provided for @settingsUnitsSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Units'**
  String get settingsUnitsSectionTitle;

  /// No description provided for @settingsUnitsSectionSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Measurement units used by products, raw materials, lab ranges, and formulas.'**
  String get settingsUnitsSectionSubtitle;

  /// No description provided for @screenRecordsTitle.
  ///
  /// In en, this message translates to:
  /// **'Current records'**
  String get screenRecordsTitle;

  /// No description provided for @screenActionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get screenActionsTitle;

  /// No description provided for @screenAddAction.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get screenAddAction;

  /// No description provided for @screenEditAction.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get screenEditAction;

  /// No description provided for @screenDeleteAction.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get screenDeleteAction;

  /// No description provided for @screenCloseAction.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get screenCloseAction;

  /// No description provided for @screenCancelAction.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get screenCancelAction;

  /// No description provided for @screenSaveAction.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get screenSaveAction;

  /// No description provided for @screenNameField.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get screenNameField;

  /// No description provided for @screenCodeField.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get screenCodeField;

  /// No description provided for @screenDetailsField.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get screenDetailsField;

  /// No description provided for @screenNoRecords.
  ///
  /// In en, this message translates to:
  /// **'No records are available yet.'**
  String get screenNoRecords;

  /// No description provided for @screenDialogSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Review the current {screen} records, then add, edit, or delete from the action column.'**
  String screenDialogSubtitle(String screen);

  /// No description provided for @screenAddDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Add {screen}'**
  String screenAddDialogTitle(String screen);

  /// No description provided for @screenEditDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit {screen}'**
  String screenEditDialogTitle(String screen);

  /// No description provided for @screenDeleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete record'**
  String get screenDeleteConfirmTitle;

  /// No description provided for @screenDeleteConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'Delete {record}? This action requires confirmation.'**
  String screenDeleteConfirmMessage(String record);

  /// No description provided for @qualityScreensSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Quality screens are separated so each inspection, sample, and result flow can be reviewed alone.'**
  String get qualityScreensSubtitle;

  /// No description provided for @qualityLabSamplesRawMaterials.
  ///
  /// In en, this message translates to:
  /// **'Raw material lab samples'**
  String get qualityLabSamplesRawMaterials;

  /// No description provided for @qualityLabResultsRawMaterials.
  ///
  /// In en, this message translates to:
  /// **'Raw material lab results'**
  String get qualityLabResultsRawMaterials;

  /// No description provided for @qualityPhysicalLabResultsRawMaterials.
  ///
  /// In en, this message translates to:
  /// **'Raw material physical lab results'**
  String get qualityPhysicalLabResultsRawMaterials;

  /// No description provided for @qualityChecksRawMaterials.
  ///
  /// In en, this message translates to:
  /// **'Raw material quality checks'**
  String get qualityChecksRawMaterials;

  /// No description provided for @qualityChecksProduction.
  ///
  /// In en, this message translates to:
  /// **'Production quality checks'**
  String get qualityChecksProduction;

  /// No description provided for @productionScreensSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Production screens are separated so orders, details, and lab follow-up stay clear.'**
  String get productionScreensSubtitle;

  /// No description provided for @productionOrders.
  ///
  /// In en, this message translates to:
  /// **'Production orders'**
  String get productionOrders;

  /// No description provided for @productionOrderDetails.
  ///
  /// In en, this message translates to:
  /// **'Production order details'**
  String get productionOrderDetails;

  /// No description provided for @productionLabSamples.
  ///
  /// In en, this message translates to:
  /// **'Production lab samples'**
  String get productionLabSamples;

  /// No description provided for @productionLabResults.
  ///
  /// In en, this message translates to:
  /// **'Production lab results'**
  String get productionLabResults;

  /// No description provided for @productionReserveMaterials.
  ///
  /// In en, this message translates to:
  /// **'Reserve materials'**
  String get productionReserveMaterials;

  /// No description provided for @rawWorkflowBatch.
  ///
  /// In en, this message translates to:
  /// **'Batch #{id}'**
  String rawWorkflowBatch(int id);

  /// No description provided for @rawWorkflowSupplierWeight.
  ///
  /// In en, this message translates to:
  /// **'Supplier weight'**
  String get rawWorkflowSupplierWeight;

  /// No description provided for @rawWorkflowWarehouse.
  ///
  /// In en, this message translates to:
  /// **'Warehouse'**
  String get rawWorkflowWarehouse;

  /// No description provided for @rawWorkflowLoadMore.
  ///
  /// In en, this message translates to:
  /// **'Load more'**
  String get rawWorkflowLoadMore;

  /// No description provided for @rawWorkflowRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get rawWorkflowRefresh;

  /// No description provided for @rawQualityTitle.
  ///
  /// In en, this message translates to:
  /// **'Raw material quality'**
  String get rawQualityTitle;

  /// No description provided for @rawQualitySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Follow each received batch from sampling through the final quality decision.'**
  String get rawQualitySubtitle;

  /// No description provided for @rawQualityQueueCount.
  ///
  /// In en, this message translates to:
  /// **'{count} batches in the quality workflow'**
  String rawQualityQueueCount(int count);

  /// No description provided for @rawQualityEmpty.
  ///
  /// In en, this message translates to:
  /// **'No batches currently require quality work.'**
  String get rawQualityEmpty;

  /// No description provided for @rawQualityTakeSample.
  ///
  /// In en, this message translates to:
  /// **'Take sample'**
  String get rawQualityTakeSample;

  /// No description provided for @rawQualityEnterAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Enter analyses'**
  String get rawQualityEnterAnalysis;

  /// No description provided for @rawQualityReviewAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Review analyses'**
  String get rawQualityReviewAnalysis;

  /// No description provided for @rawQualityAwaitingInventory.
  ///
  /// In en, this message translates to:
  /// **'Approved — awaiting inventory'**
  String get rawQualityAwaitingInventory;

  /// No description provided for @rawQualityRejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rawQualityRejected;

  /// No description provided for @rawQualityTakingSample.
  ///
  /// In en, this message translates to:
  /// **'Taking sample…'**
  String get rawQualityTakingSample;

  /// No description provided for @rawQualitySampleSuccess.
  ///
  /// In en, this message translates to:
  /// **'The sample was created successfully.'**
  String get rawQualitySampleSuccess;

  /// No description provided for @rawQualitySamplingTab.
  ///
  /// In en, this message translates to:
  /// **'Sampling'**
  String get rawQualitySamplingTab;

  /// No description provided for @rawQualityAnalysisTab.
  ///
  /// In en, this message translates to:
  /// **'Analyses'**
  String get rawQualityAnalysisTab;

  /// No description provided for @rawQualityDecisionTab.
  ///
  /// In en, this message translates to:
  /// **'Decision'**
  String get rawQualityDecisionTab;

  /// No description provided for @rawQualitySamplingCount.
  ///
  /// In en, this message translates to:
  /// **'{count} batches available for sampling'**
  String rawQualitySamplingCount(int count);

  /// No description provided for @rawQualitySamplesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} samples'**
  String rawQualitySamplesCount(int count);

  /// No description provided for @rawQualityDecisionCount.
  ///
  /// In en, this message translates to:
  /// **'{count} batches ready for a decision'**
  String rawQualityDecisionCount(int count);

  /// No description provided for @rawQualitySamplingEmpty.
  ///
  /// In en, this message translates to:
  /// **'No received batches are available for sampling.'**
  String get rawQualitySamplingEmpty;

  /// No description provided for @rawQualityAnalysisEmpty.
  ///
  /// In en, this message translates to:
  /// **'No samples are available for analysis.'**
  String get rawQualityAnalysisEmpty;

  /// No description provided for @rawQualityDecisionEmpty.
  ///
  /// In en, this message translates to:
  /// **'No batches are ready for a quality decision.'**
  String get rawQualityDecisionEmpty;

  /// No description provided for @rawQualitySampleCount.
  ///
  /// In en, this message translates to:
  /// **'{count} samples taken'**
  String rawQualitySampleCount(int count);

  /// No description provided for @rawQualityTakeAnotherSample.
  ///
  /// In en, this message translates to:
  /// **'Take sample'**
  String get rawQualityTakeAnotherSample;

  /// No description provided for @rawQualityEditAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Edit analysis'**
  String get rawQualityEditAnalysis;

  /// No description provided for @rawAnalysisTitle.
  ///
  /// In en, this message translates to:
  /// **'Complete sample analysis'**
  String get rawAnalysisTitle;

  /// No description provided for @rawAnalysisSampleNumber.
  ///
  /// In en, this message translates to:
  /// **'Sample {number}'**
  String rawAnalysisSampleNumber(String number);

  /// No description provided for @rawAnalysisChemical.
  ///
  /// In en, this message translates to:
  /// **'Chemical analyses'**
  String get rawAnalysisChemical;

  /// No description provided for @rawAnalysisPhysical.
  ///
  /// In en, this message translates to:
  /// **'Physical analyses'**
  String get rawAnalysisPhysical;

  /// No description provided for @rawAnalysisValue.
  ///
  /// In en, this message translates to:
  /// **'Measured value'**
  String get rawAnalysisValue;

  /// No description provided for @rawAnalysisSop.
  ///
  /// In en, this message translates to:
  /// **'SOP'**
  String get rawAnalysisSop;

  /// No description provided for @rawAnalysisSelectSop.
  ///
  /// In en, this message translates to:
  /// **'Select SOP'**
  String get rawAnalysisSelectSop;

  /// No description provided for @rawAnalysisNormalRange.
  ///
  /// In en, this message translates to:
  /// **'Normal: {min} – {max}'**
  String rawAnalysisNormalRange(String min, String max);

  /// No description provided for @rawAnalysisReference.
  ///
  /// In en, this message translates to:
  /// **'Reference: {value}'**
  String rawAnalysisReference(String value);

  /// No description provided for @rawAnalysisRejectReference.
  ///
  /// In en, this message translates to:
  /// **'Reject when: {value}'**
  String rawAnalysisRejectReference(String value);

  /// No description provided for @rawAnalysisRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter at least one analysis result.'**
  String get rawAnalysisRequired;

  /// No description provided for @rawAnalysisInvalidValue.
  ///
  /// In en, this message translates to:
  /// **'Enter a valid numeric result.'**
  String get rawAnalysisInvalidValue;

  /// No description provided for @rawAnalysisAtLeastOne.
  ///
  /// In en, this message translates to:
  /// **'Enter at least one result before saving.'**
  String get rawAnalysisAtLeastOne;

  /// No description provided for @rawAnalysisSopNotConfigured.
  ///
  /// In en, this message translates to:
  /// **'SOP is not configured for this parameter'**
  String get rawAnalysisSopNotConfigured;

  /// No description provided for @rawAnalysisSaveAll.
  ///
  /// In en, this message translates to:
  /// **'Save analyses'**
  String get rawAnalysisSaveAll;

  /// No description provided for @rawAnalysisSaveSuccess.
  ///
  /// In en, this message translates to:
  /// **'The sample analyses were saved.'**
  String get rawAnalysisSaveSuccess;

  /// No description provided for @rawAnalysisResultsSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} analysis results'**
  String rawAnalysisResultsSummary(int count);

  /// No description provided for @rawQualityDecisionTitle.
  ///
  /// In en, this message translates to:
  /// **'Quality decision'**
  String get rawQualityDecisionTitle;

  /// No description provided for @rawQualityDecisionHint.
  ///
  /// In en, this message translates to:
  /// **'Optional decision notes'**
  String get rawQualityDecisionHint;

  /// No description provided for @rawQualityAccept.
  ///
  /// In en, this message translates to:
  /// **'Accept batch'**
  String get rawQualityAccept;

  /// No description provided for @rawQualityReject.
  ///
  /// In en, this message translates to:
  /// **'Reject batch'**
  String get rawQualityReject;

  /// No description provided for @rawQualityAcceptConfirm.
  ///
  /// In en, this message translates to:
  /// **'Accept this batch and send it to inventory for final weighing?'**
  String get rawQualityAcceptConfirm;

  /// No description provided for @rawQualityRejectConfirm.
  ///
  /// In en, this message translates to:
  /// **'Reject this batch? It will not be available for inventory entry.'**
  String get rawQualityRejectConfirm;

  /// No description provided for @rawQualityDecisionSuccess.
  ///
  /// In en, this message translates to:
  /// **'The quality decision was saved.'**
  String get rawQualityDecisionSuccess;

  /// No description provided for @rawInventoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Approved raw material intake'**
  String get rawInventoryTitle;

  /// No description provided for @rawInventorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Only quality-approved batches appear here. Enter the actual scale weight to close receiving.'**
  String get rawInventorySubtitle;

  /// No description provided for @rawInventoryQueueCount.
  ///
  /// In en, this message translates to:
  /// **'{count} approved batches awaiting final weight'**
  String rawInventoryQueueCount(int count);

  /// No description provided for @rawInventoryEmpty.
  ///
  /// In en, this message translates to:
  /// **'No approved batches are waiting for inventory entry.'**
  String get rawInventoryEmpty;

  /// No description provided for @rawInventoryEnterStock.
  ///
  /// In en, this message translates to:
  /// **'Enter into inventory'**
  String get rawInventoryEnterStock;

  /// No description provided for @rawInventoryActualWeight.
  ///
  /// In en, this message translates to:
  /// **'Actual scale weight'**
  String get rawInventoryActualWeight;

  /// No description provided for @rawInventoryWeightRequired.
  ///
  /// In en, this message translates to:
  /// **'Enter an actual weight greater than zero.'**
  String get rawInventoryWeightRequired;

  /// No description provided for @rawInventoryVariance.
  ///
  /// In en, this message translates to:
  /// **'Difference from supplier: {value}'**
  String rawInventoryVariance(String value);

  /// No description provided for @rawInventoryConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm actual weight and add this batch to inventory?'**
  String get rawInventoryConfirm;

  /// No description provided for @rawInventorySuccess.
  ///
  /// In en, this message translates to:
  /// **'The batch was closed and added to inventory using the actual scale weight.'**
  String get rawInventorySuccess;

  /// No description provided for @rawInventoryCurrentTab.
  ///
  /// In en, this message translates to:
  /// **'Current stock'**
  String get rawInventoryCurrentTab;

  /// No description provided for @rawInventoryReceivingTab.
  ///
  /// In en, this message translates to:
  /// **'Raw receiving'**
  String get rawInventoryReceivingTab;

  /// No description provided for @rawInventoryFinishedProductTab.
  ///
  /// In en, this message translates to:
  /// **'Finished product'**
  String get rawInventoryFinishedProductTab;

  /// No description provided for @rawInventoryCurrentCount.
  ///
  /// In en, this message translates to:
  /// **'{count} raw material stock records'**
  String rawInventoryCurrentCount(int count);

  /// No description provided for @rawInventoryProductCount.
  ///
  /// In en, this message translates to:
  /// **'{count} finished product stock records'**
  String rawInventoryProductCount(int count);

  /// No description provided for @rawInventoryCurrentEmpty.
  ///
  /// In en, this message translates to:
  /// **'No raw material stock is available.'**
  String get rawInventoryCurrentEmpty;

  /// No description provided for @rawInventoryItemsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String rawInventoryItemsCount(int count);

  /// No description provided for @rawInventoryReserved.
  ///
  /// In en, this message translates to:
  /// **'Reserved: {value}'**
  String rawInventoryReserved(String value);

  /// No description provided for @rawInventoryScaleImage.
  ///
  /// In en, this message translates to:
  /// **'Scale image (required)'**
  String get rawInventoryScaleImage;

  /// No description provided for @rawInventoryScaleImageHint.
  ///
  /// In en, this message translates to:
  /// **'Add a clear image of the measured weight'**
  String get rawInventoryScaleImageHint;

  /// No description provided for @rawInventoryImageRequired.
  ///
  /// In en, this message translates to:
  /// **'A scale image is required before inventory entry.'**
  String get rawInventoryImageRequired;

  /// No description provided for @rawInventoryTakePhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get rawInventoryTakePhoto;

  /// No description provided for @rawInventoryChoosePhoto.
  ///
  /// In en, this message translates to:
  /// **'Choose from gallery'**
  String get rawInventoryChoosePhoto;

  /// No description provided for @rawInventoryAddProductTitle.
  ///
  /// In en, this message translates to:
  /// **'Add finished product stock'**
  String get rawInventoryAddProductTitle;

  /// No description provided for @rawInventoryProduct.
  ///
  /// In en, this message translates to:
  /// **'Finished product'**
  String get rawInventoryProduct;

  /// No description provided for @rawInventoryProductQuantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity to add'**
  String get rawInventoryProductQuantity;

  /// No description provided for @rawInventoryAddProduct.
  ///
  /// In en, this message translates to:
  /// **'Add to stock'**
  String get rawInventoryAddProduct;

  /// No description provided for @rawInventoryProductRequired.
  ///
  /// In en, this message translates to:
  /// **'Select a product and warehouse, then enter a quantity greater than zero.'**
  String get rawInventoryProductRequired;

  /// No description provided for @rawInventoryAddProductConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm adding this finished product quantity to the selected warehouse?'**
  String get rawInventoryAddProductConfirm;

  /// No description provided for @rawInventoryProductSuccess.
  ///
  /// In en, this message translates to:
  /// **'Finished product stock was added.'**
  String get rawInventoryProductSuccess;

  /// No description provided for @rawInventoryProductEmpty.
  ///
  /// In en, this message translates to:
  /// **'No finished product stock is currently recorded.'**
  String get rawInventoryProductEmpty;

  /// No description provided for @commonConfirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get commonConfirm;
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
