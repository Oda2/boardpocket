import 'dart:io';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProfileAvatar extends StatelessWidget {
  final String? name;
  final VoidCallback? onTap;
  final double size;
  final String? imagePath;
  final String? imageUrl;

  const ProfileAvatar({
    super.key,
    this.name,
    this.onTap,
    this.size = 40,
    this.imagePath,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(size / 2),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
            width: 2,
          ),
        ),
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (imagePath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular((size - 4) / 2),
        child: Image.file(
          File(imagePath!),
          fit: BoxFit.cover,
          width: size - 4,
          height: size - 4,
          errorBuilder: (_, __, ___) => _buildInitial(),
        ),
      );
    }
    if (imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular((size - 4) / 2),
        child: Image.network(
          imageUrl!,
          fit: BoxFit.cover,
          width: size - 4,
          height: size - 4,
          errorBuilder: (_, __, ___) => _buildInitial(),
        ),
      );
    }
    return _buildInitial();
  }

  Widget _buildInitial() {
    return Center(
      child: Text(
        name != null && name!.isNotEmpty
            ? name!.substring(0, 1).toUpperCase()
            : 'U',
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
