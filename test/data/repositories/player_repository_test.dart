import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/data/repositories/player_repository.dart';
import 'package:boardpocket/data/database/database_helper.dart';
import 'package:boardpocket/data/models/player.dart';
import 'package:sqflite/sqflite.dart';

class MockDatabaseHelper implements DatabaseHelper {
  final List<Map<String, dynamic>> _players = [];

  @override
  Future<void> init() async {}

  @override
  Future<Database> get database async => throw UnimplementedError();

  @override
  Future<String> insertGame(Map<String, dynamic> game) async => '1';

  @override
  Future<List<Map<String, dynamic>>> getAllGames() async => [];

  @override
  Future<List<Map<String, dynamic>>> searchGames(String query) async => [];

  @override
  Future<List<Map<String, dynamic>>> getGamesByCategory(
    String category,
  ) async => [];

  @override
  Future<List<String>> getDistinctCategories() async => [];

  @override
  Future<Map<String, dynamic>?> getGameById(String id) async => null;

  @override
  Future<int> updateGame(String id, Map<String, dynamic> game) async => 1;

  @override
  Future<int> deleteGame(String id) async => 1;

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
  Future<String> insertPlayer(Map<String, dynamic> player) async {
    _players.add(player);
    return '1';
  }

  @override
  Future<List<Map<String, dynamic>>> getAllPlayers() async {
    return List.from(_players);
  }

  @override
  Future<int> deletePlayer(String id) async {
    final initialLength = _players.length;
    _players.removeWhere((p) => p['id'] == id);
    return initialLength - _players.length;
  }

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
  late PlayerRepository repository;
  late MockDatabaseHelper mockDb;

  setUp(() {
    mockDb = MockDatabaseHelper();
    repository = PlayerRepository(databaseHelper: mockDb);
  });

  group('PlayerRepository', () {
    test('create should insert player and return it', () async {
      final player = Player(id: '1', name: 'John', createdAt: DateTime.now());

      final result = await repository.create(player);

      expect(result.id, equals('1'));
      expect(result.name, equals('John'));
    });

    test('getAll should return all players', () async {
      final player1 = Player(id: '1', name: 'John', createdAt: DateTime.now());
      final player2 = Player(id: '2', name: 'Jane', createdAt: DateTime.now());

      await repository.create(player1);
      await repository.create(player2);

      final players = await repository.getAll();

      expect(players.length, equals(2));
    });

    test('delete should remove player', () async {
      final player = Player(id: '1', name: 'John', createdAt: DateTime.now());

      await repository.create(player);
      expect((await repository.getAll()).length, equals(1));

      await repository.delete('1');

      expect((await repository.getAll()).length, equals(0));
    });

    test('getAll should return empty list when no players', () async {
      final players = await repository.getAll();

      expect(players, isEmpty);
    });
  });
}
