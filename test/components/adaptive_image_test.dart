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

    testWidgets('renders localPath as a network image when it is a url', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdaptiveImage(localPath: 'https://images.example/cover.jpg'),
          ),
        ),
      );

      // AdaptiveImage wraps the provider in a ResizeImage so huge photos are
      // decoded at display size rather than full resolution.
      final image = tester.widget<Image>(find.byType(Image));
      final resize = image.image as ResizeImage;
      expect(resize.imageProvider, isA<NetworkImage>());
      expect(
        (resize.imageProvider as NetworkImage).url,
        'https://images.example/cover.jpg',
      );
    });

    testWidgets('renders a local file path as a FileImage', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AdaptiveImage(localPath: '/tmp/cover.jpg')),
        ),
      );

      final image = tester.widget<Image>(find.byType(Image));
      expect((image.image as ResizeImage).imageProvider, isA<FileImage>());
    });

    testWidgets('shows error widget when a remote url fails to load', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdaptiveImage(localPath: 'https://nope.invalid'),
          ),
        ),
      );

      await tester.pump();
      expect(find.byIcon(Icons.broken_image), findsOneWidget);
    });

    testWidgets('networkUrl takes precedence over localPath', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AdaptiveImage(
              localPath: '/tmp/cover.jpg',
              networkUrl: 'https://images.example/preferred.jpg',
            ),
          ),
        ),
      );

      final image = tester.widget<Image>(find.byType(Image));
      final resize = image.image as ResizeImage;
      expect(resize.imageProvider, isA<NetworkImage>());
      expect(
        (resize.imageProvider as NetworkImage).url,
        'https://images.example/preferred.jpg',
      );
    });

    testWidgets('caps the decode width so huge photos stay cheap', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 400,
              child: AdaptiveImage(
                localPath: 'https://images.example/huge.jpg',
              ),
            ),
          ),
        ),
      );

      final image = tester.widget<Image>(find.byType(Image));
      final resize = image.image as ResizeImage;
      final ratio = MediaQuery.of(tester.element(find.byType(Image)))
          .devicePixelRatio;
      final expected = (400 * ratio).ceil();

      expect(
        resize.width,
        expected > AdaptiveImage.kMaxDecodeWidth
            ? AdaptiveImage.kMaxDecodeWidth
            : expected,
      );
    });

    testWidgets(
      'falls back to the incoming constraints when no width is given',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: AdaptiveImage(localPath: 'https://images.example/a.jpg'),
              ),
            ),
          ),
        );

        // A vertical scroll view leaves the WIDTH bounded (only the height is
        // unbounded), so the decode is capped instead of skipped.
        final image = tester.widget<Image>(find.byType(Image));
        final resize = image.image as ResizeImage;
        expect(resize.width, isNotNull);
        expect(resize.width, lessThanOrEqualTo(AdaptiveImage.kMaxDecodeWidth));
        expect(tester.takeException(), isNull);
      },
    );
  });
}
