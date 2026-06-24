import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/spacing.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../design_system/tokens/pernit_colors.dart';
import '../../../../design_system/tokens/pernit_font_weights.dart';
import '../../domain/entities/raw_material_entry.dart';

class RawMaterialEntrySummaryStrip extends StatelessWidget {
  final List<RawMaterialEntry> entries;

  const RawMaterialEntrySummaryStrip({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final waitingQualityCount = entries
        .where(
          (entry) =>
              entry.status == RawMaterialEntryStatus.sampleTaken ||
              entry.status == RawMaterialEntryStatus.labPending ||
              entry.status == RawMaterialEntryStatus.qcPending,
        )
        .length;
    final stockedCount = entries.where((entry) => entry.isInStock).length;
    final rejectedCount = entries
        .where((entry) => entry.status == RawMaterialEntryStatus.rejected)
        .length;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 640;
        final children = [
          _SummaryMetric(
            icon: Icons.inventory_2_outlined,
            label: l10n.entryTotalEntries,
            value: entries.length.toString(),
          ),
          _SummaryMetric(
            icon: Icons.science_outlined,
            label: l10n.entryWaitingQuality,
            value: waitingQualityCount.toString(),
          ),
          _SummaryMetric(
            icon: Icons.warehouse_outlined,
            label: l10n.entryStocked,
            value: stockedCount.toString(),
          ),
          _SummaryMetric(
            icon: Icons.block_outlined,
            label: l10n.entryRejected,
            value: rejectedCount.toString(),
          ),
        ];

        if (compact) {
          return Column(
            children: [
              for (final child in children) ...[child, verticalSpace(8)],
            ],
          );
        }

        return Row(
          children: [
            for (var index = 0; index < children.length; index += 1) ...[
              Expanded(child: children[index]),
              if (index != children.length - 1) horizontalSpace(8),
            ],
          ],
        );
      },
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SummaryMetric({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: PernitColors.surface,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: PernitColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: PernitColors.primary, size: 22.r),
          horizontalSpace(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: PernitColors.textStrong,
                    fontWeight: PernitFontWeights.bold,
                  ),
                ),
                Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: PernitColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
