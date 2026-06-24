import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/localization/failure_message_localizer.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../design_system/tokens/pernit_colors.dart';
import '../../../../design_system/widgets/pernit_button.dart';
import '../../../../design_system/widgets/pernit_panel_header.dart';
import '../../domain/entities/raw_material_entry_lookup.dart';
import '../bloc/raw_material_entry_cubit.dart';
import '../bloc/raw_material_entry_state.dart';
import '../widgets/raw_material_entry_content.dart';
import '../widgets/raw_material_entry_form.dart';
import '../widgets/raw_material_entry_status_filter_bar.dart';

class RawMaterialEntryScreen extends StatelessWidget {
  const RawMaterialEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<RawMaterialEntryCubit>()..load(),
      child: const _RawMaterialEntryView(),
    );
  }
}

class _RawMaterialEntryView extends StatelessWidget {
  const _RawMaterialEntryView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<RawMaterialEntryCubit, RawMaterialEntryState>(
      listener: (context, state) {
        if (state is RawMaterialEntrySubmitSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.entrySubmitSuccess)));
        } else if (state is RawMaterialEntrySubmitError) {
          final message = FailureMessageLocalizer.messageFor(
            AppLocalizations.of(context)!,
            state.failure.messageKey,
          );
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(message)));
        }
      },
      builder: (context, state) {
        final cubit = context.read<RawMaterialEntryCubit>();
        final isSubmitting = state is RawMaterialEntrySubmitting;
        final isRefreshing = state is RawMaterialEntryLookupsRefreshing;

        return ColoredBox(
          color: PernitColors.background,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.r),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 1100.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PernitPanelHeader(
                      icon: Icons.move_to_inbox_outlined,
                      title: l10n.entryTitle,
                      subtitle: l10n.entrySubtitle,
                    ),
                    SizedBox(height: 14.h),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: PernitButton(
                        label: l10n.entrySubmit,
                        icon: Icons.add_rounded,
                        fullWidth: false,
                        onPressed: () => _openEntrySheet(
                          context,
                          state: state,
                          isSubmitting: isSubmitting,
                          isRefreshing: isRefreshing,
                          onRefresh: cubit.refreshLookups,
                          onSubmit: cubit.submit,
                        ),
                      ),
                    ),
                    SizedBox(height: 14.h),
                    RawMaterialEntryStatusFilterBar(
                      selectedStatus: state.selectedStatus,
                      onStatusSelected: cubit.selectStatus,
                    ),
                    SizedBox(height: 12.h),
                    RawMaterialEntryContent(
                      state: state,
                      onRetry: () => cubit.load(status: state.selectedStatus),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _openEntrySheet(
    BuildContext context, {
    required RawMaterialEntryState state,
    required bool isSubmitting,
    required bool isRefreshing,
    required VoidCallback onRefresh,
    required ValueChanged<RawMaterialEntryDraft> onSubmit,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: PernitColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.r),
              child: RawMaterialEntryForm(
                lookups: state.lookups,
                isSubmitting: isSubmitting,
                isRefreshingLookups: isRefreshing,
                onRefreshLookups: onRefresh,
                onSubmit: (draft) {
                  Navigator.of(sheetContext).pop();
                  onSubmit(draft);
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
