import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/components/components.dart';
import '../../core/i18n/i18n.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';
import '../providers/providers.dart';

class RandomGamePickerScreen extends StatefulWidget {
  const RandomGamePickerScreen({super.key});

  @override
  State<RandomGamePickerScreen> createState() => _RandomGamePickerScreenState();
}

class _RandomGamePickerScreenState extends State<RandomGamePickerScreen>
    with SingleTickerProviderStateMixin {
  Game? _selectedGame;
  bool _isAnimating = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProvider>().loadGames();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _pickRandomGame(List<Game> games) {
    if (games.isEmpty || _isAnimating) return;
    setState(() {
      _isAnimating = true;
      _selectedGame = null;
    });

    int iterations = 0;
    final maxIterations = 20;
    final random = Random();

    Future.doWhile(() async {
      await Future.delayed(Duration(milliseconds: 50 + (iterations * 20)));
      setState(() {
        _selectedGame = games[random.nextInt(games.length)];
      });
      iterations++;
      return iterations < maxIterations;
    }).then((_) {
      setState(() => _isAnimating = false);
      _animationController
          .forward(from: 0)
          .then((_) => _animationController.reverse());
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gameProvider = context.watch<GameProvider>();
    final games = gameProvider.games;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                AppHeaderWithBack(title: l10n.randomGamePicker),
                Expanded(
                  child: gameProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : games.isEmpty
                      ? EmptyState(
                          icon: Icons.casino_outlined,
                          title: l10n.noGamesToPick,
                          subtitle: l10n.addGamesToUsePicker,
                          action: AppButton(
                            label: l10n.addGame,
                            onPressed: () => context.push('/add-game'),
                          ),
                        )
                      : _buildContent(l10n, isDark, games),
                ),
                if (!gameProvider.isLoading && games.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: AppButton(
                      label: _isAnimating
                          ? l10n.drawing
                          : (_selectedGame == null
                                ? l10n.pickRandomGame
                                : l10n.pickAgain),
                      icon: Icons.casino,
                      onPressed: _isAnimating
                          ? null
                          : () => _pickRandomGame(games),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(AppLocalizations l10n, bool isDark, List<Game> games) {
    if (_selectedGame == null) {
      return _buildInitialState(l10n, isDark, games);
    }
    return _buildSelectedGame(l10n, isDark);
  }

  Widget _buildInitialState(
    AppLocalizations l10n,
    bool isDark,
    List<Game> games,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Icon(
              Icons.casino,
              size: 80,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 32),
          Text(
            l10n.tapToPickGame,
            style: TextStyle(
              fontSize: 18,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${games.length} ${games.length == 1 ? l10n.gameAvailable : l10n.gamesAvailable}',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedGame(AppLocalizations l10n, bool isDark) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          ThemeContainer(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                if (_selectedGame!.imagePath != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.file(
                      File(_selectedGame!.imagePath!),
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  Container(
                    height: 150,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      Icons.image_not_supported,
                      size: 64,
                      color: AppColors.primary,
                    ),
                  ),
                const SizedBox(height: 24),
                Text(
                  _selectedGame!.title,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? AppColors.textDark : AppColors.textLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildInfoChip(Icons.people, _selectedGame!.players),
                    const SizedBox(width: 16),
                    _buildInfoChip(Icons.schedule, _selectedGame!.time),
                  ],
                ),
                const SizedBox(height: 8),
                Chip(label: Text(_selectedGame!.category)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class Chip extends StatelessWidget {
  final Widget label;
  const Chip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: label,
    );
  }
}
