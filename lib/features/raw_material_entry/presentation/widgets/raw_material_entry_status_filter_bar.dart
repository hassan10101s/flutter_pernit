import 'package:flutter/material.dart';

import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../design_system/widgets/pernit_filter_chip_button.dart';
import '../../domain/entities/raw_material_entry.dart';

class RawMaterialEntryStatusFilterBar extends StatelessWidget {
  final RawMaterialEntryStatus? selectedStatus;
  final ValueChanged<RawMaterialEntryStatus?> onStatusSelected;

  const RawMaterialEntryStatusFilterBar({
    super.key,
    required this.selectedStatus,
    required this.onStatusSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      height: 118,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 58,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 10),
              children: [
                PernitFilterChipButton(
                  label: l10n.entryAllStatuses,
                  selected: selectedStatus == null,
                  onPressed: () => onStatusSelected(null),
                  darkWhenSelected: true,
                  minWidth: 56.98,
                ),
                const SizedBox(width: 3),
                PernitFilterChipButton(
                  label: l10n.entryPendingFilter,
                  selected:
                      selectedStatus != null &&
                      selectedStatus != RawMaterialEntryStatus.approved &&
                      selectedStatus != RawMaterialEntryStatus.rejected,
                  onPressed: () =>
                      onStatusSelected(RawMaterialEntryStatus.labPending),
                  minWidth: 122,
                ),
                const SizedBox(width: 3),
                PernitFilterChipButton(
                  label: l10n.entryApprovedFilter,
                  selected: selectedStatus == RawMaterialEntryStatus.approved,
                  onPressed: () =>
                      onStatusSelected(RawMaterialEntryStatus.approved),
                  minWidth: 116.59,
                ),
                const SizedBox(width: 3),
                PernitFilterChipButton(
                  label: l10n.entryRejectedFilter,
                  selected: selectedStatus == RawMaterialEntryStatus.rejected,
                  onPressed: () =>
                      onStatusSelected(RawMaterialEntryStatus.rejected),
                  minWidth: 115.08,
                ),
              ],
            ),
          ),
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(2, 6, 0, 6),
              children: [
                PernitFilterChipButton(
                  label: l10n.entryLast24Hours,
                  selected: true,
                  onPressed: () {},
                  darkWhenSelected: true,
                  minWidth: 92,
                ),
                const SizedBox(width: 11),
                PernitFilterChipButton(
                  label: l10n.entryYesterday,
                  selected: false,
                  onPressed: () {},
                  minWidth: 116.59,
                ),
                const SizedBox(width: 11),
                PernitFilterChipButton(
                  label: l10n.entryCustomDate,
                  selected: false,
                  onPressed: () {},
                  minWidth: 135,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
