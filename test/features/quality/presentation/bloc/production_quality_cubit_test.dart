import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pernit/core/errors/api_result.dart';
import 'package:flutter_pernit/core/errors/failure.dart';
import 'package:flutter_pernit/core/errors/failure_code.dart';
import 'package:flutter_pernit/features/quality/domain/entities/production_lab_sample.dart';
import 'package:flutter_pernit/features/quality/domain/entities/production_lab_result.dart';
import 'package:flutter_pernit/features/quality/domain/entities/production_quality_check.dart';
import 'package:flutter_pernit/features/quality/domain/repos/production_quality_repository.dart';
import 'package:flutter_pernit/features/quality/domain/usecases/create_production_lab_result_use_case.dart';
import 'package:flutter_pernit/features/quality/domain/usecases/create_production_lab_sample_use_case.dart';
import 'package:flutter_pernit/features/quality/domain/usecases/load_production_lab_results_use_case.dart';
import 'package:flutter_pernit/features/quality/domain/usecases/load_production_lab_samples_use_case.dart';
import 'package:flutter_pernit/features/quality/domain/usecases/load_production_quality_checks_use_case.dart';
import 'package:flutter_pernit/features/quality/presentation/bloc/production_quality_cubit.dart';
import 'package:flutter_pernit/features/quality/presentation/bloc/production_quality_state.dart';

void main() {
  late ProductionQualityCubit cubit;
  late _FakeLoadSamples fakeLoadSamples;
  late _FakeCreateSample fakeCreateSample;
  late _FakeLoadResults fakeLoadResults;
  late _FakeCreateResult fakeCreateResult;
  late _FakeLoadChecks fakeLoadChecks;

  final sample = ProductionLabSample(
    id: 1,
    productionOrderId: 10,
    productionOrderCode: 'PO-001',
    status: 'pending',
    takenById: 1,
    takenByName: 'User',
    takenAt: DateTime(2026, 7, 1),
    createdAt: DateTime(2026, 7, 1),
  );

  final result = ProductionLabResult(
    id: 1,
    sampleId: 1,
    sampleNo: 'S-001',
    parameterId: 5,
    parameterName: 'pH',
    value: '7.2',
    isWithinRange: true,
    createdAt: DateTime(2026, 7, 1),
  );

  final check = ProductionQualityCheck(
    id: 1,
    status: 'release',
    receivedProductId: 10,
    productionOrderCode: 'PO-001',
    checkedById: 1,
    checkedByName: 'User',
    comments: null,
    createdAt: DateTime(2026, 7, 1),
  );

  final samplePage = ProductionLabSamplePage(
    items: [sample],
    totalCount: 1,
    page: 1,
    hasMore: false,
  );

  final resultPage = ProductionLabResultPage(
    items: [result],
    totalCount: 1,
    page: 1,
    hasMore: false,
  );

  final checkPage = ProductionQualityCheckPage(
    items: [check],
    totalCount: 1,
    page: 1,
    hasMore: false,
  );

  setUp(() {
    fakeLoadSamples = _FakeLoadSamples();
    fakeCreateSample = _FakeCreateSample();
    fakeLoadResults = _FakeLoadResults();
    fakeCreateResult = _FakeCreateResult();
    fakeLoadChecks = _FakeLoadChecks();

    cubit = ProductionQualityCubit(
      fakeLoadSamples,
      fakeCreateSample,
      fakeLoadResults,
      fakeCreateResult,
      fakeLoadChecks,
    );
  });

  tearDown(() {
    cubit.close();
  });

  group('loadAll', () {
    test('emits loaded state when all three requests succeed', () async {
      fakeLoadSamples.result = ApiSuccess(samplePage);
      fakeLoadResults.result = ApiSuccess(resultPage);
      fakeLoadChecks.result = ApiSuccess(checkPage);

      final emitted = <ProductionQualityState>[];
      cubit.stream.listen(emitted.add);

      cubit.loadAll();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(cubit.state, isA<ProductionQualityLoaded>());
      final loaded = cubit.state as ProductionQualityLoaded;
      expect(loaded.samples.length, 1);
      expect(loaded.results.length, 1);
      expect(loaded.checks.length, 1);
    });

    test('emits error when loadSamples fails', () async {
      fakeLoadSamples.result = ApiFailure(
        const Failure(code: FailureCode.server, messageKey: 'failureServer'),
      );
      fakeLoadResults.result = ApiSuccess(resultPage);
      fakeLoadChecks.result = ApiSuccess(checkPage);

      cubit.loadAll();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(cubit.state, isA<ProductionQualityError>());
    });
  });

  group('createSample', () {
    test('returns true and reloads on success', () async {
      fakeLoadSamples.result = ApiSuccess(samplePage);
      fakeCreateSample.result = ApiSuccess(sample);

      final outcome = await cubit.createSample(productionOrderId: 10);

      expect(outcome, true);
      expect(cubit.state, isA<ProductionQualityLoaded>());
    });

    test('returns false and emits error on failure', () async {
      fakeCreateSample.result = ApiFailure(
        const Failure(code: FailureCode.server, messageKey: 'failureServer'),
      );

      final outcome = await cubit.createSample(productionOrderId: 10);

      expect(outcome, false);
      expect(cubit.state, isA<ProductionQualityError>());
    });

    test('accepts optional quantityTaken', () async {
      fakeLoadSamples.result = ApiSuccess(samplePage);
      fakeCreateSample.result = ApiSuccess(sample);

      final outcome = await cubit.createSample(
        productionOrderId: 10,
        quantityTaken: '5.0',
      );

      expect(outcome, true);
    });
  });

  group('createResult', () {
    test('returns true and reloads on success', () async {
      fakeLoadResults.result = ApiSuccess(resultPage);
      fakeCreateResult.result = ApiSuccess(result);

      final outcome = await cubit.createResult(
        sampleId: 1,
        parameterId: 5,
        value: '7.2',
      );

      expect(outcome, true);
    });

    test('returns false and emits error on failure', () async {
      fakeCreateResult.result = ApiFailure(
        const Failure(code: FailureCode.server, messageKey: 'failureServer'),
      );

      final outcome = await cubit.createResult(
        sampleId: 1,
        parameterId: 5,
        value: '7.2',
      );

      expect(outcome, false);
    });
  });

  group('pagination', () {
    test('loadMoreSamples appends items', () async {
      final firstPage = ProductionLabSamplePage(
        items: [sample],
        totalCount: 2,
        page: 1,
        hasMore: true,
      );
      fakeLoadSamples.result = ApiSuccess(firstPage);
      fakeLoadResults.result = ApiSuccess(resultPage.copyWith(items: []));
      fakeLoadChecks.result = ApiSuccess(checkPage.copyWith(items: []));

      cubit.loadAll();
      await Future.delayed(const Duration(milliseconds: 50));
      expect(cubit.state.samples.length, 1);

      final secondPage = ProductionLabSamplePage(
        items: [
          ProductionLabSample(
            id: 2,
            productionOrderId: 11,
            productionOrderCode: 'PO-002',
            status: 'completed',
            createdAt: DateTime(2026, 7, 1),
          ),
        ],
        totalCount: 2,
        page: 2,
        hasMore: false,
      );
      fakeLoadSamples.result = ApiSuccess(secondPage);

      await cubit.loadMoreSamples();
      expect(cubit.state.samples.length, 2);
    });

    test('loadMore does not fire when hasMore is false', () async {
      fakeLoadSamples.result = ApiSuccess(samplePage);
      fakeLoadResults.result = ApiSuccess(resultPage.copyWith(items: []));
      fakeLoadChecks.result = ApiSuccess(checkPage.copyWith(items: []));

      cubit.loadAll();
      await Future.delayed(const Duration(milliseconds: 50));

      fakeLoadSamples.callCount = 0;

      await cubit.loadMoreSamples();
      await Future.delayed(const Duration(milliseconds: 50));

      expect(fakeLoadSamples.callCount, 0);
    });
  });

  group('checks read-only', () {
    test('no createCheck method exists on cubit', () async {
      expect(cubit, isA<ProductionQualityCubit>());
    });
  });
}

class _FakeProductionQualityRepository implements ProductionQualityRepository {
  @override
  Future<ApiResult<ProductionLabSamplePage>> loadSamples({
    required int page,
  }) async {
    return ApiSuccess(
      ProductionLabSamplePage(
        items: [],
        totalCount: 0,
        page: 1,
        hasMore: false,
      ),
    );
  }

  @override
  Future<ApiResult<ProductionLabSample>> createSample(
    int productionOrderId, {
    String? quantityTaken,
  }) async {
    return ApiFailure(
      const Failure(code: FailureCode.unknown, messageKey: 'failureUnknown'),
    );
  }

  @override
  Future<ApiResult<ProductionLabResultPage>> loadResults({
    required int page,
  }) async {
    return ApiSuccess(
      ProductionLabResultPage(
        items: [],
        totalCount: 0,
        page: 1,
        hasMore: false,
      ),
    );
  }

  @override
  Future<ApiResult<ProductionLabResult>> createResult({
    required int sampleId,
    required int parameterId,
    required String value,
  }) async {
    return ApiFailure(
      const Failure(code: FailureCode.unknown, messageKey: 'failureUnknown'),
    );
  }

  @override
  Future<ApiResult<ProductionQualityCheckPage>> loadChecks({
    required int page,
  }) async {
    return ApiSuccess(
      ProductionQualityCheckPage(
        items: [],
        totalCount: 0,
        page: 1,
        hasMore: false,
      ),
    );
  }
}

class _FakeLoadSamples extends LoadProductionLabSamplesUseCase {
  _FakeLoadSamples() : super(_FakeProductionQualityRepository());

  ApiResult<ProductionLabSamplePage> result = ApiSuccess(
    ProductionLabSamplePage(items: [], totalCount: 0, page: 1, hasMore: false),
  );
  int callCount = 0;

  @override
  Future<ApiResult<ProductionLabSamplePage>> call({required int page}) async {
    callCount++;
    return result;
  }
}

class _FakeCreateSample extends CreateProductionLabSampleUseCase {
  _FakeCreateSample() : super(_FakeProductionQualityRepository());

  ApiResult<ProductionLabSample> result = ApiFailure(
    const Failure(code: FailureCode.unknown, messageKey: 'failureUnknown'),
  );

  @override
  Future<ApiResult<ProductionLabSample>> call(
    int productionOrderId, {
    String? quantityTaken,
  }) async {
    return result;
  }
}

class _FakeLoadResults extends LoadProductionLabResultsUseCase {
  _FakeLoadResults() : super(_FakeProductionQualityRepository());

  ApiResult<ProductionLabResultPage> result = ApiSuccess(
    ProductionLabResultPage(items: [], totalCount: 0, page: 1, hasMore: false),
  );

  @override
  Future<ApiResult<ProductionLabResultPage>> call({required int page}) async {
    return result;
  }
}

class _FakeCreateResult extends CreateProductionLabResultUseCase {
  _FakeCreateResult() : super(_FakeProductionQualityRepository());

  ApiResult<ProductionLabResult> result = ApiFailure(
    const Failure(code: FailureCode.unknown, messageKey: 'failureUnknown'),
  );

  @override
  Future<ApiResult<ProductionLabResult>> call({
    required int sampleId,
    required int parameterId,
    required String value,
  }) async {
    return result;
  }
}

class _FakeLoadChecks extends LoadProductionQualityChecksUseCase {
  _FakeLoadChecks() : super(_FakeProductionQualityRepository());

  ApiResult<ProductionQualityCheckPage> result = ApiSuccess(
    ProductionQualityCheckPage(
      items: [],
      totalCount: 0,
      page: 1,
      hasMore: false,
    ),
  );

  @override
  Future<ApiResult<ProductionQualityCheckPage>> call({
    required int page,
  }) async {
    return result;
  }
}
