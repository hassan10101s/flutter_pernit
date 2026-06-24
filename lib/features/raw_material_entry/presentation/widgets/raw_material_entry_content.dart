import 'package:flutter/material.dart';

import '../../../../core/localization/failure_message_localizer.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../design_system/tokens/pernit_colors.dart';
import '../../../../design_system/tokens/pernit_font_weights.dart';
import '../../../../design_system/widgets/pernit_button.dart';
import '../../domain/entities/raw_material_entry.dart';
import '../bloc/raw_material_entry_state.dart';
import 'raw_material_entry_card.dart';

class RawMaterialEntryContent extends StatelessWidget {
  final RawMaterialEntryState state;
  final VoidCallback onRetry;

  const RawMaterialEntryContent({
    super.key,
    required this.state,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      RawMaterialEntryInitial() ||
      RawMaterialEntryLoading() => const _RawMaterialEntryLoadingView(),
      RawMaterialEntryError(failure: final failure) =>
        _RawMaterialEntryErrorView(
          message: FailureMessageLocalizer.messageFor(
            AppLocalizations.of(context)!,
            failure.messageKey,
          ),
          onRetry: onRetry,
        ),
      RawMaterialEntryEmpty() => const _RawMaterialEntryEmptyView(),
      _ => _RawMaterialEntryLoadedView(entries: state.entries),
    };
  }
}

class _RawMaterialEntryLoadedView extends StatelessWidget {
  final List<RawMaterialEntry> entries;

  const _RawMaterialEntryLoadedView({required this.entries});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final entry in entries) ...[
          RawMaterialEntryCard(entry: entry),
          const SizedBox(height: 20),
        ],
      ],
    );
  }
}

class _RawMaterialEntryLoadingView extends StatelessWidget {
  const _RawMaterialEntryLoadingView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        _LoadingTile(),
        _LoadingGap(),
        _LoadingTile(),
        _LoadingGap(),
        _LoadingTile(),
      ],
    );
  }
}

class _LoadingGap extends StatelessWidget {
  const _LoadingGap();

  @override
  Widget build(BuildContext context) => const SizedBox(height: 10);
}

class _LoadingTile extends StatelessWidget {
  const _LoadingTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 254,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _LoadingLine(widthFactor: 0.45, height: 14),
          const SizedBox(height: 12),
          const _LoadingLine(widthFactor: 0.78, height: 12),
          const SizedBox(height: 18),
          const _LoadingLine(widthFactor: 1, height: 8),
        ],
      ),
    );
  }
}

class _LoadingLine extends StatelessWidget {
  final double widthFactor;
  final double height;

  const _LoadingLine({required this.widthFactor, required this.height});

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: AlignmentDirectional.centerStart,
      widthFactor: widthFactor,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: PernitColors.border.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class _RawMaterialEntryEmptyView extends StatelessWidget {
  const _RawMaterialEntryEmptyView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _StatePanel(
      icon: Icons.inbox_outlined,
      title: l10n.entryEmptyTitle,
      message: l10n.entryEmptyMessage,
    );
  }
}

class _RawMaterialEntryErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _RawMaterialEntryErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return _StatePanel(
      icon: Icons.cloud_off_outlined,
      title: l10n.entryErrorTitle,
      message: message,
      actionLabel: l10n.entryRetry,
      onAction: onRetry,
    );
  }
}

class _StatePanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _StatePanel({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        children: [
          Icon(icon, color: PernitColors.textMuted, size: 34),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: PernitColors.textStrong,
              fontWeight: PernitFontWeights.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: PernitColors.textMuted),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 14),
            PernitButton(
              label: actionLabel!,
              icon: Icons.refresh_rounded,
              variant: PernitButtonVariant.outlined,
              fullWidth: false,
              height: 40,
              onPressed: onAction,
            ),
          ],
        ],
      ),
    );
  }
}
