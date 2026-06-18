import 'package:flutter/material.dart';

import '../tokens/pernit_colors.dart';

class PernitIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double size;
  final double iconSize;
  final Color backgroundColor;
  final Color foregroundColor;
  final Color? borderColor;
  final ShapeBorder shape;
  final bool elevated;
  final Widget? child;

  const PernitIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.size = 40,
    this.iconSize = 22,
    this.backgroundColor = Colors.transparent,
    this.foregroundColor = PernitColors.textInk,
    this.borderColor,
    this.shape = const CircleBorder(),
    this.elevated = false,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveShape = _shapeWithBorder(shape, borderColor);
    final button = SizedBox.square(
      dimension: size,
      child: Material(
        color: backgroundColor,
        shape: effectiveShape,
        elevation: elevated ? 1 : 0,
        shadowColor: Colors.black.withValues(alpha: 0.14),
        child: InkWell(
          customBorder: effectiveShape,
          onTap: onPressed,
          child: Center(
            child: child ?? Icon(icon, size: iconSize, color: foregroundColor),
          ),
        ),
      ),
    );

    if (tooltip == null || tooltip!.trim().isEmpty) {
      return button;
    }

    return Tooltip(message: tooltip!, child: button);
  }
}

ShapeBorder _shapeWithBorder(ShapeBorder shape, Color? borderColor) {
  if (borderColor == null) {
    return shape;
  }

  final side = BorderSide(color: borderColor);
  if (shape is CircleBorder) {
    return CircleBorder(side: side);
  }
  if (shape is RoundedRectangleBorder) {
    return shape.copyWith(side: side);
  }
  if (shape is StadiumBorder) {
    return StadiumBorder(side: side);
  }

  return shape;
}
