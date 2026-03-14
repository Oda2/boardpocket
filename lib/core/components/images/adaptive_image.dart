import 'dart:io';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AdaptiveImage extends StatelessWidget {
  final String? localPath;
  final String? networkUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? errorWidget;

  const AdaptiveImage({
    super.key,
    this.localPath,
    this.networkUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final imageWidget = _buildImage(context);

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: imageWidget);
    }
    return imageWidget;
  }

  Widget _buildImage(BuildContext context) {
    if (localPath != null && localPath!.isNotEmpty) {
      return Image.file(
        File(localPath!),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildError(),
      );
    }

    if (networkUrl != null && networkUrl!.isNotEmpty) {
      return Image.network(
        networkUrl!,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoading(loadingProgress);
        },
        errorBuilder: (context, error, stackTrace) => _buildError(),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildLoading(ImageChunkEvent loadingProgress) {
    return Container(
      width: width,
      height: height,
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Center(
        child: CircularProgressIndicator(
          value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
              : null,
          strokeWidth: 2,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return placeholder ??
        Container(
          width: width,
          height: height,
          color: AppColors.primary.withValues(alpha: 0.1),
          child: const Center(
            child: Icon(Icons.image_not_supported, color: AppColors.primary),
          ),
        );
  }

  Widget _buildError() {
    return errorWidget ??
        Container(
          width: width,
          height: height,
          color: AppColors.primary.withValues(alpha: 0.1),
          child: const Center(
            child: Icon(Icons.broken_image, color: AppColors.primary),
          ),
        );
  }
}
