import 'package:flutter/material.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../design_system/status_indicators/pernit_status_badge.dart';
import '../../../../design_system/tokens/pernit_colors.dart';
import '../../domain/entities/raw_material_entry.dart';

class RawMaterialEntryCard extends StatelessWidget {
  final RawMaterialEntry entry;

  const RawMaterialEntryCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      constraints: const BoxConstraints(minHeight: 254),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: PernitColors.borderSoft),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 12,
            offset: Offset(0, 3),
          ),
          BoxShadow(
            color: Color(0x08D90909),
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 14, 10, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Text(
                        entry.rawMaterialName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: const Color(0xFF0F172A),
                          fontSize: 18,
                          height: 28 / 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    PernitStatusBadge(
                      label: _designStatusLabel(l10n, entry.status),
                      tone: _statusBadgeTone(entry.status),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                _CardMetaRow(entry: entry, l10n: l10n),
                const SizedBox(height: 10),
                _InfoGrid(entry: entry, l10n: l10n),
              ],
            ),
          ),
          const Divider(height: 1, color: PernitColors.borderSoft),
          Container(
            color: const Color(0x80F8FAFC),
            padding: const EdgeInsets.fromLTRB(0, 6, 0, 9),
            child: _ProgressStepper(entry: entry, l10n: l10n),
          ),
        ],
      ),
    );
  }
}

class _CardMetaRow extends StatelessWidget {
  final RawMaterialEntry entry;
  final AppLocalizations l10n;

  const _CardMetaRow({required this.entry, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.entryDateFormat(
              l10n.entryDateLabel,
              l10n.entryMetaSeparator,
              _figmaDate(entry.createdAt),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _metaStyle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            l10n.entryIdFormat(
              l10n.entryIdLabel,
              l10n.entryMetaSeparator,
              entry.entryCode,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _metaStyle,
          ),
        ),
      ],
    );
  }
}

class _InfoGrid extends StatelessWidget {
  final RawMaterialEntry entry;
  final AppLocalizations l10n;

  const _InfoGrid({required this.entry, required this.l10n});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 66,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _InfoColumn(
              label: l10n.entrySupplier,
              value: entry.supplierName ?? l10n.entryNoSupplier,
              withLeadingBorder: true,
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoTinyLabel(label: l10n.entryVehicleNo),
                _InfoTinyValue(value: entry.vehicleNo ?? '-'),
                const SizedBox(height: 4),
                _InfoTinyLabel(label: l10n.entryDriver),
                _InfoTinyValue(value: entry.driverName ?? '-'),
              ],
            ),
          ),
          const SizedBox(width: 5),
          SizedBox(
            width: 94,
            child: _InfoColumn(
              label: l10n.entrySupplierWeight,
              value: _quantityValue(
                l10n,
                entry.quantityFromSupplier,
                entry.unitName,
              ),
              withLeadingBorder: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoColumn extends StatelessWidget {
  final String label;
  final String value;
  final bool withLeadingBorder;

  const _InfoColumn({
    required this.label,
    required this.value,
    this.withLeadingBorder = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsetsDirectional.only(start: withLeadingBorder ? 6 : 0),
      decoration: BoxDecoration(
        border: withLeadingBorder
            ? const Border(left: BorderSide(color: PernitColors.borderMuted))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoTinyLabel(label: label),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF334155),
              fontSize: 14,
              height: 20 / 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoTinyLabel extends StatelessWidget {
  final String label;

  const _InfoTinyLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: const Color(0xFF94A3B8),
        fontSize: 10,
        height: 1.1,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _InfoTinyValue extends StatelessWidget {
  final String value;

  const _InfoTinyValue({required this.value});

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: const Color(0xBF334155),
        fontSize: 9,
        height: 10 / 9,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
      ),
    );
  }
}

class _ProgressStepper extends StatelessWidget {
  final RawMaterialEntry entry;
  final AppLocalizations l10n;

  const _ProgressStepper({required this.entry, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final activeIndex = _activeStepIndex(entry);
    final isRejected = entry.status == RawMaterialEntryStatus.rejected;
    final metadata = entry.metadata;
    final firstSample = metadata?.samplingHistory.firstOrNull;
    final lastQc = metadata?.qcHistory.lastOrNull;
    final sampleCount = metadata?.samplingHistory.length ?? 0;

    final steps = [
      _StepInfo(
        label: l10n.cardStepperArrived,
        icon: Icons.local_shipping_outlined,
        detail: _arrivedDetail(l10n, entry),
        time: _figmaTime(entry.createdAt),
      ),
      _StepInfo(
        label: l10n.cardStepperSampled,
        icon: Icons.science_outlined,
        detail: firstSample != null
            ? '${l10n.cardStepperBy(firstSample.takenBy)} • $sampleCount ${l10n.rawQualitySamplesCount(sampleCount)}'
            : l10n.cardStepperPending,
        time: firstSample != null ? _figmaTime(firstSample.takenAt) : '',
      ),
      _StepInfo(
        label: l10n.cardStepperLab,
        icon: Icons.biotech_outlined,
        detail: entry.isLabDone
            ? l10n.cardStepperProcessing
            : l10n.cardStepperPending,
        time: entry.isLabDone && entry.updatedAt != null
            ? _figmaTime(entry.updatedAt!)
            : '',
      ),
      _StepInfo(
        label: l10n.cardStepperQc,
        icon: Icons.verified_user_outlined,
        detail: lastQc != null
            ? l10n.cardStepperBy(lastQc.checkedByName)
            : l10n.cardStepperPending,
        time: lastQc != null ? _figmaTime(lastQc.timestamp) : '',
      ),
      _StepInfo(
        label: l10n.cardStepperDecision,
        icon: Icons.gavel_outlined,
        detail: isRejected
            ? l10n.cardStepperRejected
            : entry.status == RawMaterialEntryStatus.approved
            ? l10n.cardStepperApproved
            : l10n.cardStepperPending,
        time: entry.status.isClosed && entry.updatedAt != null
            ? _figmaTime(entry.updatedAt!)
            : '',
      ),
    ];

    return SizedBox(
      height: 96,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            left: 32,
            right: 32,
            top: 44,
            child: Row(
              children: [
                Expanded(
                  flex: activeIndex.clamp(0, 4),
                  child: Container(height: 2, color: const Color(0xFF2BEE79)),
                ),
                Expanded(
                  flex: 4 - activeIndex.clamp(0, 4),
                  child: Container(height: 2, color: const Color(0xFFFEF08A)),
                ),
              ],
            ),
          ),
          Row(
            children: [
              for (var index = 0; index < steps.length; index += 1)
                Expanded(
                  child: _StepperStep(
                    info: steps[index],
                    state: _stepVisualState(index, activeIndex, entry.status),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepperStep extends StatelessWidget {
  final _StepInfo info;
  final _StepVisualState state;

  const _StepperStep({required this.info, required this.state});

  @override
  Widget build(BuildContext context) {
    final isGreen =
        state == _StepVisualState.completed ||
        state == _StepVisualState.activeGreen;
    final isRed = state == _StepVisualState.rejected;
    final circleFill = state == _StepVisualState.completed
        ? const Color(0xFF2BEE79)
        : isRed
        ? const Color(0xFFFF5F66)
        : Colors.white;
    final borderColor = isGreen
        ? const Color(0xFF2BEE79)
        : isRed
        ? const Color(0xFFFF5F66)
        : const Color(0xFFFEF08A);
    final textColor = isRed
        ? const Color(0xFFFF5F66)
        : isGreen
        ? const Color(0xFF2BEE79)
        : const Color(0xFF94A3B8);
    final iconColor = state == _StepVisualState.completed
        ? Colors.white
        : isRed
        ? Colors.black
        : borderColor;

    return Column(
      children: [
        Text(
          info.label.toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: textColor,
            fontSize: 10,
            height: 15 / 10,
            fontWeight: state == _StepVisualState.future
                ? FontWeight.w600
                : FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 3),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: circleFill,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 2),
            boxShadow: [
              const BoxShadow(color: Colors.white, spreadRadius: 4),
              if (state == _StepVisualState.activeGreen)
                const BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
            ],
          ),
          child: Icon(info.icon, size: 18, color: iconColor),
        ),
        const SizedBox(height: 3),
        Text(
          info.detail,
          maxLines: 2,
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: textColor,
            fontSize: 9,
            height: 12.5 / 9,
            fontWeight: state == _StepVisualState.activeGreen
                ? FontWeight.w700
                : FontWeight.w500,
            letterSpacing: 0,
          ),
        ),
        if (info.time.isNotEmpty)
          Text(
            info.time,
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFF94A3B8),
              fontSize: 8,
              height: 9 / 8,
              fontWeight: FontWeight.w500,
              letterSpacing: 0,
            ),
          ),
      ],
    );
  }
}

class _StepInfo {
  final String label;
  final IconData icon;
  final String detail;
  final String time;

  const _StepInfo({
    required this.label,
    required this.icon,
    required this.detail,
    required this.time,
  });
}

enum _StepVisualState { completed, activeGreen, future, rejected }

PernitStatusBadgeTone _statusBadgeTone(RawMaterialEntryStatus status) {
  return switch (status) {
    RawMaterialEntryStatus.approved => PernitStatusBadgeTone.success,
    RawMaterialEntryStatus.rejected => PernitStatusBadgeTone.danger,
    _ => PernitStatusBadgeTone.pending,
  };
}

_StepVisualState _stepVisualState(
  int index,
  int activeIndex,
  RawMaterialEntryStatus status,
) {
  if (status == RawMaterialEntryStatus.rejected && index == 4) {
    return _StepVisualState.rejected;
  }
  if (status == RawMaterialEntryStatus.approved && index == 4) {
    return _StepVisualState.completed;
  }
  if (index < activeIndex) {
    return _StepVisualState.completed;
  }
  if (index == activeIndex) {
    return _StepVisualState.activeGreen;
  }
  return _StepVisualState.future;
}

int _activeStepIndex(RawMaterialEntry entry) {
  return switch (entry.status) {
    RawMaterialEntryStatus.arrived => 1,
    RawMaterialEntryStatus.sampleTaken => 1,
    RawMaterialEntryStatus.labPending => 2,
    RawMaterialEntryStatus.qcPending => 3,
    RawMaterialEntryStatus.approved || RawMaterialEntryStatus.rejected => 4,
  };
}

String _arrivedDetail(AppLocalizations l10n, RawMaterialEntry entry) {
  final name = entry.driverName ?? entry.supplierName;
  if (name == null || name.trim().isEmpty) {
    return l10n.cardStepperBy('-');
  }
  final firstName = name.trim().split(RegExp(r'\s+')).first;
  return l10n.cardStepperBy(firstName);
}

String _figmaDate(DateTime? date) {
  if (date == null) {
    return '-';
  }
  return '${date.month.toString().padLeft(2, '0')}/'
      '${date.day.toString().padLeft(2, '0')}/'
      '${date.year.toString().padLeft(4, '0')}';
}

String _figmaTime(DateTime? date) {
  if (date == null) {
    return '';
  }
  final hour = date.hour == 0
      ? 12
      : date.hour > 12
      ? date.hour - 12
      : date.hour;
  final minute = date.minute.toString().padLeft(2, '0');
  final suffix = date.hour >= 12 ? 'pm' : 'am';
  return '$hour:$minute $suffix';
}

String _quantityValue(AppLocalizations l10n, double? value, String? unitName) {
  if (value == null) return '-';
  final normalized = value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(2);
  return l10n.entryQuantityValue(
    normalized,
    unitName?.trim().isNotEmpty == true ? unitName! : '',
  );
}

String _designStatusLabel(
  AppLocalizations l10n,
  RawMaterialEntryStatus status,
) {
  return switch (status) {
    RawMaterialEntryStatus.approved => l10n.entryApprovedFilter,
    RawMaterialEntryStatus.rejected => l10n.entryRejectedFilter,
    _ => l10n.entryPendingFilter,
  };
}

const _metaStyle = TextStyle(
  color: Colors.black,
  fontSize: 12,
  height: 16 / 12,
  fontWeight: FontWeight.w400,
  letterSpacing: 0,
);
