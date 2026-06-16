import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/helpers/spacing.dart';
import '../../../../design_system/tokens/pernit_colors.dart';
import '../../../../design_system/tokens/pernit_font_weights.dart';

class HomeDesktopSectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const HomeDesktopSectionHeader({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72.h.clamp(64, 82).toDouble(),
      padding: EdgeInsets.symmetric(horizontal: 22.w),
      decoration: const BoxDecoration(
        color: PernitColors.surface,
        border: Border(bottom: BorderSide(color: PernitColors.border)),
      ),
      child: Row(
        children: [
          Icon(icon, color: PernitColors.primary, size: 24.r),
          horizontalSpace(10),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 21.sp.clamp(18, 24).toDouble(),
                color: PernitColors.textStrong,
                fontWeight: PernitFontWeights.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
