import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ThemeContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BorderRadius? borderRadius;
  final bool useSecondaryBackground;
  final bool addBorder;
  final double? width;
  final double? height;
  final Color? customBackgroundColor;
  final Color? customBorderColor;

  const ThemeContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.useSecondaryBackground = false,
    this.addBorder = true,
    this.width,
    this.height,
    this.customBackgroundColor,
    this.customBorderColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        customBackgroundColor ??
        (useSecondaryBackground
            ? (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white)
            : (isDark ? AppColors.backgroundDark : AppColors.backgroundLight));
    final borderColor =
        customBorderColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.black.withValues(alpha: 0.05));

    return Container(
      width: width,
      height: height,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: borderRadius ?? BorderRadius.circular(16),
        border: addBorder ? Border.all(color: borderColor) : null,
      ),
      child: child,
    );
  }
}
