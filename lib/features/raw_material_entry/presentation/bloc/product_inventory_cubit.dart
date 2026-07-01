import '../../../../core/bloc/safe_cubit.dart';
import '../../../../core/errors/api_result.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/inventory_workflow.dart';
import '../../domain/entities/raw_material_entry_lookup.dart';
import '../../domain/usecases/raw_material_workflow_use_cases.dart';
import 'product_inventory_state.dart';

class ProductInventoryCubit extends SafeCubit<ProductInventoryState> {
  static const int maxInventoryPages = 50;
  static const int maxInventoryItems = 5000;

  final LoadProductStockUseCase _loadProductStock;
  final LoadProductStockLookupsUseCase _loadLookups;
  final AddProductStockUseCase _addProductStock;
  var _loadRequestId = 0;

  ProductInventoryCubit(
    this._loadProductStock,
    this._loadLookups,
    this._addProductStock,
  ) : super(const ProductInventoryInitial());

  Future<void> load({bool keepCurrentData = true}) async {
    final requestId = ++_loadRequestId;
    safeEmit(
      ProductInventoryLoading(
        productStock: keepCurrentData ? state.productStock : const [],
        products: keepCurrentData ? state.products : const [],
        warehouses: keepCurrentData ? state.warehouses : const [],
        lastLoadedAt: state.lastLoadedAt,
      ),
    );

    final allStock = await _loadAllStockPages(requestId);
    if (allStock == null) {
      return;
    }
    if (requestId != _loadRequestId) {
      return;
    }

    final wasTruncated = _wasStockTruncated(allStock);

    final productsResult = await _loadLookups.products();
    final warehousesResult = await _loadLookups.warehouses();
    if (requestId != _loadRequestId) {
      return;
    }

    switch ((productsResult, warehousesResult)) {
      case (
        ApiSuccess<List<LookupOption>>(data: final products),
        ApiSuccess<List<LookupOption>>(data: final warehouses),
      ):
        safeEmit(
          ProductInventoryLoaded(
            productStock: allStock,
            stockTotalCount: allStock.length,
            stockPage: 1,
            stockHasNextPage: false,
            stockWasTruncated: wasTruncated,
            products: products,
            warehouses: warehouses,
            lastLoadedAt: DateTime.now(),
          ),
        );
      case (ApiFailure<List<LookupOption>>(failure: final failure), _):
        _emitError(failure);
      case (_, ApiFailure<List<LookupOption>>(failure: final failure)):
        _emitError(failure);
    }
  }

  Future<List<ProductStockItem>?> _loadAllStockPages(int requestId) async {
    var allItems = <ProductStockItem>[];
    var page = 1;
    var hasNextPage = true;

    while (hasNextPage && page <= maxInventoryPages) {
      final result = await _loadProductStock(page: page);
      if (requestId != _loadRequestId) {
        return null;
      }
      switch (result) {
        case ApiFailure<ProductStockPage>(failure: final failure):
          _emitError(failure);
          return null;
        case ApiSuccess<ProductStockPage>(data: final stock):
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

  int _stockPagesLoaded = 0;

  bool _wasStockTruncated(List<ProductStockItem> items) {
    return items.length >= maxInventoryItems ||
        _stockPagesLoaded >= maxInventoryPages;
  }

  Future<bool> addFinishedProductStock(ProductStockDraft draft) async {
    _emitWorking(ProductInventoryAction.addingProductStock);
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

  void _emitWorking(ProductInventoryAction action) {
    safeEmit(
      ProductInventoryWorking(
        action: action,
        productStock: state.productStock,
        stockTotalCount: state.stockTotalCount,
        stockPage: state.stockPage,
        stockHasNextPage: state.stockHasNextPage,
        stockWasTruncated: state.stockWasTruncated,
        products: state.products,
        warehouses: state.warehouses,
        lastLoadedAt: state.lastLoadedAt,
      ),
    );
  }

  void _emitError(Failure failure) {
    safeEmit(
      ProductInventoryError(
        failure: failure,
        productStock: state.productStock,
        stockTotalCount: state.stockTotalCount,
        stockPage: state.stockPage,
        stockHasNextPage: state.stockHasNextPage,
        stockWasTruncated: state.stockWasTruncated,
        products: state.products,
        warehouses: state.warehouses,
        lastLoadedAt: state.lastLoadedAt,
      ),
    );
  }
}
