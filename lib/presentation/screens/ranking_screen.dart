import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/components/components.dart';
import '../../core/i18n/i18n.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/game.dart';
import '../../data/repositories/game_repository.dart';
import '../widgets/bottom_tab_bar.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  List<Game> _games = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    setState(() => _isLoading = true);
    try {
      final repository = GameRepository();
      final games = await repository.getAll();
      games.sort((a, b) => b.totalPlays.compareTo(a.totalPlays));
      setState(() {
        _games = games;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
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
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _games.isEmpty
                  ? EmptyState(
                      icon: Icons.emoji_events_outlined,
                      title: l10n.noGamesYet,
                      subtitle: l10n.addGamesToSeeRanking,
                    )
                  : _buildContent(l10n, isDark),
            ),
            const BottomTabBar(activeRoute: '/ranking'),
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
          Text(
            l10n.ranking,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          IconActionButton(
            icon: Icons.refresh,
            isDark: isDark,
            onTap: _loadGames,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AppLocalizations l10n, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatisticsSummary(isDark),
          const SizedBox(height: 32),
          Text(
            l10n.statistics,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          const SizedBox(height: 24),
          _buildWinLossChart(isDark, l10n),
          const SizedBox(height: 32),
          _buildMostPlayedChart(isDark),
          const SizedBox(height: 32),
          Text(
            l10n.gamesRanking,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
          const SizedBox(height: 16),
          _buildGamesTable(isDark),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildStatisticsSummary(bool isDark) {
    final totalPlays = _games.fold<int>(0, (sum, g) => sum + g.totalPlays);
    final totalWins = _games.fold<int>(0, (sum, g) => sum + g.wins);
    final totalLosses = _games.fold<int>(0, (sum, g) => sum + g.losses);

    return ThemeContainer(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.sports_esports,
            value: totalPlays.toString(),
            label: 'Total Plays',
            color: AppColors.primary,
          ),
          _buildStatItem(
            icon: Icons.emoji_events,
            value: totalWins.toString(),
            label: 'Wins',
            color: Colors.green,
          ),
          _buildStatItem(
            icon: Icons.thumb_down,
            value: totalLosses.toString(),
            label: 'Losses',
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildWinLossChart(bool isDark, AppLocalizations l10n) {
    final totalWins = _games.fold<int>(0, (sum, g) => sum + g.wins);
    final totalLosses = _games.fold<int>(0, (sum, g) => sum + g.losses);
    final totalGames = totalWins + totalLosses;

    if (totalGames == 0) {
      return ThemeContainer(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            l10n.noGamesPlayedYet,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final winPercentage = totalGames > 0 ? (totalWins / totalGames) * 100 : 0;

    return ThemeContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.winsVsLosses,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 35,
                sections: [
                  PieChartSectionData(
                    value: totalWins.toDouble(),
                    title: '${winPercentage.toStringAsFixed(0)}%',
                    color: Colors.green,
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    value: totalLosses.toDouble(),
                    title: '${(100 - winPercentage).toStringAsFixed(0)}%',
                    color: Colors.red,
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Wins', Colors.green),
              const SizedBox(width: 24),
              _buildLegendItem('Losses', Colors.red),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildMostPlayedChart(bool isDark) {
    final topGames = _games.take(5).toList();
    if (topGames.isEmpty) return const SizedBox();

    return ThemeContainer(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Most Played',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ...topGames.map((game) => _buildGameBar(game)),
        ],
      ),
    );
  }

  Widget _buildGameBar(Game game) {
    final maxPlays = _games.first.totalPlays.toDouble();
    final percentage = maxPlays > 0 ? game.totalPlays / maxPlays : 0.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  game.title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${game.totalPlays}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: percentage,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildGamesTable(bool isDark) {
    return Column(
      children: _games.asMap().entries.map((entry) {
        final index = entry.key;
        final game = entry.value;
        return ThemeContainer(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _getRankColor(index).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getRankColor(index),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${game.totalPlays} plays • ${game.winRate.toStringAsFixed(0)}% win rate',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.emoji_events,
                color: index < 3 ? Colors.amber : Colors.grey,
                size: 20,
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getRankColor(int index) {
    if (index == 0) return Colors.amber;
    if (index == 1) return Colors.grey;
    if (index == 2) return Colors.brown;
    return AppColors.primary;
  }
}
