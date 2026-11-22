import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../router/router.dart';
import '../../core/components/components.dart';
import '../../core/i18n/i18n.dart';
import '../../core/theme/app_theme.dart';

class FingerData {
  final int id;
  final Offset position;
  final Color color;

  FingerData({required this.id, required this.position, required this.color});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FingerData && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

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

  void _handlePointerDown(PointerDownEvent details) {
    if (_isSelecting || _winner != null) return;
    if (_activePointers.containsKey(details.pointer)) return;

    HapticFeedback.lightImpact();
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
  }

  void _handlePointerMove(PointerMoveEvent details) {
    if (_isSelecting || _winner != null) return;
    final index = _fingers.indexWhere((f) => f.id == details.pointer);
    if (index == -1) return;

    setState(() {
      _activePointers[details.pointer] = details.localPosition;
      _fingers[index] = FingerData(
        id: details.pointer,
        position: details.localPosition,
        color: _fingers[index].color,
      );
    });
  }

  void _handlePointerEnd(PointerEvent details) {
    if (!_activePointers.containsKey(details.pointer)) return;
    setState(() {
      _activePointers.remove(details.pointer);
    });
  }

  void _reset() {
    _countdownController.stop();
    _countdownController.reset();
    _winnerController.reset();
    setState(() {
      _activePointers.clear();
      _fingers.clear();
      _winner = null;
      _isSelecting = false;
      _countdown = _countdownSeconds;
      _showControls = true;
    });
  }

  Color _getFingerColor(int index) =>
      _fingerColors[index % _fingerColors.length];

  @override
  void dispose() {
    _countdownController.dispose();
    _pulseController.dispose();
    _winnerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            FingerPickerCanvas(
              onPointerDown: _handlePointerDown,
              onPointerMove: _handlePointerMove,
              onPointerUp: _handlePointerEnd,
              onPointerCancel: _handlePointerEnd,
              child: Stack(
                children: [
                  FingerPickerHeader(
                    title: 'Finger Picker',
                    subtitle: _fingers.isEmpty
                        ? l10n.tapToAddFingers
                        : '${_fingers.length} ${_fingers.length == 1 ? l10n.finger : l10n.fingers}',
                    isSelecting: _isSelecting,
                    hasWinner: _winner != null,
                  ),
                  ..._fingers.map(
                    (f) => FingerPointer(
                      position: f.position,
                      color: f.color,
                      isSelected: _winner == f,
                    ),
                  ),
                  if (_isSelecting && _winner == null)
                    CountdownOverlay(
                      count: _countdown,
                      label: l10n.seconds,
                      animation: _countdownController,
                    ),
                  if (_winner != null)
                    Center(
                      child: WinnerDisplay(
                        color: _winner!.color,
                        animation: _winnerController,
                      ),
                    ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black, Colors.black.withValues(alpha: 0)],
                  ),
                ),
                child: Row(
                  children: [
                    if (_winner != null || !_showControls)
                      Expanded(
                        child: AppButton(
                          label: 'Reset',
                          icon: Icons.refresh,
                          onPressed: _reset,
                        ),
                      ),
                    if (_winner != null || !_showControls)
                      const SizedBox(width: 16),
                    Expanded(
                      child: AppButton(
                        label: _winner != null
                            ? 'Play Again'
                            : _showControls
                            ? 'Start'
                            : 'Cancel',
                        icon: Icons.casino,
                        onPressed: () {
                          if (_winner != null || !_showControls) {
                            _reset();
                          } else {
                            _startSelection(l10n);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => context.popOrGo(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
