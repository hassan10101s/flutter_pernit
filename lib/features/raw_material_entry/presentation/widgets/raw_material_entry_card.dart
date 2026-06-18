import 'package:flutter/material.dart';

import '../../../../design_system/status_indicators/pernit_status_badge.dart';
import '../../../../design_system/tokens/pernit_colors.dart';
import '../../domain/entities/raw_material_entry.dart';
import 'raw_material_entry_copy.dart';

class RawMaterialEntryCard extends StatelessWidget {
  final RawMaterialEntry entry;

  const RawMaterialEntryCard({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final copy = RawMaterialEntryCopy.of(context);

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
                      label: copy.designStatusLabel(entry.status),
                      tone: _statusBadgeTone(entry.status),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                _CardMetaRow(entry: entry, copy: copy),
                const SizedBox(height: 10),
                _InfoGrid(entry: entry, copy: copy),
              ],
            ),
          ),
          const Divider(height: 1, color: PernitColors.borderSoft),
          Container(
            color: const Color(0x80F8FAFC),
            padding: const EdgeInsets.fromLTRB(0, 6, 0, 9),
            child: _ProgressStepper(entry: entry),
          ),
        ],
      ),
    );
  }
}

class _CardMetaRow extends StatelessWidget {
  final RawMaterialEntry entry;
  final RawMaterialEntryCopy copy;

  const _CardMetaRow({required this.entry, required this.copy});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            '${copy.dateLabel} : ${_figmaDate(entry.createdAt)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _metaStyle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            '${copy.idLabel}: #${_entryCode(entry)}',
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
  final RawMaterialEntryCopy copy;

  const _InfoGrid({required this.entry, required this.copy});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 66,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _InfoColumn(
              label: copy.supplier,
              value: entry.supplierName ?? copy.noSupplier,
              withLeadingBorder: true,
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoTinyLabel(label: copy.vehicleNo),
                _InfoTinyValue(value: entry.vehicleNo ?? '-'),
                const SizedBox(height: 4),
                _InfoTinyLabel(label: copy.driver),
                _InfoTinyValue(value: entry.driverName ?? '-'),
              ],
            ),
          ),
          const SizedBox(width: 5),
          SizedBox(
            width: 94,
            child: _InfoColumn(
              label: copy.supplierWeight,
              value: copy.quantityValue(
                entry.quantityFromSupplier,
                unitName: entry.unitName,
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

  const _ProgressStepper({required this.entry});

  @override
  Widget build(BuildContext context) {
    final activeIndex = _activeStepIndex(entry);
    final isRejected = entry.status == RawMaterialEntryStatus.rejected;
    final steps = [
      _StepInfo(
        label: 'Arrived',
        icon: Icons.local_shipping_outlined,
        detail: _arrivedDetail(entry),
        time: _figmaTime(entry.createdAt),
      ),
      _StepInfo(
        label: 'Sampled',
        icon: Icons.science_outlined,
        detail: entry.isSampled ? 'M. Smith' : 'Processing',
        time: entry.isSampled ? '9:24 pm' : '',
      ),
      _StepInfo(
        label: 'Lab',
        icon: Icons.biotech_outlined,
        detail: entry.isLabDone ? 'Mohamed. Smith' : 'Pending',
        time: entry.isLabDone ? '9:32 pm' : '',
      ),
      _StepInfo(
        label: 'QC',
        icon: Icons.verified_user_outlined,
        detail: entry.isQcDone ? 'Dr. Hasan' : 'Pending',
        time: entry.isQcDone ? '10:10 pm' : '',
      ),
      _StepInfo(
        label: 'Decision',
        icon: Icons.gavel_outlined,
        detail: isRejected
            ? 'Rejected'
            : entry.status == RawMaterialEntryStatus.approved
            ? 'Approved'
            : 'Pending',
        time: entry.status.isClosed ? '10:19 pm' : '',
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

String _arrivedDetail(RawMaterialEntry entry) {
  final name = entry.driverName ?? entry.supplierName;
  if (name == null || name.trim().isEmpty) {
    return 'By: -';
  }
  final firstName = name.trim().split(RegExp(r'\s+')).first;
  return 'By: $firstName';
}

String _entryCode(RawMaterialEntry entry) {
  final prefix = entry.rawMaterialName.toUpperCase().contains('VITAMIN')
      ? 'PV'
      : 'SB';
  return '$prefix-2026-${entry.id.toString().padLeft(3, '0')}';
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

const _metaStyle = TextStyle(
  color: Colors.black,
  fontSize: 12,
  height: 16 / 12,
  fontWeight: FontWeight.w400,
  letterSpacing: 0,
);
