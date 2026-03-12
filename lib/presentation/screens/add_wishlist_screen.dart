import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../../core/components/components.dart';
import '../../core/i18n/i18n.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/models.dart';
import '../providers/providers.dart';

class AddWishlistScreen extends StatefulWidget {
  final String? itemId;

  const AddWishlistScreen({super.key, this.itemId});

  @override
  State<AddWishlistScreen> createState() => _AddWishlistScreenState();
}

class _AddWishlistScreenState extends State<AddWishlistScreen> {
  final _titleController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _purchaseUrlController = TextEditingController();
  final _priceController = TextEditingController();

  WishlistItem? _existingItem;

  bool get _isEditing => widget.itemId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadItem();
    }
  }

  Future<void> _loadItem() async {
    final item = await context.read<WishlistProvider>().getItemById(
      widget.itemId!,
    );
    if (item != null) {
      setState(() {
        _existingItem = item;
        _titleController.text = item.title;
        _imageUrlController.text = item.imageUrl ?? '';
        _purchaseUrlController.text = item.purchaseUrl ?? '';
        _priceController.text = item.price ?? '';
      });
    }
  }

  void _saveItem() {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the game name')),
      );
      return;
    }

    if (_isEditing && _existingItem != null) {
      final updatedItem = _existingItem!.copyWith(
        title: _titleController.text,
        imageUrl: _imageUrlController.text.isNotEmpty
            ? _imageUrlController.text
            : null,
        purchaseUrl: _purchaseUrlController.text.isNotEmpty
            ? _purchaseUrlController.text
            : null,
        price: _priceController.text.isNotEmpty ? _priceController.text : null,
      );
      context.read<WishlistProvider>().updateItem(updatedItem);
    } else {
      final item = WishlistItem(
        id: const Uuid().v4(),
        title: _titleController.text,
        imageUrl: _imageUrlController.text.isNotEmpty
            ? _imageUrlController.text
            : null,
        purchaseUrl: _purchaseUrlController.text.isNotEmpty
            ? _purchaseUrlController.text
            : null,
        price: _priceController.text.isNotEmpty ? _priceController.text : null,
        createdAt: DateTime.now(),
      );
      context.read<WishlistProvider>().addItem(item);
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
                    SectionLabel(text: 'Game Name'),
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: _titleController,
                      hint: 'Enter game name',
                      icon: Icons.games_outlined,
                    ),
                    const SizedBox(height: 24),
                    SectionLabel(text: 'Image URL'),
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: _imageUrlController,
                      hint: 'https://example.com/image.jpg',
                      icon: Icons.image_outlined,
                      keyboardType: TextInputType.url,
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    if (_imageUrlController.text.isNotEmpty)
                      _buildImagePreview(),
                    const SizedBox(height: 24),
                    SectionLabel(text: 'Purchase Link'),
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: _purchaseUrlController,
                      hint: 'https://store.example.com/game',
                      icon: Icons.shopping_cart_outlined,
                      keyboardType: TextInputType.url,
                    ),
                    const SizedBox(height: 24),
                    SectionLabel(text: 'Price'),
                    const SizedBox(height: 8),
                    AppTextField(
                      controller: _priceController,
                      hint: '59.99',
                      icon: Icons.attach_money,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    SectionLabel(text: 'Created At'),
                    const SizedBox(height: 8),
                    _buildDateField(isDark),
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
              _isEditing ? 'Edit Wishlist Item' : 'Add to Wishlist',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          TextButton(onPressed: () => context.pop(), child: Text(l10n.cancel)),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          _imageUrlController.text,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.broken_image_outlined,
                    size: 48,
                    color: Colors.red.withValues(alpha: 0.6),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Failed to load image',
                    style: TextStyle(
                      color: Colors.red.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDateField(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        children: [
          Icon(
            Icons.calendar_today_outlined,
            color: AppColors.primary.withValues(alpha: 0.6),
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            _isEditing && _existingItem != null
                ? _formatDate(_existingItem!.createdAt)
                : _formatDate(DateTime.now()),
            style: TextStyle(
              color: isDark ? AppColors.textDark : AppColors.textLight,
              fontSize: 16,
            ),
          ),
        ],
      ),
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
          label: _isEditing ? 'Save Changes' : 'Add to Wishlist',
          icon: _isEditing ? Icons.save : Icons.favorite_border,
          onPressed: _saveItem,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _imageUrlController.dispose();
    _purchaseUrlController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}
