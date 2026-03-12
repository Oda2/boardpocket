import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/components/components.dart';
import '../../core/i18n/i18n.dart';
import '../../core/theme/app_theme.dart';
import '../providers/providers.dart';

class NameDrawScreen extends StatefulWidget {
  const NameDrawScreen({super.key});

  @override
  State<NameDrawScreen> createState() => _NameDrawScreenState();
}

class _NameDrawScreenState extends State<NameDrawScreen>
    with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  String? _winner;
  bool _isDrawing = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlayerProvider>().loadPlayers();
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  void _addPlayer() {
    if (_nameController.text.isNotEmpty) {
      context.read<PlayerProvider>().addPlayer(_nameController.text);
      _nameController.clear();
    }
  }

  void _drawWinner() {
    final players = context.read<PlayerProvider>().players;
    if (players.isEmpty) return;

    setState(() {
      _isDrawing = true;
      _winner = null;
    });

    int count = 0;
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      setState(() {
        _winner = players[count % players.length].name;
      });
      count++;
      return count < 20;
    }).then((_) {
      setState(() {
        _isDrawing = false;
        _winner = players[DateTime.now().millisecond % players.length].name;
      });
      _animationController.forward(from: 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final playerProvider = context.watch<PlayerProvider>();
    final players = playerProvider.players;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(l10n, isDark),
                _buildInput(l10n, isDark),
                _buildPlayersList(players, isDark),
                const Spacer(),
                _buildDrawButton(l10n, isDark, players),
                const SizedBox(height: 100),
              ],
            ),
            if (_winner != null) _buildWinnerOverlay(l10n, isDark),
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
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.nameDraw,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.randomlySelectPlayer,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
          IconActionButton(
            icon: Icons.close,
            isDark: isDark,
            onTap: () => context.pop(),
          ),
        ],
      ),
    );
  }

  Widget _buildInput(AppLocalizations l10n, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: AppTextField(
              controller: _nameController,
              hint: l10n.enterPlayerName,
              icon: Icons.person_add,
              onSubmitted: (_) => _addPlayer(),
            ),
          ),
          const SizedBox(width: 12),
          IconActionButton(icon: Icons.add, isDark: isDark, onTap: _addPlayer),
        ],
      ),
    );
  }

  Widget _buildPlayersList(List players, bool isDark) {
    if (players.isEmpty) {
      return Expanded(
        child: EmptyState(
          icon: Icons.group_add,
          title: 'No players yet',
          subtitle: 'Add players to start',
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.all(24),
        itemCount: players.length,
        itemBuilder: (context, index) {
          final player = players[index];
          return ThemeContainer(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withValues(alpha: 0.2),
                  child: Text(
                    player.name[0].toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    player.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                IconActionButton(
                  icon: Icons.delete_outline,
                  isDark: isDark,
                  size: 32,
                  backgroundColor: Colors.red.withValues(alpha: 0.1),
                  iconColor: Colors.red,
                  onTap: () =>
                      context.read<PlayerProvider>().deletePlayer(player.id),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawButton(AppLocalizations l10n, bool isDark, List players) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: AppButton(
        label: _isDrawing ? 'Drawing...' : 'Draw Winner',
        icon: Icons.casino,
        onPressed: players.length >= 2 && !_isDrawing ? _drawWinner : null,
      ),
    );
  }

  Widget _buildWinnerOverlay(AppLocalizations l10n, bool isDark) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Winner!',
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 16),
            Text(
              _winner!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 32),
            AppButton(
              label: 'Draw Again',
              icon: Icons.refresh,
              onPressed: _drawWinner,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => setState(() => _winner = null),
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _animationController.dispose();
    super.dispose();
  }
}
