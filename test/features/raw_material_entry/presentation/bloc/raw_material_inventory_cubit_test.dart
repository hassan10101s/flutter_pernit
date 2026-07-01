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

void main() {
  test('stops stock load at maxInventoryPages guard', () async {
    final repository = _MockRawRepository(
      queueResult: ApiSuccess(_emptyPage()),
      infinitePages: true,
    );
    final cubit = _cubit(repository);
    await cubit.load();
    final state = cubit.state;
    expect(state, isA<RawMaterialInventoryLoaded>());
    expect(
      repository.fetchStockPageCount <=
          RawMaterialInventoryCubit.maxInventoryPages,
      isTrue,
    );
    final loaded = state as RawMaterialInventoryLoaded;
    expect(loaded.stockWasTruncated, isTrue);
    await cubit.close();
  });

  test('stops stock load at maxInventoryItems guard', () async {
    final repository = _MockRawRepository(
      queueResult: ApiSuccess(_emptyPage()),
      manyItemsPerPage: true,
    );
    final cubit = _cubit(repository);
    await cubit.load();
    final state = cubit.state;
    expect(state, isA<RawMaterialInventoryLoaded>());
    final loaded = state as RawMaterialInventoryLoaded;
    expect(loaded.stockItems.length, greaterThan(3000));
    expect(loaded.stockWasTruncated, isTrue);
    expect(
      repository.fetchStockPageCount,
      lessThan(RawMaterialInventoryCubit.maxInventoryPages),
    );
    await cubit.close();
  });

  test('stockWasTruncated is false when all pages load normally', () async {
    final repository = _MockRawRepository(
      queueResult: ApiSuccess(_emptyPage()),
      infinitePages: false,
    );
    final cubit = _cubit(repository);
    await cubit.load();
    final state = cubit.state;
    expect(state, isA<RawMaterialInventoryLoaded>());
    final loaded = state as RawMaterialInventoryLoaded;
    expect(loaded.stockWasTruncated, isFalse);
    expect(loaded.stockItems.length, 6);
    await cubit.close();
  });
}

RawMaterialInventoryCubit _cubit(_MockRawRepository repository) {
  return RawMaterialInventoryCubit(
    LoadRawMaterialWorkflowUseCase(repository),
    RecordRawMaterialActualWeightUseCase(repository),
    LoadRawMaterialStockUseCase(repository),
  );
}

RawMaterialEntryPage _emptyPage() {
  return RawMaterialEntryPage(
    entries: [],
    totalCount: 0,
    page: 1,
    hasNextPage: false,
  );
}

class _MockRawRepository implements RawMaterialEntryRepository {
  final ApiResult<RawMaterialEntryPage> queueResult;
  final bool infinitePages;
  final bool manyItemsPerPage;
  var fetchStockPageCount = 0;

  _MockRawRepository({
    required this.queueResult,
    this.infinitePages = false,
    this.manyItemsPerPage = false,
  });

  @override
  Future<ApiResult<RawMaterialStockPage>> fetchRawMaterialStock({
    required int page,
  }) async {
    fetchStockPageCount++;
    if (infinitePages) {
      final items = List.generate(10, (i) => _stockItem(i + (page - 1) * 10));
      return ApiSuccess(
        RawMaterialStockPage(
          items: items,
          totalCount: 9999,
          page: page,
          hasNextPage: true,
        ),
      );
    }
    if (manyItemsPerPage) {
      final items = List.generate(
        3000,
        (i) => _stockItem(i + (page - 1) * 3000),
      );
      return ApiSuccess(
        RawMaterialStockPage(
          items: items,
          totalCount: 6000,
          page: page,
          hasNextPage: page == 1,
        ),
      );
    }
    switch (page) {
      case 1:
        return ApiSuccess(
          RawMaterialStockPage(
            items: [
              _stockItem(1, qty: 5),
              _stockItem(2, qty: 3),
              _stockItem(3, qty: 8),
            ],
            totalCount: 6,
            page: 1,
            hasNextPage: true,
          ),
        );
      case 2:
        return ApiSuccess(
          RawMaterialStockPage(
            items: [
              _stockItem(4, qty: 1),
              _stockItem(5, qty: 10),
              _stockItem(6, qty: 2),
            ],
            totalCount: 6,
            page: 2,
            hasNextPage: false,
          ),
        );
      default:
        return ApiSuccess(
          RawMaterialStockPage(
            items: [],
            totalCount: 6,
            page: page,
            hasNextPage: false,
          ),
        );
    }
  }

  RawMaterialStockItem _stockItem(int id, {double qty = 5}) {
    return RawMaterialStockItem(
      id: id,
      rawMaterialId: id,
      rawMaterialName: 'Material $id',
      warehouseId: 1,
      warehouseName: 'Warehouse',
      quantity: qty,
      reservedQuantity: 0,
      available: qty,
      unitName: 'kg',
    );
  }

  @override
  Future<ApiResult<ProductStockPage>> fetchProductStock({required int page}) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<RawMaterialEntryPage>> fetchWorkflowEntries({
    RawMaterialEntryStatus? status,
    bool? isInStock,
    required int page,
  }) => Future.value(queueResult);

  @override
  Future<ApiResult<bool>> recordActualWeight({
    required int batchId,
    required double measuredQuantity,
    required String measuredImagePath,
  }) => Future.value(const ApiSuccess(true));

  @override
  Future<ApiResult<List<LookupOption>>> fetchProducts({String? search}) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<List<LookupOption>>> fetchWarehouses({String? search}) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<ProductStockItem>> addProductStock(
    ProductStockDraft draft,
  ) => throw UnimplementedError();

  @override
  Future<ApiResult<List<RawMaterialEntry>>> fetchEntries({
    RawMaterialEntryStatus? status,
  }) => throw UnimplementedError();

  @override
  Future<ApiResult<RawMaterialEntryLookups>> fetchLookups() =>
      throw UnimplementedError();

  @override
  Future<ApiResult<List<LookupOption>>> fetchDrivers({String? search}) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<List<LookupOption>>> fetchPurchaseOrderDetails({
    String? search,
  }) => throw UnimplementedError();

  @override
  Future<ApiResult<List<LookupOption>>> fetchRawMaterials({String? search}) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<RawMaterialAnalysisWorkspace>> fetchAnalysisWorkspace(
    int sampleId,
  ) => throw UnimplementedError();

  @override
  Future<ApiResult<RawMaterialSamplePage>> fetchSamples({
    int? batchId,
    required int page,
  }) => throw UnimplementedError();

  @override
  Future<ApiResult<RawMaterialAnalysisWorkspace>> submitAnalysis({
    required int sampleId,
    required RawMaterialAnalysisSubmission submission,
  }) => throw UnimplementedError();

  @override
  Future<ApiResult<bool>> submitQualityDecision({
    required int batchId,
    required RawMaterialQualityDecision decision,
    String? comments,
  }) => throw UnimplementedError();

  @override
  Future<ApiResult<RawMaterialSample>> takeSample(int batchId) =>
      throw UnimplementedError();

  @override
  Future<ApiResult<RawMaterialEntry>> createEntry(
    RawMaterialEntryDraft draft,
  ) => throw UnimplementedError();
}
