import '../../../../core/errors/api_result.dart';
import '../entities/raw_material_entry.dart';
import '../entities/raw_material_entry_lookup.dart';
import '../entities/inventory_workflow.dart';
import '../entities/raw_material_workflow.dart';

abstract class RawMaterialEntryRepository {
  Future<ApiResult<List<RawMaterialEntry>>> fetchEntries({
    RawMaterialEntryStatus? status,
  });

  Future<ApiResult<List<LookupOption>>> fetchRawMaterials({String? search});

  Future<ApiResult<List<LookupOption>>> fetchProducts({String? search});

  Future<ApiResult<List<LookupOption>>> fetchWarehouses({String? search});

  Future<ApiResult<List<LookupOption>>> fetchPurchaseOrderDetails({
    String? search,
  });

  Future<ApiResult<List<LookupOption>>> fetchDrivers({String? search});

  Future<ApiResult<RawMaterialEntryLookups>> fetchLookups();

  Future<ApiResult<RawMaterialEntry>> createEntry(RawMaterialEntryDraft draft);

  Future<ApiResult<RawMaterialEntryPage>> fetchWorkflowEntries({
    RawMaterialEntryStatus? status,
    bool? isInStock,
    required int page,
  });

  Future<ApiResult<RawMaterialSample>> takeSample(int batchId);

  Future<ApiResult<RawMaterialSamplePage>> fetchSamples({
    int? batchId,
    required int page,
  });

  Future<ApiResult<RawMaterialAnalysisWorkspace>> fetchAnalysisWorkspace(
    int sampleId,
  );

  Future<ApiResult<RawMaterialAnalysisWorkspace>> submitAnalysis({
    required int sampleId,
    required RawMaterialAnalysisSubmission submission,
  });

  Future<ApiResult<bool>> submitQualityDecision({
    required int batchId,
    required RawMaterialQualityDecision decision,
    String? comments,
  });

  Future<ApiResult<bool>> recordActualWeight({
    required int batchId,
    required double measuredQuantity,
    required String measuredImagePath,
  });

  Future<ApiResult<RawMaterialStockPage>> fetchRawMaterialStock({
    required int page,
  });

  Future<ApiResult<List<ProductStockItem>>> fetchProductStock();

  Future<ApiResult<ProductStockItem>> addProductStock(ProductStockDraft draft);
}
