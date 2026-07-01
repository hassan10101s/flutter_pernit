import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../tokens/pernit_colors.dart';

class PernitBottomSegmentedBarItem {
  final IconData icon;
  final String label;
  final bool enabled;

  const PernitBottomSegmentedBarItem({
    required this.icon,
    required this.label,
    this.enabled = true,
  });
}

class PernitBottomSegmentedBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<PernitBottomSegmentedBarItem> items;

  const PernitBottomSegmentedBar({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: PernitColors.surface,
          border: Border(top: BorderSide(color: PernitColors.border)),
        ),
        child: Row(
          children: [
            for (var index = 0; index < items.length; index++) ...[
              Expanded(
                child: _BarItem(
                  item: items[index],
                  isSelected: selectedIndex == index,
                  onTap: items[index].enabled ? () => onSelected(index) : null,
                ),
              ),
              if (index < items.length - 1) SizedBox(width: 8.w),
            ],
          ],
        ),
      ),
    );
  }
}

class _BarItem extends StatelessWidget {
  final PernitBottomSegmentedBarItem item;
  final bool isSelected;
  final VoidCallback? onTap;

  const _BarItem({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = isSelected && item.enabled;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: isActive ? PernitColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              size: 20.r,
              color: !item.enabled
                  ? PernitColors.textSubtle
                  : isActive
                  ? Colors.white
                  : PernitColors.textMuted,
            ),
            SizedBox(height: 2.h),
            Text(
              item.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: !item.enabled
                    ? PernitColors.textSubtle
                    : isActive
                    ? Colors.white
                    : PernitColors.textStrong,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
