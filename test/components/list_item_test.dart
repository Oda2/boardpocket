import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/core/components/cards/list_item.dart';

void main() {
  group('ListItem', () {
    testWidgets('renders title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ListItem(title: 'Test Title')),
        ),
      );

      expect(find.text('Test Title'), findsOneWidget);
    });

    testWidgets('renders subtitle when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ListItem(title: 'Test Title', subtitle: 'Test Subtitle'),
          ),
        ),
      );

      expect(find.text('Test Subtitle'), findsOneWidget);
    });

    testWidgets('renders tag when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ListItem(title: 'Test Title', tag: 'NEW'),
          ),
        ),
      );

      expect(find.text('NEW'), findsOneWidget);
    });

    testWidgets('renders trailing text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ListItem(title: 'Test Title', trailingText: '\$29.99'),
          ),
        ),
      );

      expect(find.text('\$29.99'), findsOneWidget);
    });

    testWidgets('renders trailing widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListItem(
              title: 'Test Title',
              trailingWidget: const Icon(Icons.arrow_forward),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_forward), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GestureDetector(
              onTap: () => tapped = true,
              child: const ListItem(title: 'Test Title'),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ListItem));
      expect(tapped, isTrue);
    });

    testWidgets('renders actions', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListItem(
              title: 'Test Title',
              actions: const [
                ListItemAction(icon: Icons.edit),
                ListItemAction(icon: Icons.delete),
              ],
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('calls action onTap', (WidgetTester tester) async {
      bool editTapped = false;
      bool deleteTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListItem(
              title: 'Test Title',
              actions: [
                ListItemAction(
                  icon: Icons.edit,
                  onTap: () => editTapped = true,
                ),
                ListItemAction(
                  icon: Icons.delete,
                  onTap: () => deleteTapped = true,
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.edit));
      expect(editTapped, isTrue);

      await tester.tap(find.byIcon(Icons.delete));
      expect(deleteTapped, isTrue);
    });

    testWidgets('uses custom image size', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ListItem(title: 'Test Title', imageSize: 100)),
        ),
      );

      expect(find.byType(ListItem), findsOneWidget);
    });
  });
}
