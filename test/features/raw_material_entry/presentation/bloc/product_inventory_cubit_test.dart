import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_pernit/core/errors/api_result.dart';
import 'package:flutter_pernit/features/raw_material_entry/domain/entities/inventory_workflow.dart';
import 'package:flutter_pernit/features/raw_material_entry/domain/entities/raw_material_entry.dart';
import 'package:flutter_pernit/features/raw_material_entry/domain/entities/raw_material_entry_lookup.dart';
import 'package:flutter_pernit/features/raw_material_entry/domain/entities/raw_material_workflow.dart';
import 'package:flutter_pernit/features/raw_material_entry/domain/repos/raw_material_entry_repository.dart';
import 'package:flutter_pernit/features/raw_material_entry/domain/usecases/raw_material_workflow_use_cases.dart';
import 'package:flutter_pernit/features/raw_material_entry/presentation/bloc/product_inventory_cubit.dart';
import 'package:flutter_pernit/features/raw_material_entry/presentation/bloc/product_inventory_state.dart';

void main() {
  test(
    'loads all stock pages and sorts by available quantity descending',
    () async {
      final repository = _MockProductRepository(
        productsResult: const ApiSuccess([]),
        warehousesResult: const ApiSuccess([]),
      );
      final cubit = _cubit(repository);

      await cubit.load();

      final state = cubit.state;
      expect(state, isA<ProductInventoryLoaded>());
      final loaded = state as ProductInventoryLoaded;
      expect(loaded.productStock.length, 6);
      for (var i = 1; i < loaded.productStock.length; i++) {
        expect(
          loaded.productStock[i - 1].availableQuantity >=
              loaded.productStock[i].availableQuantity,
          isTrue,
        );
      }
      expect(loaded.stockHasNextPage, false);
      expect(loaded.lastLoadedAt, isNotNull);
      await cubit.close();
    },
  );

  test('stops at maxInventoryPages guard without infinite loop', () async {
    final repository = _MockProductRepository(
      productsResult: const ApiSuccess([]),
      warehousesResult: const ApiSuccess([]),
      infinitePages: true,
    );
    final cubit = _cubit(repository);

    await cubit.load();

    final state = cubit.state;
    expect(
      repository.fetchProductStockPageCount <=
          ProductInventoryCubit.maxInventoryPages,
      isTrue,
    );
    expect(state, isA<ProductInventoryLoaded>());
    final loaded = state as ProductInventoryLoaded;
    expect(loaded.stockWasTruncated, isTrue);
    await cubit.close();
  });

  test(
    'stops at maxInventoryItems guard without loading infinite pages',
    () async {
      final repository = _MockProductRepository(
        productsResult: const ApiSuccess([]),
        warehousesResult: const ApiSuccess([]),
        manyItemsPerPage: true,
        infinitePages: false,
      );
      final cubit = _cubit(repository);

      await cubit.load();

      final state = cubit.state;
      expect(state, isA<ProductInventoryLoaded>());
      final loaded = state as ProductInventoryLoaded;
      expect(loaded.productStock.length, greaterThan(3000));
      expect(loaded.stockWasTruncated, isTrue);
      expect(
        repository.fetchProductStockPageCount,
        lessThan(ProductInventoryCubit.maxInventoryPages),
      );
      await cubit.close();
    },
  );
}

ProductInventoryCubit _cubit(_MockProductRepository repository) {
  return ProductInventoryCubit(
    LoadProductStockUseCase(repository),
    LoadProductStockLookupsUseCase(repository),
    AddProductStockUseCase(repository),
  );
}

class _MockProductRepository implements RawMaterialEntryRepository {
  final ApiResult<List<LookupOption>> productsResult;
  final ApiResult<List<LookupOption>> warehousesResult;
  final bool infinitePages;
  final bool manyItemsPerPage;
  var fetchProductStockPageCount = 0;

  _MockProductRepository({
    required this.productsResult,
    required this.warehousesResult,
    this.infinitePages = false,
    this.manyItemsPerPage = false,
  });

  @override
  Future<ApiResult<ProductStockPage>> fetchProductStock({
    required int page,
  }) async {
    fetchProductStockPageCount++;
    if (infinitePages) {
      final items = List.generate(10, (i) => _item(i + (page - 1) * 10));
      return ApiSuccess(
        ProductStockPage(
          items: items,
          totalCount: 9999,
          page: page,
          hasNextPage: true,
        ),
      );
    }
    if (manyItemsPerPage) {
      final items = List.generate(3000, (i) => _item(i + (page - 1) * 3000));
      return ApiSuccess(
        ProductStockPage(
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
          ProductStockPage(
            items: [_item(1, qty: 5), _item(2, qty: 3), _item(3, qty: 8)],
            totalCount: 6,
            page: 1,
            hasNextPage: true,
          ),
        );
      case 2:
        return ApiSuccess(
          ProductStockPage(
            items: [_item(4, qty: 1), _item(5, qty: 10), _item(6, qty: 2)],
            totalCount: 6,
            page: 2,
            hasNextPage: false,
          ),
        );
      default:
        return ApiSuccess(
          ProductStockPage(
            items: [],
            totalCount: 6,
            page: page,
            hasNextPage: false,
          ),
        );
    }
  }

  ProductStockItem _item(int id, {double qty = 5}) {
    return ProductStockItem(
      id: id,
      productId: id,
      productName: 'Product $id',
      warehouseId: 1,
      warehouseName: 'Warehouse',
      quantity: qty,
      reservedQuantity: 0,
      available: qty,
      unitName: 'kg',
    );
  }

  @override
  Future<ApiResult<List<LookupOption>>> fetchProducts({String? search}) =>
      Future.value(productsResult);

  @override
  Future<ApiResult<List<LookupOption>>> fetchWarehouses({String? search}) =>
      Future.value(warehousesResult);

  @override
  Future<ApiResult<ProductStockItem>> addProductStock(
    ProductStockDraft draft,
  ) => throw UnimplementedError();

  @override
  Future<ApiResult<RawMaterialEntryPage>> fetchWorkflowEntries({
    RawMaterialEntryStatus? status,
    bool? isInStock,
    required int page,
  }) => throw UnimplementedError();

  @override
  Future<ApiResult<bool>> recordActualWeight({
    required int batchId,
    required double measuredQuantity,
    required String measuredImagePath,
  }) => throw UnimplementedError();

  @override
  Future<ApiResult<RawMaterialStockPage>> fetchRawMaterialStock({
    required int page,
  }) => throw UnimplementedError();

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
