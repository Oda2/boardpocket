import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:boardpocket/core/i18n/app_localizations.dart';
import 'package:boardpocket/data/models/game.dart';
import 'package:boardpocket/data/repositories/interfaces/game_repository_interface.dart';
import 'package:boardpocket/presentation/screens/ranking_screen.dart';

class _Repo implements IGameRepository {
  _Repo(this.games);
  final List<Game> games;

  @override
  Future<List<Game>> getAll() async => games;

  @override
  Future<Game?> getById(String id) async =>
      games.where((g) => g.id == id).firstOrNull;
  @override
  Future<void> recordPlay(String id, bool won) async {}
  @override
  Future<Game> create(Game game) async => game;
  @override
  Future<void> delete(String id) async {}
  @override
  Future<void> update(Game game) async {}
  @override
  Future<List<Game>> getByCategory(String category) async => games;
  @override
  Future<List<String>> getCategories() async => ['Strategy'];
  @override
  Future<List<Game>> search(String query) async => games;
}

/// Fails on purpose, to exercise the catch branch.
class _BrokenRepo implements IGameRepository {
  @override
  Future<List<Game>> getAll() async => throw Exception('db down');
  @override
  Future<Game?> getById(String id) async => null;
  @override
  Future<void> recordPlay(String id, bool won) async {}
  @override
  Future<Game> create(Game game) async => game;
  @override
  Future<void> delete(String id) async {}
  @override
  Future<void> update(Game game) async {}
  @override
  Future<List<Game>> getByCategory(String category) async => [];
  @override
  Future<List<String>> getCategories() async => [];
  @override
  Future<List<Game>> search(String query) async => [];
}

Game _game(
  String id, {
  int plays = 0,
  int wins = 0,
  int losses = 0,
}) => Game(
  id: id,
  title: 'Game $id',
  players: '2-4',
  time: '60m',
  category: 'Strategy',
  totalPlays: plays,
  wins: wins,
  losses: losses,
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

Widget app(IGameRepository repo) => MaterialApp(
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: const [Locale('en')],
  home: RankingScreen(repository: repo),
);

void main() {
  group('RankingScreen - content', () {
    testWidgets('shows the empty state when there are no games', (tester) async {
      await tester.pumpWidget(app(_Repo([])));
      await tester.pumpAndSettle();

      expect(find.text('No games yet'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows the statistics section with games', (tester) async {
      await tester.pumpWidget(
        app(_Repo([_game('1', plays: 6, wins: 4, losses: 2)])),
      );
      await tester.pumpAndSettle();

      expect(find.text('Statistics'), findsOneWidget);
      expect(find.text('Games Ranking'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('totals plays, wins and losses across games', (tester) async {
      await tester.pumpWidget(
        app(
          _Repo([
            _game('1', plays: 6, wins: 4, losses: 2),
            _game('2', plays: 3, wins: 1, losses: 2),
          ]),
        ),
      );
      await tester.pumpAndSettle();

      // 6 + 3 plays, 4 + 1 wins, 2 + 2 losses.
      expect(find.text('9'), findsWidgets);
      expect(find.text('5'), findsWidgets);
      expect(find.text('4'), findsWidgets);
    });

    testWidgets('renders both charts when there is data', (tester) async {
      await tester.pumpWidget(
        app(_Repo([_game('1', plays: 5, wins: 3, losses: 2)])),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PieChart), findsOneWidget);
      expect(find.text('Most Played Games'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('lists each game', (tester) async {
      await tester.pumpWidget(
        app(
          _Repo([
            _game('1', plays: 9),
            _game('2', plays: 2),
          ]),
        ),
      );
      await tester.pumpAndSettle();

      // The title shows up in the ranking list and in the most-played list.
      expect(find.text('Game 1'), findsWidgets);
      expect(find.text('Game 2'), findsWidgets);
    });

    testWidgets('orders games by plays, most played first', (tester) async {
      await tester.pumpWidget(
        app(
          _Repo([
            _game('low', plays: 1),
            _game('high', plays: 99),
            _game('mid', plays: 50),
          ]),
        ),
      );
      await tester.pumpAndSettle();

      final positions = ['Game high', 'Game mid', 'Game low']
          .map((t) => tester.getTopLeft(find.text(t).first).dy)
          .toList();

      expect(positions[0], lessThan(positions[1]));
      expect(positions[1], lessThan(positions[2]));
    });

    testWidgets('handles a repository that throws', (tester) async {
      await tester.pumpWidget(app(_BrokenRepo()));
      await tester.pumpAndSettle();

      // Falls back to the empty state instead of crashing.
      expect(tester.takeException(), isNull);
      expect(find.text('No games yet'), findsOneWidget);
    });

    testWidgets('shows zeroed stats when nobody has played yet', (
      tester,
    ) async {
      await tester.pumpWidget(app(_Repo([_game('1')])));
      await tester.pumpAndSettle();

      expect(find.text('0'), findsWidgets);
      expect(tester.takeException(), isNull);
    });

    testWidgets('refresh button reloads', (tester) async {
      await tester.pumpWidget(app(_Repo([_game('1', plays: 4)])));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Statistics'), findsOneWidget);
    });

    testWidgets('does not overflow on a small phone', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(
        app(
          _Repo([
            _game('1', plays: 10, wins: 6, losses: 4),
            _game('2', plays: 7, wins: 2, losses: 5),
          ]),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
