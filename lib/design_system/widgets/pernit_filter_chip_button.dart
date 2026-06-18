import 'package:flutter/material.dart';

import '../tokens/pernit_colors.dart';

class PernitFilterChipButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onPressed;
  final bool darkWhenSelected;
  final double minWidth;
  final double height;

  const PernitFilterChipButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onPressed,
    this.darkWhenSelected = false,
    this.minWidth = 64,
    this.height = 38,
  });

  @override
  Widget build(BuildContext context) {
    final useDark = selected && darkWhenSelected;

    return SizedBox(
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: Size(minWidth, height),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          backgroundColor: useDark
              ? PernitColors.textInk
              : PernitColors.surface,
          foregroundColor: useDark ? Colors.white : const Color(0xFF475569),
          side: BorderSide(
            color: useDark ? PernitColors.textInk : PernitColors.borderMuted,
          ),
          shape: const StadiumBorder(),
          elevation: useDark ? 2 : 0,
          shadowColor: Colors.black.withValues(alpha: 0.2),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            height: 20 / 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}
