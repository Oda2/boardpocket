import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/core/components/images/adaptive_image.dart';

void main() {
  group('AdaptiveImage', () {
    testWidgets('shows placeholder when no image', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AdaptiveImage())),
      );

      expect(find.byIcon(Icons.image_not_supported), findsOneWidget);
    });

    testWidgets('shows placeholder when path is empty', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AdaptiveImage(localPath: '')),
        ),
      );

      expect(find.byIcon(Icons.image_not_supported), findsOneWidget);
    });

    testWidgets('shows custom placeholder', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveImage(
              placeholder: Container(key: const Key('custom-placeholder')),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('custom-placeholder')), findsOneWidget);
    });

    testWidgets('shows error widget on load failure', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AdaptiveImage(networkUrl: 'invalid-url')),
        ),
      );

      await tester.pump();
      expect(find.byIcon(Icons.broken_image), findsOneWidget);
    });

    testWidgets('applies border radius', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AdaptiveImage(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        ),
      );

      expect(find.byType(ClipRRect), findsOneWidget);
    });
  });
}
