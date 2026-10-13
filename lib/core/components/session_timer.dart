import 'dart:async';
import 'dart:ui' show FontFeature;

import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'theme_container.dart';

/// Count-up stopwatch for a single play session.
///
/// Pure Flutter animation, no package. Labels are passed in so the caller
/// controls localisation.
class SessionTimer extends StatefulWidget {
  final bool isRunning;
  final Duration elapsed;
  final String sessionLabel;
  final String startLabel;
  final String pauseLabel;
  final String resetLabel;
  final String finishLabel;
  final VoidCallback onStart;
  final VoidCallback onPause;
  final VoidCallback onReset;
  final VoidCallback onFinish;

  const SessionTimer({
    super.key,
    required this.isRunning,
    required this.elapsed,
    required this.sessionLabel,
    required this.startLabel,
    required this.pauseLabel,
    required this.resetLabel,
    required this.finishLabel,
    required this.onStart,
    required this.onPause,
    required this.onReset,
    required this.onFinish,
  });

  /// Formats as `H:MM:SS`, dropping the hours when there are none.
  static String format(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }

  @override
  State<SessionTimer> createState() => _SessionTimerState();
}

class _SessionTimerState extends State<SessionTimer> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(SessionTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isRunning != widget.isRunning) _sync();
  }

  void _sync() {
    _ticker?.cancel();
    // Only repaint the label while it is actually counting.
    if (widget.isRunning) {
      _ticker = Timer.periodic(
        const Duration(milliseconds: 250),
        (_) => setState(() {}),
      );
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasElapsed = widget.elapsed > Duration.zero;

    return ThemeContainer(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            widget.sessionLabel,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            SessionTimer.format(widget.elapsed),
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: widget.isRunning
                  ? AppColors.primary
                  : (isDark ? AppColors.textDark : AppColors.textLight),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              if (!widget.isRunning)
                _TimerButton(
                  icon: Icons.play_arrow,
                  label: widget.startLabel,
                  filled: true,
                  onPressed: widget.onStart,
                )
              else
                _TimerButton(
                  icon: Icons.pause,
                  label: widget.pauseLabel,
                  onPressed: widget.onPause,
                ),
              if (hasElapsed)
                _TimerButton(
                  icon: Icons.restart_alt,
                  label: widget.resetLabel,
                  onPressed: widget.onReset,
                ),
              _TimerButton(
                icon: Icons.flag,
                label: widget.finishLabel,
                onPressed: hasElapsed ? widget.onFinish : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool filled;

  const _TimerButton({
    required this.icon,
    required this.label,
    this.onPressed,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final fg = filled
        ? Colors.white
        : (enabled
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.3));

    return Material(
      color: filled && enabled
          ? AppColors.primary
          : AppColors.primary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(9999),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(9999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: fg),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(fontWeight: FontWeight.w600, color: fg),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
