import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

/// A die that shakes and tumbles its digits while the pool is being rolled.
///
/// Pure Flutter animation: no package, no asset, nothing to license. When
/// [isRolling] flips to true the widget runs a shake plus a spinning cycle;
/// once it flips back the digits settle on the final value.
class AnimatedDie extends StatefulWidget {
  final int sides;
  final int value;

  /// Drives the animation. Typically `provider.isRolling`.
  final bool isRolling;

  /// How long the tumble lasts. Should match the provider's roll delay.
  final Duration duration;

  final double size;

  const AnimatedDie({
    super.key,
    required this.sides,
    required this.value,
    this.isRolling = false,
    this.duration = const Duration(milliseconds: 350),
    this.size = 52,
  });

  @override
  State<AnimatedDie> createState() => _AnimatedDieState();
}

class _AnimatedDieState extends State<AnimatedDie>
    with TickerProviderStateMixin {
  late final AnimationController _shake;
  late final AnimationController _tumble;
  late final AnimationController _digits;

  /// Random values shown while tumbling.
  late List<int> _scramble;

  @override
  void initState() {
    super.initState();

    _shake = AnimationController(vsync: this, duration: widget.duration);
    _tumble = AnimationController(vsync: this, duration: widget.duration);
    _digits = AnimationController(vsync: this, duration: widget.duration);

    _scramble = List.filled(1, widget.value);
    _syncAnimations();
  }

  @override
  void didUpdateWidget(AnimatedDie oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.duration != widget.duration) {
      _shake.duration = widget.duration;
      _tumble.duration = widget.duration;
      _digits.duration = widget.duration;
    }

    if (oldWidget.value != widget.value) {
      _scramble = [..._scramble, widget.value];
    }

    _syncAnimations();
  }

  void _syncAnimations() {
    if (widget.isRolling) {
      if (!_shake.isAnimating) _shake.forward(from: 0);
      if (!_tumble.isAnimating) _tumble.repeat();
      if (!_digits.isAnimating) _digits.repeat();
    } else {
      if (_shake.isAnimating) _shake.animateTo(1);
      if (_tumble.isAnimating) {
        _tumble.animateTo(1).whenComplete(() {
          if (mounted && !widget.isRolling) _tumble.reset();
        });
      }
      if (_digits.isAnimating) {
        _digits.animateTo(1).whenComplete(() {
          if (mounted && !widget.isRolling) {
            _digits.reset();
            setState(() => _scramble = [widget.value]);
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _shake.dispose();
    _tumble.dispose();
    _digits.dispose();
    super.dispose();
  }

  /// Picks the fake value to show on a given frame of the tumble.
  int _frameValue(int frame) {
    if (_scramble.length > 1) {
      // Finish the cycle: each frame lands on the next entry, last one real.
      return _scramble[math.min(frame, _scramble.length - 1)];
    }
    return 1 + (frame % widget.sides);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: Listenable.merge([_shake, _tumble, _digits]),
      builder: (context, _) {
        // Damped shake, like a hand flicking the die across the table.
        final shakeT = _shake.value;
        final decay = (1 - shakeT) * 6;
        final dx = math.sin(shakeT * math.pi * 10) * decay;
        final dy = math.cos(shakeT * math.pi * 14) * decay * 0.6;

        // Full tumble on the vertical axis, easing back to rest.
        final spin = widget.isRolling
            ? _tumble.value * math.pi * 4
            : math.sin(shakeT * math.pi) * math.pi * 0.5;

        final digitValue = widget.isRolling
            ? _frameValue((_digits.value * 18).floor())
            : widget.value;

        return Transform.translate(
          offset: Offset(dx, dy),
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0015)
              ..rotateY(spin),
            child: Transform.scale(
              // A slight squash sells the impact of landing.
              scale: 1 + math.sin(shakeT * math.pi) * 0.12,
              child: Container(
                width: widget.size,
                height: widget.size,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: isDark ? 0.2 : 0.12,
                  ),
                  borderRadius: BorderRadius.circular(widget.size * 0.23),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.45),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(
                        alpha: 0.18 * (1 - shakeT) + 0.05,
                      ),
                      blurRadius: 10 + 8 * (1 - shakeT),
                      offset: Offset(0, 3 * (1 - shakeT)),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // No AnimatedSwitcher here: while tumbling the value can
                    // repeat on consecutive frames, which left two children
                    // sharing a ValueKey and threw "Duplicate keys found".
                    Transform.scale(
                      // Each tick kicks the number slightly, reading as a roll.
                      scale: 1 + _digits.value * 0.12,
                      child: Text(
                        '$digitValue',
                        style: TextStyle(
                          fontSize: widget.size * 0.36,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                    Text(
                      'd${widget.sides}',
                      style: TextStyle(
                        fontSize: widget.size * 0.16,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
