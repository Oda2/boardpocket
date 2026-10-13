import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/core/components/session_timer.dart';
import 'package:boardpocket/presentation/providers/session_timer_provider.dart';

Widget wrap(
  Widget child, {
  required bool isRunning,
  required Duration elapsed,
  VoidCallback? onStart,
  VoidCallback? onPause,
  VoidCallback? onReset,
  VoidCallback? onFinish,
}) {
  return MaterialApp(
    home: Scaffold(
      body: SessionTimer(
        isRunning: isRunning,
        elapsed: elapsed,
        sessionLabel: 'SESSION',
        startLabel: 'Start',
        pauseLabel: 'Pause',
        resetLabel: 'Reset',
        finishLabel: 'Finish',
        onStart: onStart ?? () {},
        onPause: onPause ?? () {},
        onReset: onReset ?? () {},
        onFinish: onFinish ?? () {},
      ),
    ),
  );
}

void main() {
  group('SessionTimer.format', () {
    test('uses MM:SS under an hour', () {
      expect(
        SessionTimer.format(const Duration(minutes: 5, seconds: 9)),
        '05:09',
      );
    });

    test('adds hours when needed', () {
      expect(
        SessionTimer.format(
          const Duration(hours: 2, minutes: 3, seconds: 4),
        ),
        '2:03:04',
      );
    });

    test('formats zero', () {
      expect(SessionTimer.format(Duration.zero), '00:00');
    });

    test('pads both fields', () {
      expect(SessionTimer.format(const Duration(seconds: 61)), '01:01');
    });

    test('ignores sub-second precision', () {
      expect(
        SessionTimer.format(const Duration(milliseconds: 999)),
        '00:00',
      );
    });
  });

  group('SessionTimer widget', () {
    testWidgets('shows the elapsed time', (tester) async {
      await tester.pumpWidget(
        wrap(const SizedBox.shrink(), isRunning: false, elapsed: Duration.zero),
      );

      expect(find.text('00:00'), findsOneWidget);
      expect(find.text('Start'), findsOneWidget);
    });

    testWidgets('hides reset and finish when nothing has elapsed', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(const SizedBox.shrink(), isRunning: false, elapsed: Duration.zero),
      );

      expect(find.text('Start'), findsOneWidget);
      expect(find.text('Pause'), findsNothing);
      expect(find.text('Reset'), findsNothing);
      expect(find.text('Finish'), findsOneWidget);
    });

    testWidgets('shows pause instead of start while running', (tester) async {
      await tester.pumpWidget(
        wrap(const SizedBox.shrink(), isRunning: true, elapsed: const Duration(minutes: 1)),
      );

      expect(find.text('Pause'), findsOneWidget);
      expect(find.text('Start'), findsNothing);
    });

    testWidgets('reset appears once time has elapsed', (tester) async {
      await tester.pumpWidget(
        wrap(
          const SizedBox.shrink(),
          isRunning: false,
          elapsed: const Duration(seconds: 30),
        ),
      );

      expect(find.text('Reset'), findsOneWidget);
    });

    testWidgets('start triggers onStart', (tester) async {
      var started = false;
      await tester.pumpWidget(
        wrap(
          const SizedBox.shrink(),
          isRunning: false,
          elapsed: Duration.zero,
          onStart: () => started = true,
        ),
      );

      await tester.tap(find.text('Start'));
      expect(started, isTrue);
    });

    testWidgets('pause, reset and finish trigger their callbacks', (
      tester,
    ) async {
      var paused = false;
      var reset = false;
      var finished = false;

      await tester.pumpWidget(
        wrap(
          const SizedBox.shrink(),
          isRunning: true,
          elapsed: const Duration(minutes: 2),
          onPause: () => paused = true,
          onReset: () => reset = true,
          onFinish: () => finished = true,
        ),
      );

      await tester.tap(find.text('Pause'));
      await tester.tap(find.text('Reset'));
      await tester.tap(find.text('Finish'));

      expect(paused, isTrue);
      expect(reset, isTrue);
      expect(finished, isTrue);
    });

    testWidgets('finish is disabled with nothing elapsed', (tester) async {
      var finished = false;
      await tester.pumpWidget(
        wrap(
          const SizedBox.shrink(),
          isRunning: false,
          elapsed: Duration.zero,
          onFinish: () => finished = true,
        ),
      );

      await tester.tap(find.text('Finish'));
      expect(finished, isFalse);
    });

    testWidgets('repaints while running', (tester) async {
      await tester.pumpWidget(
        wrap(const SizedBox.shrink(), isRunning: true, elapsed: Duration.zero),
      );

      await tester.pump(const Duration(milliseconds: 250));
      await tester.pump(const Duration(milliseconds: 250));

      expect(tester.takeException(), isNull);
    });

    testWidgets('does not overflow on a small phone', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        wrap(
          const SizedBox.shrink(),
          isRunning: true,
          elapsed: const Duration(hours: 1, minutes: 2, seconds: 3),
        ),
      );
      await tester.pump(const Duration(milliseconds: 250));

      expect(tester.takeException(), isNull);
    });

    testWidgets('stops the ticker when removed', (tester) async {
      await tester.pumpWidget(
        wrap(const SizedBox.shrink(), isRunning: true, elapsed: Duration.zero),
      );
      await tester.pump(const Duration(milliseconds: 250));

      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('SessionTimerProvider', () {
    late SessionTimerProvider provider;

    setUp(() {
      provider = SessionTimerProvider();
    });

    test('starts with no session', () {
      expect(provider.hasSession, isFalse);
      expect(provider.isRunning, isFalse);
      expect(provider.elapsed, Duration.zero);
    });

    test('start marks the session and runs it', () async {
      provider.start();
      expect(provider.hasSession, isTrue);
      expect(provider.isRunning, isTrue);
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(provider.elapsed, greaterThan(Duration.zero));
      provider.pause();
    });

    test('pause keeps the accumulated time', () async {
      provider.start();
      await Future<void>.delayed(const Duration(milliseconds: 30));
      provider.pause();

      final atPause = provider.elapsed;
      expect(provider.isRunning, isFalse);
      expect(atPause, greaterThan(Duration.zero));

      // Time must not keep growing while paused.
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(provider.elapsed, atPause);
    });

    test('resume continues from where it stopped', () async {
      provider.start();
      await Future<void>.delayed(const Duration(milliseconds: 30));
      provider.pause();
      final atPause = provider.elapsed;

      provider.start();
      await Future<void>.delayed(const Duration(milliseconds: 30));
      expect(provider.elapsed, greaterThan(atPause));
      provider.pause();
    });

    test('finish stops and returns the duration', () async {
      provider.start();
      await Future<void>.delayed(const Duration(milliseconds: 30));

      final duration = provider.finish();

      expect(provider.isRunning, isFalse);
      expect(duration, greaterThan(Duration.zero));
      // The session is still visible until reset.
      expect(provider.hasSession, isTrue);
    });

    test('reset clears everything', () async {
      provider.start();
      await Future<void>.delayed(const Duration(milliseconds: 30));
      provider.reset();

      expect(provider.elapsed, Duration.zero);
      expect(provider.hasSession, isFalse);
      expect(provider.isRunning, isFalse);
    });

    test('notifies on every state change', () {
      var notifications = 0;
      provider
        ..addListener(() => notifications++)
        ..start();
      expect(notifications, 1);

      provider.pause();
      expect(notifications, 2);

      provider.reset();
      expect(notifications, 3);
    });

    test('finish notifies and returns zero when never started', () {
      var notifications = 0;
      provider
        ..addListener(() => notifications++)
        ..finish();

      expect(notifications, 1);
      expect(provider.elapsed, Duration.zero);
    });
  });
}
