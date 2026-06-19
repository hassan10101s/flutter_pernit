import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_pernit/core/errors/api_result.dart';
import 'package:flutter_pernit/core/errors/failure.dart';
import 'package:flutter_pernit/core/errors/failure_code.dart';
import 'package:flutter_pernit/features/raw_material_entry/domain/entities/inventory_workflow.dart';
import 'package:flutter_pernit/features/raw_material_entry/domain/entities/raw_material_entry.dart';
import 'package:flutter_pernit/features/raw_material_entry/domain/entities/raw_material_entry_lookup.dart';
import 'package:flutter_pernit/features/raw_material_entry/domain/entities/raw_material_workflow.dart';
import 'package:flutter_pernit/features/raw_material_entry/domain/repos/raw_material_entry_repository.dart';
import 'package:flutter_pernit/features/raw_material_entry/domain/usecases/raw_material_entry_use_cases.dart';
import 'package:flutter_pernit/features/raw_material_entry/presentation/bloc/raw_material_entry_cubit.dart';
import 'package:flutter_pernit/features/raw_material_entry/presentation/bloc/raw_material_entry_state.dart';

void main() {
  test('loads entries and lookup data from repository', () async {
    final repository = _FakeRawMaterialEntryRepository(
      entriesResult: const ApiSuccess([_entry]),
      lookupsResult: const ApiSuccess(_lookups),
    );
    final cubit = _cubit(repository);

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        isA<RawMaterialEntryLoading>(),
        isA<RawMaterialEntryLoaded>()
            .having((state) => state.entries.single, 'entry', _entry)
            .having(
              (state) => state.lookups.rawMaterials.single.label,
              'raw material lookup',
              'Yellow Corn',
            )
            .having(
              (state) => state.selectedStatus,
              'selectedStatus',
              RawMaterialEntryStatus.arrived,
            ),
      ]),
    );

    await cubit.load(status: RawMaterialEntryStatus.arrived);
    await expectation;

    expect(repository.requestedStatus, RawMaterialEntryStatus.arrived);
    await cubit.close();
  });

  test('emits empty state when no entries match the selected status', () async {
    final cubit = _cubit(
      _FakeRawMaterialEntryRepository(
        entriesResult: const ApiSuccess([]),
        lookupsResult: const ApiSuccess(_lookups),
      ),
    );

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        isA<RawMaterialEntryLoading>(),
        isA<RawMaterialEntryEmpty>().having(
          (state) => state.lookups,
          'lookups',
          _lookups,
        ),
      ]),
    );

    await cubit.load();
    await expectation;
    await cubit.close();
  });

  test('emits error state when entries fail', () async {
    const failure = Failure(
      code: FailureCode.network,
      messageKey: 'failureNetwork',
    );
    final cubit = _cubit(
      _FakeRawMaterialEntryRepository(
        entriesResult: const ApiFailure(failure),
        lookupsResult: const ApiSuccess(_lookups),
      ),
    );

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        isA<RawMaterialEntryLoading>(),
        isA<RawMaterialEntryError>().having(
          (state) => state.failure,
          'failure',
          failure,
        ),
      ]),
    );

    await cubit.load();
    await expectation;
    await cubit.close();
  });

  test('submits draft then reloads entries', () async {
    final repository = _FakeRawMaterialEntryRepository(
      entriesResult: const ApiSuccess([_entry]),
      lookupsResult: const ApiSuccess(_lookups),
      createResult: const ApiSuccess(_createdEntry),
    );
    final cubit = _cubit(repository);

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        isA<RawMaterialEntrySubmitting>(),
        isA<RawMaterialEntrySubmitSuccess>().having(
          (state) => state.createdEntry,
          'created entry',
          _createdEntry,
        ),
        isA<RawMaterialEntryLoading>(),
        isA<RawMaterialEntryLoaded>(),
      ]),
    );

    await cubit.submit(_draft);
    await expectation;

    expect(repository.createdDraft, _draft);
    expect(repository.entryCalls, 1);
    await cubit.close();
  });
}

RawMaterialEntryCubit _cubit(RawMaterialEntryRepository repository) {
  return RawMaterialEntryCubit(
    LoadRawMaterialEntriesUseCase(repository),
    LoadRawMaterialEntryLookupsUseCase(repository),
    CreateRawMaterialEntryUseCase(repository),
  );
}

class _FakeRawMaterialEntryRepository implements RawMaterialEntryRepository {
  final ApiResult<List<RawMaterialEntry>> entriesResult;
  final ApiResult<RawMaterialEntryLookups> lookupsResult;
  final ApiResult<RawMaterialEntry>? createResult;
  RawMaterialEntryStatus? requestedStatus;
  RawMaterialEntryDraft? createdDraft;
  var entryCalls = 0;

  _FakeRawMaterialEntryRepository({
    required this.entriesResult,
    required this.lookupsResult,
    this.createResult,
  });

  @override
  Future<ApiResult<List<RawMaterialEntry>>> fetchEntries({
    RawMaterialEntryStatus? status,
  }) async {
    entryCalls++;
    requestedStatus = status;
    return entriesResult;
  }

  @override
  Future<ApiResult<RawMaterialEntryLookups>> fetchLookups() async {
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
  rawMaterials: [LookupOption(id: 3, label: 'Yellow Corn')],
  warehouses: [LookupOption(id: 4, label: 'Main Warehouse')],
  purchaseOrderDetails: [
    LookupOption(
      id: 22,
      label: 'PO-22 - Yellow Corn',
      metadata: {'rawMaterialName': 'Yellow Corn'},
    ),
  ],
  drivers: [LookupOption(id: 5, label: 'Hassan')],
);

const _draft = RawMaterialEntryDraft(
  rawMaterialId: 3,
  purchaseOrderDetailId: 22,
  warehouseId: 4,
  quantityFromSupplier: 20,
  vehicleNo: null,
  driverName: null,
  lotNo: null,
  expiryDate: null,
);
