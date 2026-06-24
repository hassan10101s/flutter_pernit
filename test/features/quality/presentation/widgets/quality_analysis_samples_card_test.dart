import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_pernit/core/localization/generated/app_localizations.dart';
import 'package:flutter_pernit/features/quality/presentation/widgets/quality_analysis_samples_card.dart';
import 'package:flutter_pernit/features/raw_material_entry/domain/entities/raw_material_workflow.dart';

void main() {
  testWidgets('shows every sample inside one card grouped by batch', (
    tester,
  ) async {
    await tester.pumpAnalysisCard(samples: _samples);

    expect(
      find.byKey(const ValueKey('qualityAnalysisSamplesCard')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('qualityAnalysisSample-1')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('qualityAnalysisSample-2')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('qualityAnalysisSample-3')),
      findsOneWidget,
    );
    expect(find.text('Yellow Corn'), findsOneWidget);
    expect(find.text('Soybean Meal'), findsOneWidget);
    expect(find.text('Batch #20 · 2 samples'), findsOneWidget);
    expect(find.text('Batch #21 · 1 samples'), findsOneWidget);
  });

  testWidgets('uses the correct action and reports the selected sample', (
    tester,
  ) async {
    RawMaterialSample? selectedSample;
    await tester.pumpAnalysisCard(
      samples: _samples,
      onSamplePressed: (sample) => selectedSample = sample,
    );

    expect(find.text('Edit analysis'), findsNWidgets(2));
    expect(find.text('Enter analyses'), findsNWidgets(4));

    await tester.tap(find.text('Edit analysis').last);
    await tester.pump();

    expect(selectedSample?.id, 2);
  });
}

extension on WidgetTester {
  Future<void> pumpAnalysisCard({
    required List<RawMaterialSample> samples,
    ValueChanged<RawMaterialSample>? onSamplePressed,
  }) async {
    await pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: false,
        splitScreenMode: true,
        builder: (context, child) => MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SingleChildScrollView(
              child: QualityAnalysisSamplesCard(
                samples: samples,
                workingSampleId: null,
                onSamplePressed: onSamplePressed ?? (_) {},
              ),
            ),
          ),
        ),
      ),
    );
    await pumpAndSettle();
  }
}

const _samples = [
  RawMaterialSample(
    id: 1,
    batchId: 20,
    rawMaterialName: 'Yellow Corn',
    sampleNumber: 'S-001',
    status: 'pending',
    createdAt: null,
  ),
  RawMaterialSample(
    id: 2,
    batchId: 20,
    rawMaterialName: 'Yellow Corn',
    sampleNumber: 'S-002',
    status: 'completed',
    createdAt: null,
  ),
  RawMaterialSample(
    id: 3,
    batchId: 21,
    rawMaterialName: 'Soybean Meal',
    sampleNumber: 'S-003',
    status: 'pending',
    createdAt: null,
  ),
];
