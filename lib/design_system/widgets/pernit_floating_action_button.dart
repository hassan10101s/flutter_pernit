import 'package:flutter/material.dart';

import '../tokens/pernit_colors.dart';

class PernitFloatingActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final String? tooltip;
  final String heroTag;
  final double size;
  final double iconSize;
  final Color backgroundColor;
  final Color foregroundColor;

  const PernitFloatingActionButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.heroTag,
    this.tooltip,
    this.size = 56,
    this.iconSize = 30,
    this.backgroundColor = PernitColors.textInk,
    this.foregroundColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: FloatingActionButton(
        heroTag: heroTag,
        tooltip: tooltip,
        elevation: 0,
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor,
        shape: const CircleBorder(),
        onPressed: onPressed,
        child: Icon(icon, size: iconSize),
      ),
    );
  }
}
