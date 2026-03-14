import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/core/components/animations/animated_components.dart';

void main() {
  group('AnimatedResultCard', () {
    testWidgets('renders title when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AnimatedResultCard(title: 'Test Game')),
        ),
      );

      expect(find.text('Test Game'), findsOneWidget);
    });

    testWidgets('renders subtitle when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedResultCard(
              title: 'Test Game',
              subtitle: '2-4 players',
            ),
          ),
        ),
      );

      expect(find.text('2-4 players'), findsOneWidget);
    });

    testWidgets('shows placeholder when no image', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AnimatedResultCard(title: 'Test Game')),
        ),
      );

      expect(find.byIcon(Icons.casino), findsOneWidget);
    });

    testWidgets('shows default title when null', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AnimatedResultCard())),
      );

      expect(find.text('???'), findsOneWidget);
    });

    testWidgets('responds to tap', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedResultCard(title: 'Test', onTap: () => tapped = true),
          ),
        ),
      );

      await tester.tap(find.text('Test'));
      expect(tapped, isTrue);
    });
  });

  group('PulsingCircle', () {
    testWidgets('renders with default size', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PulsingCircle())),
      );

      expect(find.byType(PulsingCircle), findsOneWidget);
    });

    testWidgets('renders custom size', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: PulsingCircle(size: 100))),
      );

      final container = tester.widget<Container>(find.byType(Container).first);
      expect(container.constraints?.maxWidth, 100);
    });

    testWidgets('renders child widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: PulsingCircle(child: Icon(Icons.star))),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
    });
  });

  group('ShuffleIndicator', () {
    testWidgets('renders correct number of dots', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ShuffleIndicator(dots: 5))),
      );

      expect(find.byType(AnimatedContainer), findsNWidgets(5));
    });

    testWidgets('renders default 3 dots', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: ShuffleIndicator())),
      );

      expect(find.byType(AnimatedContainer), findsNWidgets(3));
    });

    testWidgets('renders when inactive', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ShuffleIndicator(isActive: false)),
        ),
      );

      expect(find.byType(AnimatedContainer), findsNWidgets(3));
    });
  });
}
