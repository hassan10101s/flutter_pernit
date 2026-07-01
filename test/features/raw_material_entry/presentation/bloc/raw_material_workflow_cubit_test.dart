import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_pernit/core/errors/api_result.dart';
import 'package:flutter_pernit/features/raw_material_entry/domain/entities/inventory_workflow.dart';
import 'package:flutter_pernit/features/raw_material_entry/domain/entities/raw_material_entry.dart';
import 'package:flutter_pernit/features/raw_material_entry/domain/entities/raw_material_entry_lookup.dart';
import 'package:flutter_pernit/features/raw_material_entry/domain/entities/raw_material_workflow.dart';
import 'package:flutter_pernit/features/raw_material_entry/domain/repos/raw_material_entry_repository.dart';
import 'package:flutter_pernit/features/raw_material_entry/domain/usecases/raw_material_workflow_use_cases.dart';
import 'package:flutter_pernit/features/raw_material_entry/presentation/bloc/raw_material_inventory_cubit.dart';
import 'package:flutter_pernit/features/raw_material_entry/presentation/bloc/raw_material_inventory_state.dart';
import 'package:flutter_pernit/features/raw_material_entry/presentation/bloc/raw_material_quality_cubit.dart';
import 'package:flutter_pernit/features/raw_material_entry/presentation/bloc/raw_material_quality_state.dart';

void main() {
  test('quality workflow takes another sample then reloads data', () async {
    final repository = _WorkflowRepository();
    final cubit = _qualityCubit(repository);
    await cubit.load();

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        isA<RawMaterialQualityWorking>().having(
          (state) => state.action,
          'action',
          RawMaterialQualityAction.takingSample,
        ),
        isA<RawMaterialQualityLoading>(),
        isA<RawMaterialQualityLoaded>(),
      ]),
    );

    expect(await cubit.takeSample(_arrivedEntry.id), isTrue);
    await expectation;
    expect(repository.sampledBatchId, _arrivedEntry.id);
    await cubit.close();
  });

  test(
    'quality workflow saves partial analysis then records decision',
    () async {
      final repository = _WorkflowRepository(pageEntry: _qcPendingEntry);
      final cubit = _qualityCubit(repository);
      await cubit.load();
      expect(
        await cubit.openAnalysis(
          sampleId: _sample.id,
          batchId: _sample.batchId,
        ),
        isTrue,
      );

      final submission = const RawMaterialAnalysisSubmission(
        chemicalResults: [
          ChemicalAnalysisResultDraft(parameterId: 2, value: 11),
        ],
        physicalResults: [],
      );
      expect(await cubit.submitAnalysis(submission), isTrue);
      expect(repository.savedSubmission, submission);

      expect(await cubit.openDecision(_sample.batchId), isTrue);
      final decisionExpectation = expectLater(
        cubit.stream,
        emitsInOrder([
          isA<RawMaterialQualityWorking>().having(
            (state) => state.action,
            'action',
            RawMaterialQualityAction.savingDecision,
          ),
          isA<RawMaterialQualityLoading>(),
          isA<RawMaterialQualityLoaded>(),
        ]),
      );
      expect(
        await cubit.submitDecision(
          decision: RawMaterialQualityDecision.accepted,
          comments: 'Accepted',
        ),
        isTrue,
      );
      await decisionExpectation;
      expect(repository.savedDecision, RawMaterialQualityDecision.accepted);
      await cubit.close();
    },
  );

  test('inventory workflow requires and sends actual weight image', () async {
    final repository = _WorkflowRepository(pageEntry: _approvedEntry);
    final cubit = RawMaterialInventoryCubit(
      LoadRawMaterialWorkflowUseCase(repository),
      RecordRawMaterialActualWeightUseCase(repository),
      LoadRawMaterialStockUseCase(repository),
    );
    await cubit.load();

    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        isA<RawMaterialInventoryWorking>().having(
          (state) => state.action,
          'action',
          RawMaterialInventoryAction.recordingWeight,
        ),
        isA<RawMaterialInventoryLoading>(),
        isA<RawMaterialInventoryLoaded>(),
      ]),
    );
    expect(
      await cubit.recordActualWeight(
        batchId: _approvedEntry.id,
        measuredQuantity: 9.75,
        measuredImagePath: 'scale.jpg',
      ),
      isTrue,
    );
    await expectation;
    expect(repository.recordedBatchId, _approvedEntry.id);
    expect(repository.recordedWeight, 9.75);
    expect(repository.recordedImagePath, 'scale.jpg');
    await cubit.close();
  });
}

RawMaterialQualityCubit _qualityCubit(_WorkflowRepository repository) {
  return RawMaterialQualityCubit(
    LoadRawMaterialWorkflowUseCase(repository),
    LoadRawMaterialSamplesUseCase(repository),
    TakeRawMaterialSampleUseCase(repository),
    LoadRawMaterialAnalysisUseCase(repository),
    SubmitRawMaterialAnalysisUseCase(repository),
    SubmitRawMaterialQualityDecisionUseCase(repository),
  );
}

class _WorkflowRepository implements RawMaterialEntryRepository {
  RawMaterialEntry pageEntry;
  int? sampledBatchId;
  int? recordedBatchId;
  double? recordedWeight;
  String? recordedImagePath;
  RawMaterialAnalysisSubmission? savedSubmission;
  RawMaterialQualityDecision? savedDecision;
  var workspace = _workspace;

  _WorkflowRepository({this.pageEntry = _arrivedEntry});

  @override
  Future<ApiResult<RawMaterialEntryPage>> fetchWorkflowEntries({
    RawMaterialEntryStatus? status,
    bool? isInStock,
    required int page,
  }) async {
    return ApiSuccess(
      RawMaterialEntryPage(
        entries: [pageEntry],
        totalCount: 1,
        page: page,
        hasNextPage: false,
      ),
    );
  }

  @override
  Future<ApiResult<RawMaterialSamplePage>> fetchSamples({
    int? batchId,
    required int page,
  }) async {
    return ApiSuccess(
      RawMaterialSamplePage(
        samples: const [_sample],
        totalCount: 1,
        page: page,
        hasNextPage: false,
      ),
    );
  }

  @override
  Future<ApiResult<RawMaterialSample>> takeSample(int batchId) async {
    sampledBatchId = batchId;
    return const ApiSuccess(_sample);
  }

  @override
  Future<ApiResult<RawMaterialAnalysisWorkspace>> fetchAnalysisWorkspace(
    int sampleId,
  ) async {
    return ApiSuccess(workspace);
  }

  @override
  Future<ApiResult<RawMaterialAnalysisWorkspace>> submitAnalysis({
    required int sampleId,
    required RawMaterialAnalysisSubmission submission,
  }) async {
    savedSubmission = submission;
    workspace = _completedWorkspace;
    return ApiSuccess(workspace);
  }

  @override
  Future<ApiResult<bool>> submitQualityDecision({
    required int batchId,
    required RawMaterialQualityDecision decision,
    String? comments,
  }) async {
    savedDecision = decision;
    return const ApiSuccess(true);
  }

  @override
  Future<ApiResult<bool>> recordActualWeight({
    required int batchId,
    required double measuredQuantity,
    required String measuredImagePath,
  }) async {
    recordedBatchId = batchId;
    recordedWeight = measuredQuantity;
    recordedImagePath = measuredImagePath;
    return const ApiSuccess(true);
  }

  @override
  Future<ApiResult<RawMaterialStockPage>> fetchRawMaterialStock({
    required int page,
  }) async {
    return ApiSuccess(
      RawMaterialStockPage(
        items: const [],
        totalCount: 0,
        page: page,
        hasNextPage: false,
      ),
    );
  }

  @override
  Future<ApiResult<ProductStockPage>> fetchProductStock({
    required int page,
  }) async {
    return ApiSuccess(
      ProductStockPage(
        items: [],
        totalCount: 0,
        page: page,
        hasNextPage: false,
      ),
    );
  }

  @override
  Future<ApiResult<List<LookupOption>>> fetchProducts({String? search}) async {
    return const ApiSuccess([]);
  }

  @override
  Future<ApiResult<ProductStockItem>> addProductStock(ProductStockDraft draft) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<RawMaterialEntry>> createEntry(RawMaterialEntryDraft draft) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<List<RawMaterialEntry>>> fetchEntries({
    RawMaterialEntryStatus? status,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<List<LookupOption>>> fetchDrivers({String? search}) {
    throw UnimplementedError();
  }

  @override
  Future<ApiResult<RawMaterialEntryLookups>> fetchLookups() {
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
  Future<ApiResult<List<LookupOption>>> fetchWarehouses({
    String? search,
  }) async {
    return const ApiSuccess([]);
  }
}

const _sample = RawMaterialSample(
  id: 15,
  batchId: 8,
  rawMaterialName: 'Corn',
  sampleNumber: 'SMPL-8',
  status: 'completed',
  createdAt: null,
);

const _workspace = RawMaterialAnalysisWorkspace(
  sample: _sample,
  batchId: 8,
  rawMaterialName: 'Corn',
  supplierWeight: 10,
  unit: 'Ton',
  warehouseName: 'Main',
  chemicalParameters: [
    ChemicalAnalysisParameter(
      id: 2,
      name: 'Moisture',
      unit: '%',
      normalMin: 10,
      normalMax: 13,
      rejectedMin: 8,
      rejectedMax: 15,
      value: null,
      sopId: 3,
      sopName: 'Moisture SOP',
      sopDocumentNumber: 'SOP-1',
      isWithinRange: null,
    ),
  ],
  physicalParameters: [
    PhysicalAnalysisParameter(
      id: 4,
      name: 'Color',
      reference: 'Golden',
      rejectedReference: 'Dark',
      value: null,
    ),
  ],
  sops: [],
  isComplete: false,
);

const _completedWorkspace = RawMaterialAnalysisWorkspace(
  sample: _sample,
  batchId: 8,
  rawMaterialName: 'Corn',
  supplierWeight: 10,
  unit: 'Ton',
  warehouseName: 'Main',
  chemicalParameters: [
    ChemicalAnalysisParameter(
      id: 2,
      name: 'Moisture',
      unit: '%',
      normalMin: 10,
      normalMax: 13,
      rejectedMin: 8,
      rejectedMax: 15,
      value: 11,
      sopId: 3,
      sopName: 'Moisture SOP',
      sopDocumentNumber: 'SOP-1',
      isWithinRange: true,
    ),
  ],
  physicalParameters: [],
  sops: [],
  isComplete: true,
);

const _arrivedEntry = RawMaterialEntry(
  id: 8,
  rawMaterialId: 1,
  purchaseOrderDetailId: 2,
  warehouseId: 3,
  rawMaterialName: 'Corn',
  supplierName: 'Supplier',
  quantityFromSupplier: 10,
  unitName: 'Ton',
  warehouseName: 'Main',
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

const _qcPendingEntry = RawMaterialEntry(
  id: 8,
  rawMaterialId: 1,
  purchaseOrderDetailId: 2,
  warehouseId: 3,
  rawMaterialName: 'Corn',
  supplierName: 'Supplier',
  quantityFromSupplier: 10,
  unitName: 'Ton',
  warehouseName: 'Main',
  status: RawMaterialEntryStatus.qcPending,
  isSampled: true,
  isLabDone: true,
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

const _approvedEntry = RawMaterialEntry(
  id: 9,
  rawMaterialId: 1,
  purchaseOrderDetailId: 2,
  warehouseId: 3,
  rawMaterialName: 'Corn',
  supplierName: 'Supplier',
  quantityFromSupplier: 10,
  unitName: 'Ton',
  warehouseName: 'Main',
  status: RawMaterialEntryStatus.approved,
  isSampled: true,
  isLabDone: true,
  isQcDone: true,
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
