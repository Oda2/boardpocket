import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
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
      final games = await repository.getAllGames();
      // Sort by total plays (most played first)
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
        child: Stack(
          children: [
            Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.ranking,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _buildIconButton(
                        context: context,
                        icon: Icons.refresh,
                        isDark: isDark,
                        onTap: _loadGames,
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _games.isEmpty
                      ? _buildEmptyState(l10n, isDark)
                      : SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Statistics Summary
                                _buildStatisticsSummary(isDark),
                                const SizedBox(height: 32),

                                // Charts Section
                                Text(
                                  l10n.statistics,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? AppColors.textDark
                                        : AppColors.textLight,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Win/Loss Chart
                                _buildWinLossChart(isDark, l10n),
                                const SizedBox(height: 32),

                                // Most Played Games Chart
                                _buildMostPlayedChart(isDark, l10n),
                                const SizedBox(height: 32),

                                // Games Table
                                Text(
                                  l10n.gamesRanking,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? AppColors.textDark
                                        : AppColors.textLight,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildGamesTable(isDark, l10n),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),
                ),

                // Bottom TabBar
                const BottomTabBar(activeRoute: '/ranking'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required BuildContext context,
    required IconData icon,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(icon),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 80,
            color: isDark
                ? Colors.white.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.noGamesYet,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.addGamesToSeeRanking,
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSummary(bool isDark) {
    final totalPlays = _games.fold<int>(0, (sum, g) => sum + g.totalPlays);
    final totalWins = _games.fold<int>(0, (sum, g) => sum + g.wins);
    final totalLosses = _games.fold<int>(0, (sum, g) => sum + g.losses);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
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
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildWinLossChart(bool isDark, AppLocalizations l10n) {
    final totalWins = _games.fold<int>(0, (sum, g) => sum + g.wins);
    final totalLosses = _games.fold<int>(0, (sum, g) => sum + g.losses);
    final totalGames = totalWins + totalLosses;

    if (totalGames == 0) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            l10n.noGamesPlayedYet,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final winPercentage = totalGames > 0 ? (totalWins / totalGames) * 100 : 0;
    final lossPercentage = totalGames > 0
        ? (totalLosses / totalGames) * 100
        : 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 360;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.winsVsLosses,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (isSmallScreen)
                Column(
                  children: [
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
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              value: totalLosses.toDouble(),
                              title: '${lossPercentage.toStringAsFixed(0)}%',
                              color: Colors.red,
                              radius: 50,
                              titleStyle: const TextStyle(
                                fontSize: 12,
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
                        _buildLegendItem(
                          color: Colors.green,
                          label: l10n.wins,
                          value: totalWins.toString(),
                        ),
                        const SizedBox(width: 24),
                        _buildLegendItem(
                          color: Colors.red,
                          label: l10n.losses,
                          value: totalLosses.toString(),
                        ),
                      ],
                    ),
                  ],
                )
              else
                SizedBox(
                  height: 200,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            sections: [
                              PieChartSectionData(
                                value: totalWins.toDouble(),
                                title: '${winPercentage.toStringAsFixed(1)}%',
                                color: Colors.green,
                                radius: 60,
                                titleStyle: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              PieChartSectionData(
                                value: totalLosses.toDouble(),
                                title: '${lossPercentage.toStringAsFixed(1)}%',
                                color: Colors.red,
                                radius: 60,
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
                      Expanded(
                        flex: 2,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLegendItem(
                              color: Colors.green,
                              label: l10n.wins,
                              value: totalWins.toString(),
                            ),
                            const SizedBox(height: 12),
                            _buildLegendItem(
                              color: Colors.red,
                              label: l10n.losses,
                              value: totalLosses.toString(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMostPlayedChart(bool isDark, AppLocalizations l10n) {
    final totalPlays = _games.fold<int>(0, (sum, g) => sum + g.totalPlays);

    if (totalPlays == 0) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            l10n.noPlaysRecorded,
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    // Get top 5 most played games
    final topGames = _games.take(5).toList();
    final colors = [
      AppColors.primary,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
    ];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 400;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.mostPlayedGames,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (isSmallScreen)
                Column(
                  children: [
                    SizedBox(
                      height: 180,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 35,
                          sections: topGames.asMap().entries.map((entry) {
                            final index = entry.key;
                            final game = entry.value;
                            final percentage =
                                (game.totalPlays / totalPlays) * 100;
                            return PieChartSectionData(
                              value: game.totalPlays.toDouble(),
                              title: percentage >= 10
                                  ? '${percentage.toStringAsFixed(0)}%'
                                  : '',
                              color: colors[index % colors.length],
                              radius: 50,
                              titleStyle: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: topGames.asMap().entries.map((entry) {
                        final index = entry.key;
                        final game = entry.value;
                        return _buildLegendItem(
                          color: colors[index % colors.length],
                          label: game.title.length > 10
                              ? '${game.title.substring(0, 10)}...'
                              : game.title,
                          value: '${game.totalPlays}',
                          small: true,
                        );
                      }).toList(),
                    ),
                  ],
                )
              else
                SizedBox(
                  height: 200,
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 40,
                            sections: topGames.asMap().entries.map((entry) {
                              final index = entry.key;
                              final game = entry.value;
                              final percentage =
                                  (game.totalPlays / totalPlays) * 100;
                              return PieChartSectionData(
                                value: game.totalPlays.toDouble(),
                                title: '${percentage.toStringAsFixed(1)}%',
                                color: colors[index % colors.length],
                                radius: 60,
                                titleStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: topGames.length,
                          itemBuilder: (context, index) {
                            final game = topGames[index];
                            final percentage =
                                (game.totalPlays / totalPlays) * 100;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _buildLegendItem(
                                color: colors[index % colors.length],
                                label: game.title.length > 12
                                    ? '${game.title.substring(0, 12)}...'
                                    : game.title,
                                value:
                                    '${game.totalPlays} (${percentage.toStringAsFixed(1)}%)',
                                small: true,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLegendItem({
    required Color color,
    required String label,
    required String value,
    bool small = false,
  }) {
    return Row(
      children: [
        Container(
          width: small ? 12 : 16,
          height: small ? 12 : 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: small ? 11 : 14,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                value,
                style: TextStyle(fontSize: small ? 10 : 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGamesTable(bool isDark, AppLocalizations l10n) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 360;

        if (isSmallScreen) {
          return _buildGamesCardsList(isDark, l10n);
        }

        return Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth,
                  maxWidth: double.infinity,
                ),
                child: Column(
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(
                            width: 120,
                            child: Text(
                              'Game',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 60,
                            child: Text(
                              'Plays',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 60,
                            child: Text(
                              'Wins',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 60,
                            child: Text(
                              'Losses',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 60,
                            child: Text(
                              'Win%',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Rows
                    SizedBox(
                      width: 360,
                      height: 400,
                      child: ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _games.length,
                        separatorBuilder: (context, index) => Divider(
                          height: 1,
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.1)
                              : Colors.black.withValues(alpha: 0.05),
                        ),
                        itemBuilder: (context, index) {
                          final game = _games[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: index % 2 == 0
                                  ? (isDark
                                        ? Colors.white.withValues(alpha: 0.02)
                                        : Colors.grey.withValues(alpha: 0.05))
                                  : null,
                            ),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 120,
                                  child: Text(
                                    game.title,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                SizedBox(
                                  width: 60,
                                  child: Text(
                                    game.totalPlays.toString(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                                SizedBox(
                                  width: 60,
                                  child: Text(
                                    game.wins.toString(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.green,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 60,
                                  child: Text(
                                    game.losses.toString(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.red,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 60,
                                  child: Text(
                                    '${game.winRate.toStringAsFixed(0)}%',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGamesCardsList(bool isDark, AppLocalizations l10n) {
    return Column(
      children: _games.asMap().entries.map((entry) {
        final index = entry.key;
        final game = entry.value;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      game.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatColumn(
                    'Plays',
                    game.totalPlays.toString(),
                    Colors.grey,
                  ),
                  _buildStatColumn('Wins', game.wins.toString(), Colors.green),
                  _buildStatColumn(
                    'Losses',
                    game.losses.toString(),
                    Colors.red,
                  ),
                  _buildStatColumn(
                    'Win%',
                    '${game.winRate.toStringAsFixed(0)}%',
                    AppColors.primary,
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatColumn(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
