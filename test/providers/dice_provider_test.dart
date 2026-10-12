import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/presentation/providers/dice_provider.dart';

void main() {
  group('DiceProvider', () {
    late DiceProvider provider;

    setUp(() {
      provider = DiceProvider(random: Random(1));
    });

    test('starts with an empty pool and no result', () {
      expect(provider.pool.isEmpty, isTrue);
      expect(provider.lastRoll, isEmpty);
      expect(provider.lastTotal, 0);
      expect(provider.rollNumber, 0);
    });

    test('cannot roll with an empty pool', () {
      expect(provider.canRoll, isFalse);
    });

    test('addDie adds a single die', () {
      provider.addDie(6);
      expect(provider.pool.countOf(6), 1);
      expect(provider.canRoll, isTrue);
    });

    test('addDie ignores unsupported types', () {
      provider.addDie(7);
      expect(provider.pool.isEmpty, isTrue);
    });

    test('addDie stops at the per-type maximum', () {
      for (var i = 0; i < 50; i++) {
        provider.addDie(20);
      }
      expect(provider.pool.countOf(20), 10);
    });

    test('removeDie removes a single die', () {
      provider
        ..addDie(6)
        ..addDie(6)
        ..removeDie(6);
      expect(provider.pool.countOf(6), 1);
    });

    test('setCount replaces the count', () {
      provider
        ..addDie(6)
        ..setCount(6, 5);
      expect(provider.pool.countOf(6), 5);
    });

    test('clearPool empties the selection', () {
      provider
        ..addDie(6)
        ..addDie(20)
        ..clearPool();
      expect(provider.pool.isEmpty, isTrue);
    });

    group('roll', () {
      test('returns empty and does nothing when the pool is empty', () async {
        final rolls = await provider.roll();
        expect(rolls, isEmpty);
        expect(provider.lastRoll, isEmpty);
        expect(provider.rollNumber, 0);
      });

      test('produces one result per die', () async {
        provider
          ..addDie(6)
          ..addDie(6)
          ..addDie(20);
        final rolls = await provider.roll();
        expect(rolls.length, 3);
        expect(provider.lastRoll.length, 3);
      });

      test('stores the total of the roll', () async {
        provider
          ..addDie(6)
          ..addDie(20);
        final rolls = await provider.roll();
        final expected = rolls.fold<int>(0, (sum, r) => sum + r.value);
        expect(provider.lastTotal, expected);
      });

      test('increments the roll counter', () async {
        provider.addDie(6);
        await provider.roll();
        expect(provider.rollNumber, 1);
        await provider.roll();
        expect(provider.rollNumber, 2);
      });

      test('values respect each die type range', () async {
        provider.addDie(4);
        final rolls = await provider.roll();
        for (final die in rolls) {
          expect(die.sides, 4);
          expect(die.value, inInclusiveRange(1, 4));
        }
      });

      test('changing the pool clears the previous result', () async {
        provider.addDie(6);
        await provider.roll();
        expect(provider.lastRoll, isNotEmpty);

        provider.addDie(20);
        expect(provider.lastRoll, isEmpty);
        expect(provider.lastTotal, 0);
      });

      test('clearPool clears the previous result', () async {
        provider.addDie(6);
        await provider.roll();
        provider.clearPool();
        expect(provider.lastRoll, isEmpty);
        expect(provider.lastTotal, 0);
      });

      test('rollNumber is not reset by changing the pool', () async {
        provider.addDie(6);
        await provider.roll();
        provider.addDie(20);
        expect(provider.rollNumber, 1);
      });
    });

    test('notifies listeners when the pool changes', () {
      var notifications = 0;
      provider.addListener(() => notifications++);

      provider.addDie(6);
      expect(notifications, 1);

      provider.removeDie(6);
      expect(notifications, 2);
    });

    test('notifies listeners when a roll completes', () async {
      provider.addDie(6);
      var notifications = 0;
      provider.addListener(() => notifications++);

      await provider.roll();
      expect(notifications, 2); // start + finish
    });
  });
}
