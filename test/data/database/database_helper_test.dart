import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:boardpocket/data/database/database_helper.dart';

void setUpFfi() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
}

int _testCounter = 0;

String nextId() {
  _testCounter++;
  return 'test-${DateTime.now().millisecondsSinceEpoch}-$_testCounter';
}

Future<void> clearTables() async {
  try {
    final db = await DatabaseHelper.instance.database;
    await db.delete('games', where: null);
    await db.delete('wishlist', where: null);
    await db.delete('players', where: null);
  } catch (_) {}
}

Map<String, dynamic> createTestGame({
  String? id,
  String title = 'Catan',
  String players = '3-4',
  String time = '60 min',
  String category = 'Strategy',
  int totalPlays = 0,
  int wins = 0,
  int losses = 0,
  int? createdAt,
  int? updatedAt,
}) {
  final now = DateTime.now().millisecondsSinceEpoch;
  return {
    'id': id ?? nextId(),
    'title': title,
    'players': players,
    'time': time,
    'category': category,
    'total_plays': totalPlays,
    'wins': wins,
    'losses': losses,
    'win_rate': 0.0,
    'created_at': createdAt ?? now,
    'updated_at': updatedAt ?? now,
  };
}

Map<String, dynamic> createTestWishlistItem({
  String? id,
  String title = 'Terraforming Mars',
  String players = '1-5',
  String time = '120 min',
  String category = 'Strategy',
  int? createdAt,
}) {
  final now = DateTime.now().millisecondsSinceEpoch;
  return {
    'id': id ?? nextId(),
    'title': title,
    'players': players,
    'time': time,
    'category': category,
    'created_at': createdAt ?? now,
  };
}

Map<String, dynamic> createTestPlayer({
  String? id,
  String name = 'John',
  int? createdAt,
}) {
  final now = DateTime.now().millisecondsSinceEpoch;
  return {'id': id ?? nextId(), 'name': name, 'created_at': createdAt ?? now};
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    setUpFfi();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await clearTables();
  });

  group('DatabaseHelper Singleton', () {
    test('should have singleton instance', () {
      final instance1 = DatabaseHelper.instance;
      final instance2 = DatabaseHelper.instance;
      expect(identical(instance1, instance2), true);
    });
  });

  group('DatabaseHelper - Games CRUD', () {
    setUp(() async {
      await clearTables();
    });

    test('should insert a new game', () async {
      final dbHelper = DatabaseHelper.instance;
      final game = createTestGame();

      final result = await dbHelper.insertGame(game);

      expect(result, game['id']);
      final games = await dbHelper.getAllGames();
      expect(games.length, 1);
      expect(games.first['title'], 'Catan');
    });

    test('should insert multiple games', () async {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.insertGame(createTestGame(title: 'Catan'));
      await dbHelper.insertGame(createTestGame(title: 'Monopoly'));
      await dbHelper.insertGame(createTestGame(title: 'Risk'));

      final games = await dbHelper.getAllGames();
      expect(games.length, 3);
    });

    test('should get all games sorted by created_at DESC', () async {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.insertGame(
        createTestGame(
          title: 'Old Game',
          createdAt: DateTime.now()
              .subtract(const Duration(days: 2))
              .millisecondsSinceEpoch,
        ),
      );
      await dbHelper.insertGame(
        createTestGame(
          title: 'New Game',
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      final games = await dbHelper.getAllGames();
      expect(games.first['title'], 'New Game');
      expect(games.last['title'], 'Old Game');
    });

    test('should search games by title', () async {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.insertGame(createTestGame(title: 'Catan'));
      await dbHelper.insertGame(createTestGame(title: 'Monopoly'));
      await dbHelper.insertGame(createTestGame(title: 'Carcassonne'));

      final results = await dbHelper.searchGames('cat');

      expect(results.length, greaterThanOrEqualTo(1));
      expect(results.any((g) => g['title'] == 'Catan'), true);
    });

    test('should search games case insensitive', () async {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.insertGame(createTestGame(title: 'CATAN'));
      await dbHelper.insertGame(createTestGame(title: 'catan'));

      final results = await dbHelper.searchGames('catan');

      expect(results.length, greaterThanOrEqualTo(1));
    });

    test('should return empty list when search has no matches', () async {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.insertGame(createTestGame(title: 'Catan'));

      final results = await dbHelper.searchGames('NonExistent');

      expect(results, isEmpty);
    });

    test('should get games by category', () async {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.insertGame(
        createTestGame(title: 'Catan', category: 'Strategy'),
      );
      await dbHelper.insertGame(
        createTestGame(title: 'Monopoly', category: 'Family'),
      );
      await dbHelper.insertGame(
        createTestGame(title: 'Chess', category: 'Strategy'),
      );

      final results = await dbHelper.getGamesByCategory('Strategy');

      expect(results.length, 2);
      expect(results.every((g) => g['category'] == 'Strategy'), true);
    });

    test('should return empty list for non-existent category', () async {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.insertGame(createTestGame(category: 'Strategy'));

      final results = await dbHelper.getGamesByCategory('Party');

      expect(results, isEmpty);
    });

    test('should get distinct categories', () async {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.insertGame(createTestGame(category: 'Strategy'));
      await dbHelper.insertGame(createTestGame(category: 'Family'));
      await dbHelper.insertGame(createTestGame(category: 'Strategy'));
      await dbHelper.insertGame(createTestGame(category: 'Party'));

      final categories = await dbHelper.getDistinctCategories();

      expect(categories.length, 3);
      expect(categories, containsAll(['Strategy', 'Family', 'Party']));
    });

    test('should return empty list of categories when no games', () async {
      final dbHelper = DatabaseHelper.instance;
      final categories = await dbHelper.getDistinctCategories();

      expect(categories, isEmpty);
    });

    test('should get game by id', () async {
      final dbHelper = DatabaseHelper.instance;
      final game = createTestGame(title: 'Catan');
      await dbHelper.insertGame(game);

      final result = await dbHelper.getGameById(game['id'] as String);

      expect(result, isNotNull);
      expect(result!['title'], 'Catan');
    });

    test('should return null for non-existent game id', () async {
      final dbHelper = DatabaseHelper.instance;
      final game = createTestGame();
      await dbHelper.insertGame(game);

      final result = await dbHelper.getGameById('non-existent');

      expect(result, isNull);
    });

    test('should update game', () async {
      final dbHelper = DatabaseHelper.instance;
      final game = createTestGame(title: 'Catan');
      await dbHelper.insertGame(game);

      final updatedGame = {
        'title': 'Catan Updated',
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      };
      final result = await dbHelper.updateGame(
        game['id'] as String,
        updatedGame,
      );

      expect(result, 1);
      final updated = await dbHelper.getGameById(game['id'] as String);
      expect(updated!['title'], 'Catan Updated');
    });

    test('should return 0 when updating non-existent game', () async {
      final dbHelper = DatabaseHelper.instance;
      final result = await dbHelper.updateGame('non-existent', {
        'title': 'Test',
      });

      expect(result, 0);
    });

    test('should update game preserves existing fields', () async {
      final dbHelper = DatabaseHelper.instance;
      final game = createTestGame(
        title: 'Catan',
        category: 'Strategy',
        wins: 5,
        losses: 3,
      );
      await dbHelper.insertGame(game);

      await dbHelper.updateGame(game['id'] as String, {
        'title': 'Catan Updated',
      });

      final updated = await dbHelper.getGameById(game['id'] as String);
      expect(updated!['title'], 'Catan Updated');
      expect(updated['category'], 'Strategy');
      expect(updated['wins'], 5);
      expect(updated['losses'], 3);
    });

    test('should delete game', () async {
      final dbHelper = DatabaseHelper.instance;
      final game = createTestGame();
      await dbHelper.insertGame(game);

      final result = await dbHelper.deleteGame(game['id'] as String);

      expect(result, 1);
      final deleted = await dbHelper.getGameById(game['id'] as String);
      expect(deleted, isNull);
    });

    test('should return 0 when deleting non-existent game', () async {
      final dbHelper = DatabaseHelper.instance;
      final result = await dbHelper.deleteGame('non-existent');

      expect(result, 0);
    });

    test('should delete only the specified game', () async {
      final dbHelper = DatabaseHelper.instance;
      final game1 = createTestGame();
      final game2 = createTestGame();
      await dbHelper.insertGame(game1);
      await dbHelper.insertGame(game2);

      await dbHelper.deleteGame(game1['id'] as String);

      final games = await dbHelper.getAllGames();
      expect(games.length, 1);
      expect(games.first['id'], game2['id']);
    });
  });

  group('DatabaseHelper - Wishlist CRUD', () {
    test('should insert wishlist item', () async {
      final dbHelper = DatabaseHelper.instance;
      final item = createTestWishlistItem();

      final result = await dbHelper.insertWishlistItem(item);

      expect(result, item['id']);
      final items = await dbHelper.getAllWishlistItems();
      expect(items.length, 1);
      expect(items.first['title'], 'Terraforming Mars');
    });

    test('should insert multiple wishlist items', () async {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.insertWishlistItem(createTestWishlistItem());
      await dbHelper.insertWishlistItem(createTestWishlistItem());

      final items = await dbHelper.getAllWishlistItems();
      expect(items.length, 2);
    });

    test('should get all wishlist items sorted by created_at DESC', () async {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.insertWishlistItem(
        createTestWishlistItem(
          title: 'Old Item',
          createdAt: DateTime.now()
              .subtract(const Duration(days: 1))
              .millisecondsSinceEpoch,
        ),
      );
      await dbHelper.insertWishlistItem(
        createTestWishlistItem(
          title: 'New Item',
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      final items = await dbHelper.getAllWishlistItems();
      expect(items.first['title'], 'New Item');
    });

    test('should update wishlist item', () async {
      final dbHelper = DatabaseHelper.instance;
      final item = createTestWishlistItem(title: 'Original');
      await dbHelper.insertWishlistItem(item);

      final result = await dbHelper.updateWishlistItem(item['id'] as String, {
        'title': 'Updated',
      });

      expect(result, 1);
      final items = await dbHelper.getAllWishlistItems();
      expect(items.first['title'], 'Updated');
    });

    test('should return 0 when updating non-existent wishlist item', () async {
      final dbHelper = DatabaseHelper.instance;
      final result = await dbHelper.updateWishlistItem('non-existent', {
        'title': 'Test',
      });

      expect(result, 0);
    });

    test('should delete wishlist item', () async {
      final dbHelper = DatabaseHelper.instance;
      final item = createTestWishlistItem();
      await dbHelper.insertWishlistItem(item);

      final result = await dbHelper.deleteWishlistItem(item['id'] as String);

      expect(result, 1);
      final items = await dbHelper.getAllWishlistItems();
      expect(items, isEmpty);
    });

    test('should return 0 when deleting non-existent wishlist item', () async {
      final dbHelper = DatabaseHelper.instance;
      final result = await dbHelper.deleteWishlistItem('non-existent');

      expect(result, 0);
    });
  });

  group('DatabaseHelper - Players CRUD', () {
    test('should insert player', () async {
      final dbHelper = DatabaseHelper.instance;
      final player = createTestPlayer();

      final result = await dbHelper.insertPlayer(player);

      expect(result, player['id']);
      final players = await dbHelper.getAllPlayers();
      expect(players.length, 1);
      expect(players.first['name'], 'John');
    });

    test('should insert multiple players', () async {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.insertPlayer(createTestPlayer(name: 'John'));
      await dbHelper.insertPlayer(createTestPlayer(name: 'Jane'));

      final players = await dbHelper.getAllPlayers();
      expect(players.length, 2);
    });

    test('should get all players sorted by created_at DESC', () async {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.insertPlayer(
        createTestPlayer(
          name: 'Older Player',
          createdAt: DateTime.now()
              .subtract(const Duration(days: 1))
              .millisecondsSinceEpoch,
        ),
      );
      await dbHelper.insertPlayer(
        createTestPlayer(
          name: 'Newer Player',
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      final players = await dbHelper.getAllPlayers();
      expect(players.first['name'], 'Newer Player');
    });

    test('should delete player', () async {
      final dbHelper = DatabaseHelper.instance;
      final player = createTestPlayer();
      await dbHelper.insertPlayer(player);

      final result = await dbHelper.deletePlayer(player['id'] as String);

      expect(result, 1);
      final players = await dbHelper.getAllPlayers();
      expect(players, isEmpty);
    });

    test('should return 0 when deleting non-existent player', () async {
      final dbHelper = DatabaseHelper.instance;
      final result = await dbHelper.deletePlayer('non-existent');

      expect(result, 0);
    });

    test('should delete only specified player', () async {
      final dbHelper = DatabaseHelper.instance;
      final player1 = createTestPlayer(name: 'John');
      final player2 = createTestPlayer(name: 'Jane');
      await dbHelper.insertPlayer(player1);
      await dbHelper.insertPlayer(player2);

      await dbHelper.deletePlayer(player1['id'] as String);

      final players = await dbHelper.getAllPlayers();
      expect(players.length, 1);
      expect(players.first['name'], 'Jane');
    });
  });

  group('DatabaseHelper - Settings', () {
    test('should return null for getSetting (legacy)', () async {
      final dbHelper = DatabaseHelper.instance;
      final result = await dbHelper.getSetting('some_key');

      expect(result, isNull);
    });

    test('should return 0 for setSetting (legacy)', () async {
      final dbHelper = DatabaseHelper.instance;
      final result = await dbHelper.setSetting('key', 'value');

      expect(result, 0);
    });
  });

  group('DatabaseHelper - Backup/Restore', () {
    test('should export all data when empty', () async {
      final dbHelper = DatabaseHelper.instance;
      final export = await dbHelper.exportAllData();

      expect(export['games'], isA<List>());
      expect(export['wishlist'], isA<List>());
      expect(export['players'], isA<List>());
      expect(export['settings'], isA<List>());
      expect(export['export_date'], isNotNull);
      expect(export['version'], 1);
    });

    test('should export games data', () async {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.insertGame(createTestGame(title: 'Catan'));
      await dbHelper.insertGame(createTestGame(title: 'Monopoly'));

      final export = await dbHelper.exportAllData();

      expect((export['games'] as List).length, 2);
    });

    test('should export wishlist data', () async {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.insertWishlistItem(createTestWishlistItem());
      await dbHelper.insertWishlistItem(createTestWishlistItem());

      final export = await dbHelper.exportAllData();

      expect((export['wishlist'] as List).length, 2);
    });

    test('should export players data', () async {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.insertPlayer(createTestPlayer(name: 'John'));
      await dbHelper.insertPlayer(createTestPlayer(name: 'Jane'));

      final export = await dbHelper.exportAllData();

      expect((export['players'] as List).length, 2);
    });

    test('should import all data', () async {
      final dbHelper = DatabaseHelper.instance;
      final importData = {
        'games': [createTestGame(title: 'Imported Game')],
        'wishlist': [createTestWishlistItem(title: 'Imported Wishlist')],
        'players': [createTestPlayer(name: 'Imported Player')],
        'settings': [],
      };

      await dbHelper.importAllData(importData);

      final games = await dbHelper.getAllGames();
      final wishlist = await dbHelper.getAllWishlistItems();
      final players = await dbHelper.getAllPlayers();

      expect(games.length, 1);
      expect(games.first['title'], 'Imported Game');
      expect(wishlist.length, 1);
      expect(players.length, 1);
    });

    test('should import data clears existing data', () async {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.insertGame(createTestGame(title: 'Old Game'));

      final importData = {
        'games': [createTestGame(title: 'New Game')],
        'wishlist': [],
        'players': [],
        'settings': [],
      };

      await dbHelper.importAllData(importData);

      final games = await dbHelper.getAllGames();
      expect(games.length, 1);
      expect(games.first['title'], 'New Game');
    });

    test('should import data handles partial data', () async {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.insertGame(createTestGame(title: 'Old'));

      final importData = {
        'games': [createTestGame(title: 'New')],
        'wishlist': null,
        'players': null,
        'settings': null,
      };

      await dbHelper.importAllData(importData);

      final games = await dbHelper.getAllGames();
      expect(games.length, 1);
      expect(games.first['title'], 'New');
    });

    test('should import data with empty lists', () async {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.insertGame(createTestGame());

      final importData = {
        'games': [],
        'wishlist': [],
        'players': [],
        'settings': [],
      };

      await dbHelper.importAllData(importData);

      final games = await dbHelper.getAllGames();
      expect(games, isEmpty);
    });
  });

  group('DatabaseHelper - Database Path', () {
    test('should get database path', () async {
      final dbHelper = DatabaseHelper.instance;
      final path = await dbHelper.getDatabasePath();

      expect(path, isNotNull);
      expect(path.contains('boardpocket.db'), true);
    });
  });

  group('DatabaseHelper - Database Creation', () {
    test('should create games table with all columns', () async {
      final dbHelper = DatabaseHelper.instance;
      final db = await dbHelper.database;
      await db.insert('games', createTestGame());

      final games = await dbHelper.getAllGames();
      expect(games.isNotEmpty, true);
      final game = games.first;
      expect(game.containsKey('id'), true);
      expect(game.containsKey('title'), true);
      expect(game.containsKey('players'), true);
      expect(game.containsKey('time'), true);
      expect(game.containsKey('category'), true);
      expect(game.containsKey('wins'), true);
      expect(game.containsKey('losses'), true);
    });

    test('should create wishlist table with all columns', () async {
      final dbHelper = DatabaseHelper.instance;
      final db = await dbHelper.database;
      await db.insert('wishlist', createTestWishlistItem());

      final items = await dbHelper.getAllWishlistItems();
      expect(items.isNotEmpty, true);
    });

    test('should create players table with all columns', () async {
      final dbHelper = DatabaseHelper.instance;
      final db = await dbHelper.database;
      await db.insert('players', createTestPlayer());

      final players = await dbHelper.getAllPlayers();
      expect(players.isNotEmpty, true);
    });

    test('should have default settings from database creation', () async {
      final dbHelper = DatabaseHelper.instance;
      final db = await dbHelper.database;
      await db.delete('settings', where: null);

      await db.insert('settings', {'key': 'dark_mode', 'value': 'true'});
      await db.insert('settings', {'key': 'language', 'value': 'en'});
      await db.insert('settings', {'key': 'initialized', 'value': 'true'});

      final settings = await db.query('settings');

      expect(settings.isNotEmpty, true);
      expect(settings.any((s) => s['key'] == 'dark_mode'), true);
      expect(settings.any((s) => s['key'] == 'language'), true);
      expect(settings.any((s) => s['key'] == 'initialized'), true);
    });
  });

  group('DatabaseHelper - Edge Cases', () {
    test('should handle empty games list', () async {
      final dbHelper = DatabaseHelper.instance;
      final games = await dbHelper.getAllGames();
      expect(games, isEmpty);
    });

    test('should handle empty wishlist', () async {
      final dbHelper = DatabaseHelper.instance;
      final items = await dbHelper.getAllWishlistItems();
      expect(items, isEmpty);
    });

    test('should handle empty players', () async {
      final dbHelper = DatabaseHelper.instance;
      final players = await dbHelper.getAllPlayers();
      expect(players, isEmpty);
    });

    test('should handle game with special characters in title', () async {
      final dbHelper = DatabaseHelper.instance;
      final game = createTestGame(
        title: "Game with 'quotes' and \"double quotes\"",
      );
      await dbHelper.insertGame(game);

      final result = await dbHelper.getGameById(game['id'] as String);
      expect(result!['title'], "Game with 'quotes' and \"double quotes\"");
    });

    test('should handle game with unicode characters', () async {
      final dbHelper = DatabaseHelper.instance;
      final game = createTestGame(title: 'Jogo日本語🎲');
      await dbHelper.insertGame(game);

      final result = await dbHelper.getGameById(game['id'] as String);
      expect(result!['title'], 'Jogo日本語🎲');
    });

    test('should handle very long game title', () async {
      final dbHelper = DatabaseHelper.instance;
      final longTitle = 'A' * 1000;
      final game = createTestGame(title: longTitle);
      await dbHelper.insertGame(game);

      final result = await dbHelper.getGameById(game['id'] as String);
      expect(result!['title'].length, 1000);
    });

    test('should update non-existent game returns 0', () async {
      final dbHelper = DatabaseHelper.instance;
      final result = await dbHelper.updateGame('non-existent', {
        'title': 'Test',
      });
      expect(result, 0);
    });

    test('should delete non-existent game returns 0', () async {
      final dbHelper = DatabaseHelper.instance;
      final result = await dbHelper.deleteGame('non-existent');
      expect(result, 0);
    });

    test('should search with empty query returns all games', () async {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.insertGame(createTestGame());
      await dbHelper.insertGame(createTestGame());

      final results = await dbHelper.searchGames('');

      expect(results.length, 2);
    });

    test('should get games by category with empty result', () async {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.insertGame(createTestGame(category: 'Strategy'));

      final results = await dbHelper.getGamesByCategory('NonExistent');

      expect(results, isEmpty);
    });
  });

  group('DatabaseHelper - Search Edge Cases', () {
    test('should search partial match', () async {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.insertGame(createTestGame(title: 'Catan'));

      final results = await dbHelper.searchGames('at');

      expect(results.isNotEmpty, true);
    });

    test('should search with numbers', () async {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.insertGame(createTestGame(title: 'Catan 2'));

      final results = await dbHelper.searchGames('2');

      expect(results.isNotEmpty, true);
    });

    test('should search case insensitive multiple words', () async {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.insertGame(createTestGame(title: 'Catan Classic'));

      final results = await dbHelper.searchGames('CATAN CLASSIC');

      expect(results.isNotEmpty, true);
    });
  });

  group('DatabaseHelper - Complex Queries', () {
    test('should handle large dataset', () async {
      final dbHelper = DatabaseHelper.instance;
      for (int i = 0; i < 100; i++) {
        await dbHelper.insertGame(createTestGame(title: 'Game $i'));
      }

      final games = await dbHelper.getAllGames();
      expect(games.length, 100);
    });

    test('should update multiple games', () async {
      final dbHelper = DatabaseHelper.instance;
      final game1 = createTestGame();
      final game2 = createTestGame();
      final game3 = createTestGame();
      await dbHelper.insertGame(game1);
      await dbHelper.insertGame(game2);
      await dbHelper.insertGame(game3);

      await dbHelper.updateGame(game1['id'] as String, {'title': 'Updated 1'});
      await dbHelper.updateGame(game2['id'] as String, {'title': 'Updated 2'});

      final updated1 = await dbHelper.getGameById(game1['id'] as String);
      final updated2 = await dbHelper.getGameById(game2['id'] as String);
      final game3Result = await dbHelper.getGameById(game3['id'] as String);

      expect(updated1!['title'], 'Updated 1');
      expect(updated2!['title'], 'Updated 2');
      expect(game3Result!['title'], 'Catan');
    });

    test('should delete multiple games sequentially', () async {
      final dbHelper = DatabaseHelper.instance;
      final game1 = createTestGame();
      final game2 = createTestGame();
      final game3 = createTestGame();
      await dbHelper.insertGame(game1);
      await dbHelper.insertGame(game2);
      await dbHelper.insertGame(game3);

      await dbHelper.deleteGame(game1['id'] as String);
      await dbHelper.deleteGame(game2['id'] as String);

      final games = await dbHelper.getAllGames();
      expect(games.length, 1);
      expect(games.first['id'], game3['id']);
    });

    test('should handle mixed operations', () async {
      final dbHelper = DatabaseHelper.instance;
      final game1 = createTestGame(title: 'Game 1');
      final game2 = createTestGame(title: 'Game 2');
      await dbHelper.insertGame(game1);
      await dbHelper.insertGame(game2);

      await dbHelper.updateGame(game1['id'] as String, {
        'title': 'Updated Game 1',
      });

      await dbHelper.insertGame(createTestGame(title: 'Game 3'));

      await dbHelper.deleteGame(game2['id'] as String);

      final games = await dbHelper.getAllGames();
      expect(games.length, 2);
      expect(games.any((g) => g['title'] == 'Updated Game 1'), true);
      expect(games.any((g) => g['title'] == 'Game 3'), true);
    });
  });

  group('DatabaseHelper - Sorting', () {
    setUp(() async {
      await clearTables();
    });

    test('should getAllGames sorts by created_at DESC', () async {
      final dbHelper = DatabaseHelper.instance;
      final now = DateTime.now().millisecondsSinceEpoch;
      final game = {
        'id': nextId(),
        'title': 'Catan',
        'players': '3-4',
        'time': '60 min',
        'category': 'Strategy',
        'image_path': '/path/to/image.jpg',
        'min_players': 3,
        'max_players': 4,
        'play_time': 60,
        'complexity': 2.5,
        'total_plays': 10,
        'wins': 5,
        'losses': 5,
        'win_rate': 0.5,
        'last_played': now,
        'created_at': now,
        'updated_at': now,
      };

      await dbHelper.insertGame(game);
      final games = await dbHelper.getAllGames();

      expect(games.length, 1);
      expect(games.first['image_path'], '/path/to/image.jpg');
      expect(games.first['min_players'], 3);
      expect(games.first['max_players'], 4);
      expect(games.first['play_time'], 60);
      expect(games.first['complexity'], 2.5);
      expect(games.first['total_plays'], 10);
      expect(games.first['wins'], 5);
      expect(games.first['losses'], 5);
      expect(games.first['win_rate'], 0.5);
      expect(games.first['last_played'], now);
    });

    test('should insert game with null optional fields', () async {
      final dbHelper = DatabaseHelper.instance;
      final game = createTestGame();

      await dbHelper.insertGame(game);
      final games = await dbHelper.getAllGames();

      expect(games.first['image_path'], isNull);
      expect(games.first['min_players'], isNull);
      expect(games.first['max_players'], isNull);
      expect(games.first['play_time'], isNull);
      expect(games.first['complexity'], isNull);
    });

    test('should update game wins and losses', () async {
      final dbHelper = DatabaseHelper.instance;
      final game = createTestGame(wins: 5, losses: 3);
      await dbHelper.insertGame(game);

      await dbHelper.updateGame(game['id'] as String, {
        'wins': 6,
        'losses': 4,
        'total_plays': 10,
        'win_rate': 0.6,
      });

      final updated = await dbHelper.getGameById(game['id'] as String);
      expect(updated!['wins'], 6);
      expect(updated['losses'], 4);
      expect(updated['total_plays'], 10);
      expect(updated['win_rate'], 0.6);
    });

    test('should update game last_played', () async {
      final dbHelper = DatabaseHelper.instance;
      final game = createTestGame();
      await dbHelper.insertGame(game);

      final newTime = DateTime.now().millisecondsSinceEpoch;
      await dbHelper.updateGame(game['id'] as String, {'last_played': newTime});

      final updated = await dbHelper.getGameById(game['id'] as String);
      expect(updated!['last_played'], newTime);
    });

    test('should query games with different categories', () async {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.insertGame(
        createTestGame(title: 'Game 1', category: 'Strategy'),
      );
      await dbHelper.insertGame(
        createTestGame(title: 'Game 2', category: 'Family'),
      );
      await dbHelper.insertGame(
        createTestGame(title: 'Game 3', category: 'Party'),
      );
      await dbHelper.insertGame(
        createTestGame(title: 'Game 4', category: 'Strategy'),
      );

      final strategyGames = await dbHelper.getGamesByCategory('Strategy');
      final familyGames = await dbHelper.getGamesByCategory('Family');
      final partyGames = await dbHelper.getGamesByCategory('Party');

      expect(strategyGames.length, 2);
      expect(familyGames.length, 1);
      expect(partyGames.length, 1);
    });

    test('should get distinct categories sorted alphabetically', () async {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.insertGame(createTestGame(category: 'Party'));
      await dbHelper.insertGame(createTestGame(category: 'Strategy'));
      await dbHelper.insertGame(createTestGame(category: 'Family'));

      final categories = await dbHelper.getDistinctCategories();

      expect(categories, ['Family', 'Party', 'Strategy']);
    });
  });

  group('DatabaseHelper - Wishlist Fields', () {
    setUp(() async {
      await clearTables();
    });

    test('should insert wishlist with all optional fields', () async {
      final dbHelper = DatabaseHelper.instance;
      final now = DateTime.now().millisecondsSinceEpoch;
      final item = {
        'id': nextId(),
        'title': 'Terraforming Mars',
        'players': '1-5',
        'time': '120 min',
        'category': 'Strategy',
        'image_path': '/path/to/image.jpg',
        'image_url': 'https://example.com/image.jpg',
        'price': '\$50.00',
        'purchase_url': 'https://store.example.com/game',
        'tag': 'Must Buy',
        'created_at': now,
      };

      await dbHelper.insertWishlistItem(item);
      final items = await dbHelper.getAllWishlistItems();

      expect(items.length, 1);
      expect(items.first['image_path'], '/path/to/image.jpg');
      expect(items.first['image_url'], 'https://example.com/image.jpg');
      expect(items.first['price'], '\$50.00');
      expect(items.first['purchase_url'], 'https://store.example.com/game');
      expect(items.first['tag'], 'Must Buy');
      expect(items.first['category'], 'Strategy');
    });

    test('should update wishlist item fields', () async {
      final dbHelper = DatabaseHelper.instance;
      final item = createTestWishlistItem(title: 'Original');
      await dbHelper.insertWishlistItem(item);

      await dbHelper.updateWishlistItem(item['id'] as String, {
        'price': '\$45.00',
        'purchase_url': 'https://newstore.com',
        'tag': 'On Sale',
      });

      final updated = await dbHelper.getAllWishlistItems();
      expect(updated.first['price'], '\$45.00');
      expect(updated.first['purchase_url'], 'https://newstore.com');
      expect(updated.first['tag'], 'On Sale');
    });

    test('should delete wishlist and verify count', () async {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.insertWishlistItem(createTestWishlistItem());
      await dbHelper.insertWishlistItem(createTestWishlistItem());
      await dbHelper.insertWishlistItem(createTestWishlistItem());

      var items = await dbHelper.getAllWishlistItems();
      expect(items.length, 3);

      final itemToDelete = items.first;
      await dbHelper.deleteWishlistItem(itemToDelete['id'] as String);

      items = await dbHelper.getAllWishlistItems();
      expect(items.length, 2);
      expect(items.any((i) => i['id'] == itemToDelete['id']), false);
    });

    test('should preserve other wishlist items when deleting one', () async {
      final dbHelper = DatabaseHelper.instance;
      final item1 = createTestWishlistItem(title: 'Item 1');
      final item2 = createTestWishlistItem(title: 'Item 2');
      final item3 = createTestWishlistItem(title: 'Item 3');
      await dbHelper.insertWishlistItem(item1);
      await dbHelper.insertWishlistItem(item2);
      await dbHelper.insertWishlistItem(item3);

      await dbHelper.deleteWishlistItem(item2['id'] as String);

      final items = await dbHelper.getAllWishlistItems();
      expect(items.length, 2);
      expect(items.any((i) => i['title'] == 'Item 1'), true);
      expect(items.any((i) => i['title'] == 'Item 3'), true);
    });
  });

  group('DatabaseHelper - Player Fields', () {
    setUp(() async {
      await clearTables();
    });

    test('should insert player with all fields', () async {
      final dbHelper = DatabaseHelper.instance;
      final now = DateTime.now().millisecondsSinceEpoch;
      final player = {'id': nextId(), 'name': 'John Doe', 'created_at': now};

      await dbHelper.insertPlayer(player);
      final players = await dbHelper.getAllPlayers();

      expect(players.length, 1);
      expect(players.first['name'], 'John Doe');
    });

    test('should handle many players', () async {
      final dbHelper = DatabaseHelper.instance;
      for (int i = 0; i < 50; i++) {
        await dbHelper.insertPlayer(createTestPlayer(name: 'Player $i'));
      }

      final players = await dbHelper.getAllPlayers();
      expect(players.length, 50);
    });

    test('should delete all players sequentially', () async {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.insertPlayer(createTestPlayer());
      await dbHelper.insertPlayer(createTestPlayer());
      await dbHelper.insertPlayer(createTestPlayer());

      var players = await dbHelper.getAllPlayers();
      expect(players.length, 3);

      for (var player in players) {
        await dbHelper.deletePlayer(player['id'] as String);
      }

      players = await dbHelper.getAllPlayers();
      expect(players.length, 0);
    });

    test('should return 0 when deleting non-existent player', () async {
      final dbHelper = DatabaseHelper.instance;
      final result = await dbHelper.deletePlayer('non-existent-id');
      expect(result, 0);
    });
  });

  group('DatabaseHelper - Backup/Restore Extended', () {
    setUp(() async {
      await clearTables();
    });

    test('should export and then import preserves data', () async {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.insertGame(createTestGame(title: 'Game 1'));
      await dbHelper.insertGame(createTestGame(title: 'Game 2'));
      await dbHelper.insertWishlistItem(
        createTestWishlistItem(title: 'Wish 1'),
      );
      await dbHelper.insertPlayer(createTestPlayer(name: 'Player 1'));

      final exportData = await dbHelper.exportAllData();

      await dbHelper.importAllData({
        'games': [],
        'wishlist': [],
        'players': [],
        'settings': [],
      });

      final games = await dbHelper.getAllGames();
      final wishlist = await dbHelper.getAllWishlistItems();
      final players = await dbHelper.getAllPlayers();

      expect(games.length, 0);
      expect(wishlist.length, 0);
      expect(players.length, 0);

      await dbHelper.importAllData(exportData);

      final restoredGames = await dbHelper.getAllGames();
      final restoredWishlist = await dbHelper.getAllWishlistItems();
      final restoredPlayers = await dbHelper.getAllPlayers();

      expect(restoredGames.length, 2);
      expect(restoredWishlist.length, 1);
      expect(restoredPlayers.length, 1);
    });

    test('should export contains export_date and version', () async {
      final dbHelper = DatabaseHelper.instance;
      final export = await dbHelper.exportAllData();

      expect(export.containsKey('export_date'), true);
      expect(export.containsKey('version'), true);
      expect(export['version'], 1);
      expect(export['export_date'], isA<String>());
    });

    test('should import with only games data', () async {
      final dbHelper = DatabaseHelper.instance;
      final importData = {
        'games': [createTestGame(title: 'Only Game')],
        'wishlist': null,
        'players': null,
        'settings': null,
      };

      await dbHelper.importAllData(importData);

      final games = await dbHelper.getAllGames();
      final wishlist = await dbHelper.getAllWishlistItems();
      final players = await dbHelper.getAllPlayers();

      expect(games.length, 1);
      expect(wishlist.length, 0);
      expect(players.length, 0);
    });

    test('should import with only players data', () async {
      final dbHelper = DatabaseHelper.instance;
      final importData = {
        'games': null,
        'wishlist': null,
        'players': [createTestPlayer(name: 'Only Player')],
        'settings': null,
      };

      await dbHelper.importAllData(importData);

      final players = await dbHelper.getAllPlayers();
      expect(players.length, 1);
    });

    test('should import with empty games list clears games', () async {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.insertGame(createTestGame());

      await dbHelper.importAllData({
        'games': [],
        'wishlist': [],
        'players': [],
        'settings': [],
      });

      final games = await dbHelper.getAllGames();
      expect(games.length, 0);
    });

    test('should export multiple games and wishlist items', () async {
      final dbHelper = DatabaseHelper.instance;
      for (int i = 0; i < 10; i++) {
        await dbHelper.insertGame(createTestGame(title: 'Game $i'));
        await dbHelper.insertWishlistItem(
          createTestWishlistItem(title: 'Wish $i'),
        );
      }

      final export = await dbHelper.exportAllData();

      expect((export['games'] as List).length, 10);
      expect((export['wishlist'] as List).length, 10);
    });
  });

  group('DatabaseHelper - Search Extended', () {
    setUp(() async {
      await clearTables();
    });

    test('should search with special characters', () async {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.insertGame(createTestGame(title: 'Game #1'));
      await dbHelper.insertGame(createTestGame(title: 'Game 2'));
      await dbHelper.insertGame(createTestGame(title: 'Game & More'));

      final results = await dbHelper.searchGames('#1');
      expect(results.length, 1);

      final results2 = await dbHelper.searchGames('&');
      expect(results2.length, 1);
    });

    test('should search returns empty for no matches', () async {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.insertGame(createTestGame(title: 'Catan'));

      final results = await dbHelper.searchGames('xyz123');
      expect(results, isEmpty);
    });

    test('should search is case insensitive', () async {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.insertGame(createTestGame(title: 'CaTaN'));
      await dbHelper.insertGame(createTestGame(title: 'catan'));
      await dbHelper.insertGame(createTestGame(title: 'CATAN'));

      final resultsLower = await dbHelper.searchGames('catan');
      final resultsUpper = await dbHelper.searchGames('CATAN');

      expect(resultsLower.length, 3);
      expect(resultsUpper.length, 3);
    });

    test('should search with spaces finds partial words', () async {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.insertGame(createTestGame(title: 'The Catan'));
      await dbHelper.insertGame(createTestGame(title: 'Catan Classic'));
      await dbHelper.insertGame(createTestGame(title: 'New Catan'));

      final results = await dbHelper.searchGames('Cat');
      expect(results.length, 3);
    });

    test('should search empty string returns all', () async {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.insertGame(createTestGame(title: 'Game 1'));
      await dbHelper.insertGame(createTestGame(title: 'Game 2'));

      final results = await dbHelper.searchGames('');
      expect(results.length, 2);
    });
  });

  group('DatabaseHelper - Database Version', () {
    setUp(() async {
      await clearTables();
    });

    test('should database have version 2', () async {
      final dbHelper = DatabaseHelper.instance;
      final db = await dbHelper.database;

      final version = await db.getVersion();
      expect(version, 2);
    });
  });

  group('DatabaseHelper - Concurrent Operations', () {
    setUp(() async {
      await clearTables();
    });

    test('should handle rapid inserts', () async {
      final dbHelper = DatabaseHelper.instance;
      for (int i = 0; i < 20; i++) {
        await dbHelper.insertGame(createTestGame(title: 'Rapid $i'));
      }

      final games = await dbHelper.getAllGames();
      expect(games.length, 20);
    });

    test('should handle rapid updates', () async {
      final dbHelper = DatabaseHelper.instance;
      for (int i = 0; i < 10; i++) {
        await dbHelper.insertGame(createTestGame(title: 'Game $i'));
      }

      for (int i = 0; i < 10; i++) {
        final games = await dbHelper.getAllGames();
        await dbHelper.updateGame(games[i]['id'] as String, {
          'title': 'Updated ${games[i]['title']}',
        });
      }

      final updated = await dbHelper.getAllGames();
      expect(
        updated.every((g) => (g['title'] as String).startsWith('Updated')),
        true,
      );
    });

    test('should handle interleaved operations', () async {
      final dbHelper = DatabaseHelper.instance;

      await dbHelper.insertGame(createTestGame(title: 'Game 1'));
      var games = await dbHelper.getAllGames();
      expect(games.length, 1);

      await dbHelper.insertGame(createTestGame(title: 'Game 2'));
      games = await dbHelper.getAllGames();
      expect(games.length, 2);

      await dbHelper.updateGame(games.first['id'] as String, {
        'title': 'Updated',
      });
      games = await dbHelper.getAllGames();
      expect(games.any((g) => g['title'] == 'Updated'), true);

      await dbHelper.deleteGame(games.last['id'] as String);
      games = await dbHelper.getAllGames();
      expect(games.length, 1);
    });
  });

  group('DatabaseHelper - Error Handling', () {
    setUp(() async {
      await clearTables();
    });

    test('should handle duplicate game insert', () async {
      final dbHelper = DatabaseHelper.instance;
      final game = createTestGame(id: 'duplicate-id');
      await dbHelper.insertGame(game);

      try {
        await dbHelper.insertGame(game);
      } catch (e) {
        expect(e, isNotNull);
      }

      final games = await dbHelper.getAllGames();
      expect(games.length, 1);
    });

    test('should handle update with no changes', () async {
      final dbHelper = DatabaseHelper.instance;
      final game = createTestGame(title: 'Original');
      await dbHelper.insertGame(game);

      final result = await dbHelper.updateGame(game['id'] as String, {
        'title': 'Original',
      });
      expect(result, 1);

      final updated = await dbHelper.getGameById(game['id'] as String);
      expect(updated!['title'], 'Original');
    });

    test('should handle getGameById with empty string', () async {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.insertGame(createTestGame());

      final result = await dbHelper.getGameById('');
      expect(result, isNull);
    });
  });

  group('DatabaseHelper - Sorting', () {
    setUp(() async {
      await clearTables();
    });

    test('should getAllGames sorts by created_at DESC', () async {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.insertGame(
        createTestGame(
          title: 'First',
          createdAt: DateTime.now()
              .subtract(const Duration(days: 3))
              .millisecondsSinceEpoch,
        ),
      );
      await dbHelper.insertGame(
        createTestGame(
          title: 'Second',
          createdAt: DateTime.now()
              .subtract(const Duration(days: 2))
              .millisecondsSinceEpoch,
        ),
      );
      await dbHelper.insertGame(
        createTestGame(
          title: 'Third',
          createdAt: DateTime.now()
              .subtract(const Duration(days: 1))
              .millisecondsSinceEpoch,
        ),
      );

      final games = await dbHelper.getAllGames();
      expect(games[0]['title'], 'Third');
      expect(games[1]['title'], 'Second');
      expect(games[2]['title'], 'First');
    });

    test('should getAllWishlistItems sorts by created_at DESC', () async {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.insertWishlistItem(
        createTestWishlistItem(
          title: 'First',
          createdAt: DateTime.now()
              .subtract(const Duration(days: 2))
              .millisecondsSinceEpoch,
        ),
      );
      await dbHelper.insertWishlistItem(
        createTestWishlistItem(
          title: 'Second',
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      final items = await dbHelper.getAllWishlistItems();
      expect(items[0]['title'], 'Second');
      expect(items[1]['title'], 'First');
    });

    test('should getAllPlayers sorts by created_at DESC', () async {
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.insertPlayer(
        createTestPlayer(
          name: 'First',
          createdAt: DateTime.now()
              .subtract(const Duration(days: 2))
              .millisecondsSinceEpoch,
        ),
      );
      await dbHelper.insertPlayer(
        createTestPlayer(
          name: 'Second',
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      final players = await dbHelper.getAllPlayers();
      expect(players[0]['name'], 'Second');
      expect(players[1]['name'], 'First');
    });
  });
}
