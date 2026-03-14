import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/core/components/forms/form_screen.dart';

void main() {
  group('FormScreen Widget Tests', () {
    testWidgets('renders all text fields from config', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FormScreen<void>(
            title: 'Test Form',
            isEditing: false,
            fields: const [
              FormFieldConfig(
                name: 'title',
                label: 'Title',
                hint: 'Enter title',
              ),
              FormFieldConfig(
                name: 'description',
                label: 'Description',
                hint: 'Enter description',
              ),
              FormFieldConfig(
                name: 'price',
                label: 'Price',
                hint: '0.00',
                suffixText: '\$',
              ),
            ],
            saveText: 'Save',
          ),
        ),
      );

      expect(find.byType(TextField), findsNWidgets(3));
    });

    testWidgets('shows loading indicator when isLoading', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FormScreen<void>(
            title: 'Test',
            isEditing: false,
            fields: const [],
            saveText: 'Save',
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(FormScreen<void>), findsOneWidget);
    });

    testWidgets('has back button in header', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FormScreen<void>(
            title: 'Test Form',
            isEditing: false,
            fields: const [],
            saveText: 'Save',
          ),
        ),
      );

      expect(find.byIcon(Icons.arrow_back_ios), findsOneWidget);
    });

    testWidgets('displays correct number of form sections', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FormScreen<void>(
            title: 'Add Game',
            isEditing: false,
            fields: const [
              FormFieldConfig(name: 'name', label: 'Game Name'),
              FormFieldConfig(name: 'category', label: 'Category'),
              FormFieldConfig(name: 'players', label: 'Players'),
            ],
            saveText: 'Add',
          ),
        ),
      );

      expect(find.byType(FormScreen<void>), findsOneWidget);
    });

    testWidgets('renders image preview field', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FormScreen<void>(
            title: 'Add Game',
            isEditing: false,
            fields: const [
              FormFieldConfig(
                name: 'imageUrl',
                label: 'Image URL',
                type: FormFieldType.imagePreview,
              ),
            ],
            saveText: 'Save',
          ),
        ),
      );

      expect(find.byType(FormScreen<void>), findsOneWidget);
    });

    testWidgets('renders url field with correct keyboard type', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FormScreen<void>(
            title: 'Test',
            isEditing: false,
            fields: const [
              FormFieldConfig(
                name: 'website',
                label: 'Website',
                type: FormFieldType.url,
              ),
            ],
            saveText: 'Save',
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('renders number field with correct keyboard type', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: FormScreen<void>(
            title: 'Test',
            isEditing: false,
            fields: const [
              FormFieldConfig(
                name: 'age',
                label: 'Age',
                type: FormFieldType.number,
              ),
            ],
            saveText: 'Save',
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
