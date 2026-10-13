import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:boardpocket/core/components/session_timer.dart';
import 'package:boardpocket/core/i18n/app_localizations.dart';
import 'package:boardpocket/data/models/game.dart';
import 'package:boardpocket/data/models/wishlist_item.dart';
import 'package:boardpocket/data/repositories/interfaces/game_repository_interface.dart';
import 'package:boardpocket/data/repositories/interfaces/wishlist_repository_interface.dart';
import 'package:boardpocket/presentation/providers/wishlist_provider.dart';
import 'package:boardpocket/presentation/providers/game_provider.dart';
import 'package:boardpocket/presentation/providers/session_timer_provider.dart';
import 'package:boardpocket/presentation/screens/game_detail_screen.dart';

class _Repo implements IGameRepository {
  _Repo(this.game);
  Game game;

  @override
  Future<Game?> getById(String id) async => game;
  @override
  Future<List<Game>> getAll() async => [game];
  @override
  Future<void> update(Game g) async => game = g;
  @override
  Future<void> recordPlay(String id, bool won) async {}
  @override
  Future<Game> create(Game g) async => g;
  @override
  Future<void> delete(String id) async {}
  @override
  Future<List<Game>> getByCategory(String c) async => [game];
  @override
  Future<List<String>> getCategories() async => ['Strategy'];
  @override
  Future<List<Game>> search(String q) async => [game];
}

/// The detail screen also loads the wishlist for its "add to wishlist" button.
class _WishlistRepo implements IWishlistRepository {
  @override
  Future<WishlistItem> create(WishlistItem item) async => item;
  @override
  Future<void> delete(String id) async {}
  @override
  Future<List<WishlistItem>> getAll() async => [];
  @override
  Future<WishlistItem?> getById(String id) async => null;
  @override
  Future<void> update(WishlistItem item) async {}
}

Game _game({int? lastSessionMs}) => Game(
  id: 'g1',
  title: 'Catan',
  players: '3-4',
  time: '60m',
  category: 'Strategy',
  lastSessionMs: lastSessionMs,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

Widget app(_Repo repo, SessionTimerProvider timer) => MaterialApp.router(
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: const [Locale('en')],
  routerConfig: GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => GameDetailScreen(gameId: 'g1'),
      ),
      GoRoute(
        path: '/wishlist',
        builder: (_, _) => const Scaffold(body: Text('wishlist')),
      ),
    ],
  ),
  builder: (context, child) => MultiProvider(
    providers: [
      ChangeNotifierProvider<GameProvider>(
        create: (_) => GameProvider(repository: repo),
      ),
      ChangeNotifierProvider<SessionTimerProvider>.value(value: timer),
      ChangeNotifierProvider<WishlistProvider>(
        create: (_) => WishlistProvider(repository: _WishlistRepo()),
      ),
    ],
    child: child ?? const SizedBox.shrink(),
  ),
);

void main() {
  /// The timer lives inside a CustomScrollView, so it can be below the fold.
  Future<void> scrollTo(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
  }

  group('GameDetailScreen - session timer', () {
    late _Repo repo;
    late SessionTimerProvider timer;

    setUp(() {
      repo = _Repo(_game());
      timer = SessionTimerProvider();
    });

    testWidgets('shows the timer section', (tester) async {
      await tester.pumpWidget(app(repo, timer));
      await tester.pumpAndSettle();

      expect(find.byType(SessionTimer), findsOneWidget);
      expect(find.text('Session timer'), findsOneWidget);
      expect(find.text('00:00'), findsOneWidget);
    });

    testWidgets('start begins the session', (tester) async {
      await tester.pumpWidget(app(repo, timer));
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('Start'));
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      expect(timer.isRunning, isTrue);
      expect(find.text('Pause'), findsOneWidget);
    });

    testWidgets('pause stops the clock', (tester) async {
      await tester.pumpWidget(app(repo, timer));
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('Start'));
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();
      await scrollTo(tester, find.text('Pause'));
      await tester.tap(find.text('Pause'));
      await tester.pumpAndSettle();

      expect(timer.isRunning, isFalse);
      expect(find.text('Start'), findsOneWidget);
    });

    testWidgets('reset clears the session', (tester) async {
      await tester.pumpWidget(app(repo, timer));
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('Start'));
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();
      for (var i = 0; i < 3; i++) {
        await tester.pump(const Duration(milliseconds: 400));
      }
      await scrollTo(tester, find.text('Reset'));
      await tester.tap(find.text('Reset'));
      await tester.pumpAndSettle();

      expect(timer.hasSession, isFalse);
      expect(timer.elapsed, Duration.zero);
      expect(find.text('00:00'), findsOneWidget);
    });

    testWidgets('finish stores the duration on the game', (tester) async {
      await tester.pumpWidget(app(repo, timer));
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('Start'));
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();
      for (var i = 0; i < 3; i++) {
        await tester.pump(const Duration(milliseconds: 400));
      }

      await scrollTo(tester, find.text('Finish'));
      await tester.tap(find.text('Finish'));
      await tester.pumpAndSettle();

      // Stopwatch measures wall-clock time, so the test only asserts it was
      // recorded - the exact duration cannot be faked with tester.pump().
      expect(repo.game.lastSessionMs, isNotNull);
      expect(repo.game.lastSessionMs, greaterThan(0));
      // The session resets after saving.
      expect(timer.hasSession, isFalse);
    });

    testWidgets('finish is disabled before anything is timed', (tester) async {
      await tester.pumpWidget(app(repo, timer));
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('Finish'));
      await tester.tap(find.text('Finish'));
      await tester.pumpAndSettle();

      expect(repo.game.lastSessionMs, isNull);
    });

    testWidgets('shows the previous session duration', (tester) async {
      repo = _Repo(_game(lastSessionMs: 3725000));
      await tester.pumpWidget(app(repo, timer));
      await tester.pumpAndSettle();

      // 1h 02m 05s
      expect(find.text('Last session: 1:02:05'), findsOneWidget);
    });

    testWidgets('the timer survives being rebuilt', (tester) async {
      await tester.pumpWidget(app(repo, timer));
      await tester.pumpAndSettle();

      await scrollTo(tester, find.text('Start'));
      await tester.tap(find.text('Start'));
      await tester.pumpAndSettle();

      // New widget tree, same provider instance.
      await tester.pumpWidget(app(repo, timer));
      await tester.pumpAndSettle();

      expect(timer.isRunning, isTrue);
      expect(find.text('Pause'), findsOneWidget);
    });

    testWidgets('does not overflow on a small phone', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(app(repo, timer));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('Game model - lastSessionMs', () {
    test('round-trips through a map', () {
      final game = _game(lastSessionMs: 90000);
      final restored = Game.fromMap(game.toMap());

      expect(restored.lastSessionMs, 90000);
    });

    test('is null when never timed', () {
      expect(Game.fromMap(_game().toMap()).lastSessionMs, isNull);
    });

    test('copyWith sets it without touching the other fields', () {
      final game = _game();
      final updated = game.copyWith(lastSessionMs: 1234);

      expect(updated.lastSessionMs, 1234);
      expect(updated.title, game.title);
    });

    test('copyWith keeps the old value when not provided', () {
      final game = _game(lastSessionMs: 555);
      expect(game.copyWith(title: 'X').lastSessionMs, 555);
    });
  });
}
