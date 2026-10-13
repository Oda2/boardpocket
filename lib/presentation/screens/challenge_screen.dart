import 'dart:math';

import 'package:flutter/material.dart';

import '../../router/router.dart';
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
                    _buildBadge(l10n),
                    const SizedBox(height: 32),
                    _buildChallengeCard(l10n, isDark),
                    const SizedBox(height: 32),
                    AppButton(
                      label: l10n.newChallenge,
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
            onTap: () => context.popOrGo(),
          ),
          Text(
            l10n.challenge,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildBadge(AppLocalizations l10n) {
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
            _getBadgeLabel(l10n),
            style: TextStyle(
              color: _getBadgeColor(),
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
          Icon(_getChallengeIcon(), size: 64, color: AppColors.primary),
          const SizedBox(height: 24),
          Text(
            _currentChallenge == null
                ? ''
                : l10n.challengeTitle(_currentChallenge!),
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            _currentChallenge == null
                ? ''
                : l10n.challengeDescription(_currentChallenge!),
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
    switch (_currentChallenge?.difficulty) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return AppColors.primary;
    }
  }

  IconData _getBadgeIcon() {
    switch (_currentChallenge?.difficulty) {
      case 'easy':
        return Icons.sentiment_satisfied;
      case 'medium':
        return Icons.sentiment_neutral;
      case 'hard':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.star;
    }
  }

  String _getBadgeLabel(AppLocalizations l10n) {
    final challenge = _currentChallenge;
    if (challenge == null) return l10n.challenge;
    return '${l10n.challengeCategory(challenge)} - '
        '${l10n.challengeDifficulty(challenge)}';
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
      case 'music_note':
        return Icons.music_note;
      case 'theater_comedy':
        return Icons.theater_comedy;
      case 'wb_sunny':
        return Icons.wb_sunny;
      case 'local_cafe':
        return Icons.local_cafe;
      case 'pan_tool':
        return Icons.pan_tool;
      case 'beach_access':
        return Icons.beach_access;
      case 'abc':
        return Icons.abc;
      case 'history':
        return Icons.history;
      case 'toll':
        return Icons.toll;
      case 'psychology':
        return Icons.psychology;
      case 'currency_bitcoin':
        return Icons.currency_bitcoin;
      case 'help_outline':
        return Icons.help_outline;
      case 'visibility_off':
        return Icons.visibility_off;
      case 'waves':
        return Icons.waves;
      case 'brush':
        return Icons.brush;
      case 'lightbulb':
        return Icons.lightbulb;
      case 'auto_stories':
        return Icons.auto_stories;
      case 'shuffle':
        return Icons.shuffle;
      default:
        return Icons.star;
    }
  }
}
