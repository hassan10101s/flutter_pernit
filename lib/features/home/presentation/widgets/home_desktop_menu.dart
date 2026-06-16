import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/spacing.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../design_system/tokens/pernit_colors.dart';
import '../../../../design_system/tokens/pernit_font_weights.dart';
import '../../../auth/domain/entities/auth_user.dart';
import '../../domain/entities/home_menu_section.dart';

class HomeDesktopMenu extends StatelessWidget {
  final AuthUser user;
  final List<HomeMenuSection> sections;
  final int selectedIndex;
  final bool isLoggingOut;
  final String Function(HomeMenuSection section) labelForSection;
  final IconData Function(HomeMenuSection section) iconForSection;
  final ValueChanged<int> onSelected;
  final VoidCallback onLogout;

  const HomeDesktopMenu({
    super.key,
    required this.user,
    required this.sections,
    required this.selectedIndex,
    required this.isLoggingOut,
    required this.labelForSection,
    required this.iconForSection,
    required this.onSelected,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final groups = user.groups.isEmpty
        ? l10n.homeNoGroups
        : user.groups.join(', ');

    return Container(
      width: 276.w.clamp(244, 304).toDouble(),
      color: PernitColors.surface,
      padding: EdgeInsets.fromLTRB(14.w, 16.h, 14.w, 14.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _MenuBrand(user: user, groups: groups),
          verticalSpace(18),
          Expanded(
            child: ListView.separated(
              itemCount: sections.length,
              separatorBuilder: (_, _) => verticalSpace(6),
              itemBuilder: (context, index) {
                final section = sections[index];
                return _DesktopMenuItem(
                  icon: iconForSection(section),
                  label: labelForSection(section),
                  selected: index == selectedIndex,
                  onTap: () => onSelected(index),
                );
              },
            ),
          ),
          verticalSpace(12),
          _MenuLogoutButton(
            isLoggingOut: isLoggingOut,
            label: l10n.homeLogoutTooltip,
            onPressed: isLoggingOut ? null : onLogout,
          ),
        ],
      ),
    );
  }
}

class _MenuBrand extends StatelessWidget {
  final AuthUser user;
  final String groups;

  const _MenuBrand({required this.user, required this.groups});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: PernitColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: PernitColors.primary.withValues(alpha: 0.16)),
      ),
      child: Row(
        children: [
          Container(
            width: 42.r,
            height: 42.r,
            decoration: BoxDecoration(
              color: PernitColors.primary,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.grid_view_rounded,
              color: PernitColors.surface,
              size: 22.r,
            ),
          ),
          horizontalSpace(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.appTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 17.sp.clamp(15, 19).toDouble(),
                    color: PernitColors.primaryDark,
                    fontWeight: PernitFontWeights.bold,
                  ),
                ),
                verticalSpace(3),
                Text(
                  user.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: PernitColors.textStrong,
                  ),
                ),
                verticalSpace(2),
                Text(
                  groups,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: PernitColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DesktopMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DesktopMenuItem({
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
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 11.h),
            decoration: BoxDecoration(
              color: selected
                  ? PernitColors.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: selected
                    ? PernitColors.primary.withValues(alpha: 0.18)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 34.r,
                  height: 34.r,
                  decoration: BoxDecoration(
                    color: selected
                        ? PernitColors.surface
                        : PernitColors.background,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: PernitColors.border),
                  ),
                  child: Icon(icon, color: foreground, size: 19.r),
                ),
                horizontalSpace(10),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontSize: 14.sp.clamp(12, 16).toDouble(),
                      color: selected
                          ? PernitColors.textStrong
                          : PernitColors.textMuted,
                      fontWeight: PernitFontWeights.bold,
                    ),
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

class _MenuLogoutButton extends StatelessWidget {
  final bool isLoggingOut;
  final String label;
  final VoidCallback? onPressed;

  const _MenuLogoutButton({
    required this.isLoggingOut,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: isLoggingOut
          ? SizedBox.square(
              dimension: 16.r,
              child: const CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.logout_rounded),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        foregroundColor: PernitColors.danger,
        side: const BorderSide(color: PernitColors.border),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
          fontSize: 14.sp.clamp(12, 16).toDouble(),
          fontWeight: PernitFontWeights.bold,
        ),
      ),
    );
  }
}
