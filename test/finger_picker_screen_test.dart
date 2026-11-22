import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:boardpocket/core/components/games/finger_picker_components.dart';
import 'package:boardpocket/presentation/screens/finger_picker_screen.dart';
import 'package:boardpocket/core/i18n/app_localizations.dart';

void main() {
  Future<void> pumpScreen(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // Silences the HapticFeedback calls made by the touch handlers.
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async => null,
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('en')],
        home: const FingerPickerScreen(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  testWidgets('FingerPickerScreen renders correctly with localization', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    expect(find.byType(FingerPickerScreen), findsOneWidget);
  });

  testWidgets('FingerPickerScreen shows instruction text initially', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    expect(find.text('Tap screen to add fingers'), findsOneWidget);
    expect(find.byType(FingerPointer), findsNothing);
  });

  testWidgets('Touching the screen adds a finger', (WidgetTester tester) async {
    await pumpScreen(tester);

    await tester.tapAt(const Offset(400, 500));
    await tester.pump();

    expect(find.byType(FingerPointer), findsOneWidget);
    expect(find.text('1 finger'), findsOneWidget);

    await tester.tapAt(const Offset(250, 750));
    await tester.pump();

    expect(find.byType(FingerPointer), findsNWidgets(2));
    expect(find.text('2 fingers'), findsOneWidget);
  });

  testWidgets('Moving a finger updates its position', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    final gesture = await tester.startGesture(const Offset(400, 500));
    await tester.pump();

    expect(find.byType(FingerPointer), findsOneWidget);

    await gesture.moveBy(const Offset(0, 120));
    await tester.pump();
    await gesture.up();
    await tester.pump();

    final pointer = tester.widget<FingerPointer>(find.byType(FingerPointer));
    expect(pointer.position, const Offset(400, 620));
    // The finger stays on screen after the touch is released.
    expect(find.byType(FingerPointer), findsOneWidget);
  });

  testWidgets('Starting without two fingers shows a message', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    await tester.tapAt(const Offset(400, 500));
    await tester.pump();

    await tester.tap(find.text('Start'));
    await tester.pump();

    expect(find.text('Add at least 2 fingers!'), findsOneWidget);
    expect(find.byType(CountdownOverlay), findsNothing);
  });

  testWidgets(
    'Two touches followed by Start run the countdown and pick a winner',
    (WidgetTester tester) async {
      await pumpScreen(tester);

      await tester.tapAt(const Offset(300, 500));
      await tester.tapAt(const Offset(500, 700));
      await tester.pump();

      expect(find.byType(FingerPointer), findsNWidgets(2));

      await tester.tap(find.text('Start'));
      await tester.pump();
      expect(find.byType(CountdownOverlay), findsOneWidget);

      await tester.pump(const Duration(seconds: 5));
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byType(WinnerDisplay), findsOneWidget);
      expect(find.byIcon(Icons.celebration), findsOneWidget);

      // Reset clears the fingers and the winner.
      await tester.tap(find.text('Reset'));
      await tester.pump();

      expect(find.byType(FingerPointer), findsNothing);
      expect(find.byType(WinnerDisplay), findsNothing);
      expect(find.text('Tap screen to add fingers'), findsOneWidget);
    },
  );

  testWidgets('Cancelling the countdown does not pick a winner', (
    WidgetTester tester,
  ) async {
    await pumpScreen(tester);

    await tester.tapAt(const Offset(300, 500));
    await tester.tapAt(const Offset(500, 700));
    await tester.pump();

    await tester.tap(find.text('Start'));
    await tester.pump();
    expect(find.byType(CountdownOverlay), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pump();
    expect(find.byType(CountdownOverlay), findsNothing);

    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byType(WinnerDisplay), findsNothing);
    expect(find.byType(CountdownOverlay), findsNothing);
  });
}
