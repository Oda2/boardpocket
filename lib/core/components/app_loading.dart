import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../theme/app_theme.dart';

/// Loading indicator used across the app.
///
/// Plays a Lottie animation from `assets/lottie/`. If the file is missing
/// (for example on a fresh checkout that has not pulled the animation assets)
/// it falls back to a plain spinner instead of crashing.
class AppLoading extends StatefulWidget {
  final double size;
  final String? asset;

  const AppLoading({super.key, this.size = 64, this.asset});

  static const String defaultAsset = 'assets/lottie/loading_dots.json';

  @override
  State<AppLoading> createState() => _AppLoadingState();
}

class _AppLoadingState extends State<AppLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  bool _assetMissing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_assetMissing) {
      return SizedBox(
        width: widget.size * 0.6,
        height: widget.size * 0.6,
        child: const CircularProgressIndicator(strokeWidth: 3),
      );
    }

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Lottie.asset(
        widget.asset ?? AppLoading.defaultAsset,
        controller: _controller,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) {
          // Mark on the next frame so we do not setState during build.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _assetMissing = true);
          });
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

/// Loading view for a whole screen or a large region.
class AppLoadingView extends StatelessWidget {
  final String? message;
  final double size;

  const AppLoadingView({super.key, this.message, this.size = 96});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppLoading(size: size),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
