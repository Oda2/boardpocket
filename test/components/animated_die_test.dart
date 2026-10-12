import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/core/components/animations/animated_die.dart';

Widget wrap(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

void main() {
  group('AnimatedDie', () {
    testWidgets('shows the rolled value and the die type', (tester) async {
      await tester.pumpWidget(wrap(const AnimatedDie(sides: 20, value: 17)));

      expect(find.text('17'), findsOneWidget);
      expect(find.text('d20'), findsOneWidget);
    });

    testWidgets('renders different die types', (tester) async {
      for (final sides in [4, 6, 8, 10, 12, 20, 100]) {
        await tester.pumpWidget(wrap(AnimatedDie(sides: sides, value: 1)));
        expect(find.text('d$sides'), findsOneWidget);
      }
    });

    testWidgets('shows the new value when the roll finishes', (tester) async {
      await tester.pumpWidget(wrap(const AnimatedDie(sides: 6, value: 2)));
      expect(find.text('2'), findsOneWidget);

      await tester.pumpWidget(wrap(const AnimatedDie(sides: 6, value: 5)));
      await tester.pump();

      expect(find.text('5'), findsOneWidget);
      expect(find.text('2'), findsNothing);
    });

    testWidgets('tumbling does not throw duplicate-key errors', (tester) async {
      // Regression: AnimatedSwitcher keyed by the digit kept two children with
      // the same ValueKey when the scramble repeated a value on consecutive
      // frames, which crashed the whole widget tree.
      await tester.pumpWidget(
        wrap(const AnimatedDie(sides: 4, value: 1, isRolling: true)),
      );

      for (var i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('keeps the digit inside the die range while tumbling', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(const AnimatedDie(sides: 6, value: 1, isRolling: true)),
      );

      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        final found = find.byType(Text).evaluate().map((e) {
          return (e.widget as Text).data;
        });
        for (final text in found) {
          if (text == null) continue;
          final value = int.tryParse(text);
          if (value != null) {
            expect(value, inInclusiveRange(1, 6));
          }
        }
      }
    });

    testWidgets('settles back to the real value when the roll stops', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(const AnimatedDie(sides: 20, value: 13, isRolling: true)),
      );
      await tester.pump(const Duration(milliseconds: 50));

      await tester.pumpWidget(
        wrap(const AnimatedDie(sides: 20, value: 13, isRolling: false)),
      );
      await tester.pumpAndSettle();

      expect(find.text('13'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('does not overflow at the size used by the roller', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const AnimatedDie(sides: 100, value: 99)));

      expect(tester.takeException(), isNull);
    });

    testWidgets('survives a long tumble without leaking animations', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(const AnimatedDie(sides: 20, value: 1, isRolling: true)),
      );
      await tester.pump(const Duration(seconds: 1));

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
