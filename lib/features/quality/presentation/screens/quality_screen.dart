import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/extensions/navigation_extensions.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/routing/routes.dart';
import '../../../../design_system/tokens/pernit_colors.dart';

class QualityScreen extends StatelessWidget {
  const QualityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.menuQuality,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 8.h),
          Text(
            l10n.qualityHubSubtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: PernitColors.textMuted),
          ),
          SizedBox(height: 32.h),
          _QualityHubCard(
            icon: Icons.inventory_2_outlined,
            title: l10n.qualityRawMaterialsTitle,
            subtitle: l10n.qualityRawMaterialsSubtitle,
            onTap: () => context.pushNamed(Routes.rawMaterialQuality),
          ),
          SizedBox(height: 16.h),
          _QualityHubCard(
            icon: Icons.factory_outlined,
            title: l10n.qualityProductionTitle,
            subtitle: l10n.qualityProductionSubtitle,
            onTap: () => context.pushNamed(Routes.productionQuality),
          ),
        ],
      ),
    );
  }
}

class _QualityHubCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QualityHubCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PernitColors.surface,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: PernitColors.borderMuted),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: PernitColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: PernitColors.primary, size: 28.r),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: PernitColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_left_rounded,
                color: PernitColors.textSubtle,
                size: 24.r,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
