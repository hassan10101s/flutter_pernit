import 'package:flutter/material.dart';

import '../../../../design_system/widgets/pernit_filter_chip_button.dart';
import '../../domain/entities/raw_material_entry.dart';
import 'raw_material_entry_copy.dart';

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
    final copy = RawMaterialEntryCopy.of(context);

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
                  label: copy.allStatuses,
                  selected: selectedStatus == null,
                  onPressed: () => onStatusSelected(null),
                  darkWhenSelected: true,
                  minWidth: 56.98,
                ),
                const SizedBox(width: 3),
                PernitFilterChipButton(
                  label: copy.pendingFilter,
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
                  label: copy.approvedFilter,
                  selected: selectedStatus == RawMaterialEntryStatus.approved,
                  onPressed: () =>
                      onStatusSelected(RawMaterialEntryStatus.approved),
                  minWidth: 116.59,
                ),
                const SizedBox(width: 3),
                PernitFilterChipButton(
                  label: copy.rejectedFilter,
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
                  label: copy.last24Hours,
                  selected: true,
                  onPressed: () {},
                  darkWhenSelected: true,
                  minWidth: 92,
                ),
                const SizedBox(width: 11),
                PernitFilterChipButton(
                  label: copy.yesterday,
                  selected: false,
                  onPressed: () {},
                  minWidth: 116.59,
                ),
                const SizedBox(width: 11),
                PernitFilterChipButton(
                  label: copy.customDate,
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
