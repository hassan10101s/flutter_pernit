import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/dependency_injection.dart';
import '../../../../core/localization/failure_message_localizer.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../design_system/tokens/pernit_colors.dart';
import '../../../../design_system/widgets/pernit_floating_action_button.dart';
import '../../../../design_system/widgets/pernit_icon_button.dart';
import '../bloc/raw_material_entry_cubit.dart';
import '../bloc/raw_material_entry_state.dart';
import '../../domain/entities/raw_material_entry.dart';
import '../../domain/entities/raw_material_entry_lookup.dart';
import '../widgets/raw_material_entry_content.dart';
import '../widgets/raw_material_entry_copy.dart';
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
    final copy = RawMaterialEntryCopy.of(context);

    return BlocConsumer<RawMaterialEntryCubit, RawMaterialEntryState>(
      listener: (context, state) {
        if (state is RawMaterialEntrySubmitSuccess) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(copy.submitSuccess)));
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

        return LayoutBuilder(
          builder: (context, constraints) {
            final frameHeight = constraints.hasBoundedHeight
                ? constraints.maxHeight
                : 1388.0;

            return ColoredBox(
              color: PernitColors.appCanvas,
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 390,
                    minHeight: frameHeight,
                  ),
                  child: _RawMaterialReceivedFrame(
                    state: state,
                    isSubmitting: isSubmitting,
                    isRefreshingLookups: isRefreshing,
                    onRetry: () => cubit.load(status: state.selectedStatus),
                    onStatusSelected: cubit.selectStatus,
                    onRefreshLookups: cubit.refreshLookups,
                    onSubmit: cubit.submit,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _RawMaterialReceivedFrame extends StatelessWidget {
  final RawMaterialEntryState state;
  final bool isSubmitting;
  final bool isRefreshingLookups;
  final VoidCallback onRetry;
  final ValueChanged<RawMaterialEntryStatus?> onStatusSelected;
  final VoidCallback onRefreshLookups;
  final ValueChanged<RawMaterialEntryDraft> onSubmit;

  const _RawMaterialReceivedFrame({
    required this.state,
    required this.isSubmitting,
    required this.isRefreshingLookups,
    required this.onRetry,
    required this.onStatusSelected,
    required this.onRefreshLookups,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final copy = RawMaterialEntryCopy.of(context);

    return Stack(
      children: [
        Positioned.fill(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: _TopHeader(copy: copy)),
              SliverToBoxAdapter(
                child: RawMaterialEntryStatusFilterBar(
                  selectedStatus: state.selectedStatus,
                  onStatusSelected: onStatusSelected,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                sliver: SliverToBoxAdapter(
                  child: RawMaterialEntryContent(
                    state: state,
                    onRetry: onRetry,
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 12,
          bottom: 75,
          child: PernitFloatingActionButton(
            icon: Icons.add_rounded,
            heroTag: 'raw-material-entry-add',
            tooltip: copy.submit,
            onPressed: () => _openEntrySheet(context),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: _BottomNavigation(copy: copy),
        ),
      ],
    );
  }

  void _openEntrySheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: RawMaterialEntryForm(
                  lookups: state.lookups,
                  isSubmitting: isSubmitting,
                  isRefreshingLookups: isRefreshingLookups,
                  onRefreshLookups: onRefreshLookups,
                  onSubmit: (draft) {
                    Navigator.of(sheetContext).pop();
                    onSubmit(draft);
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TopHeader extends StatelessWidget {
  final RawMaterialEntryCopy copy;

  const _TopHeader({required this.copy});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 59,
      padding: const EdgeInsets.fromLTRB(8, 11, 16, 10),
      decoration: const BoxDecoration(
        color: Color(0xE6F6F8F7),
        border: Border(bottom: BorderSide(color: PernitColors.borderMuted)),
      ),
      child: Row(
        children: [
          PernitIconButton(
            icon: Icons.arrow_back,
            onPressed: () => Navigator.maybePop(context),
            size: 32,
            iconSize: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              copy.designTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: PernitColors.textInk,
                fontSize: 20,
                height: 1.4,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ),
          const SizedBox(width: 10),
          PernitIconButton(
            icon: Icons.search,
            onPressed: () {},
            size: 36,
            iconSize: 20,
            backgroundColor: PernitColors.surface,
            foregroundColor: PernitColors.textInk,
            borderColor: PernitColors.borderSoft,
            elevated: true,
          ),
          const SizedBox(width: 8),
          PernitIconButton(
            icon: Icons.tune_rounded,
            onPressed: () {},
            size: 36,
            iconSize: 20,
            backgroundColor: PernitColors.success,
            foregroundColor: PernitColors.textInk,
            elevated: true,
          ),
        ],
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  final RawMaterialEntryCopy copy;

  const _BottomNavigation({required this.copy});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 59,
      decoration: const BoxDecoration(
        color: PernitColors.appCanvas,
        border: Border(top: BorderSide(color: PernitColors.borderMuted)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 1, 16, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _BottomNavItem(
            icon: Icons.input_rounded,
            label: copy.intake,
            selected: true,
          ),
          _BottomNavItem(
            icon: Icons.inventory_2_outlined,
            label: copy.inventory,
          ),
          _BottomNavItem(icon: Icons.factory_outlined, label: copy.production),
          _BottomNavItem(icon: Icons.verified_outlined, label: copy.quality),
        ],
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? PernitColors.textInk : PernitColors.textSubtle;

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 2),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 12,
              height: 1.5,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
