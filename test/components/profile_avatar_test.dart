import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/core/components/profile_avatar.dart';

void main() {
  group('ProfileAvatar', () {
    testWidgets('renders name initial', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ProfileAvatar(name: 'John')),
        ),
      );

      expect(find.text('J'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProfileAvatar(name: 'John', onTap: () => tapped = true),
          ),
        ),
      );

      await tester.tap(find.byType(ProfileAvatar));
      expect(tapped, isTrue);
    });

    testWidgets('renders with custom size', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ProfileAvatar(name: 'John', size: 80)),
        ),
      );

      expect(find.byType(ProfileAvatar), findsOneWidget);
    });
  });
}
