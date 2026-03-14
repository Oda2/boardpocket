import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/core/components/cards/game_card.dart';

void main() {
  group('GameCard', () {
    testWidgets('renders title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameCard(title: 'Catan', players: '3-4', time: '60m'),
          ),
        ),
      );

      expect(find.text('Catan'), findsOneWidget);
    });

    testWidgets('renders players and time', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameCard(title: 'Catan', players: '3-4', time: '60m'),
          ),
        ),
      );

      expect(find.text('3-4'), findsOneWidget);
      expect(find.text('60m'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GestureDetector(
              onTap: () => tapped = true,
              child: GameCard(title: 'Catan', players: '3-4', time: '60m'),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GameCard));
      expect(tapped, isTrue);
    });

    testWidgets('renders with custom dimensions', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GameCard(
              title: 'Catan',
              players: '3-4',
              time: '60m',
              width: 200,
              height: 300,
            ),
          ),
        ),
      );

      expect(find.byType(GameCard), findsOneWidget);
    });
  });
}
