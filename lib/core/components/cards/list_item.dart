import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../images/adaptive_image.dart';
import '../theme_container.dart';
import '../icon_action_button.dart';

class ListItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? localImagePath;
  final String? networkImageUrl;
  final String? tag;
  final String? trailingText;
  final Color? trailingTextColor;
  final Widget? trailingWidget;
  final VoidCallback? onTap;
  final List<ListItemAction>? actions;
  final double imageSize;
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  const ListItem({
    super.key,
    required this.title,
    this.subtitle,
    this.localImagePath,
    this.networkImageUrl,
    this.tag,
    this.trailingText,
    this.trailingTextColor,
    this.trailingWidget,
    this.onTap,
    this.actions,
    this.imageSize = 80,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ThemeContainer(
      margin: margin ?? const EdgeInsets.only(bottom: 16),
      padding: padding ?? const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: onTap,
            child: Stack(
              children: [
                AdaptiveImage(
                  localPath: localImagePath,
                  networkUrl: networkImageUrl,
                  width: imageSize,
                  height: imageSize,
                  borderRadius: BorderRadius.circular(8),
                ),
                if (tag != null)
                  Positioned(top: -4, left: -4, child: _TagBadge(tag: tag!)),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (trailingText != null || trailingWidget != null)
                      trailingWidget ??
                          Text(
                            trailingText!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: trailingTextColor ?? AppColors.primary,
                            ),
                          ),
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                ],
                if (actions != null && actions!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _buildActions(context, isDark),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, bool isDark) {
    return Row(
      children: actions!.asMap().entries.map((entry) {
        final action = entry.value;
        final isLast = entry.key == actions!.length - 1;
        return Row(
          children: [
            IconActionButton(
              icon: action.icon,
              isDark: isDark,
              size: 36,
              backgroundColor: action.backgroundColor,
              iconColor: action.iconColor,
              onTap: action.onTap,
            ),
            if (!isLast) const SizedBox(width: 8),
          ],
        );
      }).toList(),
    );
  }
}

class _TagBadge extends StatelessWidget {
  final String tag;

  const _TagBadge({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class ListItemAction {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  final Color? iconColor;

  const ListItemAction({
    required this.icon,
    this.onTap,
    this.backgroundColor,
    this.iconColor,
  });
}
