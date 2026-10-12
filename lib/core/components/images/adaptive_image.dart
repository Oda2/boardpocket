import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../utils/image_paths.dart';
import '../../utils/image_provider.dart';

/// Renders a game cover from either a local file path or a remote URL.
///
/// Both are stored in the same `Game.imagePath` field, so the source is
/// detected from the value itself. Use [networkUrl] when you already know the
/// image is remote (for example a search result preview).
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
    final remote = networkUrl?.isNotEmpty == true
        ? networkUrl!
        : (localPath != null && isRemoteImagePath(localPath!)
              ? localPath!
              : null);

    if (remote != null) {
      return Image.network(
        remote,
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

    final provider = resolveImageProvider(localPath ?? '');
    if (provider != null) {
      return Image(
        image: provider,
        width: width,
        height: height,
        fit: fit,
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
