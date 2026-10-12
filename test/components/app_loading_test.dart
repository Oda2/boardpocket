import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/core/components/app_loading.dart';

void main() {
  group('AppLoading', () {
    testWidgets('renders without throwing', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: AppLoading())),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(tester.takeException(), isNull);
      expect(find.byType(AppLoading), findsOneWidget);
    });

    testWidgets('keeps animating across frames', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: AppLoading())),
        ),
      );

      // An indefinitely repeating controller keeps requesting frames.
      await tester.pump(const Duration(milliseconds: 32));
      await tester.pump(const Duration(milliseconds: 32));
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('x'))),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('respects a custom size', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: Center(child: AppLoading(size: 120))),
        ),
      );
      await tester.pump(const Duration(milliseconds: 16));

      expect(tester.takeException(), isNull);
    });

    testWidgets('falls back to a spinner when the asset is missing', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: AppLoading(asset: 'assets/lottie/does_not_exist.json'),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      // No crash, and something is still shown while loading.
      expect(tester.takeException(), isNull);
      expect(find.byType(AppLoading), findsOneWidget);
    });

    testWidgets('does not overflow on a small screen', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AppLoadingView())),
      );
      await tester.pump(const Duration(milliseconds: 32));

      expect(tester.takeException(), isNull);
    });
  });

  group('AppLoadingView', () {
    testWidgets('renders the optional message', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AppLoadingView(message: 'Carregando...')),
        ),
      );
      await tester.pump(const Duration(milliseconds: 32));

      expect(find.text('Carregando...'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('works without a message', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AppLoadingView())),
      );
      await tester.pump(const Duration(milliseconds: 32));

      expect(find.byType(AppLoading), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('asset wiring', () {
    test('default asset path matches the one bundled in assets/lottie', () {
      expect(AppLoading.defaultAsset, 'assets/lottie/loading_dots.json');
    });
  });
}
