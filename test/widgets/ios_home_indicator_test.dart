import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/presentation/widgets/ios_home_indicator.dart';

void main() {
  group('IOSHomeIndicator', () {
    testWidgets('should render correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: Stack(children: [const IOSHomeIndicator()])),
        ),
      );

      expect(find.byType(IOSHomeIndicator), findsOneWidget);
    });

    testWidgets('should be positioned at bottom', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: Stack(children: [const IOSHomeIndicator()])),
        ),
      );

      final position = tester.widget<Positioned>(find.byType(Positioned));
      expect(position.bottom, 8);
    });

    testWidgets('should have container with rounded corners', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: Stack(children: [const IOSHomeIndicator()])),
        ),
      );

      expect(find.byType(Container), findsOneWidget);
    });
  });
}
