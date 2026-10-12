import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'images/adaptive_image.dart';
import '../theme/app_theme.dart';

/// Cover picker used by the add/edit game form.
///
/// Shows the current cover (local file or remote URL) and lets the user either
/// pick a new one from the device or search the web for one.
class ImageUpload extends StatelessWidget {
  final String? imagePath;
  final String? hintText;
  final double height;
  final ValueChanged<String?> onImageSelected;
  final VoidCallback? onSearchTap;

  const ImageUpload({
    super.key,
    this.imagePath,
    this.hintText,
    this.height = 200,
    required this.onImageSelected,
    this.onSearchTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasImage = imagePath != null && imagePath!.isNotEmpty;

    return GestureDetector(
      onTap: () => _pickImage(context),
      child: Container(
        height: height,
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
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (hasImage)
                AdaptiveImage(localPath: imagePath)
              else
                _buildPlaceholder(isDark),
              if (hasImage && onSearchTap != null)
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: _ActionButton(
                    icon: Icons.image_search,
                    tooltip: 'Search online',
                    onPressed: onSearchTap!,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(bool isDark) {
    return Column(
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
          child: const Icon(Icons.add_a_photo, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 16),
        Text(
          hintText ?? 'Upload Image',
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondaryLight,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (onSearchTap != null) ...[
          const SizedBox(height: 12),
          TextButton.icon(
            onPressed: onSearchTap,
            icon: const Icon(Icons.image_search, size: 20),
            label: const Text('Search online'),
          ),
        ],
      ],
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      onImageSelected(pickedFile.path);
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: 0.55),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Tooltip(
          message: tooltip,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}
