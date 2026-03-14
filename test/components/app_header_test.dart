import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/core/components/app_header.dart';

void main() {
  group('AppHeader', () {
    testWidgets('renders title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppHeader(title: 'My Header')),
        ),
      );

      expect(find.text('My Header'), findsOneWidget);
    });

    testWidgets('renders subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppHeader(title: 'Title', subtitle: 'Subtitle'),
          ),
        ),
      );

      expect(find.text('Subtitle'), findsOneWidget);
    });

    testWidgets('renders leading widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppHeader(
              title: 'Title',
              leading: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.menu), findsOneWidget);
    });

    testWidgets('renders trailing widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppHeader(
              title: 'Title',
              trailing: Container(key: const Key('trailing')),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('trailing')), findsOneWidget);
    });
  });
}
