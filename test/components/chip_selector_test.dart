import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/core/components/chip_selector.dart';

void main() {
  group('ChipSelector', () {
    testWidgets('renders all items', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChipSelector(
              items: const ['All', 'Strategy', 'Party'],
              selected: 'All',
              onSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Strategy'), findsOneWidget);
      expect(find.text('Party'), findsOneWidget);
    });

    testWidgets('calls onSelected when item is tapped', (
      WidgetTester tester,
    ) async {
      String? selected;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChipSelector(
              items: const ['A', 'B', 'C'],
              selected: 'A',
              onSelected: (item) => selected = item,
            ),
          ),
        ),
      );

      await tester.tap(find.text('B'));
      expect(selected, 'B');
    });

    testWidgets('highlights selected item', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChipSelector(
              items: const ['Selected', 'Unselected'],
              selected: 'Selected',
              onSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Selected'), findsOneWidget);
    });
  });
}
