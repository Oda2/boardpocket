import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/data/repositories/game_repository.dart';
import 'package:boardpocket/data/database/database_helper.dart';
import 'package:boardpocket/data/models/game.dart';
import 'package:sqflite/sqflite.dart';

class MockDatabaseHelper implements DatabaseHelper {
  final List<Map<String, dynamic>> _games = [];

  @override
  Future<void> init() async {}

  @override
  Future<Database> get database async => throw UnimplementedError();

  @override
  Future<String> insertGame(Map<String, dynamic> game) async {
    _games.add(game);
    return '1';
  }

  @override
  Future<List<Map<String, dynamic>>> getAllGames() async {
    return List.from(_games);
  }

  @override
  Future<List<Map<String, dynamic>>> searchGames(String query) async {
    return _games
        .where(
          (g) => (g['title'] as String).toLowerCase().contains(
            query.toLowerCase(),
          ),
        )
        .toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getGamesByCategory(String category) async {
    return _games.where((g) => g['category'] == category).toList();
  }

  @override
  Future<List<String>> getDistinctCategories() async {
    return _games.map((g) => g['category'] as String).toSet().toList();
  }

  @override
  Future<Map<String, dynamic>?> getGameById(String id) async {
    try {
      return _games.firstWhere((g) => g['id'] == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int> updateGame(String id, Map<String, dynamic> game) async {
    final index = _games.indexWhere((g) => g['id'] == id);
    if (index >= 0) {
      _games[index] = game;
      return 1;
    }
    return 0;
  }

  @override
  Future<int> deleteGame(String id) async {
    final initialLength = _games.length;
    _games.removeWhere((g) => g['id'] == id);
    return initialLength - _games.length;
  }

  @override
  Future<String> insertWishlistItem(Map<String, dynamic> item) async => '1';

  @override
  Future<List<Map<String, dynamic>>> getAllWishlistItems() async => [];

  @override
  Future<int> updateWishlistItem(String id, Map<String, dynamic> item) async =>
      1;

  @override
  Future<int> deleteWishlistItem(String id) async => 1;

  @override
  Future<String> insertPlayer(Map<String, dynamic> player) async => '1';

  @override
  Future<List<Map<String, dynamic>>> getAllPlayers() async => [];

  @override
  Future<int> deletePlayer(String id) async => 1;

  @override
  Future<String> getDatabasePath() async => '';

  @override
  Future<Map<String, dynamic>> exportData() async => {};

  @override
  Future<void> importData(Map<String, dynamic> data) async {}

  @override
  Future<int> getDatabaseVersion() async => 2;

  @override
  DatabaseHelper get instance => this;

  @override
  Future<void> close() async {}

  @override
  Future<Map<String, dynamic>> exportAllData() async => {};

  @override
  Future<void> importAllData(Map<String, dynamic> data) async {}

  @override
  Future<String?> getSetting(String key) async => null;

  @override
  Future<int> setSetting(String key, String value) async => 1;
}

void main() {
  late GameRepository repository;
  late MockDatabaseHelper mockDb;

  setUp(() {
    mockDb = MockDatabaseHelper();
    repository = GameRepository(databaseHelper: mockDb);
  });

  group('GameRepository', () {
    test('create should insert game and return it', () async {
      final game = Game(
        id: '1',
        title: 'Chess',
        players: '2',
        time: '60m',
        category: 'Strategy',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await repository.create(game);

      expect(result.id, equals('1'));
      expect(result.title, equals('Chess'));
    });

    test('getAll should return all games', () async {
      final game1 = Game(
        id: '1',
        title: 'Chess',
        players: '2',
        time: '60m',
        category: 'Strategy',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final game2 = Game(
        id: '2',
        title: 'Uno',
        players: '4',
        time: '30m',
        category: 'Party',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.create(game1);
      await repository.create(game2);

      final games = await repository.getAll();

      expect(games.length, equals(2));
    });

    test('getById should return game by id', () async {
      final game = Game(
        id: 'test-id',
        title: 'Chess',
        players: '2',
        time: '60m',
        category: 'Strategy',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.create(game);

      final result = await repository.getById('test-id');

      expect(result, isNotNull);
      expect(result!.id, equals('test-id'));
    });

    test('getById should return null for non-existent id', () async {
      final result = await repository.getById('non-existent');

      expect(result, isNull);
    });

    test('update should modify existing game', () async {
      final game = Game(
        id: '1',
        title: 'Chess',
        players: '2',
        time: '60m',
        category: 'Strategy',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.create(game);

      final updatedGame = game.copyWith(title: 'Updated Chess');
      await repository.update(updatedGame);

      final result = await repository.getById('1');
      expect(result!.title, equals('Updated Chess'));
    });

    test('delete should remove game', () async {
      final game = Game(
        id: '1',
        title: 'Chess',
        players: '2',
        time: '60m',
        category: 'Strategy',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.create(game);
      expect((await repository.getAll()).length, equals(1));

      await repository.delete('1');

      expect((await repository.getAll()).length, equals(0));
    });

    test('search should filter games by title', () async {
      await repository.create(
        Game(
          id: '1',
          title: 'Chess',
          players: '2',
          time: '60m',
          category: 'Strategy',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      await repository.create(
        Game(
          id: '2',
          title: 'Checkers',
          players: '2',
          time: '30m',
          category: 'Strategy',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      final results = await repository.search('chess');

      expect(results.length, equals(1));
      expect(results.first.title, equals('Chess'));
    });

    test('search should be case insensitive', () async {
      await repository.create(
        Game(
          id: '1',
          title: 'Chess',
          players: '2',
          time: '60m',
          category: 'Strategy',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      final results = await repository.search('CHESS');

      expect(results.length, equals(1));
    });

    test('getByCategory should filter games by category', () async {
      await repository.create(
        Game(
          id: '1',
          title: 'Chess',
          players: '2',
          time: '60m',
          category: 'Strategy',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      await repository.create(
        Game(
          id: '2',
          title: 'Uno',
          players: '4',
          time: '30m',
          category: 'Party',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      final results = await repository.getByCategory('Strategy');

      expect(results.length, equals(1));
      expect(results.first.title, equals('Chess'));
    });

    test('getCategories should return unique categories', () async {
      await repository.create(
        Game(
          id: '1',
          title: 'Chess',
          players: '2',
          time: '60m',
          category: 'Strategy',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      await repository.create(
        Game(
          id: '2',
          title: 'Checkers',
          players: '2',
          time: '30m',
          category: 'Strategy',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      final categories = await repository.getCategories();

      expect(categories.length, equals(1));
      expect(categories.first, equals('Strategy'));
    });

    test('recordPlay should increment wins', () async {
      final game = Game(
        id: '1',
        title: 'Chess',
        players: '2',
        time: '60m',
        category: 'Strategy',
        wins: 0,
        losses: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.create(game);
      await repository.recordPlay('1', true);

      final result = await repository.getById('1');
      expect(result!.wins, equals(1));
    });

    test('recordPlay should increment losses', () async {
      final game = Game(
        id: '1',
        title: 'Chess',
        players: '2',
        time: '60m',
        category: 'Strategy',
        wins: 0,
        losses: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.create(game);
      await repository.recordPlay('1', false);

      final result = await repository.getById('1');
      expect(result!.losses, equals(1));
    });
  });
}
