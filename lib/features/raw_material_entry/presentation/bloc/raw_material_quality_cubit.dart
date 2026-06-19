import '../../../../core/bloc/safe_cubit.dart';
import '../../../../core/errors/api_result.dart';
import '../../../../core/errors/failure.dart';
import '../../domain/entities/raw_material_entry.dart';
import '../../domain/entities/raw_material_workflow.dart';
import '../../domain/usecases/raw_material_workflow_use_cases.dart';
import 'raw_material_quality_state.dart';

class RawMaterialQualityCubit extends SafeCubit<RawMaterialQualityState> {
  final LoadRawMaterialWorkflowUseCase _loadWorkflow;
  final LoadRawMaterialSamplesUseCase _loadSamples;
  final TakeRawMaterialSampleUseCase _takeSample;
  final LoadRawMaterialAnalysisUseCase _loadAnalysis;
  final SubmitRawMaterialAnalysisUseCase _submitAnalysis;
  final SubmitRawMaterialQualityDecisionUseCase _submitDecision;
  var _loadRequestId = 0;

  RawMaterialQualityCubit(
    this._loadWorkflow,
    this._loadSamples,
    this._takeSample,
    this._loadAnalysis,
    this._submitAnalysis,
    this._submitDecision,
  ) : super(const RawMaterialQualityInitial());

  Future<void> load({bool keepCurrentData = true}) async {
    final requestId = ++_loadRequestId;
    safeEmit(
      RawMaterialQualityLoading(
        entries: keepCurrentData ? state.entries : const [],
        samples: keepCurrentData ? state.samples : const [],
      ),
    );

    final entriesResult = await _loadWorkflow(page: 1, isInStock: false);
    if (requestId != _loadRequestId) {
      return;
    }
    final samplesResult = await _loadSamples(page: 1);
    if (requestId != _loadRequestId) {
      return;
    }

    switch ((entriesResult, samplesResult)) {
      case (
        ApiSuccess<RawMaterialEntryPage>(data: final entriesPage),
        ApiSuccess<RawMaterialSamplePage>(data: final samplesPage),
      ):
        safeEmit(
          RawMaterialQualityLoaded(
            entries: entriesPage.entries,
            totalCount: entriesPage.totalCount,
            page: entriesPage.page,
            hasNextPage: entriesPage.hasNextPage,
            samples: samplesPage.samples,
            sampleTotalCount: samplesPage.totalCount,
            samplePage: samplesPage.page,
            samplesHaveNextPage: samplesPage.hasNextPage,
          ),
        );
      case (ApiFailure<RawMaterialEntryPage>(failure: final failure), _):
        _emitError(failure);
      case (_, ApiFailure<RawMaterialSamplePage>(failure: final failure)):
        _emitError(failure);
    }
  }

  Future<void> loadMoreEntries() async {
    if (!state.hasNextPage || state is RawMaterialQualityLoadingMore) {
      return;
    }
    safeEmit(_loadingMore(loadingSamples: false));
    final result = await _loadWorkflow(page: state.page + 1, isInStock: false);
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

  Future<void> loadMoreSamples() async {
    if (!state.samplesHaveNextPage || state is RawMaterialQualityLoadingMore) {
      return;
    }
    safeEmit(_loadingMore(loadingSamples: true));
    final result = await _loadSamples(page: state.samplePage + 1);
    switch (result) {
      case ApiSuccess<RawMaterialSamplePage>(data: final page):
        _emitLoaded(
          samples: _mergeSamples(state.samples, page.samples),
          sampleTotalCount: page.totalCount,
          samplePage: page.page,
          samplesHaveNextPage: page.hasNextPage,
        );
      case ApiFailure<RawMaterialSamplePage>(failure: final failure):
        _emitError(failure);
    }
  }

  Future<bool> takeSample(int batchId) async {
    _emitWorking(RawMaterialQualityAction.takingSample, activeBatchId: batchId);
    final result = await _takeSample(batchId);
    switch (result) {
      case ApiSuccess<RawMaterialSample>():
        await load();
        return true;
      case ApiFailure<RawMaterialSample>(failure: final failure):
        _emitError(failure, activeBatchId: batchId);
        return false;
    }
  }

  Future<bool> openAnalysis({
    required int sampleId,
    required int batchId,
  }) async {
    _emitWorking(
      RawMaterialQualityAction.loadingAnalysis,
      activeBatchId: batchId,
      activeSampleId: sampleId,
    );
    final result = await _loadAnalysis(sampleId);
    switch (result) {
      case ApiSuccess<RawMaterialAnalysisWorkspace>(data: final workspace):
        safeEmit(
          _workspaceReady(
            activeBatchId: batchId,
            activeSampleId: sampleId,
            workspace: workspace,
          ),
        );
        return true;
      case ApiFailure<RawMaterialAnalysisWorkspace>(failure: final failure):
        _emitError(failure, activeBatchId: batchId, activeSampleId: sampleId);
        return false;
    }
  }

  Future<bool> openDecision(int batchId) async {
    _emitWorking(
      RawMaterialQualityAction.loadingDecision,
      activeBatchId: batchId,
    );
    final samplesResult = await _loadEverySampleForBatch(batchId);
    if (samplesResult case ApiFailure<List<RawMaterialSample>>(
      failure: final failure,
    )) {
      _emitError(failure, activeBatchId: batchId);
      return false;
    }

    final samples = (samplesResult as ApiSuccess<List<RawMaterialSample>>).data;
    final workspaces = <RawMaterialAnalysisWorkspace>[];
    for (final sample in samples) {
      final result = await _loadAnalysis(sample.id);
      switch (result) {
        case ApiSuccess<RawMaterialAnalysisWorkspace>(data: final workspace):
          workspaces.add(workspace);
        case ApiFailure<RawMaterialAnalysisWorkspace>(failure: final failure):
          _emitError(failure, activeBatchId: batchId);
          return false;
      }
    }

    safeEmit(
      _workspaceReady(activeBatchId: batchId, reviewWorkspaces: workspaces),
    );
    return true;
  }

  Future<bool> submitAnalysis(RawMaterialAnalysisSubmission submission) async {
    final workspace = state.workspace;
    if (workspace == null) {
      return false;
    }
    _emitWorking(
      RawMaterialQualityAction.savingAnalysis,
      activeBatchId: workspace.batchId,
      activeSampleId: workspace.sample.id,
      workspace: workspace,
    );
    final result = await _submitAnalysis(
      workspace: workspace,
      submission: submission,
    );
    switch (result) {
      case ApiSuccess<RawMaterialAnalysisWorkspace>(
        data: final updatedWorkspace,
      ):
        final updatedSamples = [
          for (final sample in state.samples)
            if (sample.id == updatedWorkspace.sample.id)
              updatedWorkspace.sample
            else
              sample,
        ];
        safeEmit(
          _workspaceReady(
            activeBatchId: updatedWorkspace.batchId,
            activeSampleId: updatedWorkspace.sample.id,
            workspace: updatedWorkspace,
            samples: updatedSamples,
          ),
        );
        return true;
      case ApiFailure<RawMaterialAnalysisWorkspace>(failure: final failure):
        _emitError(
          failure,
          activeBatchId: workspace.batchId,
          activeSampleId: workspace.sample.id,
          workspace: workspace,
        );
        return false;
    }
  }

  Future<bool> submitDecision({
    required RawMaterialQualityDecision decision,
    String? comments,
  }) async {
    final batchId = state.activeBatchId;
    if (batchId == null ||
        state.reviewWorkspaces.isEmpty ||
        state.reviewWorkspaces.any((workspace) => !workspace.isComplete)) {
      return false;
    }
    _emitWorking(
      RawMaterialQualityAction.savingDecision,
      activeBatchId: batchId,
      reviewWorkspaces: state.reviewWorkspaces,
    );
    final result = await _submitDecision(
      batchId: batchId,
      decision: decision,
      comments: comments,
    );
    switch (result) {
      case ApiSuccess<bool>():
        await load();
        return true;
      case ApiFailure<bool>(failure: final failure):
        _emitError(
          failure,
          activeBatchId: batchId,
          reviewWorkspaces: state.reviewWorkspaces,
        );
        return false;
    }
  }

  void closeWorkspace() {
    _emitLoaded();
  }

  Future<ApiResult<List<RawMaterialSample>>> _loadEverySampleForBatch(
    int batchId,
  ) async {
    final samples = <RawMaterialSample>[];
    var page = 1;
    var hasNext = true;
    while (hasNext) {
      final result = await _loadSamples(batchId: batchId, page: page);
      switch (result) {
        case ApiSuccess<RawMaterialSamplePage>(data: final samplePage):
          samples.addAll(samplePage.samples);
          hasNext = samplePage.hasNextPage;
          page += 1;
        case ApiFailure<RawMaterialSamplePage>(failure: final failure):
          return ApiFailure(failure);
      }
    }
    return ApiSuccess(samples);
  }

  RawMaterialQualityLoadingMore _loadingMore({required bool loadingSamples}) {
    return RawMaterialQualityLoadingMore(
      loadingSamples: loadingSamples,
      entries: state.entries,
      totalCount: state.totalCount,
      page: state.page,
      hasNextPage: state.hasNextPage,
      samples: state.samples,
      sampleTotalCount: state.sampleTotalCount,
      samplePage: state.samplePage,
      samplesHaveNextPage: state.samplesHaveNextPage,
    );
  }

  void _emitLoaded({
    List<RawMaterialEntry>? entries,
    int? totalCount,
    int? page,
    bool? hasNextPage,
    List<RawMaterialSample>? samples,
    int? sampleTotalCount,
    int? samplePage,
    bool? samplesHaveNextPage,
  }) {
    safeEmit(
      RawMaterialQualityLoaded(
        entries: entries ?? state.entries,
        totalCount: totalCount ?? state.totalCount,
        page: page ?? state.page,
        hasNextPage: hasNextPage ?? state.hasNextPage,
        samples: samples ?? state.samples,
        sampleTotalCount: sampleTotalCount ?? state.sampleTotalCount,
        samplePage: samplePage ?? state.samplePage,
        samplesHaveNextPage: samplesHaveNextPage ?? state.samplesHaveNextPage,
      ),
    );
  }

  RawMaterialQualityWorkspaceReady _workspaceReady({
    required int activeBatchId,
    int? activeSampleId,
    RawMaterialAnalysisWorkspace? workspace,
    List<RawMaterialAnalysisWorkspace> reviewWorkspaces = const [],
    List<RawMaterialSample>? samples,
  }) {
    return RawMaterialQualityWorkspaceReady(
      entries: state.entries,
      totalCount: state.totalCount,
      page: state.page,
      hasNextPage: state.hasNextPage,
      samples: samples ?? state.samples,
      sampleTotalCount: state.sampleTotalCount,
      samplePage: state.samplePage,
      samplesHaveNextPage: state.samplesHaveNextPage,
      activeBatchId: activeBatchId,
      activeSampleId: activeSampleId,
      workspace: workspace,
      reviewWorkspaces: reviewWorkspaces,
    );
  }

  void _emitWorking(
    RawMaterialQualityAction action, {
    required int activeBatchId,
    int? activeSampleId,
    RawMaterialAnalysisWorkspace? workspace,
    List<RawMaterialAnalysisWorkspace>? reviewWorkspaces,
  }) {
    safeEmit(
      RawMaterialQualityWorking(
        action: action,
        entries: state.entries,
        totalCount: state.totalCount,
        page: state.page,
        hasNextPage: state.hasNextPage,
        samples: state.samples,
        sampleTotalCount: state.sampleTotalCount,
        samplePage: state.samplePage,
        samplesHaveNextPage: state.samplesHaveNextPage,
        activeBatchId: activeBatchId,
        activeSampleId: activeSampleId,
        workspace: workspace ?? state.workspace,
        reviewWorkspaces: reviewWorkspaces ?? state.reviewWorkspaces,
      ),
    );
  }

  void _emitError(
    Failure failure, {
    int? activeBatchId,
    int? activeSampleId,
    RawMaterialAnalysisWorkspace? workspace,
    List<RawMaterialAnalysisWorkspace>? reviewWorkspaces,
  }) {
    safeEmit(
      RawMaterialQualityError(
        failure: failure,
        entries: state.entries,
        totalCount: state.totalCount,
        page: state.page,
        hasNextPage: state.hasNextPage,
        samples: state.samples,
        sampleTotalCount: state.sampleTotalCount,
        samplePage: state.samplePage,
        samplesHaveNextPage: state.samplesHaveNextPage,
        activeBatchId: activeBatchId,
        activeSampleId: activeSampleId,
        workspace: workspace ?? state.workspace,
        reviewWorkspaces: reviewWorkspaces ?? state.reviewWorkspaces,
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

  List<RawMaterialSample> _mergeSamples(
    List<RawMaterialSample> current,
    List<RawMaterialSample> incoming,
  ) {
    final byId = {for (final sample in current) sample.id: sample};
    for (final sample in incoming) {
      byId[sample.id] = sample;
    }
    return byId.values.toList(growable: false);
  }
}
