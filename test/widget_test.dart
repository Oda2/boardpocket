import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:boardpocket/core/di/dependency_injection.dart';
import 'package:boardpocket/main.dart';

void main() {
  setUpAll(() async {
    await DependencyInjection().init();
  });

  testWidgets('App initializes and shows loading or content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
