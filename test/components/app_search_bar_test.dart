import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/core/components/app_search_bar.dart';

void main() {
  group('AppSearchBar', () {
    testWidgets('renders hint text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppSearchBar(hint: 'Search here')),
        ),
      );

      expect(find.text('Search here'), findsOneWidget);
    });

    testWidgets('calls onChanged when text is entered', (
      WidgetTester tester,
    ) async {
      String? query;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppSearchBar(
              hint: 'Search',
              onChanged: (value) => query = value,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'test query');
      expect(query, 'test query');
    });

    testWidgets('renders search icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppSearchBar(hint: 'Search')),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
    });
  });
}
