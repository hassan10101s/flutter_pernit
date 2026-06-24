import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/di/dependency_injection.dart';
import '../core/localization/generated/app_localizations.dart';
import '../core/routing/app_router.dart';
import '../core/routing/navigator_key.dart';
import '../core/routing/routes.dart';
import '../design_system/tokens/pernit_colors.dart';
import '../design_system/tokens/pernit_font_weights.dart';
import '../design_system/tokens/pernit_text_theme.dart';

class PernitApp extends StatelessWidget {
  const PernitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: false,
      splitScreenMode: true,
      builder: (context, child) {
        final textTheme = PernitTextTheme.build();

        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: PernitTextTheme.cairoFontFamily,
            textTheme: textTheme,
            colorScheme: ColorScheme.fromSeed(
              seedColor: PernitColors.primary,
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: PernitColors.background,
            appBarTheme: AppBarTheme(
              centerTitle: false,
              elevation: 0,
              scrolledUnderElevation: 0,
              backgroundColor: PernitColors.surface,
              foregroundColor: PernitColors.textStrong,
              surfaceTintColor: PernitColors.surface,
              titleTextStyle: textTheme.titleLarge?.copyWith(
                color: PernitColors.textStrong,
                fontWeight: PernitFontWeights.bold,
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: PernitColors.surface,
              labelStyle: textTheme.bodyMedium?.copyWith(
                color: PernitColors.textMuted,
              ),
              hintStyle: textTheme.bodyMedium?.copyWith(
                color: PernitColors.textMuted,
              ),
              border: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
            navigationBarTheme: NavigationBarThemeData(
              height: 70.h,
              backgroundColor: PernitColors.surface,
              surfaceTintColor: PernitColors.surface,
              indicatorColor: PernitColors.primary.withValues(alpha: 0.12),
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                final selected = states.contains(WidgetState.selected);
                return textTheme.labelSmall?.copyWith(
                  color: selected
                      ? PernitColors.primary
                      : PernitColors.textMuted,
                  fontWeight: PernitFontWeights.bold,
                );
              }),
              iconTheme: WidgetStateProperty.resolveWith((states) {
                final selected = states.contains(WidgetState.selected);
                return IconThemeData(
                  color: selected
                      ? PernitColors.primary
                      : PernitColors.textMuted,
                  size: 22.r,
                );
              }),
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
