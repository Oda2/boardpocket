import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/i18n/i18n.dart';
import '../../../core/theme/app_theme.dart';

class BottomTabBar extends StatelessWidget {
  final String activeRoute;

  const BottomTabBar({super.key, required this.activeRoute});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildTabItem(
                context,
                icon: Icons.grid_view_rounded,
                label: l10n.collection,
                route: '/',
                isActive: activeRoute == '/',
              ),
              _buildTabItem(
                context,
                icon: Icons.shopping_bag_rounded,
                label: l10n.wishlist,
                route: '/wishlist',
                isActive: activeRoute == '/wishlist',
              ),
              // Randomizer - Botão destacado no centro
              _buildFeaturedTabItem(
                context,
                icon: Icons.casino_rounded,
                label: l10n.randomizer,
                route: '/randomizer',
                isActive: activeRoute == '/randomizer',
              ),
              _buildTabItem(
                context,
                icon: Icons.emoji_events_rounded,
                label: l10n.ranking,
                route: '/ranking',
                isActive: activeRoute == '/ranking',
              ),
              _buildTabItem(
                context,
                icon: Icons.settings_rounded,
                label: l10n.settings,
                route: '/settings',
                isActive: activeRoute == '/settings',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
    required bool isActive,
  }) {
    final color = isActive ? AppColors.primary : Colors.grey;

    return GestureDetector(
      onTap: () => context.go(route),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedTabItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () => context.go(route),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Botão destacado circular
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.8),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.primary : Colors.grey,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}
