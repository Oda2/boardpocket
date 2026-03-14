import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/core/components/theme_container.dart';

void main() {
  group('ThemeContainer', () {
    testWidgets('renders child', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ThemeContainer(child: Text('Content'))),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('applies custom padding', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ThemeContainer(
              padding: EdgeInsets.all(20),
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.byType(ThemeContainer), findsOneWidget);
    });

    testWidgets('applies custom margin', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ThemeContainer(
              margin: EdgeInsets.all(16),
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.byType(ThemeContainer), findsOneWidget);
    });
  });
}
