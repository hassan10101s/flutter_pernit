import 'package:flutter/material.dart';

import '../../../../core/helpers/spacing.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../design_system/widgets/pernit_panel_header.dart';
import '../widgets/production_screens_section.dart';

class ProductionScreen extends StatelessWidget {
  const ProductionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PernitPanelHeader(
          icon: Icons.factory_outlined,
          title: l10n.menuProduction,
          subtitle: l10n.productionScreensSubtitle,
        ),
        verticalSpace(16),
        const ProductionScreensSection(),
      ],
    );
  }
}
