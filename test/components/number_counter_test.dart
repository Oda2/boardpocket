import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/core/components/number_counter.dart';

void main() {
  group('NumberCounter', () {
    testWidgets('renders current value', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumberCounter(value: 5, min: 0, max: 10, onChanged: (_) {}),
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('renders increment button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumberCounter(value: 5, min: 0, max: 10, onChanged: (_) {}),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('renders decrement button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumberCounter(value: 5, min: 0, max: 10, onChanged: (_) {}),
          ),
        ),
      );

      expect(find.byIcon(Icons.remove), findsOneWidget);
    });

    testWidgets('calls onChanged when increment is tapped', (
      WidgetTester tester,
    ) async {
      int? newValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumberCounter(
              value: 5,
              min: 0,
              max: 10,
              onChanged: (v) => newValue = v,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.add));
      expect(newValue, 6);
    });

    testWidgets('calls onChanged when decrement is tapped', (
      WidgetTester tester,
    ) async {
      int? newValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumberCounter(
              value: 5,
              min: 0,
              max: 10,
              onChanged: (v) => newValue = v,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.remove));
      expect(newValue, 4);
    });
  });
}
