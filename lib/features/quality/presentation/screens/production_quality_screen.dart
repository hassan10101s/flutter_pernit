import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/localization/failure_message_localizer.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../design_system/forms/pernit_lookup_autocomplete_field.dart';
import '../../../../design_system/status_indicators/pernit_status_badge.dart';
import '../../../../design_system/tokens/pernit_colors.dart';
import '../../../../design_system/widgets/pernit_button.dart';
import '../../data/datasources/production_quality_remote_data_source.dart';
import '../../domain/entities/production_lab_sample.dart';
import '../../domain/entities/production_lab_result.dart';
import '../../domain/entities/production_quality_check.dart';
import '../bloc/production_quality_cubit.dart';
import '../bloc/production_quality_state.dart';

class ProductionQualityScreen extends StatelessWidget {
  const ProductionQualityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ProductionQualityCubit>()..loadAll(),
      child: const _ProductionQualityView(),
    );
  }
}

class _ProductionQualityView extends StatefulWidget {
  const _ProductionQualityView();

  @override
  State<_ProductionQualityView> createState() => _ProductionQualityViewState();
}

class _ProductionQualityViewState extends State<_ProductionQualityView> {
  var _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<ProductionQualityCubit, ProductionQualityState>(
      listener: (context, state) {
        if (state.failure != null) {
          final message = FailureMessageLocalizer.messageFor(
            l10n,
            state.failure!.messageKey,
          );
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
      },
      builder: (context, state) {
        if (state is ProductionQualityInitial ||
            (state is ProductionQualityLoading &&
                state.samples.isEmpty &&
                state.results.isEmpty &&
                state.checks.isEmpty)) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _ProductionTabs(
              selectedIndex: _selectedTab,
              onSelected: (index) => setState(() => _selectedTab = index),
            ),
            SizedBox(height: 12.h),
            Expanded(
              child: switch (_selectedTab) {
                0 => _SamplesTab(state: state),
                1 => _ResultsTab(state: state),
                _ => _ChecksTab(state: state),
              },
            ),
          ],
        );
      },
    );
  }
}

class _ProductionTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const _ProductionTabs({
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final items = [
      (Icons.colorize_outlined, l10n.prodQualitySamplesTab),
      (Icons.science_outlined, l10n.prodQualityResultsTab),
      (Icons.fact_check_outlined, l10n.prodQualityChecksTab),
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

class _SamplesTab extends StatelessWidget {
  final ProductionQualityState state;

  const _SamplesTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<ProductionQualityCubit>();

    if (state.isLoadingSamples && state.samples.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => cubit.loadSamples(),
      child: ListView(
        padding: EdgeInsets.only(top: 8.h),
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: PernitButton(
              label: l10n.prodQualityCreateSample,
              icon: Icons.add_circle_outline,
              isLoading: state.isCreatingSample,
              onPressed: state.isCreatingSample
                  ? null
                  : () => _showCreateSampleSheet(context),
            ),
          ),
          if (state.samples.isEmpty)
            _EmptyState(message: l10n.prodQualitySamplesEmpty)
          else ...[
            for (final sample in state.samples) _SampleCard(sample: sample),
            if (state.samplesHasMore)
              Center(
                child: PernitButton(
                  label: l10n.rawWorkflowLoadMore,
                  icon: Icons.expand_more_rounded,
                  fullWidth: false,
                  isLoading: state.isLoadingSamples,
                  onPressed: state.isLoadingSamples
                      ? null
                      : cubit.loadMoreSamples,
                ),
              ),
          ],
        ],
      ),
    );
  }

  void _showCreateSampleSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: PernitColors.surface,
      builder: (_) => _CreateSampleSheet(
        onCreated: (orderId, quantityTaken) {
          if (!context.mounted) return;
          context.read<ProductionQualityCubit>().createSample(
            productionOrderId: orderId,
            quantityTaken: quantityTaken,
          );
        },
      ),
    );
  }
}

class _ResultsTab extends StatelessWidget {
  final ProductionQualityState state;

  const _ResultsTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<ProductionQualityCubit>();

    if (state.isLoadingResults && state.results.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => cubit.loadResults(),
      child: ListView(
        padding: EdgeInsets.only(top: 8.h),
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: PernitButton(
              label: l10n.prodQualityCreateResult,
              icon: Icons.add_circle_outline,
              isLoading: state.isCreatingResult,
              onPressed: state.isCreatingResult
                  ? null
                  : () => _showCreateResultSheet(context),
            ),
          ),
          if (state.results.isEmpty)
            _EmptyState(message: l10n.prodQualityResultsEmpty)
          else ...[
            for (final result in state.results) _ResultCard(result: result),
            if (state.resultsHasMore)
              Center(
                child: PernitButton(
                  label: l10n.rawWorkflowLoadMore,
                  icon: Icons.expand_more_rounded,
                  fullWidth: false,
                  isLoading: state.isLoadingResults,
                  onPressed: state.isLoadingResults
                      ? null
                      : cubit.loadMoreResults,
                ),
              ),
          ],
        ],
      ),
    );
  }

  void _showCreateResultSheet(BuildContext context) {
    final currentSamples = context.read<ProductionQualityCubit>().state.samples;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: PernitColors.surface,
      builder: (_) => _CreateResultSheet(
        loadedSamples: currentSamples,
        onCreated: (sampleId, parameterId, value) {
          if (!context.mounted) return;
          context.read<ProductionQualityCubit>().createResult(
            sampleId: sampleId,
            parameterId: parameterId,
            value: value,
          );
        },
      ),
    );
  }
}

class _ChecksTab extends StatelessWidget {
  final ProductionQualityState state;

  const _ChecksTab({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cubit = context.read<ProductionQualityCubit>();

    if (state.isLoadingChecks && state.checks.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => cubit.loadChecks(),
      child: ListView(
        padding: EdgeInsets.only(top: 8.h),
        children: [
          if (state.checks.isEmpty)
            _EmptyState(message: l10n.prodQualityChecksEmpty)
          else ...[
            for (final check in state.checks) _CheckCard(check: check),
            if (state.checksHasMore)
              Center(
                child: PernitButton(
                  label: l10n.rawWorkflowLoadMore,
                  icon: Icons.expand_more_rounded,
                  fullWidth: false,
                  isLoading: state.isLoadingChecks,
                  onPressed: state.isLoadingChecks
                      ? null
                      : cubit.loadMoreChecks,
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _SampleCard extends StatelessWidget {
  final ProductionLabSample sample;

  const _SampleCard({required this.sample});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: PernitColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: PernitColors.borderMuted),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  sample.productionOrderCode ??
                      l10n.entryIdPrefix(sample.id.toString()),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              _StatusBadge(status: sample.status, l10n: l10n),
            ],
          ),
          SizedBox(height: 6.h),
          if (sample.quantityTaken != null) ...[
            Text(
              '${l10n.prodQualityQuantityTaken}: ${sample.quantityTaken}',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: PernitColors.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final ProductionLabResult result;

  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: PernitColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: PernitColors.borderMuted),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  result.parameterName ??
                      l10n.entryIdPrefix(result.id.toString()),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              if (result.isWithinRange)
                Icon(
                  Icons.check_circle,
                  color: PernitColors.success,
                  size: 18.r,
                )
              else
                Icon(
                  Icons.error_outline,
                  color: PernitColors.danger,
                  size: 18.r,
                ),
            ],
          ),
          SizedBox(height: 4.h),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              result.value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            result.sampleNo ?? l10n.prodQualitySampleLabel(result.sampleId),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: PernitColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _CheckCard extends StatelessWidget {
  final ProductionQualityCheck check;

  const _CheckCard({required this.check});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: PernitColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: PernitColors.borderMuted),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.prodQualityCheckLabel(check.id),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              _StatusBadge(status: check.status, l10n: l10n),
            ],
          ),
          if (check.productionOrderCode != null) ...[
            SizedBox(height: 4.h),
            Text(
              check.productionOrderCode!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: PernitColors.textMuted),
            ),
          ],
          if (check.checkedByName != null) ...[
            SizedBox(height: 4.h),
            Text(
              check.checkedByName!,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: PernitColors.textMuted),
            ),
          ],
          if (check.comments != null && check.comments!.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Text(check.comments!, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}

class _CreateSampleSheet extends StatefulWidget {
  final void Function(int orderId, String? quantityTaken) onCreated;

  const _CreateSampleSheet({required this.onCreated});

  @override
  State<_CreateSampleSheet> createState() => _CreateSampleSheetState();
}

class _CreateSampleSheetState extends State<_CreateSampleSheet> {
  final _quantityController = TextEditingController();
  int? _selectedOrderId;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<List<PernitLookupItem<int>>> _fetchOrders(String query) async {
    final dataSource = sl<ProductionQualityRemoteDataSource>();
    final orders = await dataSource.fetchProductionOrders(search: query);
    return orders.map((o) {
      final id = (o['id'] as num).toInt();
      final orderNo = o['order_no'] as String? ?? '';
      final formulaName = o['formula_name'] as String?;
      final status = o['status'] as String?;
      final totalTons = o['total_tons'] as String?;
      final parts = <String>[orderNo];
      if (formulaName != null && formulaName.isNotEmpty) {
        parts.add(formulaName);
      }
      if (totalTons != null && totalTons.isNotEmpty) {
        parts.add('$totalTons t');
      }
      return PernitLookupItem<int>(
        value: id,
        label: orderNo,
        subtitle: parts.length > 1 ? parts.sublist(1).join(' | ') : status,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.prodQualityCreateSample,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          PernitLookupAutocompleteField<int>(
            fetchItems: _fetchOrders,
            selectedItem: _selectedOrderId != null
                ? PernitLookupItem<int>(
                    value: _selectedOrderId!,
                    label: _selectedOrderId.toString(),
                  )
                : null,
            onSelected: (item) => _selectedOrderId = item.value,
            labelText: l10n.prodQualityProductionOrder,
            hintText: l10n.prodQualityProductionOrderHint,
            emptyText: l10n.prodQualityNoOrders,
            errorText: l10n.failureUnknown,
            loadingText: l10n.rawWorkflowRefresh,
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: _quantityController,
            decoration: InputDecoration(
              labelText: l10n.prodQualityQuantityTaken,
              hintText: l10n.prodQualityQuantityTakenHint,
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: true),
          ),
          SizedBox(height: 20.h),
          PernitButton(
            label: l10n.prodQualityCreateSampleAction,
            onPressed: () {
              if (_selectedOrderId == null) return;
              final quantity = _quantityController.text.trim();
              widget.onCreated(
                _selectedOrderId!,
                quantity.isNotEmpty ? quantity : null,
              );
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

class _CreateResultSheet extends StatefulWidget {
  final List<ProductionLabSample> loadedSamples;
  final void Function(int sampleId, int parameterId, String value) onCreated;

  const _CreateResultSheet({
    required this.loadedSamples,
    required this.onCreated,
  });

  @override
  State<_CreateResultSheet> createState() => _CreateResultSheetState();
}

class _CreateResultSheetState extends State<_CreateResultSheet> {
  final _valueController = TextEditingController();
  int? _selectedSampleId;
  int? _selectedParameterId;

  @override
  void dispose() {
    _valueController.dispose();
    super.dispose();
  }

  Future<List<PernitLookupItem<int>>> _fetchSamples(String query) async {
    final filtered = widget.loadedSamples.where((s) {
      final code = s.productionOrderCode ?? '';
      return code.toLowerCase().contains(query.toLowerCase());
    }).toList();
    return filtered
        .map(
          (s) => PernitLookupItem<int>(
            value: s.id,
            label: s.productionOrderCode ?? '#${s.id}',
            subtitle:
                '${s.status} | ${s.createdAt.toString().substring(0, 10)}',
          ),
        )
        .toList();
  }

  Future<List<PernitLookupItem<int>>> _fetchParameters(String query) async {
    final dataSource = sl<ProductionQualityRemoteDataSource>();
    final params = await dataSource.fetchAnalysisParameters();
    final filtered = params.where((p) {
      final name = (p['name'] as String? ?? '').toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();
    return filtered
        .map(
          (p) => PernitLookupItem<int>(
            value: (p['id'] as num).toInt(),
            label: p['name'] as String? ?? '',
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.prodQualityCreateResult,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          PernitLookupAutocompleteField<int>(
            fetchItems: _fetchSamples,
            selectedItem: _selectedSampleId != null
                ? PernitLookupItem<int>(
                    value: _selectedSampleId!,
                    label: '#$_selectedSampleId',
                  )
                : null,
            onSelected: (item) => _selectedSampleId = item.value,
            labelText: l10n.prodQualitySampleLabelSelect,
            hintText: l10n.prodQualitySampleSearchHint,
            emptyText: l10n.prodQualityNoSamples,
            errorText: l10n.failureUnknown,
            loadingText: l10n.rawWorkflowRefresh,
          ),
          SizedBox(height: 12.h),
          PernitLookupAutocompleteField<int>(
            fetchItems: _fetchParameters,
            selectedItem: _selectedParameterId != null
                ? PernitLookupItem<int>(
                    value: _selectedParameterId!,
                    label: _selectedParameterId.toString(),
                  )
                : null,
            onSelected: (item) => _selectedParameterId = item.value,
            labelText: l10n.prodQualityParameter,
            hintText: l10n.prodQualityParameterHint,
            emptyText: l10n.prodQualityNoParameters,
            errorText: l10n.failureUnknown,
            loadingText: l10n.rawWorkflowRefresh,
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: _valueController,
            decoration: InputDecoration(
              labelText: l10n.prodQualityMeasuredValue,
              hintText: l10n.prodQualityMeasuredValueHint,
            ),
          ),
          SizedBox(height: 20.h),
          PernitButton(
            label: l10n.prodQualityCreateResultAction,
            onPressed: () {
              if (_selectedSampleId == null ||
                  _selectedParameterId == null ||
                  _valueController.text.trim().isEmpty) {
                return;
              }
              widget.onCreated(
                _selectedSampleId!,
                _selectedParameterId!,
                _valueController.text.trim(),
              );
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final AppLocalizations l10n;

  const _StatusBadge({required this.status, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final tone = switch (status) {
      'completed' || 'accepted' || 'release' => PernitStatusBadgeTone.success,
      'rejected' || 'invalid' => PernitStatusBadgeTone.danger,
      'quarantine' => PernitStatusBadgeTone.pending,
      _ => PernitStatusBadgeTone.pending,
    };

    final label = switch (status) {
      'pending' => l10n.prodQualityStatusPending,
      'completed' => l10n.prodQualityStatusCompleted,
      'invalid' => l10n.prodQualityStatusInvalid,
      'accepted' => l10n.prodQualityStatusAccepted,
      'rejected' => l10n.prodQualityStatusRejected,
      'release' => l10n.prodQualityStatusRelease,
      'quarantine' => l10n.prodQualityStatusQuarantine,
      _ => status,
    };

    return PernitStatusBadge(label: label, tone: tone);
  }
}

class _EmptyState extends StatelessWidget {
  final String message;

  const _EmptyState({required this.message});

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
