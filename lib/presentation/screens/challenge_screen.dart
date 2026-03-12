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
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(l10n, isDark),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildBadge(isDark),
                    const SizedBox(height: 32),
                    _buildChallengeCard(l10n, isDark),
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

  Widget _buildHeader(AppLocalizations l10n, bool isDark) {
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
          Text(
            l10n.gameMaster,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconActionButton(icon: Icons.history, isDark: isDark, onTap: () {}),
        ],
      ),
    );
  }

  Widget _buildBadge(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.casino, color: AppColors.primary, size: 20),
          const SizedBox(width: 8),
          Text(
            'Challenge',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(AppLocalizations l10n, bool isDark) {
    return ThemeContainer(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.emoji_events, size: 64, color: AppColors.primary),
          const SizedBox(height: 24),
          Text(
            _currentChallenge?.title ?? '',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
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
}
