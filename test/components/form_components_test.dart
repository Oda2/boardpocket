import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/core/components/forms/form_section.dart';
import 'package:boardpocket/core/components/forms/form_screen_base.dart';

void main() {
  group('FormSection', () {
    testWidgets('renders label', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FormSection(label: 'Test Label', child: Text('Content')),
          ),
        ),
      );

      expect(find.text('TEST LABEL'), findsOneWidget);
    });

    testWidgets('renders child', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FormSection(label: 'Test', child: Text('Child Content')),
          ),
        ),
      );

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

      expect(find.byType(FormSection), findsOneWidget);
    });
  });

  group('FormScreenHeader', () {
    testWidgets('renders title', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: FormScreenHeader(title: 'Form Title')),
        ),
      );

      expect(find.text('Form Title'), findsOneWidget);
    });

    testWidgets('renders cancel text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FormScreenHeader(title: 'Test', cancelText: 'Cancel'),
          ),
        ),
      );

      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('calls onBack when back button is tapped', (
      WidgetTester tester,
    ) async {
      bool backPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormScreenHeader(
              title: 'Test',
              onBack: () => backPressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.arrow_back_ios));
      expect(backPressed, isTrue);
    });

    testWidgets('calls onCancel when cancel is tapped', (
      WidgetTester tester,
    ) async {
      bool cancelPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormScreenHeader(
              title: 'Test',
              cancelText: 'Cancel',
              onCancel: () => cancelPressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Cancel'));
      expect(cancelPressed, isTrue);
    });
  });

  group('FormScreenFooter', () {
    testWidgets('renders label', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: FormScreenFooter(label: 'Save')),
        ),
      );

      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('renders icon when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FormScreenFooter(label: 'Save', icon: Icons.save),
          ),
        ),
      );

      expect(find.byIcon(Icons.save), findsOneWidget);
    });

    testWidgets('calls onPressed when button is tapped', (
      WidgetTester tester,
    ) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FormScreenFooter(
              label: 'Save',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Save'));
      expect(pressed, isTrue);
    });
  });
}
