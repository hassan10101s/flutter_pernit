import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/di/dependency_injection.dart';
import '../core/localization/generated/app_localizations.dart';
import '../core/routing/app_router.dart';
import '../core/routing/routes.dart';
import '../design_system/tokens/pernit_colors.dart';

class PernitApp extends StatelessWidget {
  const PernitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: false,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: PernitColors.primary,
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: PernitColors.background,
            inputDecorationTheme: const InputDecorationTheme(
              filled: true,
              fillColor: PernitColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
          ),
          locale: const Locale('ar'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          initialRoute: Routes.startup,
          onGenerateRoute: sl<AppRouter>().onGenerateRoute,
          builder: (context, materialChild) {
            return MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.noScaling),
              child: materialChild!,
            );
          },
        );
      },
    );
  }
}
