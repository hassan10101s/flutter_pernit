import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../design_system/status_indicators/pernit_status_badge.dart';
import '../../../../design_system/tokens/pernit_colors.dart';
import '../../../../design_system/tokens/pernit_font_weights.dart';
import '../../../../design_system/widgets/pernit_button.dart';
import '../../../raw_material_entry/domain/entities/raw_material_workflow.dart';

class QualityAnalysisSamplesCard extends StatelessWidget {
  final List<RawMaterialSample> samples;
  final int? workingSampleId;
  final ValueChanged<RawMaterialSample> onSamplePressed;

  const QualityAnalysisSamplesCard({
    super.key,
    required this.samples,
    required this.workingSampleId,
    required this.onSamplePressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final groups = _groupSamplesByBatch(samples);

    return Container(
      key: const ValueKey('qualityAnalysisSamplesCard'),
      decoration: BoxDecoration(
        color: PernitColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: PernitColors.borderMuted),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16.r,
            offset: Offset(0, 5.h),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(14.r),
            child: Row(
              children: [
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: PernitColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(
                    Icons.biotech_outlined,
                    color: PernitColors.primary,
                    size: 24.r,
                  ),
                ),
                SizedBox(width: 11.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.rawQualityAnalysisTab,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: PernitColors.textStrong,
                              fontWeight: PernitFontWeights.bold,
                            ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        l10n.rawQualitySamplesCount(samples.length),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: PernitColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                PernitStatusBadge(
                  label: l10n.rawQualitySamplesCount(samples.length),
                  tone: PernitStatusBadgeTone.neutral,
                  minWidth: 0,
                  showDot: false,
                ),
              ],
            ),
          ),
          Divider(height: 1, color: PernitColors.borderSoft),
          for (var index = 0; index < groups.length; index++) ...[
            _BatchSamplesSection(
              group: groups[index],
              workingSampleId: workingSampleId,
              onSamplePressed: onSamplePressed,
            ),
            if (index < groups.length - 1)
              Divider(height: 1, thickness: 1, color: PernitColors.borderSoft),
          ],
        ],
      ),
    );
  }
}

class _BatchSamplesSection extends StatelessWidget {
  final _BatchSampleGroup group;
  final int? workingSampleId;
  final ValueChanged<RawMaterialSample> onSamplePressed;

  const _BatchSamplesSection({
    required this.group,
    required this.workingSampleId,
    required this.onSamplePressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.all(12.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 9.h),
            decoration: BoxDecoration(
              color: PernitColors.background,
              borderRadius: BorderRadius.circular(11.r),
              border: Border.all(color: PernitColors.borderSoft),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  size: 20.r,
                  color: PernitColors.primary,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.rawMaterialName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: PernitColors.textStrong,
                          fontWeight: PernitFontWeights.semiBold,
                        ),
                      ),
                      Text(
                        '${l10n.rawWorkflowBatch(group.batchId)} · '
                        '${l10n.rawQualitySamplesCount(group.samples.length)}',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: PernitColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 5.h),
          for (var index = 0; index < group.samples.length; index++) ...[
            _AnalysisSampleRow(
              sample: group.samples[index],
              isWorking: workingSampleId == group.samples[index].id,
              onPressed: () => onSamplePressed(group.samples[index]),
            ),
            if (index < group.samples.length - 1)
              Divider(height: 1, indent: 50.w, color: PernitColors.borderSoft),
          ],
        ],
      ),
    );
  }
}

class _AnalysisSampleRow extends StatelessWidget {
  final RawMaterialSample sample;
  final bool isWorking;
  final VoidCallback onPressed;

  const _AnalysisSampleRow({
    required this.sample,
    required this.isWorking,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isComplete = sample.status == 'completed';
    final actionLabel = isComplete
        ? l10n.rawQualityEditAnalysis
        : l10n.rawQualityEnterAnalysis;

    return Padding(
      key: ValueKey('qualityAnalysisSample-${sample.id}'),
      padding: EdgeInsets.symmetric(vertical: 9.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  color: isComplete
                      ? PernitColors.success.withValues(alpha: 0.14)
                      : PernitColors.primary.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isComplete ? Icons.check_rounded : Icons.science_outlined,
                  size: 20.r,
                  color: isComplete
                      ? PernitColors.textStrong
                      : PernitColors.primary,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  l10n.rawAnalysisSampleNumber(
                    sample.sampleNumber ?? '#${sample.id}',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: PernitColors.textStrong,
                    fontWeight: PernitFontWeights.semiBold,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              PernitStatusBadge(
                label: actionLabel,
                tone: isComplete
                    ? PernitStatusBadgeTone.success
                    : PernitStatusBadgeTone.pending,
                height: 24,
                minWidth: 0,
              ),
            ],
          ),
          SizedBox(height: 8.h),
          PernitButton(
            label: actionLabel,
            icon: isComplete ? Icons.edit_outlined : Icons.add_chart_outlined,
            height: 40,
            borderRadius: 9,
            variant: isComplete
                ? PernitButtonVariant.outlined
                : PernitButtonVariant.filled,
            isLoading: isWorking,
            onPressed: isWorking ? null : onPressed,
          ),
        ],
      ),
    );
  }
}

List<_BatchSampleGroup> _groupSamplesByBatch(List<RawMaterialSample> samples) {
  final groupedSamples = <int, List<RawMaterialSample>>{};
  for (final sample in samples) {
    groupedSamples.putIfAbsent(sample.batchId, () => []).add(sample);
  }

  return [
    for (final entry in groupedSamples.entries)
      _BatchSampleGroup(
        batchId: entry.key,
        rawMaterialName: entry.value.first.rawMaterialName,
        samples: entry.value,
      ),
  ];
}

class _BatchSampleGroup {
  final int batchId;
  final String rawMaterialName;
  final List<RawMaterialSample> samples;

  const _BatchSampleGroup({
    required this.batchId,
    required this.rawMaterialName,
    required this.samples,
  });
}
