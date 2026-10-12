import 'dart:math';

/// Die types offered by the roller, in display order.
const List<int> kDieTypes = <int>[4, 6, 8, 10, 12, 20, 100];

/// Upper bound for how many dice of a single type can be added.
const int kMaxDicePerType = 10;

/// A single die result.
class DieRoll {
  final int sides;
  final int value;

  const DieRoll({required this.sides, required this.value});

  DieRoll copyWith({int? value}) =>
      DieRoll(sides: sides, value: value ?? this.value);

  Map<String, dynamic> toMap() => {'sides': sides, 'value': value};

  factory DieRoll.fromMap(Map<String, dynamic> map) =>
      DieRoll(sides: map['sides'] as int, value: map['value'] as int);

  @override
  bool operator ==(Object other) =>
      other is DieRoll && other.sides == sides && other.value == value;

  @override
  int get hashCode => Object.hash(sides, value);

  @override
  String toString() => 'd$sides=$value';
}

/// An immutable selection of dice, keyed by number of sides.
///
/// The user builds a pool (for example 3x d6 + 1x d20) and then rolls it.
class DicePool {
  final Map<int, int> _counts;

  DicePool({Map<int, int>? counts})
    : _counts = Map.unmodifiable(_normalize(counts));

  const DicePool.empty() : _counts = const {};

  static Map<int, int> _normalize(Map<int, int>? counts) {
    if (counts == null) return const {};
    final result = <int, int>{};
    for (final entry in counts.entries) {
      final sides = entry.key;
      final count = entry.value;
      if (!kDieTypes.contains(sides)) continue;
      if (count <= 0) continue;
      result[sides] = count.clamp(1, kMaxDicePerType);
    }
    return result;
  }

  /// How many dice of [sides] are in the pool.
  int countOf(int sides) => _counts[sides] ?? 0;

  /// Total number of dice in the pool.
  int get diceCount => _counts.values.fold<int>(0, (sum, count) => sum + count);

  bool get isEmpty => diceCount == 0;

  bool get isNotEmpty => !isEmpty;

  /// Side counts present in the pool, in display order.
  List<int> get selectedTypes =>
      kDieTypes.where((sides) => countOf(sides) > 0).toList();

  DicePool withCount(int sides, int count) {
    final next = Map<int, int>.from(_counts);
    if (count <= 0) {
      next.remove(sides);
    } else {
      next[sides] = count.clamp(1, kMaxDicePerType);
    }
    return DicePool(counts: next);
  }

  DicePool addOne(int sides) {
    if (!kDieTypes.contains(sides)) return this;
    return withCount(sides, countOf(sides) + 1);
  }

  DicePool removeOne(int sides) => withCount(sides, countOf(sides) - 1);

  DicePool cleared() => const DicePool.empty();

  /// Rolls every die in the pool. Dice come out ordered by [kDieTypes].
  List<DieRoll> roll([Random? random]) {
    final rng = random ?? Random();
    final rolls = <DieRoll>[];
    for (final sides in selectedTypes) {
      for (var i = 0; i < countOf(sides); i++) {
        rolls.add(DieRoll(sides: sides, value: rng.nextInt(sides) + 1));
      }
    }
    return rolls;
  }

  /// Sum of [rolls].
  static int totalOf(List<DieRoll> rolls) =>
      rolls.fold<int>(0, (sum, roll) => sum + roll.value);

  Map<String, dynamic> toMap() => {'counts': Map.from(_counts)};

  factory DicePool.fromMap(Map<String, dynamic> map) =>
      DicePool(counts: (map['counts'] as Map?)?.cast<int, int>());
}
