import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/spacing.dart';
import '../../../../design_system/dialogs/pernit_screen_detail_dialog.dart';
import '../../../../design_system/tokens/pernit_colors.dart';
import '../../../../design_system/tokens/pernit_font_weights.dart';
import '../bloc/screen_records_cubit.dart';
import '../bloc/screen_records_state.dart';

typedef ScreenRecordsCubitFactory =
    ScreenRecordsCubit Function(
      PernitScreenDetailItem item,
      List<PernitScreenRecord> initialRecords,
    );

class ScreenRecordFeatureSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<PernitScreenDetailItem> screens;
  final ScreenRecordsCubitFactory createCubit;

  const ScreenRecordFeatureSection({
    super.key,
    required this.title,
    required this.subtitle,
    required this.screens,
    required this.createCubit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: PernitColors.textStrong,
            fontWeight: PernitFontWeights.bold,
          ),
        ),
        verticalSpace(4),
        Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: PernitColors.textMuted),
        ),
        verticalSpace(10),
        for (final screen in screens) ...[
          _ScreenRecordFeatureTile(item: screen, createCubit: createCubit),
          verticalSpace(8),
        ],
      ],
    );
  }
}

class _ScreenRecordFeatureTile extends StatelessWidget {
  final PernitScreenDetailItem item;
  final ScreenRecordsCubitFactory createCubit;

  const _ScreenRecordFeatureTile({
    required this.item,
    required this.createCubit,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => createCubit(item, item.records)..load(),
      child: BlocBuilder<ScreenRecordsCubit, ScreenRecordsState>(
        builder: (context, state) {
          return _ScreenTile(
            item: item,
            records: _recordsForState(state, item.records),
          );
        },
      ),
    );
  }
}

class _ScreenTile extends StatelessWidget {
  final PernitScreenDetailItem item;
  final List<PernitScreenRecord> records;

  const _ScreenTile({required this.item, required this.records});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: PernitColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
        side: const BorderSide(color: PernitColors.border),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(8.r),
        onTap: () => showDialog<void>(
          context: context,
          builder: (_) => BlocProvider.value(
            value: context.read<ScreenRecordsCubit>(),
            child: BlocBuilder<ScreenRecordsCubit, ScreenRecordsState>(
              builder: (context, state) {
                return PernitScreenDetailDialog(
                  item: item,
                  records: _recordsForState(state, records),
                  onAdd: context.read<ScreenRecordsCubit>().addRecord,
                  onEdit: context.read<ScreenRecordsCubit>().updateRecord,
                  onDelete: context.read<ScreenRecordsCubit>().deleteRecord,
                );
              },
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          child: Row(
            children: [
              Icon(item.icon, color: PernitColors.primary, size: 22.r),
              horizontalSpace(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: PernitColors.textStrong,
                        fontWeight: PernitFontWeights.medium,
                      ),
                    ),
                    verticalSpace(3),
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        item.endpoint,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: PernitColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: PernitColors.textMuted,
                size: 22.r,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

List<PernitScreenRecord> _recordsForState(
  ScreenRecordsState state,
  List<PernitScreenRecord> fallback,
) {
  return switch (state) {
    ScreenRecordsInitial() ||
    ScreenRecordsLoading() when state.records.isEmpty => fallback,
    _ => state.records,
  };
}
