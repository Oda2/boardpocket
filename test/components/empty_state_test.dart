import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/core/components/empty_state.dart';

void main() {
  group('EmptyState', () {
    testWidgets('renders icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(icon: Icons.inbox, title: 'Empty'),
          ),
        ),
      );

      expect(find.byIcon(Icons.inbox), findsOneWidget);
    });

    testWidgets('renders title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(icon: Icons.inbox, title: 'No items'),
          ),
        ),
      );

      expect(find.text('No items'), findsOneWidget);
    });

    testWidgets('renders subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'Empty',
              subtitle: 'Add some items',
            ),
          ),
        ),
      );

      expect(find.text('Add some items'), findsOneWidget);
    });

    testWidgets('renders action button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyState(
              icon: Icons.inbox,
              title: 'Empty',
              action: ElevatedButton(
                key: const Key('action'),
                onPressed: () {},
                child: const Text('Add'),
              ),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('action')), findsOneWidget);
    });
  });
}
