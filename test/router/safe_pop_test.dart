import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:boardpocket/core/components/app_header.dart';
import 'package:boardpocket/router/router.dart';

GoRouter buildRouter({required String initialLocation}) => GoRouter(
  initialLocation: initialLocation,
  routes: [
    GoRoute(
      path: '/',
      builder: (_, _) => const Scaffold(body: Text('home')),
    ),
    GoRoute(
      path: '/second',
      builder: (_, _) =>
          const Scaffold(body: AppHeaderWithBack(title: 'Second')),
    ),
  ],
);

void main() {
  group('SafePop', () {
    testWidgets('pops normally when there is history', (tester) async {
      final router = buildRouter(initialLocation: '/');
      addTearDown(router.dispose);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      router.push('/second');
      await tester.pumpAndSettle();
      expect(find.text('Second'), findsOneWidget);

      tester.element(find.text('Second')).popOrGo();
      await tester.pumpAndSettle();

      expect(find.text('home'), findsOneWidget);
    });

    testWidgets('falls back to / when there is nothing to pop', (tester) async {
      // Reached directly, so the stack holds a single page. Since go_router 18
      // a bare pop() there throws instead of being a no-op, which is what used
      // to crash the back button on every screen opened from a tab.
      final router = buildRouter(initialLocation: '/second');
      addTearDown(router.dispose);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      tester.element(find.text('Second')).popOrGo();
      await tester.pumpAndSettle();

      expect(find.text('home'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('honours a custom fallback route', (tester) async {
      final router = buildRouter(initialLocation: '/second');
      addTearDown(router.dispose);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      tester.element(find.text('Second')).popOrGo(fallback: '/');
      await tester.pumpAndSettle();

      expect(find.text('home'), findsOneWidget);
    });
  });

  group('AppHeaderWithBack on a root screen', () {
    testWidgets('back button does not throw when there is nothing to pop', (
      tester,
    ) async {
      final router = buildRouter(initialLocation: '/second');
      addTearDown(router.dispose);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('home'), findsOneWidget);
    });

    testWidgets('back button pops when there is history', (tester) async {
      final router = buildRouter(initialLocation: '/');
      addTearDown(router.dispose);

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));
      await tester.pumpAndSettle();

      router.push('/second');
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('home'), findsOneWidget);
    });
  });
}
