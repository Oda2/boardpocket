import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/data/repositories/wishlist_repository.dart';
import 'package:boardpocket/data/database/database_helper.dart';
import 'package:boardpocket/data/models/wishlist_item.dart';
import '../../helpers/mock_database_interface.dart';

void main() {
  late WishlistRepository repository;
  late MockDatabaseInterface mockDb;

  setUp(() {
    mockDb = MockDatabaseInterface();
    final dbHelper = DatabaseHelper.withInterface(mockDb);
    repository = WishlistRepository(databaseHelper: dbHelper);
  });

  tearDown(() {
    mockDb.clearWishlist();
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
