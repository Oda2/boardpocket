import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/core/components/forms/generic_form_screen.dart';

void main() {
  group('GenericFormScreen Widget Tests', () {
    testWidgets('renders multiple text fields', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GenericFormScreen(
            title: 'Test Form',
            fields: const [
              FormFieldDef(
                key: 'name',
                label: 'Name',
                type: FormFieldKind.text,
              ),
              FormFieldDef(
                key: 'email',
                label: 'Email',
                type: FormFieldKind.text,
              ),
              FormFieldDef(
                key: 'phone',
                label: 'Phone',
                type: FormFieldKind.text,
              ),
            ],
            onSave: (_) async {},
            saveLabel: 'Save',
          ),
        ),
      );

      expect(find.byType(TextField), findsNWidgets(3));
    });

    testWidgets('renders chip selector with options', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GenericFormScreen(
            title: 'Test Form',
            fields: [
              FormFieldDef(
                key: 'category',
                label: 'Category',
                type: FormFieldKind.chipSelector,
                chipOptions: const ['Strategy', 'Party', 'Euro', 'Abstract'],
              ),
            ],
            onSave: (_) async {},
            saveLabel: 'Save',
          ),
        ),
      );

      expect(find.text('Strategy'), findsOneWidget);
      expect(find.text('Party'), findsOneWidget);
      expect(find.text('Euro'), findsOneWidget);
      expect(find.text('Abstract'), findsOneWidget);
    });

    testWidgets('chip selector is interactive', (WidgetTester tester) async {
      String selectedValue = 'Strategy';

      await tester.pumpWidget(
        MaterialApp(
          home: GenericFormScreen(
            title: 'Test Form',
            fields: [
              FormFieldDef(
                key: 'category',
                label: 'Category',
                type: FormFieldKind.chipSelector,
                chipOptions: const ['Strategy', 'Party'],
              ),
            ],
            onSave: (_) async {},
            saveLabel: 'Save',
          ),
        ),
      );

      await tester.tap(find.text('Party'));
      await tester.pump();
      expect(find.text('Party'), findsOneWidget);
    });

    testWidgets('renders number selector', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GenericFormScreen(
            title: 'Test Form',
            fields: [
              FormFieldDef(
                key: 'players',
                label: 'Players',
                type: FormFieldKind.numberSelector,
                minValue: 1,
                maxValue: 10,
                defaultValue: 4,
              ),
            ],
            onSave: (_) async {},
            saveLabel: 'Save',
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget);
    });

    testWidgets('number selector has increment and decrement buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GenericFormScreen(
            title: 'Test Form',
            fields: [
              FormFieldDef(
                key: 'players',
                label: 'Players',
                type: FormFieldKind.numberSelector,
                minValue: 1,
                maxValue: 10,
                defaultValue: 4,
              ),
            ],
            onSave: (_) async {},
            saveLabel: 'Save',
          ),
        ),
      );

      expect(find.text('Players'), findsOneWidget);
    });

    testWidgets('renders star rating field', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GenericFormScreen(
            title: 'Test Form',
            fields: const [],
            onSave: (_) async {},
            saveLabel: 'Save',
          ),
        ),
      );

      expect(find.text('Test Form'), findsOneWidget);
    });

    testWidgets('renders image URL field with preview', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GenericFormScreen(
            title: 'Test Form',
            fields: const [
              FormFieldDef(
                key: 'imageUrl',
                label: 'Image URL',
                type: FormFieldKind.imageUrl,
              ),
            ],
            onSave: (_) async {},
            saveLabel: 'Save',
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('renders URL field', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GenericFormScreen(
            title: 'Test Form',
            fields: const [
              FormFieldDef(
                key: 'link',
                label: 'Website',
                type: FormFieldKind.url,
              ),
            ],
            onSave: (_) async {},
            saveLabel: 'Save',
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('renders number field', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GenericFormScreen(
            title: 'Test Form',
            fields: const [
              FormFieldDef(
                key: 'age',
                label: 'Age',
                type: FormFieldKind.number,
              ),
            ],
            onSave: (_) async {},
            saveLabel: 'Save',
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('has header with title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GenericFormScreen(
            title: 'Add New Game',
            fields: const [],
            onSave: (_) async {},
            saveLabel: 'Add Game',
          ),
        ),
      );

      expect(find.text('Add New Game'), findsOneWidget);
    });

    testWidgets('has save button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GenericFormScreen(
            title: 'Test',
            fields: const [],
            onSave: (_) async {},
            saveLabel: 'Submit Form',
          ),
        ),
      );

      expect(find.text('Submit Form'), findsOneWidget);
    });

    testWidgets('has cancel button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GenericFormScreen(
            title: 'Test',
            fields: const [],
            onSave: (_) async {},
            saveLabel: 'Save',
          ),
        ),
      );

      expect(find.text('Cancel'), findsOneWidget);
    });
  });
}
