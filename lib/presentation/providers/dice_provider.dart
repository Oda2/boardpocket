import 'dart:math';

import 'package:flutter/material.dart';
import '../../data/models/models.dart';

/// Holds the dice selection and the roll history for the dice roller.
///
/// Kept out of the widget so the selection survives navigation inside the
/// Randomizer tab and so the rolling logic stays unit-testable.
class DiceProvider extends ChangeNotifier {
  final Random _random;

  DicePool _pool = const DicePool.empty();
  List<DieRoll> _lastRoll = const [];
  int _lastTotal = 0;
  bool _isRolling = false;
  int _rollNumber = 0;

  DiceProvider({Random? random}) : _random = random ?? Random();

  DicePool get pool => _pool;
  List<DieRoll> get lastRoll => _lastRoll;
  int get lastTotal => _lastTotal;
  bool get isRolling => _isRolling;
  int get rollNumber => _rollNumber;
  bool get canRoll => _pool.isNotEmpty && !_isRolling;

  void addDie(int sides) {
    if (_pool.countOf(sides) >= kMaxDicePerType) return;
    _pool = _pool.addOne(sides);
    _clearResult();
    notifyListeners();
  }

  void removeDie(int sides) {
    _pool = _pool.removeOne(sides);
    _clearResult();
    notifyListeners();
  }

  void setCount(int sides, int count) {
    _pool = _pool.withCount(sides, count);
    _clearResult();
    notifyListeners();
  }

  void clearPool() {
    _pool = const DicePool.empty();
    _clearResult();
    notifyListeners();
  }

  /// Rolls the current pool and returns the individual dice.
  Future<List<DieRoll>> roll() async {
    if (_pool.isEmpty) return const [];

    _isRolling = true;
    notifyListeners();

    // Brief delay so the animation reads as a roll rather than a flicker.
    await Future<void>.delayed(const Duration(milliseconds: 350));

    final rolls = _pool.roll(_random);
    _lastRoll = rolls;
    _lastTotal = DicePool.totalOf(rolls);
    _rollNumber++;
    _isRolling = false;
    notifyListeners();

    return rolls;
  }

  void _clearResult() {
    if (_lastRoll.isEmpty && _lastTotal == 0) return;
    _lastRoll = const [];
    _lastTotal = 0;
  }
}
