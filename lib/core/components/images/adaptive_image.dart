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

  /// Upper bound for the decode size. Past this the memory saved no longer
  /// justifies another resampling pass.
  static const int kMaxDecodeWidth = 2048;

  @override
  Widget build(BuildContext context) {
    // Decode at display size. Without cacheWidth/cacheHeight Flutter decodes
    // the full-resolution bitmap, so a 4000x3000 photo costs ~48 MB of RAM per
    // card - which is what made huge covers choke the collection grid, mostly
    // on the web where there is no native thumbnail cache to lean on.
    return LayoutBuilder(
      builder: (context, constraints) {
        final target = _decodeWidth(context, constraints);
        return _wrap(_buildImage(context, target));
      },
    );
  }

  /// Largest width the image will actually be painted at, in device pixels.
  int? _decodeWidth(BuildContext context, BoxConstraints constraints) {
    var logical = width;
    if (logical == null || !logical.isFinite || logical <= 0) {
      logical = constraints.maxWidth.isFinite && constraints.maxWidth > 0
          ? constraints.maxWidth
          : null;
    }
    if (logical == null) return null;

    final ratio = MediaQuery.maybeDevicePixelRatioOf(context) ?? 1.0;
    final pixels = (logical * ratio).ceil();
    return pixels > kMaxDecodeWidth ? kMaxDecodeWidth : pixels;
  }

  Widget _wrap(Widget image) {
    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }

  Widget _buildImage(BuildContext context, int? cacheWidth) {
    final remote = networkUrl?.isNotEmpty == true
        ? networkUrl!
        : (localPath != null && isRemoteImagePath(localPath!)
              ? localPath!
              : null);

    if (remote != null) {
      // ResizeImage is how you ask Flutter to decode at a smaller size; the
      // Image.network/file constructors have no cacheWidth of their own.
      return Image(
        image: ResizeImage(NetworkImage(remote), width: cacheWidth),
        width: width,
        height: height,
        fit: fit,
        gaplessPlayback: true,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded || frame != null) return child;
          return _buildLoading(null);
        },
        errorBuilder: (context, error, stackTrace) => _buildError(),
      );
    }

    final provider = resolveImageProvider(localPath ?? '');
    if (provider != null) {
      return Image(
        image: ResizeImage(provider, width: cacheWidth),
        width: width,
        height: height,
        fit: fit,
        gaplessPlayback: true,
        errorBuilder: (context, error, stackTrace) => _buildError(),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildLoading(ImageChunkEvent? loadingProgress) {
    return Container(
      width: width,
      height: height,
      color: AppColors.primary.withValues(alpha: 0.1),
      child: Center(
        child: CircularProgressIndicator(
          value: loadingProgress != null &&
                  loadingProgress.expectedTotalBytes != null
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
