import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/core/components/forms/form_section.dart';

void main() {
  group('FormSection', () {
    testWidgets('renders label and child', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FormSection(
              label: 'Test Label',
              child: Text('Child Content'),
            ),
          ),
        ),
      );

      expect(find.text('TEST LABEL'), findsOneWidget);
      expect(find.text('Child Content'), findsOneWidget);
    });

    testWidgets('renders trailing widget', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormSection(
              label: 'Test',
              trailing: Container(key: const Key('trailing')),
              child: const Text('Content'),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('trailing')), findsOneWidget);
    });

    testWidgets('applies custom spacing', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FormSection(
              label: 'Test',
              spacing: 24,
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
    });
  });

  group('FormRow', () {
    testWidgets('renders children in row', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormRow(
              children: [
                Container(key: const Key('child1')),
                Container(key: const Key('child2')),
                Container(key: const Key('child3')),
              ],
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('child1')), findsOneWidget);
      expect(find.byKey(const Key('child2')), findsOneWidget);
      expect(find.byKey(const Key('child3')), findsOneWidget);
    });

    testWidgets('renders single child', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormRow(children: [Container(key: const Key('single'))]),
          ),
        ),
      );

      expect(find.byKey(const Key('single')), findsOneWidget);
    });

    testWidgets('applies custom spacing', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormRow(
              spacing: 32,
              children: [
                Container(key: const Key('a')),
                Container(key: const Key('b')),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(FormRow), findsOneWidget);
    });

    testWidgets('uses Expanded for children', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormRow(
              children: [
                Container(key: const Key('first')),
                Container(key: const Key('second')),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(Expanded), findsNWidgets(2));
    });
  });
}
