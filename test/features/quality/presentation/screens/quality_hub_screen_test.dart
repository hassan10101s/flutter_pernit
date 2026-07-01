import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pernit/core/localization/generated/app_localizations.dart';
import 'package:flutter_pernit/core/routing/routes.dart';
import 'package:flutter_pernit/features/quality/presentation/screens/quality_screen.dart';

void main() {
  group('QualityHubScreen', () {
    Widget buildTestWidget({Locale locale = const Locale('en')}) {
      return ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: false,
        splitScreenMode: true,
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en'), Locale('ar')],
          home: const QualityScreen(),
          routes: {
            Routes.rawMaterialQuality: (_) =>
                const _Placeholder(label: 'RawMaterialQuality'),
            Routes.productionQuality: (_) =>
                const _Placeholder(label: 'ProductionQuality'),
          },
        ),
      );
    }

    testWidgets('route /quality opens hub', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Quality'), findsOneWidget);
    });

    testWidgets('hub shows Raw Material and Production cards', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Raw material quality'), findsOneWidget);
      expect(find.text('Production quality'), findsOneWidget);
    });

    testWidgets(
      'tapping Raw Material card navigates to /quality/raw-materials',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Raw material quality'));
        await tester.pumpAndSettle();

        expect(find.text('RawMaterialQuality'), findsAtLeast(1));
      },
    );

    testWidgets('tapping Production card navigates to /quality/production', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Production quality'));
      await tester.pumpAndSettle();

      expect(find.text('ProductionQuality'), findsAtLeast(1));
    });

    testWidgets('hub shows choices in Arabic', (tester) async {
      await tester.pumpWidget(buildTestWidget(locale: const Locale('ar')));
      await tester.pumpAndSettle();

      expect(find.text('جودة الخامات'), findsOneWidget);
      expect(find.text('جودة الإنتاج'), findsOneWidget);
    });
  });
}

class _Placeholder extends StatelessWidget {
  final String label;

  const _Placeholder({required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(label)),
      body: Center(child: Text(label)),
    );
  }
}
