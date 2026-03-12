import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../core/components/components.dart';
import '../../core/i18n/i18n.dart';
import '../../core/theme/app_theme.dart';

class FingerPickerScreen extends StatefulWidget {
  const FingerPickerScreen({super.key});

  @override
  State<FingerPickerScreen> createState() => _FingerPickerScreenState();
}

class _FingerPickerScreenState extends State<FingerPickerScreen>
    with TickerProviderStateMixin {
  late AnimationController _countdownController;
  late AnimationController _pulseController;
  late AnimationController _winnerController;
  int _countdown = 5;
  bool _isSelecting = false;
  final Map<int, Offset> _activePointers = {};
  final List<FingerData> _fingers = [];
  FingerData? _winner;
  final Random _random = Random();
  bool _showControls = true;
  static const int _countdownSeconds = 5;

  final List<Color> _fingerColors = [
    Colors.purple,
    Colors.green,
    Colors.blue,
    Colors.orange,
    Colors.pink,
    Colors.teal,
    Colors.red,
    Colors.yellow,
    Colors.indigo,
    Colors.cyan,
  ];

  @override
  void initState() {
    super.initState();
    _countdownController =
        AnimationController(
          vsync: this,
          duration: Duration(seconds: _countdownSeconds),
        )..addListener(() {
          final elapsed = _countdownController.value * _countdownSeconds;
          final newCountdown = _countdownSeconds - elapsed.ceil();
          if (newCountdown != _countdown)
            setState(
              () => _countdown = newCountdown.clamp(0, _countdownSeconds),
            );
          if (_countdownController.isCompleted && _fingers.isNotEmpty)
            _selectWinner();
        });

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _winnerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  void _selectWinner() {
    if (_fingers.isEmpty) return;
    setState(() {
      _isSelecting = false;
      _winner = _fingers[_random.nextInt(_fingers.length)];
    });
    _winnerController.forward();
    HapticFeedback.heavyImpact();
  }

  void _startSelection(AppLocalizations l10n) {
    if (_fingers.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.addAtLeastTwoFingers),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }
    setState(() {
      _isSelecting = true;
      _countdown = _countdownSeconds;
      _showControls = false;
      _winner = null;
    });
    _countdownController.forward(from: 0);
  }

  void _reset() {
    setState(() {
      _fingers.clear();
      _activePointers.clear();
      _winner = null;
      _isSelecting = false;
      _countdown = _countdownSeconds;
      _showControls = true;
    });
    _countdownController.reset();
    _winnerController.reset();
  }

  void _removeFinger(int index) {
    if (_isSelecting || _winner != null) return;
    setState(() => _fingers.removeAt(index));
  }

  Color _getFingerColor(int index) =>
      _fingerColors[index % _fingerColors.length];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.backgroundDark
          : AppColors.backgroundLight,
      body: SafeArea(
        child: Stack(
          children: [
            _buildTouchArea(l10n),
            _buildHeader(l10n),
            if (_showControls) _buildBottomControls(l10n),
            if (_winner != null) _buildWinnerOverlay(l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildTouchArea(AppLocalizations l10n) {
    return Listener(
      onPointerDown: (details) {
        if (_isSelecting || _winner != null) return;
        setState(() {
          _activePointers[details.pointer] = details.localPosition;
          _fingers.add(
            FingerData(
              id: details.pointer,
              position: details.localPosition,
              color: _getFingerColor(_fingers.length),
            ),
          );
        });
      },
      onPointerMove: (details) {
        if (_fingers.isEmpty) return;
        final fingerIndex = _fingers.indexWhere((f) => f.id == details.pointer);
        if (fingerIndex != -1) {
          setState(
            () => _fingers[fingerIndex] = FingerData(
              id: details.pointer,
              position: details.localPosition,
              color: _fingers[fingerIndex].color,
            ),
          );
        }
      },
      onPointerUp: (details) =>
          setState(() => _activePointers.remove(details.pointer)),
      onPointerCancel: (details) =>
          setState(() => _activePointers.remove(details.pointer)),
      behavior: HitTestBehavior.opaque,
      child: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [Colors.grey.shade900, Colors.black],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: MediaQuery.of(context).padding.top + 80,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Text(
                    'FINGER PICKER'.toUpperCase(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                      letterSpacing: 4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _winner != null
                        ? l10n.winnerSelected
                        : _isSelecting
                        ? l10n.selecting
                        : l10n.tapToAddFingers,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            if (_isSelecting && _winner == null)
              Center(
                child: AnimatedBuilder(
                  animation: _countdownController,
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
                            '$_countdown',
                            style: const TextStyle(
                              fontSize: 72,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            l10n.seconds,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ..._fingers.asMap().entries.map((entry) {
              final index = entry.key;
              final finger = entry.value;
              final isWinner = _winner == finger;
              final isActive = _activePointers.containsKey(finger.id);
              return AnimatedPositioned(
                duration: const Duration(milliseconds: 50),
                left: finger.position.dx - (isWinner ? 60 : 45),
                top: finger.position.dy - (isWinner ? 60 : 45),
                child: GestureDetector(
                  onTap: () => _removeFinger(index),
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (_, __) {
                      final scale = isWinner
                          ? 1.0 + (_winnerController.value * 0.3)
                          : isActive && !_isSelecting
                          ? 1.0 + (_pulseController.value * 0.05)
                          : 1.0;
                      return Transform.scale(
                        scale: scale,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: isWinner ? 120 : 90,
                          height: isWinner ? 120 : 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: finger.color.withValues(alpha: 0.2),
                            border: Border.all(
                              color: isWinner ? Colors.amber : finger.color,
                              width: isWinner ? 4 : 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                fontSize: isWinner ? 36 : 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.close, color: Colors.white),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.touch_app, color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '${_fingers.length} ${_fingers.length != 1 ? l10n.fingers : l10n.finger}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls(AppLocalizations l10n) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Colors.black, Colors.black.withValues(alpha: 0)],
          ),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                child: AppButton(
                  label: 'Start',
                  icon: Icons.play_arrow,
                  onPressed: () => _startSelection(l10n),
                ),
              ),
              const SizedBox(width: 16),
              AppButton(
                label: 'Reset',
                icon: Icons.refresh,
                isSecondary: true,
                onPressed: _reset,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWinnerOverlay(AppLocalizations l10n) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'WINNER!',
              style: TextStyle(color: Colors.white70, fontSize: 24),
            ),
            const SizedBox(height: 16),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _winner!.color.withValues(alpha: 0.3),
                border: Border.all(color: Colors.amber, width: 4),
              ),
              child: Center(
                child: Text(
                  '${_fingers.indexOf(_winner!) + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            AppButton(
              label: 'Play Again',
              icon: Icons.refresh,
              onPressed: _reset,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() => _winner = null);
              },
              child: const Text(
                'Close',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _countdownController.dispose();
    _pulseController.dispose();
    _winnerController.dispose();
    super.dispose();
  }
}

class FingerData {
  final int id;
  Offset position;
  final Color color;
  FingerData({required this.id, required this.position, required this.color});
}
