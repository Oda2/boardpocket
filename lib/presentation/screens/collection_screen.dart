import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/components/components.dart';
import '../../core/i18n/i18n.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProvider>().loadGames();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    final gameProvider = context.watch<GameProvider>();
    final games = gameProvider.filteredGames;
    final categories = [l10n.all, ...gameProvider.categories];

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                AppHeader(
                  subtitle: 'BoardPocket',
                  title: l10n.collection,
                  trailing: ProfileAvatar(
                    onTap: () => context.push('/settings'),
                  ),
                ),
                AppSearchBar(
                  hint: l10n.searchGames,
                  onChanged: (value) =>
                      context.read<GameProvider>().setSearchQuery(value),
                ),
                ChipSelector(
                  items: categories,
                  selected: gameProvider.selectedCategory,
                  onSelected: (category) =>
                      context.read<GameProvider>().setCategory(category),
                ),
                Expanded(
                  child: gameProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : games.isEmpty
                      ? EmptyState(
                          icon: Icons.sports_esports_outlined,
                          title: l10n.noGamesYet,
                          subtitle: l10n.tapToAddFirstGame,
                        )
                      : _buildGamesGrid(context, games),
                ),
                const BottomTabBar(activeRoute: '/'),
              ],
            ),
            Positioned(
              right: 24,
              bottom: 100,
              child: FloatingActionButton(
                onPressed: () => context.push('/add-game'),
                backgroundColor: AppColors.primary,
                elevation: 4,
                child: const Icon(Icons.add, size: 32),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGamesGrid(BuildContext context, List<Game> games) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxCardWidth = 200.0;
        final crossAxisCount = (constraints.maxWidth / (maxCardWidth + 16))
            .floor()
            .clamp(2, 4);
        final cardWidth =
            (constraints.maxWidth - (crossAxisCount - 1) * 16) / crossAxisCount;
        final cardHeight = cardWidth * 1.35;

        return GridView.builder(
          padding: const EdgeInsets.all(24),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: cardWidth / cardHeight,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: games.length,
          itemBuilder: (context, index) {
            final game = games[index];
            return _buildGameCard(context, game, cardHeight);
          },
        );
      },
    );
  }

  Widget _buildGameCard(BuildContext context, Game game, double cardHeight) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => context.push('/game-detail/${game.id}'),
      child: ThemeContainer(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: game.imagePath != null
                    ? Image.file(
                        File(game.imagePath!),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : Container(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        child: const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      game.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          game.players,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.schedule_outlined,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          game.time,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ],
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
}
