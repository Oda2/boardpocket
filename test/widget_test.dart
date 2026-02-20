// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:boardpocket/main.dart';

void main() {
  testWidgets('App initializes and shows loading or content', (
    WidgetTester tester,
  ) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // The app starts with a loading indicator or MaterialApp content
    // Just verify the app builds without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
