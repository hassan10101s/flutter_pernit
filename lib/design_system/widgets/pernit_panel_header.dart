import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../core/helpers/spacing.dart';
import '../tokens/pernit_colors.dart';
import '../tokens/pernit_font_weights.dart';

class PernitPanelHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const PernitPanelHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: PernitColors.surface,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: PernitColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: PernitColors.primary, size: 28.r),
          horizontalSpace(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: PernitFontWeights.bold,
                    color: PernitColors.textStrong,
                  ),
                ),
                verticalSpace(4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
