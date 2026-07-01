import '../../../../core/bloc/safe_cubit.dart';
import '../../../../core/errors/api_result.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/production_lab_sample.dart';
import '../../domain/entities/production_lab_result.dart';
import '../../domain/entities/production_quality_check.dart';
import '../../domain/usecases/create_production_lab_result_use_case.dart';
import '../../domain/usecases/create_production_lab_sample_use_case.dart';
import '../../domain/usecases/load_production_lab_results_use_case.dart';
import '../../domain/usecases/load_production_lab_samples_use_case.dart';
import '../../domain/usecases/load_production_quality_checks_use_case.dart';
import 'production_quality_state.dart';

class ProductionQualityCubit extends SafeCubit<ProductionQualityState> {
  final LoadProductionLabSamplesUseCase _loadSamples;
  final CreateProductionLabSampleUseCase _createSample;
  final LoadProductionLabResultsUseCase _loadResults;
  final CreateProductionLabResultUseCase _createResult;
  final LoadProductionQualityChecksUseCase _loadChecks;

  ProductionQualityCubit(
    this._loadSamples,
    this._createSample,
    this._loadResults,
    this._createResult,
    this._loadChecks,
  ) : super(const ProductionQualityInitial());

  Future<void> loadAll() async {
    safeEmit(const ProductionQualityLoading());

    final results = await Future.wait([
      _loadSamples(page: 1),
      _loadResults(page: 1),
      _loadChecks(page: 1),
    ]);

    final samplesResult = results[0] as ApiResult<ProductionLabSamplePage>;
    final resultsResult = results[1] as ApiResult<ProductionLabResultPage>;
    final checksResult = results[2] as ApiResult<ProductionQualityCheckPage>;

    switch ((samplesResult, resultsResult, checksResult)) {
      case (
        ApiSuccess<ProductionLabSamplePage>(data: final samplesPage),
        ApiSuccess<ProductionLabResultPage>(data: final resultsPage),
        ApiSuccess<ProductionQualityCheckPage>(data: final checksPage),
      ):
        safeEmit(
          ProductionQualityLoaded(
            samples: samplesPage.items,
            samplesTotalCount: samplesPage.totalCount,
            samplesPage: samplesPage.page,
            samplesHasMore: samplesPage.hasMore,
            results: resultsPage.items,
            resultsTotalCount: resultsPage.totalCount,
            resultsPage: resultsPage.page,
            resultsHasMore: resultsPage.hasMore,
            checks: checksPage.items,
            checksTotalCount: checksPage.totalCount,
            checksPage: checksPage.page,
            checksHasMore: checksPage.hasMore,
          ),
        );
      case (ApiFailure(:final failure), _, _):
        _emitError(failure);
      case (_, ApiFailure(:final failure), _):
        _emitError(failure);
      case (_, _, ApiFailure(:final failure)):
        _emitError(failure);
    }
  }

  Future<void> loadSamples() async {
    safeEmit(_tabLoading(isLoadingSamples: true));

    final result = await _loadSamples(page: 1);
    switch (result) {
      case ApiSuccess<ProductionLabSamplePage>(data: final page):
        safeEmit(
          _loaded(
            samples: page.items,
            samplesTotalCount: page.totalCount,
            samplesPage: page.page,
            samplesHasMore: page.hasMore,
          ),
        );
      case ApiFailure<ProductionLabSamplePage>(failure: final failure):
        _emitError(failure);
    }
  }

  Future<void> loadMoreSamples() async {
    if (!state.samplesHasMore || state.isLoadingSamples) return;

    safeEmit(_tabLoading(isLoadingSamples: true));
    final result = await _loadSamples(page: state.samplesPage + 1);
    switch (result) {
      case ApiSuccess<ProductionLabSamplePage>(data: final page):
        safeEmit(
          _loaded(
            samples: [...state.samples, ...page.items],
            samplesTotalCount: page.totalCount,
            samplesPage: page.page,
            samplesHasMore: page.hasMore,
          ),
        );
      case ApiFailure<ProductionLabSamplePage>(failure: final failure):
        _emitError(failure);
    }
  }

  Future<bool> createSample({
    required int productionOrderId,
    String? quantityTaken,
  }) async {
    safeEmit(
      ProductionQualityCreating(
        samples: state.samples,
        samplesTotalCount: state.samplesTotalCount,
        samplesPage: state.samplesPage,
        samplesHasMore: state.samplesHasMore,
        results: state.results,
        resultsTotalCount: state.resultsTotalCount,
        resultsPage: state.resultsPage,
        resultsHasMore: state.resultsHasMore,
        checks: state.checks,
        checksTotalCount: state.checksTotalCount,
        checksPage: state.checksPage,
        checksHasMore: state.checksHasMore,
        isCreatingSample: true,
        creatingSampleOrderId: productionOrderId,
      ),
    );

    final result = await _createSample(
      productionOrderId,
      quantityTaken: quantityTaken,
    );
    switch (result) {
      case ApiSuccess<ProductionLabSample>():
        await loadSamples();
        return true;
      case ApiFailure<ProductionLabSample>(failure: final failure):
        _emitError(failure);
        return false;
    }
  }

  Future<void> loadResults() async {
    safeEmit(_tabLoading(isLoadingResults: true));

    final result = await _loadResults(page: 1);
    switch (result) {
      case ApiSuccess<ProductionLabResultPage>(data: final page):
        safeEmit(
          _loaded(
            results: page.items,
            resultsTotalCount: page.totalCount,
            resultsPage: page.page,
            resultsHasMore: page.hasMore,
          ),
        );
      case ApiFailure<ProductionLabResultPage>(failure: final failure):
        _emitError(failure);
    }
  }

  Future<void> loadMoreResults() async {
    if (!state.resultsHasMore || state.isLoadingResults) return;

    safeEmit(_tabLoading(isLoadingResults: true));
    final result = await _loadResults(page: state.resultsPage + 1);
    switch (result) {
      case ApiSuccess<ProductionLabResultPage>(data: final page):
        safeEmit(
          _loaded(
            results: [...state.results, ...page.items],
            resultsTotalCount: page.totalCount,
            resultsPage: page.page,
            resultsHasMore: page.hasMore,
          ),
        );
      case ApiFailure<ProductionLabResultPage>(failure: final failure):
        _emitError(failure);
    }
  }

  Future<bool> createResult({
    required int sampleId,
    required int parameterId,
    required String value,
  }) async {
    safeEmit(
      ProductionQualityCreating(
        samples: state.samples,
        samplesTotalCount: state.samplesTotalCount,
        samplesPage: state.samplesPage,
        samplesHasMore: state.samplesHasMore,
        results: state.results,
        resultsTotalCount: state.resultsTotalCount,
        resultsPage: state.resultsPage,
        resultsHasMore: state.resultsHasMore,
        checks: state.checks,
        checksTotalCount: state.checksTotalCount,
        checksPage: state.checksPage,
        checksHasMore: state.checksHasMore,
        isCreatingResult: true,
      ),
    );

    final result = await _createResult(
      sampleId: sampleId,
      parameterId: parameterId,
      value: value,
    );
    switch (result) {
      case ApiSuccess<ProductionLabResult>():
        await loadResults();
        return true;
      case ApiFailure<ProductionLabResult>(failure: final failure):
        _emitError(failure);
        return false;
    }
  }

  Future<void> loadChecks() async {
    safeEmit(_tabLoading(isLoadingChecks: true));

    final result = await _loadChecks(page: 1);
    switch (result) {
      case ApiSuccess<ProductionQualityCheckPage>(data: final page):
        safeEmit(
          _loaded(
            checks: page.items,
            checksTotalCount: page.totalCount,
            checksPage: page.page,
            checksHasMore: page.hasMore,
          ),
        );
      case ApiFailure<ProductionQualityCheckPage>(failure: final failure):
        _emitError(failure);
    }
  }

  Future<void> loadMoreChecks() async {
    if (!state.checksHasMore || state.isLoadingChecks) return;

    safeEmit(_tabLoading(isLoadingChecks: true));
    final result = await _loadChecks(page: state.checksPage + 1);
    switch (result) {
      case ApiSuccess<ProductionQualityCheckPage>(data: final page):
        safeEmit(
          _loaded(
            checks: [...state.checks, ...page.items],
            checksTotalCount: page.totalCount,
            checksPage: page.page,
            checksHasMore: page.hasMore,
          ),
        );
      case ApiFailure<ProductionQualityCheckPage>(failure: final failure):
        _emitError(failure);
    }
  }

  ProductionQualityTabLoading _tabLoading({
    bool isLoadingSamples = false,
    bool isLoadingResults = false,
    bool isLoadingChecks = false,
  }) {
    return ProductionQualityTabLoading(
      samples: state.samples,
      samplesTotalCount: state.samplesTotalCount,
      samplesPage: state.samplesPage,
      samplesHasMore: state.samplesHasMore,
      results: state.results,
      resultsTotalCount: state.resultsTotalCount,
      resultsPage: state.resultsPage,
      resultsHasMore: state.resultsHasMore,
      checks: state.checks,
      checksTotalCount: state.checksTotalCount,
      checksPage: state.checksPage,
      checksHasMore: state.checksHasMore,
      isLoadingSamples: isLoadingSamples,
      isLoadingResults: isLoadingResults,
      isLoadingChecks: isLoadingChecks,
    );
  }

  ProductionQualityLoaded _loaded({
    List<ProductionLabSample>? samples,
    int? samplesTotalCount,
    int? samplesPage,
    bool? samplesHasMore,
    List<ProductionLabResult>? results,
    int? resultsTotalCount,
    int? resultsPage,
    bool? resultsHasMore,
    List<ProductionQualityCheck>? checks,
    int? checksTotalCount,
    int? checksPage,
    bool? checksHasMore,
  }) {
    return ProductionQualityLoaded(
      samples: samples ?? state.samples,
      samplesTotalCount: samplesTotalCount ?? state.samplesTotalCount,
      samplesPage: samplesPage ?? state.samplesPage,
      samplesHasMore: samplesHasMore ?? state.samplesHasMore,
      results: results ?? state.results,
      resultsTotalCount: resultsTotalCount ?? state.resultsTotalCount,
      resultsPage: resultsPage ?? state.resultsPage,
      resultsHasMore: resultsHasMore ?? state.resultsHasMore,
      checks: checks ?? state.checks,
      checksTotalCount: checksTotalCount ?? state.checksTotalCount,
      checksPage: checksPage ?? state.checksPage,
      checksHasMore: checksHasMore ?? state.checksHasMore,
    );
  }

  void _emitError(Failure failure) {
    safeEmit(
      ProductionQualityError(
        failure: failure,
        samples: state.samples,
        samplesTotalCount: state.samplesTotalCount,
        samplesPage: state.samplesPage,
        samplesHasMore: state.samplesHasMore,
        results: state.results,
        resultsTotalCount: state.resultsTotalCount,
        resultsPage: state.resultsPage,
        resultsHasMore: state.resultsHasMore,
        checks: state.checks,
        checksTotalCount: state.checksTotalCount,
        checksPage: state.checksPage,
        checksHasMore: state.checksHasMore,
      ),
    );
  }
}
