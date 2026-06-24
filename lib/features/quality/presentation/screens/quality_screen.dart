import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/localization/failure_message_localizer.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../design_system/status_indicators/pernit_status_badge.dart';
import '../../../../design_system/tokens/pernit_colors.dart';
import '../../../../design_system/widgets/pernit_button.dart';
import '../../../raw_material_entry/domain/entities/raw_material_entry.dart';
import '../../../raw_material_entry/domain/entities/raw_material_workflow.dart';
import '../../../raw_material_entry/presentation/bloc/raw_material_quality_cubit.dart';
import '../../../raw_material_entry/presentation/bloc/raw_material_quality_state.dart';
import '../../../raw_material_entry/presentation/widgets/raw_material_analysis_sheet.dart';
import '../../../raw_material_entry/presentation/widgets/raw_material_workflow_card.dart';
import '../widgets/quality_analysis_samples_card.dart';

class QualityScreen extends StatelessWidget {
  const QualityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RawMaterialQualityCubit>()..load(),
      child: const _QualityWorkflowView(),
    );
  }
}

class _QualityWorkflowView extends StatefulWidget {
  const _QualityWorkflowView();

  @override
  State<_QualityWorkflowView> createState() => _QualityWorkflowViewState();
}

class _QualityWorkflowViewState extends State<_QualityWorkflowView> {
  var _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<RawMaterialQualityCubit, RawMaterialQualityState>(
      listener: (context, state) {
        if (state is RawMaterialQualityError) {
          final message = FailureMessageLocalizer.messageFor(
            l10n,
            state.failure.messageKey,
          );
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
      },
      builder: (context, state) {
        final cubit = context.read<RawMaterialQualityCubit>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _QualityTabs(
              selectedIndex: _selectedTab,
              onSelected: (index) => setState(() => _selectedTab = index),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _queueLabel(l10n, state),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: PernitColors.textMuted,
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  tooltip: l10n.rawWorkflowRefresh,
                  onPressed: state is RawMaterialQualityLoading
                      ? null
                      : cubit.load,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            if (state is RawMaterialQualityLoading &&
                state.entries.isEmpty &&
                state.samples.isEmpty)
              const Center(child: CircularProgressIndicator())
            else
              switch (_selectedTab) {
                0 => _SamplingTab(state: state, cubit: cubit),
                1 => _AnalysisTab(state: state, cubit: cubit),
                _ => _DecisionTab(state: state, cubit: cubit),
              },
          ],
        );
      },
    );
  }

  String _queueLabel(AppLocalizations l10n, RawMaterialQualityState state) {
    return switch (_selectedTab) {
      0 => l10n.rawQualitySamplingCount(
        state.entries.where((entry) => !entry.isQcDone).length,
      ),
      1 => l10n.rawQualitySamplesCount(state.sampleTotalCount),
      _ => l10n.rawQualityDecisionCount(
        state.entries
            .where((entry) => entry.isLabDone && !entry.isQcDone)
            .length,
      ),
    };
  }
}

class _QualityTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _QualityTabs({required this.selectedIndex, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = [
      (Icons.colorize_outlined, l10n.rawQualitySamplingTab),
      (Icons.science_outlined, l10n.rawQualityAnalysisTab),
      (Icons.fact_check_outlined, l10n.rawQualityDecisionTab),
    ];

    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: PernitColors.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: PernitColors.borderMuted),
      ),
      child: Row(
        children: [
          for (var index = 0; index < items.length; index++) ...[
            Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(9.r),
                onTap: () => onSelected(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: EdgeInsets.symmetric(
                    vertical: 10.h,
                    horizontal: 4.w,
                  ),
                  decoration: BoxDecoration(
                    color: selectedIndex == index
                        ? PernitColors.primary
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(9.r),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        items[index].$1,
                        size: 19.r,
                        color: selectedIndex == index
                            ? Colors.white
                            : PernitColors.textMuted,
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        items[index].$2,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: selectedIndex == index
                              ? Colors.white
                              : PernitColors.textStrong,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (index < items.length - 1) SizedBox(width: 4.w),
          ],
        ],
      ),
    );
  }
}

class _SamplingTab extends StatelessWidget {
  final RawMaterialQualityState state;
  final RawMaterialQualityCubit cubit;

  const _SamplingTab({required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final entries = state.entries
        .where((entry) => !entry.isQcDone && !entry.isInStock)
        .toList(growable: false);

    if (entries.isEmpty) {
      return _EmptyQualityState(message: l10n.rawQualitySamplingEmpty);
    }

    return Column(
      children: [
        for (final entry in entries) ...[
          RawMaterialWorkflowCard(
            entry: entry,
            statusLabel: l10n.rawQualitySampleCount(
              state.samples
                  .where((sample) => sample.batchId == entry.id)
                  .length,
            ),
            statusTone: PernitStatusBadgeTone.pending,
            actionLabel: l10n.rawQualityTakeAnotherSample,
            actionIcon: Icons.add_circle_outline,
            isWorking:
                state is RawMaterialQualityWorking &&
                state.activeBatchId == entry.id &&
                state.action == RawMaterialQualityAction.takingSample,
            onAction: () => _takeSample(context, entry.id),
          ),
          SizedBox(height: 10.h),
        ],
        if (state.hasNextPage)
          PernitButton(
            label: l10n.rawWorkflowLoadMore,
            icon: Icons.expand_more_rounded,
            fullWidth: false,
            isLoading:
                state is RawMaterialQualityLoadingMore && !state.loadingSamples,
            onPressed: state is RawMaterialQualityLoadingMore
                ? null
                : cubit.loadMoreEntries,
          ),
      ],
    );
  }

  Future<void> _takeSample(BuildContext context, int batchId) async {
    final succeeded = await cubit.takeSample(batchId);
    if (succeeded && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.rawQualitySampleSuccess),
        ),
      );
    }
  }
}

class _AnalysisTab extends StatelessWidget {
  final RawMaterialQualityState state;
  final RawMaterialQualityCubit cubit;

  const _AnalysisTab({required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final samples = state.samples
        .where((sample) {
          final batch = _batchFor(state.entries, sample.batchId);
          return batch == null || !batch.isQcDone;
        })
        .toList(growable: false);

    if (samples.isEmpty) {
      return _EmptyQualityState(message: l10n.rawQualityAnalysisEmpty);
    }

    return Column(
      children: [
        QualityAnalysisSamplesCard(
          samples: samples,
          workingSampleId: state is RawMaterialQualityWorking
              ? state.activeSampleId
              : null,
          onSamplePressed: (sample) => _openAnalysis(context, sample),
        ),
        if (state.samplesHaveNextPage)
          Padding(
            padding: EdgeInsets.only(top: 10.h),
            child: PernitButton(
              label: l10n.rawWorkflowLoadMore,
              icon: Icons.expand_more_rounded,
              fullWidth: false,
              isLoading:
                  state is RawMaterialQualityLoadingMore &&
                  state.loadingSamples,
              onPressed: state is RawMaterialQualityLoadingMore
                  ? null
                  : cubit.loadMoreSamples,
            ),
          ),
      ],
    );
  }

  Future<void> _openAnalysis(
    BuildContext context,
    RawMaterialSample sample,
  ) async {
    final opened = await cubit.openAnalysis(
      sampleId: sample.id,
      batchId: sample.batchId,
    );
    if (!opened || !context.mounted || cubit.state.workspace == null) {
      return;
    }

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: PernitColors.surface,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: BlocBuilder<RawMaterialQualityCubit, RawMaterialQualityState>(
          builder: (sheetContext, sheetState) {
            final workspace = sheetState.workspace;
            if (workspace == null) {
              return const SizedBox.shrink();
            }
            return RawMaterialAnalysisSheet(
              workspace: workspace,
              isWorking:
                  sheetState is RawMaterialQualityWorking &&
                  sheetState.action == RawMaterialQualityAction.savingAnalysis,
              onSave: cubit.submitAnalysis,
            );
          },
        ),
      ),
    );
    if (!context.mounted) {
      return;
    }
    cubit.closeWorkspace();
    if (saved == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.rawAnalysisSaveSuccess),
        ),
      );
      await cubit.load();
    }
  }
}

class _DecisionTab extends StatelessWidget {
  final RawMaterialQualityState state;
  final RawMaterialQualityCubit cubit;

  const _DecisionTab({required this.state, required this.cubit});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final entries = state.entries
        .where((entry) => entry.isLabDone && !entry.isQcDone)
        .toList(growable: false);

    if (entries.isEmpty) {
      return _EmptyQualityState(message: l10n.rawQualityDecisionEmpty);
    }

    return Column(
      children: [
        for (final entry in entries) ...[
          RawMaterialWorkflowCard(
            entry: entry,
            statusLabel: l10n.rawQualityReviewAnalysis,
            statusTone: PernitStatusBadgeTone.pending,
            actionLabel: l10n.rawQualityDecisionTitle,
            actionIcon: Icons.fact_check_outlined,
            isWorking:
                state is RawMaterialQualityWorking &&
                state.activeBatchId == entry.id,
            onAction: () => _openDecision(context, entry),
          ),
          SizedBox(height: 10.h),
        ],
        if (state.hasNextPage)
          PernitButton(
            label: l10n.rawWorkflowLoadMore,
            icon: Icons.expand_more_rounded,
            fullWidth: false,
            isLoading:
                state is RawMaterialQualityLoadingMore && !state.loadingSamples,
            onPressed: state is RawMaterialQualityLoadingMore
                ? null
                : cubit.loadMoreEntries,
          ),
      ],
    );
  }

  Future<void> _openDecision(
    BuildContext context,
    RawMaterialEntry entry,
  ) async {
    final opened = await cubit.openDecision(entry.id);
    if (!opened || !context.mounted) {
      return;
    }
    final succeeded = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: PernitColors.surface,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: _QualityDecisionSheet(entry: entry),
      ),
    );
    if (!context.mounted) {
      return;
    }
    cubit.closeWorkspace();
    if (succeeded == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.rawQualityDecisionSuccess,
          ),
        ),
      );
    }
  }
}

class _QualityDecisionSheet extends StatefulWidget {
  final RawMaterialEntry entry;

  const _QualityDecisionSheet({required this.entry});

  @override
  State<_QualityDecisionSheet> createState() => _QualityDecisionSheetState();
}

class _QualityDecisionSheetState extends State<_QualityDecisionSheet> {
  final _commentsController = TextEditingController();

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      top: false,
      child: BlocBuilder<RawMaterialQualityCubit, RawMaterialQualityState>(
        builder: (context, state) {
          final isWorking =
              state is RawMaterialQualityWorking &&
              state.action == RawMaterialQualityAction.savingDecision;
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.92,
              ),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(16.w, 12.h, 8.w, 6.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${l10n.rawQualityDecisionTitle}${l10n.separatorDot}'
                            '${widget.entry.rawMaterialName}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        IconButton(
                          onPressed: isWorking
                              ? null
                              : () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.close_rounded),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 16.h),
                      children: [
                        for (final workspace in state.reviewWorkspaces) ...[
                          _SampleResultsReview(workspace: workspace),
                          SizedBox(height: 8.h),
                        ],
                        TextField(
                          controller: _commentsController,
                          enabled: !isWorking,
                          maxLines: 3,
                          maxLength: 1000,
                          decoration: InputDecoration(
                            hintText: l10n.rawQualityDecisionHint,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Expanded(
                              child: PernitButton(
                                label: l10n.rawQualityReject,
                                icon: Icons.close_rounded,
                                variant: PernitButtonVariant.outlined,
                                onPressed: isWorking
                                    ? null
                                    : () => _confirm(
                                        RawMaterialQualityDecision.rejected,
                                      ),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: PernitButton(
                                label: l10n.rawQualityAccept,
                                icon: Icons.check_rounded,
                                isLoading: isWorking,
                                onPressed: isWorking
                                    ? null
                                    : () => _confirm(
                                        RawMaterialQualityDecision.accepted,
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirm(RawMaterialQualityDecision decision) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.rawQualityDecisionTitle),
        content: Text(
          decision == RawMaterialQualityDecision.accepted
              ? l10n.rawQualityAcceptConfirm
              : l10n.rawQualityRejectConfirm,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.screenCancelAction),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: decision == RawMaterialQualityDecision.rejected
                ? FilledButton.styleFrom(backgroundColor: PernitColors.danger)
                : null,
            child: Text(l10n.commonConfirm),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }
    final succeeded = await context
        .read<RawMaterialQualityCubit>()
        .submitDecision(
          decision: decision,
          comments: _commentsController.text.trim().isEmpty
              ? null
              : _commentsController.text.trim(),
        );
    if (succeeded && mounted) {
      Navigator.of(context).pop(true);
    }
  }
}

class _SampleResultsReview extends StatelessWidget {
  final RawMaterialAnalysisWorkspace workspace;

  const _SampleResultsReview({required this.workspace});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final chemical = workspace.chemicalParameters
        .where((parameter) => parameter.value != null)
        .toList(growable: false);
    final physical = workspace.physicalParameters
        .where((parameter) => parameter.value?.isNotEmpty == true)
        .toList(growable: false);

    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: PernitColors.background,
        borderRadius: BorderRadius.circular(11.r),
        border: Border.all(color: PernitColors.borderMuted),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.rawAnalysisSampleNumber(
              workspace.sample.sampleNumber ??
                  l10n.entryIdPrefix(workspace.sample.id.toString()),
            ),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          SizedBox(height: 5.h),
          for (final parameter in chemical)
            _ResultRow(
              name: parameter.name,
              value: '${parameter.value} ${parameter.unit ?? ''}',
              accepted: parameter.isWithinRange,
            ),
          for (final parameter in physical)
            _ResultRow(name: parameter.name, value: parameter.value!),
        ],
      ),
    );
  }
}

class _ResultRow extends StatelessWidget {
  final String name;
  final String value;
  final bool? accepted;

  const _ResultRow({required this.name, required this.value, this.accepted});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.h),
      child: Row(
        children: [
          Expanded(child: Text(name)),
          Directionality(textDirection: TextDirection.ltr, child: Text(value)),
          if (accepted != null) ...[
            SizedBox(width: 5.w),
            Icon(
              accepted! ? Icons.check_circle_outline : Icons.error_outline,
              size: 18.r,
              color: accepted! ? PernitColors.success : PernitColors.danger,
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyQualityState extends StatelessWidget {
  final String message;

  const _EmptyQualityState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: PernitColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: PernitColors.borderMuted),
      ),
      child: Column(
        children: [
          Icon(
            Icons.task_alt_rounded,
            size: 38.r,
            color: PernitColors.textMuted,
          ),
          SizedBox(height: 8.h),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

RawMaterialEntry? _batchFor(List<RawMaterialEntry> entries, int batchId) {
  for (final entry in entries) {
    if (entry.id == batchId) {
      return entry;
    }
  }
  return null;
}
