import 'package:flutter/material.dart';

import '../tokens/pernit_colors.dart';

enum PernitStatusBadgeTone { pending, success, danger, neutral }

class PernitStatusBadge extends StatelessWidget {
  final String label;
  final PernitStatusBadgeTone tone;
  final double height;
  final double minWidth;
  final bool showDot;

  const PernitStatusBadge({
    super.key,
    required this.label,
    required this.tone,
    this.height = 26,
    this.minWidth = 104,
    this.showDot = true,
  });

  @override
  Widget build(BuildContext context) {
    final palette = _paletteFor(tone);

    return Container(
      height: height,
      constraints: BoxConstraints(minWidth: minWidth),
      padding: const EdgeInsets.symmetric(horizontal: 11),
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: palette.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showDot) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: palette.dot,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: palette.text,
                fontSize: 14,
                height: 20 / 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

_StatusBadgePalette _paletteFor(PernitStatusBadgeTone tone) {
  return switch (tone) {
    PernitStatusBadgeTone.success => const _StatusBadgePalette(
      background: PernitColors.success,
      border: PernitColors.success,
      dot: Colors.white,
      text: Colors.black,
    ),
    PernitStatusBadgeTone.danger => const _StatusBadgePalette(
      background: PernitColors.dangerSurface,
      border: PernitColors.dangerSurface,
      dot: Colors.black,
      text: Colors.black,
    ),
    PernitStatusBadgeTone.pending => const _StatusBadgePalette(
      background: PernitColors.warningSurface,
      border: PernitColors.warningBorder,
      dot: PernitColors.warning,
      text: Color(0xFF475569),
    ),
    PernitStatusBadgeTone.neutral => const _StatusBadgePalette(
      background: PernitColors.surface,
      border: PernitColors.borderMuted,
      dot: PernitColors.textSubtle,
      text: PernitColors.textMuted,
    ),
  };
}

class _StatusBadgePalette {
  final Color background;
  final Color border;
  final Color dot;
  final Color text;

  const _StatusBadgePalette({
    required this.background,
    required this.border,
    required this.dot,
    required this.text,
  });
}
