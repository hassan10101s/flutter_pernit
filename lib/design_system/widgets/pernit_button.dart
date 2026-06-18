import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

enum PernitButtonVariant { filled, outlined, text }

class PernitButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isLoading;
  final VoidCallback? onPressed;
  final PernitButtonVariant variant;
  final bool fullWidth;
  final double height;
  final double borderRadius;

  const PernitButton({
    super.key,
    required this.label,
    this.icon,
    this.isLoading = false,
    required this.onPressed,
    this.variant = PernitButtonVariant.filled,
    this.fullWidth = true,
    this.height = 52,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final style = switch (variant) {
      PernitButtonVariant.filled => FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius.r),
        ),
      ),
      PernitButtonVariant.outlined => OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius.r),
        ),
      ),
      PernitButtonVariant.text => TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius.r),
        ),
      ),
    };
    final iconWidget = isLoading
        ? SizedBox.square(
            dimension: 18.r,
            child: const CircularProgressIndicator(strokeWidth: 2),
          )
        : Icon(icon ?? Icons.login_rounded);
    final effectiveOnPressed = isLoading ? null : onPressed;
    final button = switch (variant) {
      PernitButtonVariant.filled => FilledButton.icon(
        onPressed: effectiveOnPressed,
        icon: iconWidget,
        label: Text(label),
        style: style,
      ),
      PernitButtonVariant.outlined => OutlinedButton.icon(
        onPressed: effectiveOnPressed,
        icon: iconWidget,
        label: Text(label),
        style: style,
      ),
      PernitButtonVariant.text => TextButton.icon(
        onPressed: effectiveOnPressed,
        icon: iconWidget,
        label: Text(label),
        style: style,
      ),
    };

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height.h,
      child: button,
    );
  }
}
