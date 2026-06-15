import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/spacing.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../design_system/tokens/pernit_colors.dart';
import '../../../../design_system/tokens/pernit_font_weights.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.homeTitle),
        backgroundColor: PernitColors.surface,
        foregroundColor: PernitColors.textStrong,
        surfaceTintColor: PernitColors.surface,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.dashboard_outlined,
                color: PernitColors.primary,
                size: 40.r,
              ),
              verticalSpace(16),
              Text(
                l10n.homeEmptyTitle,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: PernitColors.textStrong,
                  fontWeight: PernitFontWeights.bold,
                ),
              ),
              verticalSpace(8),
              Text(
                l10n.homeEmptySubtitle,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: PernitColors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
