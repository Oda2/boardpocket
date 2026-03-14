import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/core/components/star_rating.dart';

void main() {
  group('StarRating', () {
    testWidgets('renders stars', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: StarRating(value: 3, onChanged: (_) {})),
        ),
      );

      expect(find.byType(StarRating), findsOneWidget);
    });

    testWidgets('calls onChanged when star is tapped', (
      WidgetTester tester,
    ) async {
      int? newValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StarRating(value: 1, onChanged: (v) => newValue = v),
          ),
        ),
      );

      final stars = find.byType(GestureDetector);
      await tester.tap(stars.last);
      expect(newValue, isNotNull);
    });
  });
}
