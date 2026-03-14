import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/core/components/form_fields.dart';

void main() {
  group('TextFieldInput', () {
    testWidgets('renders with hint text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: TextFieldInput(hint: 'Enter name')),
        ),
      );

      expect(find.text('Enter name'), findsOneWidget);
    });

    testWidgets('renders with icon', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: TextFieldInput(icon: Icons.person)),
        ),
      );

      expect(find.byIcon(Icons.person), findsOneWidget);
    });

    testWidgets('calls onChanged when text is entered', (
      WidgetTester tester,
    ) async {
      String? changedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextFieldInput(onChanged: (value) => changedValue = value),
          ),
        ),
      );

      await tester.enterText(find.byType(TextField), 'test value');
      expect(changedValue, 'test value');
    });

    testWidgets('renders with suffix text', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: TextFieldInput(suffixText: 'MINS')),
        ),
      );

      expect(find.text('MINS'), findsOneWidget);
    });
  });

  group('ChipSelectorInput', () {
    testWidgets('renders all items', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChipSelectorInput(
              items: const ['Strategy', 'Party', 'Euro'],
              selected: 'Strategy',
              onSelected: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Strategy'), findsOneWidget);
      expect(find.text('Party'), findsOneWidget);
      expect(find.text('Euro'), findsOneWidget);
    });

    testWidgets('calls onSelected when item is tapped', (
      WidgetTester tester,
    ) async {
      String? selectedItem;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChipSelectorInput(
              items: const ['Strategy', 'Party'],
              selected: 'Strategy',
              onSelected: (item) => selectedItem = item,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Party'));
      expect(selectedItem, 'Party');
    });

    testWidgets('highlights selected item', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChipSelectorInput(
              items: const ['Strategy', 'Party'],
              selected: 'Strategy',
              onSelected: (_) {},
            ),
          ),
        ),
      );

      final containers = find.byType(Container);
      expect(containers, findsWidgets);
    });
  });

  group('NumberInput', () {
    testWidgets('renders current value', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumberInput(value: 5, min: 1, max: 10, onChanged: (_) {}),
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('renders increment and decrement buttons', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumberInput(value: 5, min: 1, max: 10, onChanged: (_) {}),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.remove), findsOneWidget);
    });

    testWidgets('calls onChanged when increment is tapped', (
      WidgetTester tester,
    ) async {
      int? newValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumberInput(
              value: 5,
              min: 1,
              max: 10,
              onChanged: (value) => newValue = value,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.add));
      expect(newValue, 6);
    });

    testWidgets('calls onChanged when decrement is tapped', (
      WidgetTester tester,
    ) async {
      int? newValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumberInput(
              value: 5,
              min: 1,
              max: 10,
              onChanged: (value) => newValue = value,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.remove));
      expect(newValue, 4);
    });

    testWidgets('does not decrement below min', (WidgetTester tester) async {
      int? newValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumberInput(
              value: 1,
              min: 1,
              max: 10,
              onChanged: (value) => newValue = value,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.remove));
      expect(newValue, isNull);
    });

    testWidgets('does not increment above max', (WidgetTester tester) async {
      int? newValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumberInput(
              value: 10,
              min: 1,
              max: 10,
              onChanged: (value) => newValue = value,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.add));
      expect(newValue, isNull);
    });
  });

  group('RatingStarsInput', () {
    testWidgets('renders correct number of stars', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingStarsInput(value: 3, maxStars: 5, onChanged: (_) {}),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsNWidgets(3));
      expect(find.byIcon(Icons.star_border), findsNWidgets(2));
    });

    testWidgets('calls onChanged when star is tapped', (
      WidgetTester tester,
    ) async {
      int? newValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RatingStarsInput(
              value: 3,
              maxStars: 5,
              onChanged: (value) => newValue = value,
            ),
          ),
        ),
      );

      final stars = find.byType(GestureDetector);
      await tester.tap(stars.at(4));
      expect(newValue, 5);
    });

    testWidgets('renders with default maxStars', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: RatingStarsInput(value: 3, onChanged: (_) {})),
        ),
      );

      expect(find.byIcon(Icons.star), findsNWidgets(3));
      expect(find.byIcon(Icons.star_border), findsNWidgets(2));
    });
  });

  group('ImagePreviewInput', () {
    testWidgets('returns empty when imageUrl is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ImagePreviewInput(imageUrl: null)),
        ),
      );

      expect(find.byType(Container), findsNothing);
    });

    testWidgets('returns empty when imageUrl is empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: ImagePreviewInput(imageUrl: '')),
        ),
      );

      expect(find.byType(Container), findsNothing);
    });

    testWidgets('renders Container when imageUrl is provided', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ImagePreviewInput(imageUrl: 'https://example.com/image.jpg'),
          ),
        ),
      );

      expect(find.byType(Container), findsOneWidget);
    });
  });
}
