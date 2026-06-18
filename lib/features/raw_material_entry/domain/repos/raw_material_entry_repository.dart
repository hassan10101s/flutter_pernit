import '../../../../core/errors/api_result.dart';
import '../entities/raw_material_entry.dart';
import '../entities/raw_material_entry_lookup.dart';

abstract class RawMaterialEntryRepository {
  Future<ApiResult<List<RawMaterialEntry>>> fetchEntries({
    RawMaterialEntryStatus? status,
  });

  Future<ApiResult<List<LookupOption>>> fetchRawMaterials({String? search});

  Future<ApiResult<List<LookupOption>>> fetchWarehouses({String? search});

  Future<ApiResult<List<LookupOption>>> fetchPurchaseOrderDetails({
    String? search,
  });

  Future<ApiResult<List<LookupOption>>> fetchDrivers({String? search});

  Future<ApiResult<RawMaterialEntryLookups>> fetchLookups();

  Future<ApiResult<RawMaterialEntry>> createEntry(RawMaterialEntryDraft draft);
}
