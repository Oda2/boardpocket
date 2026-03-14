import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/core/components/forms/generic_form_screen.dart';

void main() {
  group('FormFieldDef', () {
    test('creates text field config', () {
      const field = FormFieldDef(
        key: 'title',
        label: 'Title',
        type: FormFieldKind.text,
      );

      expect(field.key, 'title');
      expect(field.label, 'Title');
      expect(field.type, FormFieldKind.text);
    });

    test('creates number field config with defaults', () {
      const field = FormFieldDef(
        key: 'age',
        label: 'Age',
        type: FormFieldKind.number,
        minValue: 1,
        maxValue: 100,
        defaultValue: 18,
      );

      expect(field.minValue, 1);
      expect(field.maxValue, 100);
      expect(field.defaultValue, 18);
    });

    test('creates chip selector config', () {
      const field = FormFieldDef(
        key: 'category',
        label: 'Category',
        type: FormFieldKind.chipSelector,
        chipOptions: ['Strategy', 'Party', 'Euro'],
      );

      expect(field.chipOptions, ['Strategy', 'Party', 'Euro']);
    });

    test('creates url field config', () {
      const field = FormFieldDef(
        key: 'link',
        label: 'Link',
        type: FormFieldKind.url,
        hint: 'https://example.com',
      );

      expect(field.hint, 'https://example.com');
    });

    test('creates image url field config', () {
      const field = FormFieldDef(
        key: 'image',
        label: 'Image',
        type: FormFieldKind.imageUrl,
      );

      expect(field.type, FormFieldKind.imageUrl);
    });

    test('creates required field', () {
      const field = FormFieldDef(
        key: 'email',
        label: 'Email',
        type: FormFieldKind.text,
        required: true,
      );

      expect(field.required, true);
    });
  });

  group('FormFieldKind enum', () {
    test('has all expected values', () {
      expect(FormFieldKind.values.length, 7);
      expect(FormFieldKind.values.contains(FormFieldKind.text), true);
      expect(FormFieldKind.values.contains(FormFieldKind.number), true);
      expect(FormFieldKind.values.contains(FormFieldKind.url), true);
      expect(FormFieldKind.values.contains(FormFieldKind.imageUrl), true);
      expect(FormFieldKind.values.contains(FormFieldKind.chipSelector), true);
      expect(FormFieldKind.values.contains(FormFieldKind.numberSelector), true);
      expect(FormFieldKind.values.contains(FormFieldKind.starRating), true);
    });
  });
}
