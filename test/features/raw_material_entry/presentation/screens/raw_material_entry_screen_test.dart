import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_pernit/core/di/dependency_injection.dart';
import 'package:flutter_pernit/core/errors/api_result.dart';
import 'package:flutter_pernit/core/errors/failure.dart';
import 'package:flutter_pernit/core/errors/failure_code.dart';
import 'package:flutter_pernit/core/localization/generated/app_localizations.dart';
import 'package:flutter_pernit/features/raw_material_entry/domain/entities/inventory_workflow.dart';
import 'package:flutter_pernit/features/raw_material_entry/domain/entities/raw_material_entry.dart';
import 'package:flutter_pernit/features/raw_material_entry/domain/entities/raw_material_entry_lookup.dart';
import 'package:flutter_pernit/features/raw_material_entry/domain/entities/raw_material_workflow.dart';
import 'package:flutter_pernit/features/raw_material_entry/domain/repos/raw_material_entry_repository.dart';
import 'package:flutter_pernit/features/raw_material_entry/domain/usecases/raw_material_entry_use_cases.dart';
import 'package:flutter_pernit/features/raw_material_entry/presentation/bloc/raw_material_entry_cubit.dart';
import 'package:flutter_pernit/features/raw_material_entry/presentation/screens/raw_material_entry_screen.dart';

void main() {
  tearDown(() async {
    await sl.reset();
  });

  testWidgets('screen loads entries and autocomplete lookup data', (
    tester,
  ) async {
    final repository = _FakeRawMaterialEntryRepository(
      entriesResult: const ApiSuccess([_entry]),
      lookupsResult: const ApiSuccess(_lookups),
    );
    sl.registerFactory<RawMaterialEntryCubit>(() => _cubit(repository));

    await tester.pumpRawMaterialEntryScreen();
    await tester.pumpAndSettle();

    expect(repository.entryCalls, 1);
    expect(repository.lookupCalls, 1);
    expect(find.text('Raw material entry'), findsOneWidget);
    expect(find.text('Yellow Corn'), findsWidgets);
    expect(find.textContaining('Delta Supply'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'corn');
    await tester.pump();

    expect(find.text('RM-3 - Yellow Corn'), findsOneWidget);
  });

  testWidgets('screen submits selected raw material and quantity', (
    tester,
  ) async {
    final repository = _FakeRawMaterialEntryRepository(
      entriesResult: const ApiSuccess([_entry]),
      lookupsResult: const ApiSuccess(_lookups),
      createResult: const ApiSuccess(_createdEntry),
    );
    sl.registerFactory<RawMaterialEntryCubit>(() => _cubit(repository));

    await tester.pumpRawMaterialEntryScreen();
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).first, 'corn');
    await tester.pump();
    await tester.tap(find.text('RM-3 - Yellow Corn').last);
    await tester.pump();

    await tester.enterText(find.byType(TextFormField).at(1), 'PO-22');
    await tester.pump();
    await tester.tap(find.text('PO-22 - Yellow Corn').last);
    await tester.pump();

    await tester.enterText(find.byType(TextFormField).at(2), 'Main');
    await tester.pump();
    await tester.tap(find.text('Main Warehouse').last);
    await tester.pump();

    await tester.enterText(find.byType(TextFormField).at(4), '20');
    await tester.ensureVisible(find.text('Create entry').last);
    await tester.tap(find.text('Create entry').last);
    await tester.pumpAndSettle();

    expect(repository.createdDraft?.rawMaterialId, 3);
    expect(repository.createdDraft?.quantityFromSupplier, 20);
    expect(find.text('Raw material entry created.'), findsOneWidget);
  });

  testWidgets('screen shows error state and retries', (tester) async {
    final results = <ApiResult<List<RawMaterialEntry>>>[
      const ApiFailure(
        Failure(code: FailureCode.network, messageKey: 'failureNetwork'),
      ),
      const ApiSuccess([_entry]),
    ];
    final repository = _FakeRawMaterialEntryRepository(
      entriesHandler: () => results.removeAt(0),
      lookupsResult: const ApiSuccess(_lookups),
    );
    sl.registerFactory<RawMaterialEntryCubit>(() => _cubit(repository));

    await tester.pumpRawMaterialEntryScreen();
    await tester.pumpAndSettle();

    expect(find.text('Could not load entries'), findsOneWidget);
    expect(
      find.text('Check your internet connection and try again.'),
      findsOneWidget,
    );

    await tester.ensureVisible(find.text('Retry'));
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    expect(repository.entryCalls, 2);
    expect(find.text('Yellow Corn'), findsWidgets);
    expect(find.text('Could not load entries'), findsNothing);
  });
}

RawMaterialEntryCubit _cubit(RawMaterialEntryRepository repository) {
  return RawMaterialEntryCubit(
    LoadRawMaterialEntriesUseCase(repository),
    LoadRawMaterialEntryLookupsUseCase(repository),
    CreateRawMaterialEntryUseCase(repository),
  );
}

extension on WidgetTester {
  Future<void> pumpRawMaterialEntryScreen() async {
    await pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: false,
        splitScreenMode: true,
        builder: (context, child) => MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const Scaffold(body: RawMaterialEntryScreen()),
        ),
      ),
    );
  }
}

class _FakeRawMaterialEntryRepository implements RawMaterialEntryRepository {
  final ApiResult<List<RawMaterialEntry>>? entriesResult;
  final ApiResult<List<RawMaterialEntry>> Function()? entriesHandler;
  final ApiResult<RawMaterialEntryLookups> lookupsResult;
  final ApiResult<RawMaterialEntry>? createResult;
  RawMaterialEntryDraft? createdDraft;
  var entryCalls = 0;
  var lookupCalls = 0;

  _FakeRawMaterialEntryRepository({
    this.entriesResult,
    this.entriesHandler,
    required this.lookupsResult,
    this.createResult,
  });

  @override
  Future<ApiResult<List<RawMaterialEntry>>> fetchEntries({
    RawMaterialEntryStatus? status,
  }) async {
    entryCalls++;
    return entriesHandler?.call() ?? entriesResult ?? const ApiSuccess([]);
  }

  @override
  Future<ApiResult<RawMaterialEntryLookups>> fetchLookups() async {
    lookupCalls++;
    return lookupsResult;
  }

  @override
  Future<ApiResult<RawMaterialEntry>> createEntry(
    RawMaterialEntryDraft draft,
  ) async {
    createdDraft = draft;
    return createResult ?? const ApiSuccess(_createdEntry);
  }

  @override
  Future<ApiResult<List<LookupOption>>> fetchDrivers({String? search}) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<List<LookupOption>>> fetchPurchaseOrderDetails({
    String? search,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<List<LookupOption>>> fetchRawMaterials({String? search}) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<List<LookupOption>>> fetchWarehouses({String? search}) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<RawMaterialAnalysisWorkspace>> fetchAnalysisWorkspace(
    int sampleId,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<RawMaterialEntryPage>> fetchWorkflowEntries({
    RawMaterialEntryStatus? status,
    bool? isInStock,
    required int page,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<bool>> recordActualWeight({
    required int batchId,
    required double measuredQuantity,
    required String measuredImagePath,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<RawMaterialAnalysisWorkspace>> submitAnalysis({
    required int sampleId,
    required RawMaterialAnalysisSubmission submission,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<bool>> submitQualityDecision({
    required int batchId,
    required RawMaterialQualityDecision decision,
    String? comments,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<RawMaterialSample>> takeSample(int batchId) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<RawMaterialSamplePage>> fetchSamples({
    int? batchId,
    required int page,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<List<LookupOption>>> fetchProducts({String? search}) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<RawMaterialStockPage>> fetchRawMaterialStock({
    required int page,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<List<ProductStockItem>>> fetchProductStock() {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<ProductStockItem>> addProductStock(ProductStockDraft draft) {
    throw UnimplementedError();
  }
}

const _entry = RawMaterialEntry(
  id: 1,
  rawMaterialId: 3,
  purchaseOrderDetailId: 22,
  warehouseId: 4,
  rawMaterialName: 'Yellow Corn',
  supplierName: 'Delta Supply',
  quantityFromSupplier: 14,
  unitName: 'ton',
  warehouseName: 'Main Warehouse',
  status: RawMaterialEntryStatus.arrived,
  isSampled: false,
  isLabDone: false,
  isQcDone: false,
  isInStock: false,
  acceptedQuantity: null,
  rejectedQuantity: null,
  availableQuantity: null,
  measuredQuantity: null,
  vehicleNo: null,
  driverName: null,
  lotNo: null,
  expiryDate: null,
  createdAt: null,
);

const _createdEntry = RawMaterialEntry(
  id: 2,
  rawMaterialId: 3,
  purchaseOrderDetailId: 22,
  warehouseId: 4,
  rawMaterialName: 'Yellow Corn',
  supplierName: 'Delta Supply',
  quantityFromSupplier: 20,
  unitName: 'ton',
  warehouseName: 'Main Warehouse',
  status: RawMaterialEntryStatus.arrived,
  isSampled: false,
  isLabDone: false,
  isQcDone: false,
  isInStock: false,
  acceptedQuantity: null,
  rejectedQuantity: null,
  availableQuantity: null,
  measuredQuantity: null,
  vehicleNo: null,
  driverName: null,
  lotNo: null,
  expiryDate: null,
  createdAt: null,
);

const _lookups = RawMaterialEntryLookups(
  rawMaterials: [
    LookupOption(
      id: 3,
      label: 'RM-3 - Yellow Corn',
      metadata: {'unitName': 'ton', 'rawMaterialId': '3'},
    ),
  ],
  warehouses: [LookupOption(id: 4, label: 'Main Warehouse')],
  purchaseOrderDetails: [
    LookupOption(
      id: 22,
      label: 'PO-22 - Yellow Corn',
      metadata: {
        'rawMaterialName': 'Yellow Corn',
        'rawMaterialId': '3',
        'supplierName': 'Delta Supply',
        'unitName': 'ton',
      },
    ),
  ],
  drivers: [LookupOption(id: 5, label: 'Hassan')],
);
