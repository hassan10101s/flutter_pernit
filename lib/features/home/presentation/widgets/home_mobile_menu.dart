import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/spacing.dart';
import '../../../../design_system/tokens/pernit_colors.dart';
import '../../../../design_system/tokens/pernit_font_weights.dart';
import '../../domain/entities/home_menu_section.dart';

class HomeMobileMenu extends StatelessWidget {
  final List<HomeMenuSection> sections;
  final int selectedIndex;
  final String Function(HomeMenuSection section) labelForSection;
  final IconData Function(HomeMenuSection section) iconForSection;
  final ValueChanged<int> onSelected;

  const HomeMobileMenu({
    super.key,
    required this.sections,
    required this.selectedIndex,
    required this.labelForSection,
    required this.iconForSection,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final scrollable = sections.length > 4;

    return SafeArea(
      top: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 10.h),
        decoration: const BoxDecoration(
          color: PernitColors.surface,
          border: Border(top: BorderSide(color: PernitColors.border)),
        ),
        child: SizedBox(
          height: 62.h.clamp(58, 68).toDouble(),
          child: scrollable
              ? ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: sections.length,
                  separatorBuilder: (_, _) => horizontalSpace(8),
                  itemBuilder: (context, index) {
                    final section = sections[index];
                    return SizedBox(
                      width: 86.w.clamp(78, 96).toDouble(),
                      child: _MobileMenuItem(
                        icon: iconForSection(section),
                        label: labelForSection(section),
                        selected: index == selectedIndex,
                        onTap: () => onSelected(index),
                      ),
                    );
                  },
                )
              : Row(
                  children: [
                    for (var index = 0; index < sections.length; index++) ...[
                      Expanded(
                        child: _MobileMenuItem(
                          icon: iconForSection(sections[index]),
                          label: labelForSection(sections[index]),
                          selected: index == selectedIndex,
                          onTap: () => onSelected(index),
                        ),
                      ),
                      if (index != sections.length - 1) horizontalSpace(8),
                    ],
                  ],
                ),
        ),
      ),
    );
  }
}

class _MobileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _MobileMenuItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? PernitColors.primary : PernitColors.textMuted;

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8.r),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: selected
                  ? PernitColors.primary.withValues(alpha: 0.1)
                  : PernitColors.background,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: selected
                    ? PernitColors.primary.withValues(alpha: 0.18)
                    : PernitColors.border,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: foreground, size: 21.r),
                verticalSpace(3),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 11.sp.clamp(10, 12).toDouble(),
                    color: selected
                        ? PernitColors.textStrong
                        : PernitColors.textMuted,
                    fontWeight: PernitFontWeights.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
