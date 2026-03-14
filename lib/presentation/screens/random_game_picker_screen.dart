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

class _RandomGamePickerScreenState extends State<RandomGamePickerScreen> {
  Game? _selectedGame;
  bool _isAnimating = false;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProvider>().loadGames();
    });
  }

  void _pickRandomGame(List<Game> games) {
    if (games.isEmpty || _isAnimating) return;
    setState(() {
      _isAnimating = true;
      _selectedGame = null;
    });

    int iterations = 0;
    final maxIterations = 20;

    Future.doWhile(() async {
      await Future.delayed(Duration(milliseconds: 50 + (iterations * 20)));
      setState(() => _selectedGame = games[_random.nextInt(games.length)]);
      iterations++;
      return iterations < maxIterations;
    }).then((_) {
      setState(() => _isAnimating = false);
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
        child: Column(
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
                  onPressed: _isAnimating ? null : () => _pickRandomGame(games),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(AppLocalizations l10n, bool isDark, List<Game> games) {
    if (_selectedGame == null) return _buildInitialState(l10n, isDark, games);
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
          PulsingCircle(
            size: 200,
            color: AppColors.primary,
            child: Icon(Icons.casino, size: 80, color: AppColors.primary),
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
            '${games.length} ${games.length == 1 ? 'game' : 'games'} available',
            style: const TextStyle(
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
          AnimatedResultCard(
            title: _selectedGame!.title,
            subtitle:
                '${_selectedGame!.players} players • ${_selectedGame!.time}',
            imagePath: _selectedGame!.imagePath,
            isAnimating: _isAnimating,
            width: 300,
            height: 400,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildGameStat(Icons.people, _selectedGame!.players),
              const SizedBox(width: 24),
              _buildGameStat(Icons.timer, _selectedGame!.time),
              const SizedBox(width: 24),
              _buildGameStat(Icons.category, _selectedGame!.category),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameStat(IconData icon, String value) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
