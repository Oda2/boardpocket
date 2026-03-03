import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:boardpocket/presentation/screens/challenge_screen.dart';
import 'package:boardpocket/core/i18n/app_localizations.dart';

void main() {
  Widget createTestWidget({Widget? child}) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: MediaQuery(
        data: const MediaQueryData(size: Size(400, 900)),
        child: child ?? const ChallengeScreen(),
      ),
    );
  }

  group('ChallengeScreen - Basic Rendering', () {
    testWidgets('should render without errors', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should have SafeArea', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(SafeArea), findsWidgets);
    });

    testWidgets('should have Column', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('should have IconButton', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(IconButton), findsWidgets);
    });
  });
}
