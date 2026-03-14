import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/components/components.dart';
import '../../core/i18n/i18n.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';

class ChallengeScreen extends StatefulWidget {
  const ChallengeScreen({super.key});

  @override
  State<ChallengeScreen> createState() => _ChallengeScreenState();
}

class _ChallengeScreenState extends State<ChallengeScreen> {
  Challenge? _currentChallenge;
  final Random _random = Random();

  void _shuffleChallenge() {
    setState(() {
      _currentChallenge =
          defaultChallenges[_random.nextInt(defaultChallenges.length)];
    });
  }

  @override
  void initState() {
    super.initState();
    _shuffleChallenge();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildBadge(isDark),
                    const SizedBox(height: 32),
                    _buildChallengeCard(isDark),
                    const SizedBox(height: 32),
                    AppButton(
                      label: 'New Challenge',
                      icon: Icons.shuffle,
                      onPressed: _shuffleChallenge,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconActionButton(
            icon: Icons.chevron_left,
            isDark: isDark,
            onTap: () => context.pop(),
          ),
          const Text(
            'Challenge',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildBadge(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _getBadgeColor().withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getBadgeIcon(), color: _getBadgeColor(), size: 16),
          const SizedBox(width: 8),
          Text(
            _getBadgeLabel(),
            style: TextStyle(
              color: _getBadgeColor(),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(bool isDark) {
    return ThemeContainer(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(_getChallengeIcon(), size: 64, color: AppColors.primary),
          const SizedBox(height: 24),
          Text(
            _currentChallenge?.title ?? '',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            _currentChallenge?.description ?? '',
            style: TextStyle(
              fontSize: 16,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getBadgeColor() {
    switch (_currentChallenge?.category) {
      case 'Easy':
        return Colors.green;
      case 'Medium':
        return Colors.orange;
      case 'Hard':
        return Colors.red;
      default:
        return AppColors.primary;
    }
  }

  IconData _getBadgeIcon() {
    switch (_currentChallenge?.category) {
      case 'Easy':
        return Icons.sentiment_satisfied;
      case 'Medium':
        return Icons.sentiment_neutral;
      case 'Hard':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.star;
    }
  }

  String _getBadgeLabel() {
    return _currentChallenge?.category ?? 'Challenge';
  }

  IconData _getChallengeIcon() {
    final iconName = _currentChallenge?.iconName ?? '';
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'cake':
        return Icons.cake;
      case 'flight':
        return Icons.flight;
      case 'battery_alert':
        return Icons.battery_alert;
      case 'height':
        return Icons.height;
      case 'sort_by_alpha':
        return Icons.sort_by_alpha;
      case 'pets':
        return Icons.pets;
      case 'checkroom':
        return Icons.checkroom;
      default:
        return Icons.star;
    }
  }
}
