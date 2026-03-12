import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/components/components.dart';
import '../../core/i18n/i18n.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';
import '../providers/providers.dart';

class AddGameScreen extends StatefulWidget {
  final String? gameId;

  const AddGameScreen({super.key, this.gameId});

  @override
  State<AddGameScreen> createState() => _AddGameScreenState();
}

class _AddGameScreenState extends State<AddGameScreen> {
  final _titleController = TextEditingController();
  String? _selectedImagePath;
  int _minPlayers = 1;
  int _maxPlayers = 4;
  int _playTime = 60;
  int _complexity = 3;
  String _category = 'Strategy';
  Game? _existingGame;
  final List<String> _categories = [
    'Strategy',
    'Party',
    'Euro',
    'Solo',
    'Co-op',
    'Abstract',
  ];

  bool get _isEditing => widget.gameId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadGame();
    }
  }

  Future<void> _loadGame() async {
    final game = await context.read<GameProvider>().getGameById(widget.gameId!);
    if (game != null) {
      setState(() {
        _existingGame = game;
        _titleController.text = game.title;
        _selectedImagePath = game.imagePath;
        _minPlayers = game.minPlayers ?? 1;
        _maxPlayers = game.maxPlayers ?? 4;
        _playTime = game.playTime ?? 60;
        _complexity = (game.complexity ?? 3).toInt();
        _category = game.category;
      });
    }
  }

  void _saveGame() {
    if (_titleController.text.isEmpty) return;

    if (_isEditing && _existingGame != null) {
      final updatedGame = _existingGame!.copyWith(
        title: _titleController.text,
        imagePath: _selectedImagePath,
        players: '$_minPlayers-$_maxPlayers',
        time: '${_playTime}m',
        category: _category,
        minPlayers: _minPlayers,
        maxPlayers: _maxPlayers,
        playTime: _playTime,
        complexity: _complexity.toDouble(),
        updatedAt: DateTime.now(),
      );
      context.read<GameProvider>().updateGame(updatedGame);
    } else {
      final game = Game(
        id: const Uuid().v4(),
        title: _titleController.text,
        imagePath: _selectedImagePath,
        players: '$_minPlayers-$_maxPlayers',
        time: '${_playTime}m',
        category: _category,
        minPlayers: _minPlayers,
        maxPlayers: _maxPlayers,
        playTime: _playTime,
        complexity: _complexity.toDouble(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      context.read<GameProvider>().addGame(game);
    }
    context.pop();
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
            _buildHeader(context, l10n),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ImageUpload(
                      imagePath: _selectedImagePath,
                      hintText: l10n.uploadCover,
                      onImageSelected: (path) {
                        setState(() => _selectedImagePath = path);
                      },
                    ),
                    const SizedBox(height: 24),
                    SectionLabel(text: l10n.gameTitle),
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: _titleController,
                      hint: l10n.enterGameTitle,
                      icon: Icons.label_outline,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SectionLabel(text: l10n.players),
                              const SizedBox(height: 8),
                              _buildPlayerSelector(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SectionLabel(text: l10n.playTime),
                              const SizedBox(height: 8),
                              AppTextField(
                                hint: '60',
                                icon: Icons.schedule,
                                suffixText: 'MINS',
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  setState(() {
                                    _playTime = int.tryParse(value) ?? 60;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SectionLabel(text: l10n.category),
                    const SizedBox(height: 8),
                    ChipSelector(
                      items: _categories,
                      selected: _category,
                      onSelected: (cat) => setState(() => _category = cat),
                    ),
                    const SizedBox(height: 24),
                    SectionLabel(
                      text: l10n.complexity,
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getComplexityLabel(l10n),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    StarRating(
                      value: _complexity,
                      onChanged: (val) => setState(() => _complexity = val),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            _buildSaveButton(l10n, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios),
            color: AppColors.primary,
          ),
          Expanded(
            child: Text(
              _isEditing ? l10n.editGame : l10n.newBoardGame,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(onPressed: () => context.pop(), child: Text(l10n.cancel)),
        ],
      ),
    );
  }

  Widget _buildPlayerSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        NumberCounter(
          value: _minPlayers,
          min: 1,
          max: _maxPlayers,
          onChanged: (val) => setState(() => _minPlayers = val),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '-',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textDark
                  : AppColors.textLight,
            ),
          ),
        ),
        NumberCounter(
          value: _maxPlayers,
          min: _minPlayers,
          max: 20,
          onChanged: (val) => setState(() => _maxPlayers = val),
        ),
      ],
    );
  }

  Widget _buildSaveButton(AppLocalizations l10n, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
            (isDark ? AppColors.backgroundDark : AppColors.backgroundLight)
                .withValues(alpha: 0),
          ],
        ),
      ),
      child: SafeArea(
        child: AppButton(
          label: _isEditing ? l10n.save : l10n.addToCollection,
          icon: _isEditing ? Icons.save : Icons.library_add,
          onPressed: _saveGame,
        ),
      ),
    );
  }

  String _getComplexityLabel(AppLocalizations l10n) {
    if (_complexity <= 2) return l10n.light;
    if (_complexity <= 3) return l10n.medium;
    if (_complexity <= 4) return l10n.heavy;
    return l10n.expert;
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }
}
