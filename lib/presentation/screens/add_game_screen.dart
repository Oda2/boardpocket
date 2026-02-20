import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
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
  File? _selectedImage;
  int _minPlayers = 1;
  int _maxPlayers = 4;
  int _playTime = 60;
  double _complexity = 3;
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
        if (game.imagePath != null) {
          _selectedImage = File(game.imagePath!);
        }
        _minPlayers = game.minPlayers ?? 1;
        _maxPlayers = game.maxPlayers ?? 4;
        _playTime = game.playTime ?? 60;
        _complexity = game.complexity ?? 3;
        _category = game.category;
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _saveGame() {
    if (_titleController.text.isEmpty) return;

    if (_isEditing && _existingGame != null) {
      final updatedGame = _existingGame!.copyWith(
        title: _titleController.text,
        imagePath: _selectedImage?.path,
        players: '$_minPlayers-$_maxPlayers',
        time: '${_playTime}m',
        category: _category,
        minPlayers: _minPlayers,
        maxPlayers: _maxPlayers,
        playTime: _playTime,
        complexity: _complexity,
        updatedAt: DateTime.now(),
      );
      context.read<GameProvider>().updateGame(updatedGame);
    } else {
      final game = Game(
        id: const Uuid().v4(),
        title: _titleController.text,
        imagePath: _selectedImage?.path,
        players: '$_minPlayers-$_maxPlayers',
        time: '${_playTime}m',
        category: _category,
        minPlayers: _minPlayers,
        maxPlayers: _maxPlayers,
        playTime: _playTime,
        complexity: _complexity,
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
            // Header
            _buildHeader(context, isDark),

            // Form
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image Upload
                    _buildImageUpload(context, isDark),
                    const SizedBox(height: 24),

                    // Title
                    _buildLabel(l10n.gameTitle),
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: _titleController,
                      hint: l10n.enterGameTitle,
                      icon: Icons.label_outline,
                    ),
                    const SizedBox(height: 24),

                    // Players & Time
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(l10n.players),
                              const SizedBox(height: 8),
                              _buildPlayerSelector(context, isDark),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildLabel(l10n.playTime),
                              const SizedBox(height: 8),
                              _buildTimeInput(context, isDark),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Category
                    _buildLabel(l10n.category),
                    const SizedBox(height: 8),
                    _buildCategorySelector(context, isDark),
                    const SizedBox(height: 24),

                    // Complexity
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildLabel(l10n.complexity),
                        Container(
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
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildComplexitySelector(context, isDark),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),

            // Save Button
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    isDark
                        ? AppColors.backgroundDark
                        : AppColors.backgroundLight,
                    (isDark
                            ? AppColors.backgroundDark
                            : AppColors.backgroundLight)
                        .withValues(alpha: 0),
                  ],
                ),
              ),
              child: SafeArea(
                child: ElevatedButton.icon(
                  onPressed: _saveGame,
                  icon: Icon(_isEditing ? Icons.save : Icons.library_add),
                  label: Text(_isEditing ? l10n.save : l10n.addToCollection),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 56),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context);
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

  Widget _buildImageUpload(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
          image: _selectedImage != null
              ? DecorationImage(
                  image: FileImage(_selectedImage!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: _selectedImage == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(32),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.add_a_photo,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.uploadCover,
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: AppColors.primary,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(
            icon,
            color: AppColors.primary.withValues(alpha: 0.6),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget _buildPlayerSelector(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildCircularButton(
            icon: Icons.remove,
            onTap: () {
              if (_minPlayers > 1) {
                setState(() => _minPlayers--);
              } else if (_maxPlayers > _minPlayers) {
                setState(() => _maxPlayers--);
              }
            },
          ),
          Text(
            '$_minPlayers-$_maxPlayers',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          _buildCircularButton(
            icon: Icons.add,
            onTap: () {
              setState(() => _maxPlayers++);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCircularButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.backgroundDark
              : AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.primary),
      ),
    );
  }

  Widget _buildTimeInput(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: TextField(
        keyboardType: TextInputType.number,
        onChanged: (value) {
          setState(() {
            _playTime = int.tryParse(value) ?? 60;
          });
        },
        decoration: InputDecoration(
          hintText: '60',
          prefixIcon: Icon(
            Icons.schedule,
            color: AppColors.primary.withValues(alpha: 0.6),
          ),
          suffixText: 'MINS',
          suffixStyle: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            fontWeight: FontWeight.bold,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  Widget _buildCategorySelector(BuildContext context, bool isDark) {
    return Container(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _category;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _category = category),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildComplexitySelector(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(5, (index) {
          final isSelected = index < _complexity;
          return GestureDetector(
            onTap: () => setState(() => _complexity = index + 1),
            child: Icon(
              Icons.star,
              size: 32,
              color: isSelected
                  ? AppColors.primary
                  : AppColors.primary.withValues(alpha: 0.3),
            ),
          );
        }),
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
