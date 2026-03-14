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
      setState(() => _winner = players[count % players.length].name);
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
  void dispose() {
    _nameController.dispose();
    _animationController.dispose();
    super.dispose();
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
                _buildInput(l10n),
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

  Widget _buildInput(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Expanded(
            child: TextFieldInput(
              controller: _nameController,
              hint: l10n.enterPlayerName,
              icon: Icons.person_add,
              onChanged: (_) {},
            ),
          ),
          const SizedBox(width: 12),
          IconActionButton(icon: Icons.add, isDark: false, onTap: _addPlayer),
        ],
      ),
    );
  }

  Widget _buildPlayersList(List players, bool isDark) {
    if (players.isEmpty) {
      return const Expanded(
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
          return _buildPlayerItem(player, isDark);
        },
      ),
    );
  }

  Widget _buildPlayerItem(dynamic player, bool isDark) {
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
            onTap: () => context.read<PlayerProvider>().deletePlayer(player.id),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawButton(AppLocalizations l10n, bool isDark, List players) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        child: AppButton(
          label: players.isEmpty ? 'Add Players' : 'Draw Winner',
          icon: Icons.casino,
          onPressed: players.isEmpty ? null : _drawWinner,
        ),
      ),
    );
  }

  Widget _buildWinnerOverlay(AppLocalizations l10n, bool isDark) {
    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: AnimatedResultCard(
          title: _winner,
          subtitle: 'Winner!',
          isAnimating: _isDrawing,
        ),
      ),
    );
  }
}
