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

    testWidgets(
      'does not overflow at the card size used by the collection grid',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.reset);

        // 2-column phone grid: (400 - 16) / 2 wide, * 1.35 tall.
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: SizedBox(
                  width: 192,
                  height: 259,
                  child: GameCard(
                    title: 'Ticket to Ride',
                    imagePath: '/tmp/missing_cover.jpg',
                    players: '2-5',
                    time: '60m',
                  ),
                ),
              ),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('does not overflow with a long title and long metadata', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: 120,
                height: 162,
                child: GameCard(
                  title: 'Twilight Imperium: Fourth Edition Progression Game',
                  players: '1-8 (or more with expansions)',
                  time: '480m',
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
