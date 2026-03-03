import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:boardpocket/presentation/screens/ranking_screen.dart';
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
      home: child ?? const RankingScreen(),
    );
  }

  group('RankingScreen - Basic Rendering', () {
    testWidgets('should render without errors', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should have SafeArea', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(SafeArea), findsWidgets);
    });

    testWidgets('should have Stack', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(Stack), findsWidgets);
    });

    testWidgets('should have Column', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('should have Icon widgets', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(Icon), findsWidgets);
    });
  });

  group('RankingScreen - Icons', () {
    testWidgets('should have refresh icon', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });
  });
}
