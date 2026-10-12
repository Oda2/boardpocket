import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/data/models/dice.dart';

void main() {
  group('DieRoll', () {
    test('exposes sides and value', () {
      const die = DieRoll(sides: 20, value: 17);
      expect(die.sides, 20);
      expect(die.value, 17);
    });

    test('copyWith overrides value only', () {
      const die = DieRoll(sides: 6, value: 3);
      final updated = die.copyWith(value: 5);
      expect(updated.sides, 6);
      expect(updated.value, 5);
    });

    test('serializes to and from map', () {
      const die = DieRoll(sides: 12, value: 9);
      expect(DieRoll.fromMap(die.toMap()), die);
    });

    test('equality is by sides and value', () {
      expect(
        const DieRoll(sides: 6, value: 2),
        const DieRoll(sides: 6, value: 2),
      );
      expect(
        const DieRoll(sides: 6, value: 2),
        isNot(const DieRoll(sides: 6, value: 3)),
      );
    });
  });

  group('DicePool', () {
    test('starts empty', () {
      const pool = DicePool.empty();
      expect(pool.isEmpty, isTrue);
      expect(pool.isNotEmpty, isFalse);
      expect(pool.diceCount, 0);
    });

    test('addOne increments the count for a die type', () {
      final pool = const DicePool.empty().addOne(6).addOne(6).addOne(20);

      expect(pool.countOf(6), 2);
      expect(pool.countOf(20), 1);
      expect(pool.diceCount, 3);
      expect(pool.isNotEmpty, isTrue);
    });

    test('removeOne decrements and drops the type at zero', () {
      final pool = const DicePool.empty().addOne(6).removeOne(6);
      expect(pool.countOf(6), 0);
      expect(pool.isEmpty, isTrue);
    });

    test('removeOne on a missing type is a no-op', () {
      final pool = const DicePool.empty().removeOne(12);
      expect(pool.diceCount, 0);
    });

    test('addOne ignores unsupported die types', () {
      final pool = const DicePool.empty().addOne(7).addOne(0).addOne(-3);
      expect(pool.isEmpty, isTrue);
    });

    test('withCount replaces the whole count', () {
      final pool = const DicePool.empty().addOne(6).withCount(6, 4);
      expect(pool.countOf(6), 4);
    });

    test('withCount at zero removes the type', () {
      final pool = const DicePool.empty().addOne(6).withCount(6, 0);
      expect(pool.countOf(6), 0);
    });

    test('counts are capped at kMaxDicePerType', () {
      final pool = const DicePool.empty().withCount(6, 999);
      expect(pool.countOf(6), kMaxDicePerType);
    });

    test('negative counts in the constructor are dropped', () {
      final pool = DicePool(counts: const {6: -3, 20: 2});
      expect(pool.countOf(6), 0);
      expect(pool.countOf(20), 2);
    });

    test('unsupported types in the constructor are dropped', () {
      final pool = DicePool(counts: const {7: 3, 6: 1});
      expect(pool.selectedTypes, [6]);
    });

    test('selectedTypes follows kDieTypes order', () {
      final pool = const DicePool.empty().addOne(100).addOne(4).addOne(20);
      expect(pool.selectedTypes, [4, 20, 100]);
    });

    test('cleared empties the pool', () {
      final pool = const DicePool.empty().addOne(6).cleared();
      expect(pool.isEmpty, isTrue);
    });

    test('is immutable', () {
      final original = const DicePool.empty().addOne(6);
      final modified = original.addOne(20);
      expect(original.countOf(20), 0);
      expect(modified.countOf(20), 1);
    });

    group('roll', () {
      test('returns no dice for an empty pool', () {
        expect(const DicePool.empty().roll(), isEmpty);
      });

      test('returns one die per selected die', () {
        final pool = const DicePool.empty().addOne(6).addOne(6).addOne(20);
        expect(pool.roll(Random(1)).length, 3);
      });

      test('every value stays within 1..sides', () {
        final pool = DicePool(
          counts: const {4: 5, 6: 5, 8: 5, 10: 5, 12: 5, 20: 5, 100: 5},
        );

        for (final die in pool.roll(Random(7))) {
          expect(die.value, greaterThanOrEqualTo(1));
          expect(die.value, lessThanOrEqualTo(die.sides));
        }
      });

      test('results are grouped by die type in kDieTypes order', () {
        final pool = const DicePool.empty().addOne(20).addOne(6);
        final rolls = pool.roll(Random(3));
        expect(rolls.map((r) => r.sides), [6, 20]);
      });

      test('is reproducible with a seeded Random', () {
        final pool = const DicePool.empty().addOne(20).addOne(20);
        final first = pool.roll(Random(42));
        final second = pool.roll(Random(42));
        expect(first, second);
      });

      test('totalOf sums the dice', () {
        const rolls = [
          DieRoll(sides: 6, value: 4),
          DieRoll(sides: 6, value: 5),
          DieRoll(sides: 20, value: 11),
        ];
        expect(DicePool.totalOf(rolls), 20);
      });

      test('totalOf is zero for no dice', () {
        expect(DicePool.totalOf(const []), 0);
      });
    });

    test('serializes to and from map', () {
      final pool = const DicePool.empty().addOne(6).addOne(6).addOne(20);
      final restored = DicePool.fromMap(pool.toMap());
      expect(restored.countOf(6), 2);
      expect(restored.countOf(20), 1);
    });
  });
}
