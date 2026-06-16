import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/spacing.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../design_system/tokens/pernit_colors.dart';
import '../../../../design_system/tokens/pernit_font_weights.dart';
import '../../../../design_system/widgets/pernit_panel_header.dart';
import '../../../auth/domain/entities/auth_user.dart';
import '../../../production/presentation/screens/production_screen.dart';
import '../../../quality/presentation/screens/quality_screen.dart';
import '../../../settings/presentation/screens/settings_screen.dart';
import '../../domain/entities/home_menu_section.dart';

class HomeSectionBody extends StatelessWidget {
  final HomeMenuSection section;
  final AuthUser user;

  const HomeSectionBody({super.key, required this.section, required this.user});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: SingleChildScrollView(
          child: switch (section) {
            HomeMenuSection.overview => _OverviewPanel(user: user),
            HomeMenuSection.settings => const SettingsScreen(),
            HomeMenuSection.quality => const QualityScreen(),
            HomeMenuSection.production => const ProductionScreen(),
            _ => _PlaceholderPanel(
              title: _moduleTitle(l10n, section),
              icon: _moduleIcon(section),
            ),
          },
        ),
      ),
    );
  }

  IconData _moduleIcon(HomeMenuSection section) {
    return switch (section) {
      HomeMenuSection.inventory => Icons.inventory_2_outlined,
      HomeMenuSection.quality => Icons.verified_outlined,
      HomeMenuSection.production => Icons.factory_outlined,
      HomeMenuSection.commercial => Icons.receipt_long_outlined,
      HomeMenuSection.overview ||
      HomeMenuSection.settings => Icons.apps_outlined,
    };
  }

  String _moduleTitle(AppLocalizations l10n, HomeMenuSection section) {
    return switch (section) {
      HomeMenuSection.overview => l10n.menuOverview,
      HomeMenuSection.inventory => l10n.menuInventory,
      HomeMenuSection.quality => l10n.menuQuality,
      HomeMenuSection.production => l10n.menuProduction,
      HomeMenuSection.commercial => l10n.menuCommercial,
      HomeMenuSection.settings => l10n.menuSettings,
    };
  }
}

class _OverviewPanel extends StatelessWidget {
  final AuthUser user;

  const _OverviewPanel({required this.user});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final groups = user.groups.isEmpty
        ? l10n.homeNoGroups
        : user.groups.join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PernitPanelHeader(
          icon: Icons.dashboard_outlined,
          title: l10n.homeGreeting(user.displayName),
          subtitle: l10n.homeGroupLabel(groups),
        ),
        verticalSpace(16),
        Text(
          l10n.overviewTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: PernitFontWeights.bold,
            color: PernitColors.textStrong,
          ),
        ),
        verticalSpace(8),
        Text(
          l10n.overviewSubtitle,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: PernitColors.textMuted),
        ),
      ],
    );
  }
}

class _PlaceholderPanel extends StatelessWidget {
  final String title;
  final IconData icon;

  const _PlaceholderPanel({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return PernitPanelHeader(
      icon: icon,
      title: title,
      subtitle: l10n.modulePlaceholder(title),
    );
  }
}
