import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/data/repositories/wishlist_repository.dart';
import 'package:boardpocket/data/database/database_helper.dart';
import 'package:boardpocket/data/models/wishlist_item.dart';
import 'package:sqflite/sqflite.dart';

class MockDatabaseHelper implements DatabaseHelper {
  final List<Map<String, dynamic>> _wishlist = [];

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
  Future<String> insertWishlistItem(Map<String, dynamic> item) async {
    _wishlist.add(item);
    return '1';
  }

  @override
  Future<List<Map<String, dynamic>>> getAllWishlistItems() async {
    return List.from(_wishlist);
  }

  @override
  Future<int> updateWishlistItem(String id, Map<String, dynamic> item) async {
    final index = _wishlist.indexWhere((i) => i['id'] == id);
    if (index >= 0) {
      _wishlist[index] = item;
      return 1;
    }
    return 0;
  }

  @override
  Future<int> deleteWishlistItem(String id) async {
    final initialLength = _wishlist.length;
    _wishlist.removeWhere((i) => i['id'] == id);
    return initialLength - _wishlist.length;
  }

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
  late WishlistRepository repository;
  late MockDatabaseHelper mockDb;

  setUp(() {
    mockDb = MockDatabaseHelper();
    repository = WishlistRepository(databaseHelper: mockDb);
  });

  group('WishlistRepository', () {
    test('create should insert item and return it', () async {
      final item = WishlistItem(
        id: '1',
        title: 'Catan',
        category: 'Strategy',
        createdAt: DateTime.now(),
      );

      final result = await repository.create(item);

      expect(result.id, equals('1'));
      expect(result.title, equals('Catan'));
    });

    test('getAll should return all items', () async {
      final item1 = WishlistItem(
        id: '1',
        title: 'Catan',
        category: 'Strategy',
        createdAt: DateTime.now(),
      );
      final item2 = WishlistItem(
        id: '2',
        title: 'Ticket to Ride',
        category: 'Family',
        createdAt: DateTime.now(),
      );

      await repository.create(item1);
      await repository.create(item2);

      final items = await repository.getAll();

      expect(items.length, equals(2));
    });

    test('getById should return item by id', () async {
      final item = WishlistItem(
        id: 'test-id',
        title: 'Catan',
        category: 'Strategy',
        createdAt: DateTime.now(),
      );

      await repository.create(item);

      final result = await repository.getById('test-id');

      expect(result, isNotNull);
      expect(result!.id, equals('test-id'));
    });

    test('getById should return null for non-existent id', () async {
      final result = await repository.getById('non-existent');

      expect(result, isNull);
    });

    test('update should modify existing item', () async {
      final item = WishlistItem(
        id: '1',
        title: 'Catan',
        category: 'Strategy',
        createdAt: DateTime.now(),
      );

      await repository.create(item);

      final updatedItem = item.copyWith(title: 'Updated Catan');
      await repository.update(updatedItem);

      final result = await repository.getById('1');
      expect(result!.title, equals('Updated Catan'));
    });

    test('delete should remove item', () async {
      final item = WishlistItem(
        id: '1',
        title: 'Catan',
        category: 'Strategy',
        createdAt: DateTime.now(),
      );

      await repository.create(item);
      expect((await repository.getAll()).length, equals(1));

      await repository.delete('1');

      expect((await repository.getAll()).length, equals(0));
    });

    test('getAll should return empty list when no items', () async {
      final items = await repository.getAll();

      expect(items, isEmpty);
    });
  });
}
