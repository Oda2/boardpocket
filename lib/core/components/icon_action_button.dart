import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class IconActionButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback? onTap;
  final double size;
  final Color? backgroundColor;
  final Color? iconColor;

  const IconActionButton({
    super.key,
    required this.icon,
    required this.isDark,
    this.onTap,
    this.size = 40,
    this.backgroundColor,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: backgroundColor ?? AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(size / 2),
        ),
        child: Icon(
          icon,
          color: iconColor ?? AppColors.primary,
          size: size * 0.5,
        ),
      ),
    );
  }
}
