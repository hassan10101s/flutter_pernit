import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/raw_material_entry.dart';
import '../../domain/entities/raw_material_workflow.dart';

enum RawMaterialQualityAction {
  takingSample,
  loadingAnalysis,
  savingAnalysis,
  loadingDecision,
  savingDecision,
}

sealed class RawMaterialQualityState extends Equatable {
  final List<RawMaterialEntry> entries;
  final int totalCount;
  final int page;
  final bool hasNextPage;
  final List<RawMaterialSample> samples;
  final int sampleTotalCount;
  final int samplePage;
  final bool samplesHaveNextPage;
  final int? activeBatchId;
  final int? activeSampleId;
  final RawMaterialAnalysisWorkspace? workspace;
  final List<RawMaterialAnalysisWorkspace> reviewWorkspaces;

  const RawMaterialQualityState({
    this.entries = const [],
    this.totalCount = 0,
    this.page = 1,
    this.hasNextPage = false,
    this.samples = const [],
    this.sampleTotalCount = 0,
    this.samplePage = 1,
    this.samplesHaveNextPage = false,
    this.activeBatchId,
    this.activeSampleId,
    this.workspace,
    this.reviewWorkspaces = const [],
  });

  RawMaterialQualityAction? get action => null;

  bool get loadingSamples => false;

  @override
  List<Object?> get props => [
    entries,
    totalCount,
    page,
    hasNextPage,
    samples,
    sampleTotalCount,
    samplePage,
    samplesHaveNextPage,
    activeBatchId,
    activeSampleId,
    workspace,
    reviewWorkspaces,
  ];
}

final class RawMaterialQualityInitial extends RawMaterialQualityState {
  const RawMaterialQualityInitial();
}

final class RawMaterialQualityLoading extends RawMaterialQualityState {
  const RawMaterialQualityLoading({super.entries, super.samples});
}

final class RawMaterialQualityLoaded extends RawMaterialQualityState {
  const RawMaterialQualityLoaded({
    required super.entries,
    required super.totalCount,
    required super.page,
    required super.hasNextPage,
    required super.samples,
    required super.sampleTotalCount,
    required super.samplePage,
    required super.samplesHaveNextPage,
  });
}

final class RawMaterialQualityLoadingMore extends RawMaterialQualityState {
  @override
  final bool loadingSamples;

  const RawMaterialQualityLoadingMore({
    required this.loadingSamples,
    required super.entries,
    required super.totalCount,
    required super.page,
    required super.hasNextPage,
    required super.samples,
    required super.sampleTotalCount,
    required super.samplePage,
    required super.samplesHaveNextPage,
  });

  @override
  List<Object?> get props => [...super.props, loadingSamples];
}

final class RawMaterialQualityWorking extends RawMaterialQualityState {
  @override
  final RawMaterialQualityAction action;

  const RawMaterialQualityWorking({
    required this.action,
    required super.entries,
    required super.totalCount,
    required super.page,
    required super.hasNextPage,
    required super.samples,
    required super.sampleTotalCount,
    required super.samplePage,
    required super.samplesHaveNextPage,
    required super.activeBatchId,
    super.activeSampleId,
    super.workspace,
    super.reviewWorkspaces,
  });

  @override
  List<Object?> get props => [...super.props, action];
}

final class RawMaterialQualityWorkspaceReady extends RawMaterialQualityState {
  const RawMaterialQualityWorkspaceReady({
    required super.entries,
    required super.totalCount,
    required super.page,
    required super.hasNextPage,
    required super.samples,
    required super.sampleTotalCount,
    required super.samplePage,
    required super.samplesHaveNextPage,
    required super.activeBatchId,
    super.activeSampleId,
    super.workspace,
    super.reviewWorkspaces,
  });
}

final class RawMaterialQualityError extends RawMaterialQualityState {
  final Failure failure;

  const RawMaterialQualityError({
    required this.failure,
    required super.entries,
    required super.totalCount,
    required super.page,
    required super.hasNextPage,
    required super.samples,
    required super.sampleTotalCount,
    required super.samplePage,
    required super.samplesHaveNextPage,
    super.activeBatchId,
    super.activeSampleId,
    super.workspace,
    super.reviewWorkspaces,
  });

  @override
  List<Object?> get props => [...super.props, failure];
}
