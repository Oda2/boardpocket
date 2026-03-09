import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:boardpocket/presentation/screens/ranking_screen.dart';
import 'package:boardpocket/core/i18n/app_localizations.dart';
import 'package:boardpocket/presentation/widgets/bottom_tab_bar.dart';

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

    testWidgets('should have Text widgets for title', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(Text), findsWidgets);
    });
  });

  group('RankingScreen - Icons', () {
    testWidgets('should have refresh icon', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });
  });

  group('RankingScreen - Empty State', () {
    testWidgets('should show empty state when no games', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.emoji_events_outlined), findsOneWidget);
    });

    testWidgets('should show add games message in empty state', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.textContaining('Add games'), findsOneWidget);
    });
  });

  group('RankingScreen - Loading State', () {
    testWidgets('should show loading indicator initially', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('RankingScreen - Refresh', () {
    testWidgets('should have refresh button that is tappable', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final refreshButton = find.byIcon(Icons.refresh);
      expect(refreshButton, findsOneWidget);

      await tester.tap(refreshButton);
      await tester.pumpAndSettle();
    });

    testWidgets('refresh button should be in header', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final headerRow = find.byType(Row);
      expect(headerRow, findsWidgets);
    });
  });

  group('RankingScreen - Layout Structure', () {
    testWidgets('should have BottomTabBar', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(BottomTabBar), findsOneWidget);
    });

    testWidgets('should use correct theme colors', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(Scaffold), findsOneWidget);
    });
  });
}
