import 'package:flutter/material.dart';

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
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.dashboard_outlined,
                color: PernitColors.primary,
                size: 40,
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
