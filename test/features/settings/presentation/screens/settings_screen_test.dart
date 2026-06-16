import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_pernit/core/localization/generated/app_localizations.dart';
import 'package:flutter_pernit/features/settings/presentation/screens/settings_screen.dart';

void main() {
  testWidgets('settings units item opens records dialog', (tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: false,
        builder: (context, child) => MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('en'),
          home: const Scaffold(
            body: SingleChildScrollView(child: SettingsScreen()),
          ),
        ),
      ),
    );

    expect(find.text('Core setup'), findsOneWidget);
    expect(find.text('/v1/auth/erp/units/'), findsOneWidget);

    await tester.tap(find.text('/v1/auth/erp/units/'));
    await tester.pumpAndSettle();

    expect(find.text('Current records'), findsOneWidget);
    expect(find.text('KG'), findsOneWidget);
    expect(find.text('short_code: KG'), findsOneWidget);
    expect(find.byIcon(Icons.edit_outlined), findsWidgets);
    expect(find.byIcon(Icons.delete_outline), findsWidgets);
    expect(find.text('Add'), findsOneWidget);
  });
}
