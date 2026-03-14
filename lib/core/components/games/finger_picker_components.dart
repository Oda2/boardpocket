import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class CountdownOverlay extends StatelessWidget {
  final int count;
  final String label;
  final Animation<double> animation;

  const CountdownOverlay({
    super.key,
    required this.count,
    required this.label,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: animation,
        builder: (_, __) => Container(
          width: 180,
          height: 180,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
              width: 4,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FingerPointer extends StatelessWidget {
  final Offset position;
  final Color color;
  final bool isSelected;

  const FingerPointer({
    super.key,
    required this.position,
    required this.color,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx - 30,
      top: position.dy - 30,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color.withValues(alpha: isSelected ? 0.9 : 0.7),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.5),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.touch_app,
            color: Colors.white.withValues(alpha: 0.8),
            size: 24,
          ),
        ),
      ),
    );
  }
}

class WinnerDisplay extends StatelessWidget {
  final Color color;
  final Animation<double> animation;

  const WinnerDisplay({
    super.key,
    required this.color,
    required this.animation,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: const Icon(Icons.celebration, color: Colors.white, size: 60),
          ),
        );
      },
    );
  }
}

class FingerPickerHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelecting;
  final bool hasWinner;

  const FingerPickerHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.isSelecting = false,
    this.hasWinner = false,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 80,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasWinner
                ? 'Winner!'
                : isSelecting
                ? 'Selecting...'
                : subtitle,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class FingerPickerCanvas extends StatelessWidget {
  final Widget child;

  const FingerPickerCanvas({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {},
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [Colors.grey.shade900, Colors.black],
          ),
        ),
        child: Stack(children: [child]),
      ),
    );
  }
}
