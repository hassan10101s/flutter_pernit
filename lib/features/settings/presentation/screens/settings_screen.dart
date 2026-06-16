import 'package:flutter/material.dart';

import '../../../../core/helpers/spacing.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../design_system/tokens/pernit_colors.dart';
import '../../../../design_system/widgets/pernit_panel_header.dart';
import '../widgets/settings_basics_section.dart';
import '../widgets/settings_units_section.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PernitPanelHeader(
          icon: Icons.settings_outlined,
          title: l10n.settingsTitle,
          subtitle: l10n.settingsSubtitle,
        ),
        verticalSpace(16),
        Text(
          l10n.settingsAdminOnlyNote,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: PernitColors.textMuted),
        ),
        verticalSpace(12),
        const SettingsUnitsSection(),
        verticalSpace(16),
        const SettingsBasicsSection(),
      ],
    );
  }
}
