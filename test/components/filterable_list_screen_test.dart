import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/core/components/screens/filterable_list_screen.dart';

void main() {
  group('FilterableListScreen', () {
    testWidgets('renders title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FilterableListScreen(
            title: 'My List',
            activeRoute: '/',
            addRoute: '/add',
            emptyIcon: Icons.list,
            emptyTitle: 'Empty',
            emptySubtitle: 'No items',
            filters: const ['All', 'Category1'],
            searchHint: 'Search...',
            body: const [Text('Item 1')],
          ),
        ),
      );

      expect(find.text('My List'), findsOneWidget);
    });

    testWidgets('renders empty state when isEmpty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FilterableListScreen(
            title: 'Test',
            activeRoute: '/',
            addRoute: '/add',
            emptyIcon: Icons.list,
            emptyTitle: 'No items',
            emptySubtitle: 'Add some items',
            filters: const [],
            searchHint: 'Search',
            body: const [],
            isEmpty: true,
          ),
        ),
      );

      expect(find.text('No items'), findsOneWidget);
      expect(find.text('Add some items'), findsOneWidget);
    });

    testWidgets('renders search bar when showSearch is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FilterableListScreen(
            title: 'Test',
            activeRoute: '/',
            addRoute: '/add',
            emptyIcon: Icons.list,
            emptyTitle: 'Empty',
            emptySubtitle: 'No items',
            filters: const [],
            searchHint: 'Search here',
            showSearch: true,
            body: const [],
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('hides search bar when showSearch is false', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FilterableListScreen(
            title: 'Test',
            activeRoute: '/',
            addRoute: '/add',
            emptyIcon: Icons.list,
            emptyTitle: 'Empty',
            emptySubtitle: 'No items',
            filters: const [],
            searchHint: 'Search',
            showSearch: false,
            body: const [],
          ),
        ),
      );

      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('renders filters', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FilterableListScreen(
            title: 'Test',
            activeRoute: '/',
            addRoute: '/add',
            emptyIcon: Icons.list,
            emptyTitle: 'Empty',
            emptySubtitle: 'No items',
            filters: const ['All', 'Category 1', 'Category 2'],
            searchHint: 'Search',
            body: const [],
          ),
        ),
      );

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Category 1'), findsOneWidget);
      expect(find.text('Category 2'), findsOneWidget);
    });

    testWidgets('renders body content', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FilterableListScreen(
            title: 'Test',
            activeRoute: '/',
            addRoute: '/add',
            emptyIcon: Icons.list,
            emptyTitle: 'Empty',
            emptySubtitle: 'No items',
            filters: const [],
            searchHint: 'Search',
            body: const [Text('Item 1'), Text('Item 2'), Text('Item 3')],
          ),
        ),
      );

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
    });

    testWidgets('shows loading indicator when isLoading', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FilterableListScreen(
            title: 'Test',
            activeRoute: '/',
            addRoute: '/add',
            emptyIcon: Icons.list,
            emptyTitle: 'Empty',
            emptySubtitle: 'No items',
            filters: const [],
            searchHint: 'Search',
            isLoading: true,
            body: const [],
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders FAB', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FilterableListScreen(
            title: 'Test',
            activeRoute: '/',
            addRoute: '/add',
            emptyIcon: Icons.list,
            emptyTitle: 'Empty',
            emptySubtitle: 'No items',
            filters: const [],
            searchHint: 'Search',
            body: const [],
          ),
        ),
      );

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });
}
