import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
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
  DateTime? _lastFingerAddedTime;
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
          if (newCountdown != _countdown) {
            setState(() {
              _countdown = newCountdown.clamp(0, _countdownSeconds);
            });
          }
          if (_countdownController.isCompleted && _fingers.isNotEmpty) {
            _selectWinner();
          }
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
      _showMessage(l10n.addAtLeastTwoFingers);
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
    if (_fingers.length <= 2) {
      _resetCountdown();
    }
    setState(() {
      _fingers.removeAt(index);
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Color _getFingerColor(int index) {
    return _fingerColors[index % _fingerColors.length];
  }

  void _startAutoCountdown() {
    if (_fingers.length < 2 || _winner != null) return;

    setState(() {
      _isSelecting = true;
      _showControls = false;
    });
    _countdownController.forward(from: 0);
  }

  void _resetCountdown() {
    _countdownController.stop();
    setState(() {
      _countdown = _countdownSeconds;
      _isSelecting = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      body: Listener(
        onPointerDown: (details) {
          if (_winner != null) return;

          setState(() {
            _activePointers[details.pointer] = details.localPosition;
            _fingers.add(
              FingerData(
                id: details.pointer,
                position: details.localPosition,
                color: _getFingerColor(_fingers.length),
              ),
            );
            _lastFingerAddedTime = DateTime.now();
          });

          if (_fingers.length >= 2) {
            if (_isSelecting) {
              _countdownController.stop();
              _countdownController.forward(from: 0);
              setState(() {
                _countdown = _countdownSeconds;
              });
            } else {
              _startAutoCountdown();
            }
          }
          HapticFeedback.lightImpact();
        },
        onPointerMove: (details) {
          if (_isSelecting || _winner != null) return;
          if (!_activePointers.containsKey(details.pointer)) return;

          setState(() {
            _activePointers[details.pointer] = details.localPosition;
            final fingerIndex = _fingers.indexWhere(
              (f) => f.id == details.pointer,
            );
            if (fingerIndex != -1) {
              _fingers[fingerIndex] = FingerData(
                id: details.pointer,
                position: details.localPosition,
                color: _fingers[fingerIndex].color,
              );
            }
          });
        },
        onPointerUp: (details) {
          setState(() {
            _activePointers.remove(details.pointer);
          });
        },
        onPointerCancel: (details) {
          setState(() {
            _activePointers.remove(details.pointer);
          });
        },
        behavior: HitTestBehavior.opaque,
        child: Stack(
          children: [
            // Fundo com gradiente sutil
            Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [Colors.grey.shade900, Colors.black],
                ),
              ),
            ),

            // Header
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.touch_app,
                            color: AppColors.primary,
                            size: 18,
                          ),
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
            ),

            // Título central
            Positioned(
              top: MediaQuery.of(context).padding.top + 80,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Text(
                    l10n.fingerPicker.toUpperCase(),
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
                      color: Colors.white.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Círculo de contagem regressiva
            if (_isSelecting && _winner == null)
              Center(
                child: AnimatedBuilder(
                  animation: _countdownController,
                  builder: (context, child) {
                    return Container(
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
                          mainAxisAlignment: MainAxisAlignment.center,
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
                    );
                  },
                ),
              ),

            // Dedos na tela
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
                    builder: (context, child) {
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
                              color: isWinner
                                  ? finger.color
                                  : finger.color.withValues(alpha: 0.5),
                              width: isWinner ? 4 : 2,
                            ),
                            boxShadow: isWinner
                                ? [
                                    BoxShadow(
                                      color: finger.color.withValues(
                                        alpha: 0.8,
                                      ),
                                      blurRadius: 40,
                                      spreadRadius: 15,
                                    ),
                                  ]
                                : [
                                    BoxShadow(
                                      color: finger.color.withValues(
                                        alpha: 0.3,
                                      ),
                                      blurRadius: 20,
                                      spreadRadius: 5,
                                    ),
                                  ],
                          ),
                          child: Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: isWinner ? 70 : 50,
                              height: isWinner ? 70 : 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: finger.color,
                                boxShadow: [
                                  BoxShadow(
                                    color: finger.color.withValues(alpha: 0.6),
                                    blurRadius: 20,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: isWinner ? 28 : 20,
                                  ),
                                ),
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

            // Controles inferiores
            if (_showControls && _winner == null)
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 100,
                left: 24,
                right: 24,
                child: Column(
                  children: [
                    // Botão de iniciar
                    if (_fingers.length >= 2)
                      ElevatedButton(
                        onPressed: () => _startSelection(l10n),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 48,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 8,
                          shadowColor: AppColors.primary.withValues(alpha: 0.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.play_arrow, size: 28),
                            const SizedBox(width: 8),
                            Text(
                              l10n.startSelection,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.touch_app,
                              color: Colors.white.withValues(alpha: 0.6),
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Flexible(
                              child: Text(
                                _fingers.isEmpty
                                    ? l10n.tapToAddFingers
                                    : l10n.addMoreFingersOrStart,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 12),
                    // Botão de limpar
                    if (_fingers.isNotEmpty)
                      TextButton.icon(
                        onPressed: _reset,
                        icon: Icon(
                          Icons.delete_outline,
                          color: Colors.white.withValues(alpha: 0.6),
                        ),
                        label: Text(
                          l10n.clearAll,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

            // Botão de jogar novamente (quando há vencedor)
            if (_winner != null)
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 100,
                left: 24,
                right: 24,
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: _winner!.color.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _winner!.color.withValues(alpha: 0.5),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.emoji_events,
                            color: _winner!.color,
                            size: 28,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            l10n.fingerNumberWon.replaceAll(
                              '#',
                              '${_fingers.indexOf(_winner!) + 1}',
                            ),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _reset,
                      icon: const Icon(Icons.replay),
                      label: Text(
                        l10n.playAgain,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Mensagem durante seleção
            if (_isSelecting && _winner == null)
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 40,
                left: 24,
                right: 24,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        l10n.keepFingersPressed,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
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
