import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/components/components.dart';
import '../../core/i18n/i18n.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';
import '../providers/game_provider.dart';

class GameDetailScreen extends StatefulWidget {
  final String gameId;

  const GameDetailScreen({super.key, required this.gameId});

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  Game? _game;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGame();
    });
  }

  Future<void> _loadGame() async {
    setState(() => _isLoading = true);
    final game = await context.read<GameProvider>().getGameById(widget.gameId);
    setState(() {
      _game = game;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading || _game == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            _buildSliverAppBar(isDark),
            SliverToBoxAdapter(
              child: Transform.translate(
                offset: const Offset(0, -30),
                child: _buildContent(l10n, isDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(bool isDark) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.transparent,
      leading: _buildCircleButton(
        icon: Icons.arrow_back_ios_new,
        onPressed: () => context.pop(),
      ),
      actions: [
        _buildCircleButton(
          icon: Icons.edit,
          onPressed: () => context.push('/edit-game/${_game!.id}'),
        ),
        _buildCircleButton(
          icon: Icons.delete,
          color: Colors.red,
          onPressed: _deleteGame,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            AdaptiveImage(
              localPath: _game!.imagePath,
              placeholder: Container(
                color: AppColors.primary.withValues(alpha: 0.2),
                child: const Icon(
                  Icons.image_not_supported,
                  size: 100,
                  color: AppColors.primary,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    VoidCallback? onPressed,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
        ),
        child: IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: color ?? Colors.white),
        ),
      ),
    );
  }

  Widget _buildContent(AppLocalizations l10n, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            _buildTitleSection(isDark),
            const SizedBox(height: 16),
            _buildStatsRow(l10n, isDark),
            const SizedBox(height: 32),
            _buildStatsCards(l10n),
            const SizedBox(height: 32),
            _buildLastPlayedSection(l10n, isDark),
            const SizedBox(height: 32),
            _buildPlayButtons(context, l10n),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection(bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            _game!.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textDark : AppColors.textLight,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _game!.category.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 1,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(AppLocalizations l10n, bool isDark) {
    return Row(
      children: [
        Icon(Icons.group, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          '${_game!.players} ${l10n.players}',
          style: TextStyle(
            fontSize: 14,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
        const SizedBox(width: 24),
        Icon(Icons.timer, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Text(
          _game!.time,
          style: TextStyle(
            fontSize: 14,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards(AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            value: '${_game!.totalPlays}',
            label: l10n.totalPlays,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: StatCard(
            value: '${_game!.winRate.toStringAsFixed(0)}%',
            label: l10n.winRate,
          ),
        ),
      ],
    );
  }

  Widget _buildLastPlayedSection(AppLocalizations l10n, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.lastPlayed,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textDark : AppColors.textLight,
          ),
        ),
        const SizedBox(height: 16),
        ThemeContainer(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              DateBox(date: _game!.lastPlayed),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _game!.lastPlayed != null
                          ? _getDayName(_game!.lastPlayed!)
                          : l10n.neverPlayed,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _game!.lastPlayed != null
                          ? 'Played ${_getTimeAgo(_game!.lastPlayed!, l10n)}'
                          : l10n.addPlaySession,
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlayButtons(BuildContext context, AppLocalizations l10n) {
    return ActionButtonsRow(
      buttons: [
        ActionButtonConfig(
          label: l10n.won,
          icon: Icons.emoji_events,
          onPressed: () => _recordPlay(context, true),
        ),
        ActionButtonConfig(
          label: l10n.lost,
          icon: Icons.sentiment_dissatisfied,
          isSecondary: true,
          onPressed: () => _recordPlay(context, false),
        ),
      ],
    );
  }

  void _editGame() => context.push('/edit-game/${_game!.id}');

  void _deleteGame() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Game'),
        content: Text('Are you sure you want to delete "${_game!.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<GameProvider>().deleteGame(_game!.id);
              Navigator.pop(ctx);
              context.pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _recordPlay(BuildContext context, bool won) {
    context.read<GameProvider>().recordPlay(_game!.id, won);
    _loadGame();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(won ? 'Recorded win!' : 'Recorded loss!'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  String _getDayName(DateTime date) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[date.weekday - 1];
  }

  String _getTimeAgo(DateTime date, AppLocalizations l10n) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()} months ago';
    if (diff.inDays > 0) return '${diff.inDays} days ago';
    if (diff.inHours > 0) return '${diff.inHours} hours ago';
    return 'recently';
  }
}
