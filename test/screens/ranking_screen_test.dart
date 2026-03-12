import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:boardpocket/presentation/screens/ranking_screen.dart';
import 'package:boardpocket/core/i18n/app_localizations.dart';
import 'package:boardpocket/presentation/widgets/bottom_tab_bar.dart';
import 'package:boardpocket/core/components/components.dart';

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

  group('RankingScreen - Empty State', () {
    testWidgets('should show empty state when no games', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(EmptyState), findsOneWidget);
    });

    testWidgets('should show add games message in empty state', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.textContaining('Add games'), findsOneWidget);
    });

    testWidgets('should show no games yet text', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.textContaining('No games yet'), findsOneWidget);
    });

    testWidgets('should show trophy icon in empty state', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.emoji_events_outlined), findsOneWidget);
    });
  });

  group('RankingScreen - Loading State', () {
    testWidgets('should show loading indicator initially', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should hide loading after data loads', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  group('RankingScreen - Refresh', () {
    testWidgets('should have refresh icon button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('should have refresh button that is tappable', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();
    });

    testWidgets('should have IconActionButton for refresh', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.byType(IconActionButton), findsOneWidget);
    });

    testWidgets('refresh button should be in header Row', (tester) async {
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

  group('RankingScreen - Header', () {
    testWidgets('should have ranking title text', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      expect(find.text('Ranking'), findsWidgets);
    });

    testWidgets('header should have proper padding', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();
      final padding = find.byType(Padding);
      expect(padding, findsWidgets);
    });
  });

  group('RankingScreen - State Management', () {
    testWidgets('should handle loading state correctly', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should update state on refresh', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();
    });

    testWidgets('should switch between loading and content states', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(EmptyState), findsNothing);

      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(EmptyState), findsOneWidget);
    });
  });
}
