import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/components/components.dart';
import '../../core/i18n/i18n.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';
import '../providers/providers.dart';

class AddGameScreen extends StatelessWidget {
  final String? gameId;

  const AddGameScreen({super.key, this.gameId});

  @override
  Widget build(BuildContext context) {
    return _GameFormScreen(gameId: gameId);
  }
}

class _GameFormScreen extends StatefulWidget {
  final String? gameId;

  const _GameFormScreen({this.gameId});

  @override
  State<_GameFormScreen> createState() => _GameFormScreenState();
}

class _GameFormScreenState extends State<_GameFormScreen> {
  final _titleController = TextEditingController();
  String? _selectedImagePath;
  int _minPlayers = 1;
  int _maxPlayers = 4;
  int _playTime = 60;
  int _complexity = 3;
  String _category = 'Strategy';
  Game? _existingGame;
  bool _isLoading = false;

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
    if (_isEditing) _loadGame();
  }

  Future<void> _loadGame() async {
    setState(() => _isLoading = true);
    final game = await context.read<GameProvider>().getGameById(widget.gameId!);
    if (game != null && mounted) {
      setState(() {
        _existingGame = game;
        _titleController.text = game.title;
        _selectedImagePath = game.imagePath;
        _minPlayers = game.minPlayers ?? 1;
        _maxPlayers = game.maxPlayers ?? 4;
        _playTime = game.playTime ?? 60;
        _complexity = (game.complexity ?? 3).toInt();
        _category = game.category;
        _isLoading = false;
      });
    }
  }

  void _save() {
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
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(l10n),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ImageUpload(
                      imagePath: _selectedImagePath,
                      hintText: l10n.uploadCover,
                      onImageSelected: (path) =>
                          setState(() => _selectedImagePath = path),
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      label: l10n.gameTitle,
                      controller: _titleController,
                      hint: l10n.enterGameTitle,
                      icon: Icons.label_outline,
                    ),
                    const SizedBox(height: 24),
                    _buildRow([
                      _buildNumberSelector(
                        label: l10n.players,
                        value: _minPlayers,
                        min: 1,
                        max: _maxPlayers,
                        onChanged: (v) => setState(() => _minPlayers = v),
                      ),
                      const SizedBox(width: 16),
                      _buildNumberSelector(
                        label: l10n.playTime,
                        value: _playTime,
                        min: 5,
                        max: 480,
                        suffix: 'm',
                        onChanged: (v) => setState(() => _playTime = v),
                      ),
                    ]),
                    const SizedBox(height: 24),
                    _buildChipSelector(
                      label: l10n.category,
                      options: _categories,
                    ),
                    const SizedBox(height: 24),
                    _buildStarRating(label: l10n.complexity),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
            _buildFooter(l10n, isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFieldInput(controller: controller, hint: hint, icon: icon),
      ],
    );
  }

  Widget _buildRow(List<Widget> children) {
    return Row(children: children.map((c) => Expanded(child: c)).toList());
  }

  Widget _buildNumberSelector({
    required String label,
    required int value,
    required int min,
    required int max,
    String? suffix,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        NumberInput(value: value, min: min, max: max, onChanged: onChanged),
      ],
    );
  }

  Widget _buildChipSelector({
    required String label,
    required List<String> options,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ChipSelectorInput(
          items: options,
          selected: _category,
          onSelected: (c) => setState(() => _category = c),
        ),
      ],
    );
  }

  Widget _buildStarRating({required String label}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        RatingStarsInput(
          value: _complexity,
          onChanged: (v) => setState(() => _complexity = v),
        ),
      ],
    );
  }

  Widget _buildFooter(AppLocalizations l10n, bool isDark) {
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
          onPressed: _save,
        ),
      ),
    );
  }
}
