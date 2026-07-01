import '../../../../core/bloc/safe_cubit.dart';
import '../../../../core/errors/api_result.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/inventory_workflow.dart';
import '../../domain/entities/raw_material_entry.dart';
import '../../domain/entities/raw_material_workflow.dart';
import '../../domain/usecases/raw_material_workflow_use_cases.dart';
import 'raw_material_inventory_state.dart';

class RawMaterialInventoryCubit extends SafeCubit<RawMaterialInventoryState> {
  static const int maxInventoryPages = 50;
  static const int maxInventoryItems = 5000;

  final LoadRawMaterialWorkflowUseCase _loadWorkflow;
  final RecordRawMaterialActualWeightUseCase _recordActualWeight;
  final LoadRawMaterialStockUseCase _loadStock;
  var _loadRequestId = 0;

  RawMaterialInventoryCubit(
    this._loadWorkflow,
    this._recordActualWeight,
    this._loadStock,
  ) : super(const RawMaterialInventoryInitial());

  Future<void> load({bool keepCurrentData = true}) async {
    final requestId = ++_loadRequestId;
    safeEmit(
      RawMaterialInventoryLoading(
        entries: keepCurrentData ? state.entries : const [],
        stockItems: keepCurrentData ? state.stockItems : const [],
        lastLoadedAt: state.lastLoadedAt,
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

    final allStock = await _loadAllStockPages(requestId);
    if (allStock == null) {
      return;
    }
    if (requestId != _loadRequestId) {
      return;
    }

    final wasTruncated = _wasStockTruncated(allStock);
    final queue = (queueResult as ApiSuccess<RawMaterialEntryPage>).data;

    safeEmit(
      RawMaterialInventoryLoaded(
        entries: queue.entries,
        totalCount: queue.totalCount,
        page: queue.page,
        hasNextPage: queue.hasNextPage,
        stockItems: allStock,
        stockTotalCount: allStock.length,
        stockPage: 1,
        stockHasNextPage: false,
        stockWasTruncated: wasTruncated,
        lastLoadedAt: DateTime.now(),
      ),
    );
  }

  int _stockPagesLoaded = 0;

  bool _wasStockTruncated(List<RawMaterialStockItem> items) {
    return items.length >= maxInventoryItems ||
        _stockPagesLoaded >= maxInventoryPages;
  }

  Future<List<RawMaterialStockItem>?> _loadAllStockPages(int requestId) async {
    var allItems = <RawMaterialStockItem>[];
    var page = 1;
    var hasNextPage = true;

    while (hasNextPage && page <= maxInventoryPages) {
      final result = await _loadStock(page: page);
      if (requestId != _loadRequestId) {
        return null;
      }
      switch (result) {
        case ApiFailure<RawMaterialStockPage>(failure: final failure):
          _emitError(failure);
          return null;
        case ApiSuccess<RawMaterialStockPage>(data: final stock):
          allItems.addAll(stock.items);
          if (allItems.length >= maxInventoryItems) {
            hasNextPage = false;
          } else {
            hasNextPage = stock.hasNextPage;
          }
          page++;
      }
    }

    _stockPagesLoaded = page - 1;
    allItems.sort((a, b) => b.availableQuantity.compareTo(a.availableQuantity));
    return allItems;
  }

  Future<void> loadMoreQueue() async {
    if (!state.hasNextPage || state is RawMaterialInventoryLoadingMore) {
      return;
    }
    safeEmit(_loadingMore());
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

  RawMaterialInventoryLoadingMore _loadingMore() {
    return RawMaterialInventoryLoadingMore(
      entries: state.entries,
      totalCount: state.totalCount,
      page: state.page,
      hasNextPage: state.hasNextPage,
      stockItems: state.stockItems,
      stockTotalCount: state.stockTotalCount,
      stockPage: state.stockPage,
      stockHasNextPage: state.stockHasNextPage,
      stockWasTruncated: state.stockWasTruncated,
      lastLoadedAt: state.lastLoadedAt,
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
        stockWasTruncated: state.stockWasTruncated,
        lastLoadedAt: state.lastLoadedAt ?? DateTime.now(),
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
        stockWasTruncated: state.stockWasTruncated,
        activeBatchId: activeBatchId,
        lastLoadedAt: state.lastLoadedAt,
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
        stockWasTruncated: state.stockWasTruncated,
        activeBatchId: activeBatchId,
        lastLoadedAt: state.lastLoadedAt,
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
}
