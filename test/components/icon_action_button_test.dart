import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/core/components/icon_action_button.dart';

void main() {
  group('IconActionButton', () {
    testWidgets('renders icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconActionButton(
              icon: Icons.settings,
              isDark: false,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconActionButton(
              icon: Icons.add,
              isDark: false,
              onTap: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.add));
      expect(pressed, isTrue);
    });

    testWidgets('renders with custom size', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconActionButton(
              icon: Icons.edit,
              isDark: false,
              size: 48,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.edit), findsOneWidget);
    });
  });
}
