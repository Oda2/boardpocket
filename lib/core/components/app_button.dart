import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isSecondary;
  final double? width;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isSecondary = false,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSecondary
            ? (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200])
            : AppColors.primary,
        foregroundColor: isSecondary
            ? (isDark ? AppColors.textDark : AppColors.textLight)
            : Colors.white,
        minimumSize: const Size(0, 56),
      ),
      child: isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isSecondary
                      ? (isDark ? AppColors.textDark : AppColors.textLight)
                      : Colors.white,
                ),
              ),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[Icon(icon), const SizedBox(width: 8)],
                Text(label),
              ],
            ),
    );

    if (width != null) {
      return SizedBox(width: width, height: 56, child: button);
    }
    return button;
  }
}
