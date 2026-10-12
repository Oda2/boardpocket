import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boardpocket/data/database/web_database.dart';

Map<String, dynamic> game(
  String id, {
  String title = 'Game',
  String category = 'Strategy',
  int createdAt = 0,
}) => {
  'id': id,
  'title': title,
  'category': category,
  'image_path': null,
  'players': '2-4',
  'time': '60m',
  'created_at': createdAt,
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late WebDatabase db;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = WebDatabase();
  });

  group('games', () {
    test('insertGame returns the id and stores the game', () async {
      final id = await db.insertGame(game('1', title: 'Catan'));

      expect(id, '1');
      final all = await db.getAllGames();
      expect(all, hasLength(1));
      expect(all.first['title'], 'Catan');
    });

    test('getAllGames returns newest first', () async {
      await db.insertGame(game('1', createdAt: 100));
      await db.insertGame(game('2', createdAt: 300));
      await db.insertGame(game('3', createdAt: 200));

      final all = await db.getAllGames();
      expect(all.map((g) => g['id']), ['2', '3', '1']);
    });

    test('getAllGames does not leak the internal list', () async {
      await db.insertGame(game('1'));
      final first = await db.getAllGames();
      first.clear();

      expect(await db.getAllGames(), hasLength(1));
    });

    test('searchGames filters by title, case-insensitively', () async {
      await db.insertGame(game('1', title: 'Catan'));
      await db.insertGame(game('2', title: 'Ticket to Ride'));

      expect(await db.searchGames('catan'), hasLength(1));
      expect(await db.searchGames('CATAN'), hasLength(1));
      expect(await db.searchGames('ride'), hasLength(1));
      expect(await db.searchGames('nothing'), isEmpty);
    });

    test('searchGames sorts newest first', () async {
      await db.insertGame(game('1', title: 'Same', createdAt: 10));
      await db.insertGame(game('2', title: 'Same', createdAt: 20));

      final found = await db.searchGames('same');
      expect(found.map((g) => g['id']), ['2', '1']);
    });

    test('getGamesByCategory filters and sorts', () async {
      await db.insertGame(game('1', category: 'Euro', createdAt: 10));
      await db.insertGame(game('2', category: 'Party', createdAt: 20));
      await db.insertGame(game('3', category: 'Euro', createdAt: 30));

      final euro = await db.getGamesByCategory('Euro');
      expect(euro.map((g) => g['id']), ['3', '1']);
      expect(await db.getGamesByCategory('None'), isEmpty);
    });

    test('getDistinctCategories returns a sorted unique list', () async {
      await db.insertGame(game('1', category: 'Strategy'));
      await db.insertGame(game('2', category: 'Abstract'));
      await db.insertGame(game('3', category: 'Strategy'));

      expect(await db.getDistinctCategories(), ['Abstract', 'Strategy']);
    });

    test('getGameById finds a game', () async {
      await db.insertGame(game('42', title: 'Azul'));

      final found = await db.getGameById('42');
      expect(found, isNotNull);
      expect(found!['title'], 'Azul');
    });

    test('getGameById returns null for an unknown id', () async {
      expect(await db.getGameById('nope'), isNull);
    });

    test('updateGame merges fields and reports 1 row', () async {
      await db.insertGame(game('1', title: 'Old'));

      final changed = await db.updateGame('1', {'title': 'New'});

      expect(changed, 1);
      expect((await db.getGameById('1'))!['title'], 'New');
      // Untouched fields survive the merge.
      expect((await db.getGameById('1'))!['category'], 'Strategy');
    });

    test('updateGame returns 0 for an unknown id', () async {
      expect(await db.updateGame('nope', {'title': 'X'}), 0);
    });

    test('deleteGame removes the game and reports 1', () async {
      await db.insertGame(game('1'));

      expect(await db.deleteGame('1'), 1);
      expect(await db.getAllGames(), isEmpty);
    });

    test('deleteGame returns 0 when nothing matched', () async {
      await db.insertGame(game('1'));
      expect(await db.deleteGame('other'), 0);
      expect(await db.getAllGames(), hasLength(1));
    });
  });

  group('wishlist', () {
    test('insert and list newest first', () async {
      await db.insertWishlistItem({'id': 'w1', 'created_at': 100});
      await db.insertWishlistItem({'id': 'w2', 'created_at': 200});

      final all = await db.getAllWishlistItems();
      expect(all.map((w) => w['id']), ['w2', 'w1']);
    });

    test('insert returns the id', () async {
      expect(await db.insertWishlistItem({'id': 'w1'}), 'w1');
    });

    test('update merges fields', () async {
      await db.insertWishlistItem({'id': 'w1', 'title': 'Old', 'priority': 2});

      expect(await db.updateWishlistItem('w1', {'title': 'New'}), 1);
      final all = await db.getAllWishlistItems();
      expect(all.single['title'], 'New');
      expect(all.single['priority'], 2);
    });

    test('update returns 0 for an unknown id', () async {
      expect(await db.updateWishlistItem('nope', {'title': 'X'}), 0);
    });

    test('delete removes and reports 1', () async {
      await db.insertWishlistItem({'id': 'w1'});

      expect(await db.deleteWishlistItem('w1'), 1);
      expect(await db.getAllWishlistItems(), isEmpty);
    });

    test('delete returns 0 when nothing matched', () async {
      await db.insertWishlistItem({'id': 'w1'});
      expect(await db.deleteWishlistItem('other'), 0);
    });
  });

  group('players', () {
    test('insert and list newest first', () async {
      await db.insertPlayer({'id': 'p1', 'name': 'Ana', 'created_at': 10});
      await db.insertPlayer({'id': 'p2', 'name': 'Bia', 'created_at': 20});

      final all = await db.getAllPlayers();
      expect(all.map((p) => p['id']), ['p2', 'p1']);
    });

    test('insert returns the id', () async {
      expect(await db.insertPlayer({'id': 'p1'}), 'p1');
    });

    test('delete removes and reports 1', () async {
      await db.insertPlayer({'id': 'p1'});
      expect(await db.deletePlayer('p1'), 1);
      expect(await db.getAllPlayers(), isEmpty);
    });

    test('delete returns 0 when nothing matched', () async {
      expect(await db.deletePlayer('nope'), 0);
    });
  });

  group('export and import', () {
    test('exportAllData carries every collection plus metadata', () async {
      await db.insertGame(game('1'));
      await db.insertWishlistItem({'id': 'w1'});
      await db.insertPlayer({'id': 'p1'});

      final data = await db.exportAllData();

      expect(data['games'], hasLength(1));
      expect(data['wishlist'], hasLength(1));
      expect(data['players'], hasLength(1));
      expect(data['settings'], isEmpty);
      expect(data['version'], 1);
      expect(data['export_date'], isA<String>());
    });

    test('importAllData replaces the collections', () async {
      await db.insertGame(game('old'));

      await db.importAllData({
        'games': [game('new1'), game('new2')],
        'wishlist': [
          {'id': 'w1'},
        ],
        'players': [
          {'id': 'p1'},
        ],
      });

      final games = await db.getAllGames();
      expect(games.map((g) => g['id']), containsAll(['new1', 'new2']));
      expect(games.map((g) => g['id']), isNot(contains('old')));
      expect(await db.getAllWishlistItems(), hasLength(1));
      expect(await db.getAllPlayers(), hasLength(1));
    });

    test('importAllData ignores collections that are absent', () async {
      await db.insertGame(game('keep'));
      await db.insertWishlistItem({'id': 'keep-w'});

      await db.importAllData({
        'games': [game('replaced')],
      });

      expect(await db.getAllGames(), hasLength(1));
      expect(await db.getAllWishlistItems(), hasLength(1));
    });

    test('a round trip through export/import preserves the data', () async {
      await db.insertGame(game('1', title: 'Catan'));
      await db.insertWishlistItem({'id': 'w1'});
      await db.insertPlayer({'id': 'p1', 'name': 'Ana'});

      final backup = await db.exportAllData();
      SharedPreferences.setMockInitialValues({});
      final restored = WebDatabase();
      await restored.importAllData(backup);

      expect(await restored.getAllGames(), hasLength(1));
      expect((await restored.getGameById('1'))!['title'], 'Catan');
      expect(await restored.getAllWishlistItems(), hasLength(1));
      expect(await restored.getAllPlayers(), hasLength(1));
    });
  });

  group('persistence', () {
    test('writes games, wishlist and players to shared preferences', () async {
      await db.insertGame(game('1'));
      await db.insertWishlistItem({'id': 'w1'});
      await db.insertPlayer({'id': 'p1'});

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('games_data'), isNotNull);
      expect(prefs.getString('wishlist_data'), isNotNull);
      expect(prefs.getString('players_data'), isNotNull);
    });

    test('a fresh instance reloads what was persisted', () async {
      await db.insertGame(game('1', title: 'Catan'));
      await db.insertWishlistItem({'id': 'w1'});
      await db.insertPlayer({'id': 'p1'});

      final reopened = WebDatabase();
      expect(await reopened.getAllGames(), hasLength(1));
      expect(await reopened.getAllWishlistItems(), hasLength(1));
      expect(await reopened.getAllPlayers(), hasLength(1));
    });

    test('deletes are persisted too', () async {
      await db.insertGame(game('1'));
      await db.deleteGame('1');

      final reopened = WebDatabase();
      expect(await reopened.getAllGames(), isEmpty);
    });

    test('close flushes to preferences', () async {
      await db.insertGame(game('1'));
      await db.close();

      final reopened = WebDatabase();
      expect(await reopened.getAllGames(), hasLength(1));
    });

    test('starts empty when nothing was stored', () async {
      expect(await db.getAllGames(), isEmpty);
      expect(await db.getAllWishlistItems(), isEmpty);
      expect(await db.getAllPlayers(), isEmpty);
      expect(await db.getDistinctCategories(), isEmpty);
    });
  });

  test('getDatabasePath throws on the web', () async {
    await expectLater(db.getDatabasePath(), throwsException);
  });
}
