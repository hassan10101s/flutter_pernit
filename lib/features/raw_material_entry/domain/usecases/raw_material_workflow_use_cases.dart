import '../../../../core/errors/api_result.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/errors/failure_code.dart';
import '../entities/raw_material_entry.dart';
import '../entities/raw_material_entry_lookup.dart';
import '../entities/inventory_workflow.dart';
import '../entities/raw_material_workflow.dart';
import '../repos/raw_material_entry_repository.dart';

class LoadRawMaterialWorkflowUseCase {
  final RawMaterialEntryRepository _repository;

  const LoadRawMaterialWorkflowUseCase(this._repository);

  Future<ApiResult<RawMaterialEntryPage>> call({
    RawMaterialEntryStatus? status,
    bool? isInStock,
    required int page,
  }) {
    return _repository.fetchWorkflowEntries(
      status: status,
      isInStock: isInStock,
      page: page,
    );
  }
}

class TakeRawMaterialSampleUseCase {
  final RawMaterialEntryRepository _repository;

  const TakeRawMaterialSampleUseCase(this._repository);

  Future<ApiResult<RawMaterialSample>> call(int batchId) {
    return _repository.takeSample(batchId);
  }
}

class LoadRawMaterialAnalysisUseCase {
  final RawMaterialEntryRepository _repository;

  const LoadRawMaterialAnalysisUseCase(this._repository);

  Future<ApiResult<RawMaterialAnalysisWorkspace>> call(int sampleId) {
    return _repository.fetchAnalysisWorkspace(sampleId);
  }
}

class LoadRawMaterialSamplesUseCase {
  final RawMaterialEntryRepository _repository;

  const LoadRawMaterialSamplesUseCase(this._repository);

  Future<ApiResult<RawMaterialSamplePage>> call({
    int? batchId,
    required int page,
  }) {
    return _repository.fetchSamples(batchId: batchId, page: page);
  }
}

class SubmitRawMaterialAnalysisUseCase {
  final RawMaterialEntryRepository _repository;

  const SubmitRawMaterialAnalysisUseCase(this._repository);

  Future<ApiResult<RawMaterialAnalysisWorkspace>> call({
    required RawMaterialAnalysisWorkspace workspace,
    required RawMaterialAnalysisSubmission submission,
  }) {
    if (!submission.matches(workspace)) {
      return Future.value(
        const ApiFailure(
          Failure(
            code: FailureCode.validation,
            messageKey: 'failureValidation',
          ),
        ),
      );
    }
    return _repository.submitAnalysis(
      sampleId: workspace.sample.id,
      submission: submission,
    );
  }
}

class SubmitRawMaterialQualityDecisionUseCase {
  final RawMaterialEntryRepository _repository;

  const SubmitRawMaterialQualityDecisionUseCase(this._repository);

  Future<ApiResult<bool>> call({
    required int batchId,
    required RawMaterialQualityDecision decision,
    String? comments,
  }) {
    return _repository.submitQualityDecision(
      batchId: batchId,
      decision: decision,
      comments: comments,
    );
  }
}

class RecordRawMaterialActualWeightUseCase {
  final RawMaterialEntryRepository _repository;

  const RecordRawMaterialActualWeightUseCase(this._repository);

  Future<ApiResult<bool>> call({
    required int batchId,
    required double measuredQuantity,
    required String measuredImagePath,
  }) {
    return _repository.recordActualWeight(
      batchId: batchId,
      measuredQuantity: measuredQuantity,
      measuredImagePath: measuredImagePath,
    );
  }
}

class LoadRawMaterialStockUseCase {
  final RawMaterialEntryRepository _repository;

  const LoadRawMaterialStockUseCase(this._repository);

  Future<ApiResult<RawMaterialStockPage>> call({required int page}) {
    return _repository.fetchRawMaterialStock(page: page);
  }
}

class LoadProductStockUseCase {
  final RawMaterialEntryRepository _repository;

  const LoadProductStockUseCase(this._repository);

  Future<ApiResult<List<ProductStockItem>>> call() {
    return _repository.fetchProductStock();
  }
}

class LoadProductStockLookupsUseCase {
  final RawMaterialEntryRepository _repository;

  const LoadProductStockLookupsUseCase(this._repository);

  Future<ApiResult<List<LookupOption>>> products() {
    return _repository.fetchProducts();
  }

  Future<ApiResult<List<LookupOption>>> warehouses() {
    return _repository.fetchWarehouses();
  }
}

class AddProductStockUseCase {
  final RawMaterialEntryRepository _repository;

  const AddProductStockUseCase(this._repository);

  Future<ApiResult<ProductStockItem>> call(ProductStockDraft draft) {
    if (!draft.isValid) {
      return Future.value(
        const ApiFailure(
          Failure(
            code: FailureCode.validation,
            messageKey: 'failureValidation',
          ),
        ),
      );
    }
    return _repository.addProductStock(draft);
  }
}
