import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/core/components/forms/generic_form_screen.dart';

void main() {
  group('GenericFormScreen Unit Tests', () {
    test('FormFieldDef default values', () {
      const field = FormFieldDef(
        key: 'test',
        label: 'Test',
        type: FormFieldKind.text,
      );

      expect(field.key, 'test');
      expect(field.label, 'Test');
      expect(field.type, FormFieldKind.text);
      expect(field.required, false);
      expect(field.chipOptions, isNull);
      expect(field.minValue, isNull);
      expect(field.maxValue, isNull);
      expect(field.defaultValue, isNull);
    });

    test('FormFieldDef with all options', () {
      const field = FormFieldDef(
        key: 'players',
        label: 'Players',
        type: FormFieldKind.numberSelector,
        required: true,
        chipOptions: ['A', 'B'],
        minValue: 1,
        maxValue: 10,
        defaultValue: 4,
      );

      expect(field.required, true);
      expect(field.chipOptions, ['A', 'B']);
      expect(field.minValue, 1);
      expect(field.maxValue, 10);
      expect(field.defaultValue, 4);
    });

    test('FormFieldKind enum values', () {
      expect(FormFieldKind.values.length, 7);
      expect(FormFieldKind.values.contains(FormFieldKind.text), true);
      expect(FormFieldKind.values.contains(FormFieldKind.number), true);
      expect(FormFieldKind.values.contains(FormFieldKind.url), true);
      expect(FormFieldKind.values.contains(FormFieldKind.imageUrl), true);
      expect(FormFieldKind.values.contains(FormFieldKind.chipSelector), true);
      expect(FormFieldKind.values.contains(FormFieldKind.numberSelector), true);
      expect(FormFieldKind.values.contains(FormFieldKind.starRating), true);
    });

    testWidgets('renders with custom title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GenericFormScreen(
            title: 'Custom Title Here',
            fields: const [],
            onSave: (_) async {},
            saveLabel: 'Save',
          ),
        ),
      );

      expect(find.text('Custom Title Here'), findsOneWidget);
    });

    testWidgets('renders save button with icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GenericFormScreen(
            title: 'Test',
            fields: const [],
            onSave: (_) async {},
            saveLabel: 'Save',
            saveIcon: Icons.check,
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('renders all chip options', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GenericFormScreen(
            title: 'Test',
            fields: [
              FormFieldDef(
                key: 'cat',
                label: 'Category',
                type: FormFieldKind.chipSelector,
                chipOptions: const ['Option 1', 'Option 2', 'Option 3'],
              ),
            ],
            onSave: (_) async {},
            saveLabel: 'Save',
          ),
        ),
      );

      expect(find.text('Option 1'), findsOneWidget);
      expect(find.text('Option 2'), findsOneWidget);
      expect(find.text('Option 3'), findsOneWidget);
    });

    testWidgets('number selector shows correct default value', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GenericFormScreen(
            title: 'Test',
            fields: [
              FormFieldDef(
                key: 'num',
                label: 'Number',
                type: FormFieldKind.numberSelector,
                minValue: 0,
                maxValue: 100,
                defaultValue: 42,
              ),
            ],
            onSave: (_) async {},
            saveLabel: 'Save',
          ),
        ),
      );

      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('text field accepts input', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GenericFormScreen(
            title: 'Test',
            fields: const [
              FormFieldDef(
                key: 'input',
                label: 'Input',
                type: FormFieldKind.text,
              ),
            ],
            onSave: (_) async {},
            saveLabel: 'Save',
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'Hello');
      expect(find.text('Hello'), findsOneWidget);
    });
  });
}
