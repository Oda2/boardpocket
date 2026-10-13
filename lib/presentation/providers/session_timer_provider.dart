import 'package:flutter/material.dart';

/// Holds the running play session for the dice/game screens.
///
/// Kept out of the widget so the timer survives navigating away and back, and
/// so the elapsed time derives from a [Stopwatch] instead of a tick counter.
class SessionTimerProvider extends ChangeNotifier {
  final Stopwatch _stopwatch = Stopwatch();

  bool _started = false;

  /// True once a session has been started and not reset.
  bool get hasSession => _started;

  bool get isRunning => _stopwatch.isRunning;

  Duration get elapsed => _stopwatch.elapsed;

  void start() {
    _started = true;
    _stopwatch.start();
    notifyListeners();
  }

  void pause() {
    _stopwatch.stop();
    notifyListeners();
  }

  /// Clears the session entirely.
  void reset() {
    _stopwatch
      ..stop()
      ..reset();
    _started = false;
    notifyListeners();
  }

  /// Stops and returns the finished duration, keeping the session visible
  /// until [reset] is called.
  Duration finish() {
    _stopwatch.stop();
    notifyListeners();
    return _stopwatch.elapsed;
  }
}
