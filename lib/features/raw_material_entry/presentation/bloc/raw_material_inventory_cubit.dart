import '../../../../core/bloc/safe_cubit.dart';
import '../../../../core/errors/api_result.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/inventory_workflow.dart';
import '../../domain/entities/raw_material_entry.dart';
import '../../domain/entities/raw_material_entry_lookup.dart';
import '../../domain/entities/raw_material_workflow.dart';
import '../../domain/usecases/raw_material_workflow_use_cases.dart';
import 'raw_material_inventory_state.dart';

class RawMaterialInventoryCubit extends SafeCubit<RawMaterialInventoryState> {
  final LoadRawMaterialWorkflowUseCase _loadWorkflow;
  final RecordRawMaterialActualWeightUseCase _recordActualWeight;
  final LoadRawMaterialStockUseCase _loadStock;
  final LoadProductStockUseCase _loadProductStock;
  final LoadProductStockLookupsUseCase _loadLookups;
  final AddProductStockUseCase _addProductStock;
  var _loadRequestId = 0;

  RawMaterialInventoryCubit(
    this._loadWorkflow,
    this._recordActualWeight,
    this._loadStock,
    this._loadProductStock,
    this._loadLookups,
    this._addProductStock,
  ) : super(const RawMaterialInventoryInitial());

  Future<void> load({bool keepCurrentData = true}) async {
    final requestId = ++_loadRequestId;
    safeEmit(
      RawMaterialInventoryLoading(
        entries: keepCurrentData ? state.entries : const [],
        stockItems: keepCurrentData ? state.stockItems : const [],
        productStock: keepCurrentData ? state.productStock : const [],
        products: keepCurrentData ? state.products : const [],
        warehouses: keepCurrentData ? state.warehouses : const [],
      ),
    );

    final queueResult = await _loadWorkflow(
      status: RawMaterialEntryStatus.approved,
      isInStock: false,
      page: 1,
    );
    if (requestId != _loadRequestId) {
      return;
    }
    if (queueResult case ApiFailure<RawMaterialEntryPage>(
      failure: final failure,
    )) {
      _emitError(failure);
      return;
    }

    final stockResult = await _loadStock(page: 1);
    if (requestId != _loadRequestId) {
      return;
    }
    if (stockResult case ApiFailure<RawMaterialStockPage>(
      failure: final failure,
    )) {
      _emitError(failure);
      return;
    }

    final productStockResult = await _loadProductStock();
    final productsResult = await _loadLookups.products();
    final warehousesResult = await _loadLookups.warehouses();
    if (requestId != _loadRequestId) {
      return;
    }

    switch ((productStockResult, productsResult, warehousesResult)) {
      case (
        ApiSuccess<List<ProductStockItem>>(data: final productStock),
        ApiSuccess<List<LookupOption>>(data: final products),
        ApiSuccess<List<LookupOption>>(data: final warehouses),
      ):
        final queue = (queueResult as ApiSuccess<RawMaterialEntryPage>).data;
        final stock = (stockResult as ApiSuccess<RawMaterialStockPage>).data;
        safeEmit(
          RawMaterialInventoryLoaded(
            entries: queue.entries,
            totalCount: queue.totalCount,
            page: queue.page,
            hasNextPage: queue.hasNextPage,
            stockItems: stock.items,
            stockTotalCount: stock.totalCount,
            stockPage: stock.page,
            stockHasNextPage: stock.hasNextPage,
            productStock: productStock,
            products: products,
            warehouses: warehouses,
          ),
        );
      case (ApiFailure<List<ProductStockItem>>(failure: final failure), _, _):
        _emitError(failure);
      case (_, ApiFailure<List<LookupOption>>(failure: final failure), _):
        _emitError(failure);
      case (_, _, ApiFailure<List<LookupOption>>(failure: final failure)):
        _emitError(failure);
    }
  }

  Future<void> loadMoreQueue() async {
    if (!state.hasNextPage || state is RawMaterialInventoryLoadingMore) {
      return;
    }
    safeEmit(_loadingMore(loadingStock: false));
    final result = await _loadWorkflow(
      status: RawMaterialEntryStatus.approved,
      isInStock: false,
      page: state.page + 1,
    );
    switch (result) {
      case ApiSuccess<RawMaterialEntryPage>(data: final page):
        _emitLoaded(
          entries: _mergeEntries(state.entries, page.entries),
          totalCount: page.totalCount,
          page: page.page,
          hasNextPage: page.hasNextPage,
        );
      case ApiFailure<RawMaterialEntryPage>(failure: final failure):
        _emitError(failure);
    }
  }

  Future<void> loadMoreStock() async {
    if (!state.stockHasNextPage || state is RawMaterialInventoryLoadingMore) {
      return;
    }
    safeEmit(_loadingMore(loadingStock: true));
    final result = await _loadStock(page: state.stockPage + 1);
    switch (result) {
      case ApiSuccess<RawMaterialStockPage>(data: final page):
        _emitLoaded(
          stockItems: _mergeStock(state.stockItems, page.items),
          stockTotalCount: page.totalCount,
          stockPage: page.page,
          stockHasNextPage: page.hasNextPage,
        );
      case ApiFailure<RawMaterialStockPage>(failure: final failure):
        _emitError(failure);
    }
  }

  Future<bool> recordActualWeight({
    required int batchId,
    required double measuredQuantity,
    required String measuredImagePath,
  }) async {
    _emitWorking(
      RawMaterialInventoryAction.recordingWeight,
      activeBatchId: batchId,
    );
    final result = await _recordActualWeight(
      batchId: batchId,
      measuredQuantity: measuredQuantity,
      measuredImagePath: measuredImagePath,
    );
    switch (result) {
      case ApiSuccess<bool>():
        await load();
        return true;
      case ApiFailure<bool>(failure: final failure):
        _emitError(failure, activeBatchId: batchId);
        return false;
    }
  }

  Future<bool> addFinishedProductStock(ProductStockDraft draft) async {
    _emitWorking(RawMaterialInventoryAction.addingProductStock);
    final result = await _addProductStock(draft);
    switch (result) {
      case ApiSuccess<ProductStockItem>():
        await load();
        return true;
      case ApiFailure<ProductStockItem>(failure: final failure):
        _emitError(failure);
        return false;
    }
  }

  RawMaterialInventoryLoadingMore _loadingMore({required bool loadingStock}) {
    return RawMaterialInventoryLoadingMore(
      loadingStock: loadingStock,
      entries: state.entries,
      totalCount: state.totalCount,
      page: state.page,
      hasNextPage: state.hasNextPage,
      stockItems: state.stockItems,
      stockTotalCount: state.stockTotalCount,
      stockPage: state.stockPage,
      stockHasNextPage: state.stockHasNextPage,
      productStock: state.productStock,
      products: state.products,
      warehouses: state.warehouses,
    );
  }

  void _emitLoaded({
    List<RawMaterialEntry>? entries,
    int? totalCount,
    int? page,
    bool? hasNextPage,
    List<RawMaterialStockItem>? stockItems,
    int? stockTotalCount,
    int? stockPage,
    bool? stockHasNextPage,
  }) {
    safeEmit(
      RawMaterialInventoryLoaded(
        entries: entries ?? state.entries,
        totalCount: totalCount ?? state.totalCount,
        page: page ?? state.page,
        hasNextPage: hasNextPage ?? state.hasNextPage,
        stockItems: stockItems ?? state.stockItems,
        stockTotalCount: stockTotalCount ?? state.stockTotalCount,
        stockPage: stockPage ?? state.stockPage,
        stockHasNextPage: stockHasNextPage ?? state.stockHasNextPage,
        productStock: state.productStock,
        products: state.products,
        warehouses: state.warehouses,
      ),
    );
  }

  void _emitWorking(RawMaterialInventoryAction action, {int? activeBatchId}) {
    safeEmit(
      RawMaterialInventoryWorking(
        action: action,
        entries: state.entries,
        totalCount: state.totalCount,
        page: state.page,
        hasNextPage: state.hasNextPage,
        stockItems: state.stockItems,
        stockTotalCount: state.stockTotalCount,
        stockPage: state.stockPage,
        stockHasNextPage: state.stockHasNextPage,
        productStock: state.productStock,
        products: state.products,
        warehouses: state.warehouses,
        activeBatchId: activeBatchId,
      ),
    );
  }

  void _emitError(Failure failure, {int? activeBatchId}) {
    safeEmit(
      RawMaterialInventoryError(
        failure: failure,
        entries: state.entries,
        totalCount: state.totalCount,
        page: state.page,
        hasNextPage: state.hasNextPage,
        stockItems: state.stockItems,
        stockTotalCount: state.stockTotalCount,
        stockPage: state.stockPage,
        stockHasNextPage: state.stockHasNextPage,
        productStock: state.productStock,
        products: state.products,
        warehouses: state.warehouses,
        activeBatchId: activeBatchId,
      ),
    );
  }

  List<RawMaterialEntry> _mergeEntries(
    List<RawMaterialEntry> current,
    List<RawMaterialEntry> incoming,
  ) {
    final byId = {for (final entry in current) entry.id: entry};
    for (final entry in incoming) {
      byId[entry.id] = entry;
    }
    return byId.values.toList(growable: false);
  }

  List<RawMaterialStockItem> _mergeStock(
    List<RawMaterialStockItem> current,
    List<RawMaterialStockItem> incoming,
  ) {
    final byId = {for (final item in current) item.id: item};
    for (final item in incoming) {
      byId[item.id] = item;
    }
    return byId.values.toList(growable: false);
  }
}
