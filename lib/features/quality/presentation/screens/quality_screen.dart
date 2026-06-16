import 'package:flutter/material.dart';

import '../../../../core/helpers/spacing.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../design_system/widgets/pernit_panel_header.dart';
import '../widgets/quality_screens_section.dart';

class QualityScreen extends StatelessWidget {
  const QualityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PernitPanelHeader(
          icon: Icons.verified_outlined,
          title: l10n.menuQuality,
          subtitle: l10n.qualityScreensSubtitle,
        ),
        verticalSpace(16),
        const QualityScreensSection(),
      ],
    );
  }
}
