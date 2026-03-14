import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/core/components/section_label.dart';

void main() {
  group('SectionLabel', () {
    testWidgets('renders text in uppercase', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: SectionLabel(text: 'My Section')),
        ),
      );

      expect(find.text('MY SECTION'), findsOneWidget);
    });

    testWidgets('renders trailing widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SectionLabel(
              text: 'Section',
              trailing: Container(key: const Key('trailing')),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('trailing')), findsOneWidget);
    });
  });
}
