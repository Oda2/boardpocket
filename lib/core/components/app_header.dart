import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'icon_action_button.dart';
import 'profile_avatar.dart';

class AppHeader extends StatelessWidget {
  final String? subtitle;
  final String title;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTrailingTap;
  final List<Widget>? actions;
  final double? titleFontSize;
  final FontWeight? titleFontWeight;
  final CrossAxisAlignment? crossAxisAlignment;

  const AppHeader({
    super.key,
    this.subtitle,
    required this.title,
    this.leading,
    this.trailing,
    this.onTrailingTap,
    this.actions,
    this.titleFontSize,
    this.titleFontWeight,
    this.crossAxisAlignment,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
                  crossAxisAlignment ?? CrossAxisAlignment.start,
              children: [
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 2,
                    ),
                  ),
                if (subtitle != null) const SizedBox(height: 4),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: titleFontSize ?? 28,
                    fontWeight: titleFontWeight ?? FontWeight.w800,
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          if (leading != null) leading!,
          if (trailing != null)
            GestureDetector(onTap: onTrailingTap, child: trailing),
          if (actions != null) ...actions!,
        ],
      ),
    );
  }
}

class AppHeaderWithBack extends StatelessWidget {
  final String title;
  final VoidCallback? onBack;
  final VoidCallback? onAction;
  final IconData? actionIcon;
  final double? titleFontSize;

  const AppHeaderWithBack({
    super.key,
    required this.title,
    this.onBack,
    this.onAction,
    this.actionIcon,
    this.titleFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconActionButton(
            icon: Icons.arrow_back_ios_new,
            isDark: isDark,
            onTap: onBack ?? () => Navigator.of(context).pop(),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: titleFontSize ?? 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (actionIcon != null)
            IconActionButton(icon: actionIcon!, isDark: isDark, onTap: onAction)
          else
            const SizedBox(width: 48),
        ],
      ),
    );
  }
}
