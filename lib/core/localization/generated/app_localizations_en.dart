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
  String get menuCommercial => 'Raw entry';

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

  @override
  String get settingsBasicsSectionTitle => 'Core setup';

  @override
  String get settingsBasicsSectionSubtitle =>
      'Foundational setup screens that define reusable ERP reference data.';

  @override
  String get settingsUnitsSectionTitle => 'Units';

  @override
  String get settingsUnitsSectionSubtitle =>
      'Measurement units used by products, raw materials, lab ranges, and formulas.';

  @override
  String get screenRecordsTitle => 'Current records';

  @override
  String get screenActionsTitle => 'Actions';

  @override
  String get screenAddAction => 'Add';

  @override
  String get screenEditAction => 'Edit';

  @override
  String get screenDeleteAction => 'Delete';

  @override
  String get screenCloseAction => 'Close';

  @override
  String get screenCancelAction => 'Cancel';

  @override
  String get screenSaveAction => 'Save';

  @override
  String get screenNameField => 'Name';

  @override
  String get screenCodeField => 'Code';

  @override
  String get screenDetailsField => 'Details';

  @override
  String get screenNoRecords => 'No records are available yet.';

  @override
  String screenDialogSubtitle(String screen) {
    return 'Review the current $screen records, then add, edit, or delete from the action column.';
  }

  @override
  String screenAddDialogTitle(String screen) {
    return 'Add $screen';
  }

  @override
  String screenEditDialogTitle(String screen) {
    return 'Edit $screen';
  }

  @override
  String get screenDeleteConfirmTitle => 'Delete record';

  @override
  String screenDeleteConfirmMessage(String record) {
    return 'Delete $record? This action requires confirmation.';
  }

  @override
  String get qualityScreensSubtitle =>
      'Quality screens are separated so each inspection, sample, and result flow can be reviewed alone.';

  @override
  String get qualityLabSamplesRawMaterials => 'Raw material lab samples';

  @override
  String get qualityLabResultsRawMaterials => 'Raw material lab results';

  @override
  String get qualityPhysicalLabResultsRawMaterials =>
      'Raw material physical lab results';

  @override
  String get qualityChecksRawMaterials => 'Raw material quality checks';

  @override
  String get qualityChecksProduction => 'Production quality checks';

  @override
  String get productionScreensSubtitle =>
      'Production screens are separated so orders, details, and lab follow-up stay clear.';

  @override
  String get productionOrders => 'Production orders';

  @override
  String get productionOrderDetails => 'Production order details';

  @override
  String get productionLabSamples => 'Production lab samples';

  @override
  String get productionLabResults => 'Production lab results';

  @override
  String get productionReserveMaterials => 'Reserve materials';

  @override
  String rawWorkflowBatch(int id) {
    return 'Batch #$id';
  }

  @override
  String get rawWorkflowSupplierWeight => 'Supplier weight';

  @override
  String get rawWorkflowWarehouse => 'Warehouse';

  @override
  String get rawWorkflowLoadMore => 'Load more';

  @override
  String get rawWorkflowRefresh => 'Refresh';

  @override
  String get rawQualityTitle => 'Raw material quality';

  @override
  String get rawQualitySubtitle =>
      'Follow each received batch from sampling through the final quality decision.';

  @override
  String rawQualityQueueCount(int count) {
    return '$count batches in the quality workflow';
  }

  @override
  String get rawQualityEmpty => 'No batches currently require quality work.';

  @override
  String get rawQualityTakeSample => 'Take sample';

  @override
  String get rawQualityEnterAnalysis => 'Enter analyses';

  @override
  String get rawQualityReviewAnalysis => 'Review analyses';

  @override
  String get rawQualityAwaitingInventory => 'Approved — awaiting inventory';

  @override
  String get rawQualityRejected => 'Rejected';

  @override
  String get rawQualityTakingSample => 'Taking sample…';

  @override
  String get rawQualitySampleSuccess => 'The sample was created successfully.';

  @override
  String get rawQualitySamplingTab => 'Sampling';

  @override
  String get rawQualityAnalysisTab => 'Analyses';

  @override
  String get rawQualityDecisionTab => 'Decision';

  @override
  String rawQualitySamplingCount(int count) {
    return '$count batches available for sampling';
  }

  @override
  String rawQualitySamplesCount(int count) {
    return '$count samples';
  }

  @override
  String rawQualityDecisionCount(int count) {
    return '$count batches ready for a decision';
  }

  @override
  String get rawQualitySamplingEmpty =>
      'No received batches are available for sampling.';

  @override
  String get rawQualityAnalysisEmpty =>
      'No samples are available for analysis.';

  @override
  String get rawQualityDecisionEmpty =>
      'No batches are ready for a quality decision.';

  @override
  String rawQualitySampleCount(int count) {
    return '$count samples taken';
  }

  @override
  String get rawQualityTakeAnotherSample => 'Take sample';

  @override
  String get rawQualityEditAnalysis => 'Edit analysis';

  @override
  String get rawAnalysisTitle => 'Complete sample analysis';

  @override
  String rawAnalysisSampleNumber(String number) {
    return 'Sample $number';
  }

  @override
  String get rawAnalysisChemical => 'Chemical analyses';

  @override
  String get rawAnalysisPhysical => 'Physical analyses';

  @override
  String get rawAnalysisValue => 'Measured value';

  @override
  String get rawAnalysisSop => 'SOP';

  @override
  String get rawAnalysisSelectSop => 'Select SOP';

  @override
  String rawAnalysisNormalRange(String min, String max) {
    return 'Normal: $min – $max';
  }

  @override
  String rawAnalysisReference(String value) {
    return 'Reference: $value';
  }

  @override
  String rawAnalysisRejectReference(String value) {
    return 'Reject when: $value';
  }

  @override
  String get rawAnalysisRequired => 'Enter at least one analysis result.';

  @override
  String get rawAnalysisInvalidValue => 'Enter a valid numeric result.';

  @override
  String get rawAnalysisAtLeastOne =>
      'Enter at least one result before saving.';

  @override
  String get rawAnalysisSopNotConfigured =>
      'SOP is not configured for this parameter';

  @override
  String get rawAnalysisSaveAll => 'Save analyses';

  @override
  String get rawAnalysisSaveSuccess => 'The sample analyses were saved.';

  @override
  String rawAnalysisResultsSummary(int count) {
    return '$count analysis results';
  }

  @override
  String get rawQualityDecisionTitle => 'Quality decision';

  @override
  String get rawQualityDecisionHint => 'Optional decision notes';

  @override
  String get rawQualityAccept => 'Accept batch';

  @override
  String get rawQualityReject => 'Reject batch';

  @override
  String get rawQualityAcceptConfirm =>
      'Accept this batch and send it to inventory for final weighing?';

  @override
  String get rawQualityRejectConfirm =>
      'Reject this batch? It will not be available for inventory entry.';

  @override
  String get rawQualityDecisionSuccess => 'The quality decision was saved.';

  @override
  String get rawInventoryTitle => 'Approved raw material intake';

  @override
  String get rawInventorySubtitle =>
      'Only quality-approved batches appear here. Enter the actual scale weight to close receiving.';

  @override
  String rawInventoryQueueCount(int count) {
    return '$count approved batches awaiting final weight';
  }

  @override
  String get rawInventoryEmpty =>
      'No approved batches are waiting for inventory entry.';

  @override
  String get rawInventoryEnterStock => 'Enter into inventory';

  @override
  String get rawInventoryActualWeight => 'Actual scale weight';

  @override
  String get rawInventoryWeightRequired =>
      'Enter an actual weight greater than zero.';

  @override
  String rawInventoryVariance(String value) {
    return 'Difference from supplier: $value';
  }

  @override
  String get rawInventoryConfirm =>
      'Confirm actual weight and add this batch to inventory?';

  @override
  String get rawInventorySuccess =>
      'The batch was closed and added to inventory using the actual scale weight.';

  @override
  String get rawInventoryCurrentTab => 'Current stock';

  @override
  String get rawInventoryReceivingTab => 'Raw receiving';

  @override
  String get rawInventoryFinishedProductTab => 'Finished product';

  @override
  String rawInventoryCurrentCount(int count) {
    return '$count raw material stock records';
  }

  @override
  String rawInventoryProductCount(int count) {
    return '$count finished product stock records';
  }

  @override
  String get rawInventoryCurrentEmpty => 'No raw material stock is available.';

  @override
  String rawInventoryItemsCount(int count) {
    return '$count items';
  }

  @override
  String rawInventoryReserved(String value) {
    return 'Reserved: $value';
  }

  @override
  String get rawInventoryScaleImage => 'Scale image (required)';

  @override
  String get rawInventoryScaleImageHint =>
      'Add a clear image of the measured weight';

  @override
  String get rawInventoryImageRequired =>
      'A scale image is required before inventory entry.';

  @override
  String get rawInventoryTakePhoto => 'Take a photo';

  @override
  String get rawInventoryChoosePhoto => 'Choose from gallery';

  @override
  String get rawInventoryAddProductTitle => 'Add finished product stock';

  @override
  String get rawInventoryProduct => 'Finished product';

  @override
  String get rawInventoryProductQuantity => 'Quantity to add';

  @override
  String get rawInventoryAddProduct => 'Add to stock';

  @override
  String get rawInventoryProductRequired =>
      'Select a product and warehouse, then enter a quantity greater than zero.';

  @override
  String get rawInventoryAddProductConfirm =>
      'Confirm adding this finished product quantity to the selected warehouse?';

  @override
  String get rawInventoryProductSuccess => 'Finished product stock was added.';

  @override
  String get rawInventoryProductEmpty =>
      'No finished product stock is currently recorded.';

  @override
  String get commonConfirm => 'Confirm';
}
