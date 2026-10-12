import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:boardpocket/core/components/app_button.dart';
import 'package:boardpocket/core/i18n/app_localizations.dart';
import 'package:boardpocket/data/models/dice.dart';
import 'package:boardpocket/presentation/providers/dice_provider.dart';
import 'package:boardpocket/presentation/screens/dice_roller_screen.dart';

Widget createTestWidget({required DiceProvider dice}) {
  return MultiProvider(
    providers: [ChangeNotifierProvider<DiceProvider>.value(value: dice)],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: const DiceRollerScreen(),
    ),
  );
}

void main() {
  group('DiceRollerScreen', () {
    late DiceProvider dice;

    setUp(() {
      dice = DiceProvider(random: Random(1));
    });

    Future<void> pump(WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(dice: dice));
      await tester.pumpAndSettle();
    }

    testWidgets('renders every die type offered', (tester) async {
      await pump(tester);

      for (final sides in kDieTypes) {
        expect(find.text('d$sides'), findsOneWidget);
      }
    });

    testWidgets('starts with an empty pool message', (tester) async {
      await pump(tester);
      expect(
        find.text('No dice selected yet. Pick one above to start.'),
        findsOneWidget,
      );
    });

    testWidgets('tapping a die adds it to the pool', (tester) async {
      await pump(tester);

      await tester.tap(find.text('d20'));
      await tester.pumpAndSettle();

      expect(dice.pool.countOf(20), 1);
      expect(find.text('1x d20'), findsOneWidget);
    });

    testWidgets('tapping a selected die again adds another one', (
      tester,
    ) async {
      await pump(tester);

      await tester.tap(find.text('d6'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('d6 x1'));
      await tester.pumpAndSettle();

      expect(dice.pool.countOf(6), 2);
      expect(find.text('2x d6'), findsOneWidget);
    });

    testWidgets('the delete button removes a die', (tester) async {
      await pump(tester);

      await tester.tap(find.text('d8'));
      await tester.pumpAndSettle();
      expect(dice.pool.countOf(8), 1);

      await tester.tap(find.byIcon(Icons.remove_circle_outline));
      await tester.pumpAndSettle();

      expect(dice.pool.countOf(8), 0);
    });

    testWidgets('mixed pools render each type', (tester) async {
      await pump(tester);

      await tester.tap(find.text('d6'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('d6 x1'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('d20'));
      await tester.pumpAndSettle();

      expect(find.text('2x d6'), findsOneWidget);
      expect(find.text('1x d20'), findsOneWidget);
    });

    testWidgets('roll button is disabled while the pool is empty', (
      tester,
    ) async {
      await pump(tester);

      final button = tester.widget<AppButton>(find.byType(AppButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('roll button is enabled once a die is selected', (
      tester,
    ) async {
      await pump(tester);

      await tester.tap(find.text('d10'));
      await tester.pumpAndSettle();

      final button = tester.widget<AppButton>(find.byType(AppButton));
      expect(button.onPressed, isNotNull);
    });

    testWidgets('rolling shows a total and increments the roll counter', (
      tester,
    ) async {
      dice.addDie(20);
      await pump(tester);

      await tester.tap(find.text('ROLL THE DICE'));
      await tester.pumpAndSettle();

      expect(find.text('Result'), findsOneWidget);
      expect(find.text('Roll #1'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
    });

    testWidgets('rolling twice increments the counter again', (tester) async {
      dice.addDie(6);
      await pump(tester);

      await tester.tap(find.text('ROLL THE DICE'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('ROLL THE DICE'));
      await tester.pumpAndSettle();

      expect(find.text('Roll #2'), findsOneWidget);
    });

    testWidgets('changing the pool clears the previous result', (tester) async {
      dice.addDie(20);
      await pump(tester);

      await tester.tap(find.text('ROLL THE DICE'));
      await tester.pumpAndSettle();
      expect(find.text('Result'), findsOneWidget);

      await tester.tap(find.text('d20 x1'));
      await tester.pumpAndSettle();

      expect(find.text('Result'), findsNothing);
    });

    testWidgets('clear all empties the pool', (tester) async {
      dice
        ..addDie(6)
        ..addDie(20);
      await pump(tester);

      await tester.tap(find.text('Clear all'));
      await tester.pumpAndSettle();

      expect(dice.pool.isEmpty, isTrue);
      expect(
        find.text('No dice selected yet. Pick one above to start.'),
        findsOneWidget,
      );
    });

    testWidgets('shows a die result chip per rolled die', (tester) async {
      dice
        ..addDie(6)
        ..addDie(6)
        ..addDie(20);
      await pump(tester);

      await tester.tap(find.text('ROLL THE DICE'));
      await tester.pumpAndSettle();

      // The selector chips read "d6 x2"/"d20 x1", so these only match the
      // per-die result chips.
      expect(find.text('d6'), findsNWidgets(2));
      expect(find.text('d20'), findsNWidgets(1));
    });

    testWidgets('renders without overflow on a small phone', (tester) async {
      // 360x800 logical, a common small phone size.
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      dice
        ..addDie(6)
        ..addDie(20);
      await pump(tester);
      await tester.tap(find.text('ROLL THE DICE'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
