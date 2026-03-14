import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/core/components/forms/form_screen.dart';

void main() {
  group('FormFieldConfig', () {
    test('creates config with required fields', () {
      const config = FormFieldConfig(name: 'title', label: 'Title');

      expect(config.name, 'title');
      expect(config.label, 'Title');
    });

    test('creates config with all optional fields', () {
      const config = FormFieldConfig(
        name: 'title',
        label: 'Title',
        hint: 'Enter title',
        icon: Icons.title,
        suffixText: 'max',
        required: true,
      );

      expect(config.hint, 'Enter title');
      expect(config.icon, Icons.title);
      expect(config.suffixText, 'max');
      expect(config.required, true);
    });

    test('creates config with default type', () {
      const config = FormFieldConfig(name: 'title', label: 'Title');

      expect(config.type, FormFieldType.text);
    });

    test('creates config with url type', () {
      const config = FormFieldConfig(
        name: 'link',
        label: 'Link',
        type: FormFieldType.url,
      );

      expect(config.type, FormFieldType.url);
    });

    test('creates config with number type', () {
      const config = FormFieldConfig(
        name: 'age',
        label: 'Age',
        type: FormFieldType.number,
      );

      expect(config.type, FormFieldType.number);
    });

    test('creates config with imagePreview type', () {
      const config = FormFieldConfig(
        name: 'image',
        label: 'Image',
        type: FormFieldType.imagePreview,
      );

      expect(config.type, FormFieldType.imagePreview);
    });
  });

  group('FormFieldType enum', () {
    test('has all expected values', () {
      expect(FormFieldType.values.length, 4);
      expect(FormFieldType.values.contains(FormFieldType.text), true);
      expect(FormFieldType.values.contains(FormFieldType.url), true);
      expect(FormFieldType.values.contains(FormFieldType.number), true);
      expect(FormFieldType.values.contains(FormFieldType.imagePreview), true);
    });
  });
}
