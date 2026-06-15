import 'package:flutter/material.dart';

class PernitButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isLoading;
  final VoidCallback? onPressed;

  const PernitButton({
    super.key,
    required this.label,
    this.icon,
    this.isLoading = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton.icon(
        onPressed: isLoading ? null : onPressed,
        icon: isLoading
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon ?? Icons.login_rounded),
        label: Text(label),
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
