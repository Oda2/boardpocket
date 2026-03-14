import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/core/components/games/finger_picker_components.dart';

void main() {
  group('CountdownOverlay', () {
    testWidgets('renders countdown number', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountdownOverlay(
              count: 3,
              label: 'seconds',
              animation: const AlwaysStoppedAnimation(0.5),
            ),
          ),
        ),
      );

      expect(find.text('3'), findsOneWidget);
      expect(find.text('seconds'), findsOneWidget);
    });
  });

  group('FingerPointer', () {
    testWidgets('renders at position', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                FingerPointer(position: Offset(100, 200), color: Colors.blue),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(FingerPointer), findsOneWidget);
    });
  });

  group('WinnerDisplay', () {
    testWidgets('renders with color', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WinnerDisplay(
              color: Colors.purple,
              animation: const AlwaysStoppedAnimation(1.0),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.celebration), findsOneWidget);
    });
  });

  group('FingerPickerCanvas', () {
    testWidgets('renders child', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: FingerPickerCanvas(child: Text('Content'))),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
    });
  });
}
