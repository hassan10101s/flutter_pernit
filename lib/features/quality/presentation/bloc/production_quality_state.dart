import 'package:equatable/equatable.dart';

import '../../../../core/errors/failure.dart';
import '../../domain/entities/production_lab_sample.dart';
import '../../domain/entities/production_lab_result.dart';
import '../../domain/entities/production_quality_check.dart';

sealed class ProductionQualityState extends Equatable {
  final List<ProductionLabSample> samples;
  final int samplesTotalCount;
  final int samplesPage;
  final bool samplesHasMore;
  final List<ProductionLabResult> results;
  final int resultsTotalCount;
  final int resultsPage;
  final bool resultsHasMore;
  final List<ProductionQualityCheck> checks;
  final int checksTotalCount;
  final int checksPage;
  final bool checksHasMore;
  final bool isLoadingSamples;
  final bool isLoadingResults;
  final bool isLoadingChecks;
  final bool isCreatingSample;
  final bool isCreatingResult;
  final int? creatingSampleOrderId;
  final Failure? failure;

  const ProductionQualityState({
    this.samples = const [],
    this.samplesTotalCount = 0,
    this.samplesPage = 1,
    this.samplesHasMore = false,
    this.results = const [],
    this.resultsTotalCount = 0,
    this.resultsPage = 1,
    this.resultsHasMore = false,
    this.checks = const [],
    this.checksTotalCount = 0,
    this.checksPage = 1,
    this.checksHasMore = false,
    this.isLoadingSamples = false,
    this.isLoadingResults = false,
    this.isLoadingChecks = false,
    this.isCreatingSample = false,
    this.isCreatingResult = false,
    this.creatingSampleOrderId,
    this.failure,
  });

  @override
  List<Object?> get props => [
    samples,
    samplesTotalCount,
    samplesPage,
    samplesHasMore,
    results,
    resultsTotalCount,
    resultsPage,
    resultsHasMore,
    checks,
    checksTotalCount,
    checksPage,
    checksHasMore,
    isLoadingSamples,
    isLoadingResults,
    isLoadingChecks,
    isCreatingSample,
    isCreatingResult,
    creatingSampleOrderId,
    failure,
  ];
}

final class ProductionQualityInitial extends ProductionQualityState {
  const ProductionQualityInitial();
}

final class ProductionQualityLoading extends ProductionQualityState {
  const ProductionQualityLoading({
    super.isLoadingSamples = true,
    super.isLoadingResults = true,
    super.isLoadingChecks = true,
  });
}

final class ProductionQualityLoaded extends ProductionQualityState {
  const ProductionQualityLoaded({
    required super.samples,
    required super.samplesTotalCount,
    required super.samplesPage,
    required super.samplesHasMore,
    required super.results,
    required super.resultsTotalCount,
    required super.resultsPage,
    required super.resultsHasMore,
    required super.checks,
    required super.checksTotalCount,
    required super.checksPage,
    required super.checksHasMore,
  });
}

final class ProductionQualityTabLoading extends ProductionQualityState {
  const ProductionQualityTabLoading({
    required super.samples,
    required super.samplesTotalCount,
    required super.samplesPage,
    required super.samplesHasMore,
    required super.results,
    required super.resultsTotalCount,
    required super.resultsPage,
    required super.resultsHasMore,
    required super.checks,
    required super.checksTotalCount,
    required super.checksPage,
    required super.checksHasMore,
    super.isLoadingSamples = false,
    super.isLoadingResults = false,
    super.isLoadingChecks = false,
  });
}

final class ProductionQualityCreating extends ProductionQualityState {
  const ProductionQualityCreating({
    required super.samples,
    required super.samplesTotalCount,
    required super.samplesPage,
    required super.samplesHasMore,
    required super.results,
    required super.resultsTotalCount,
    required super.resultsPage,
    required super.resultsHasMore,
    required super.checks,
    required super.checksTotalCount,
    required super.checksPage,
    required super.checksHasMore,
    super.isCreatingSample = false,
    super.isCreatingResult = false,
    super.creatingSampleOrderId,
  });
}

final class ProductionQualityError extends ProductionQualityState {
  const ProductionQualityError({
    required super.failure,
    required super.samples,
    required super.samplesTotalCount,
    required super.samplesPage,
    required super.samplesHasMore,
    required super.results,
    required super.resultsTotalCount,
    required super.resultsPage,
    required super.resultsHasMore,
    required super.checks,
    required super.checksTotalCount,
    required super.checksPage,
    required super.checksHasMore,
  });
}
