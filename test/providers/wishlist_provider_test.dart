import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/data/models/wishlist_item.dart';
import 'package:boardpocket/presentation/providers/wishlist_provider.dart';
import 'package:boardpocket/data/repositories/interfaces/wishlist_repository_interface.dart';

class MockWishlistRepository implements IWishlistRepository {
  final List<WishlistItem> _items = [];

  @override
  Future<WishlistItem> create(WishlistItem item) async {
    _items.add(item);
    return item;
  }

  @override
  Future<List<WishlistItem>> getAll() async => List.from(_items);

  @override
  Future<WishlistItem?> getById(String id) async {
    try {
      return _items.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> update(WishlistItem item) async {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index >= 0) _items[index] = item;
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((i) => i.id == id);
  }

  void addTestItem(WishlistItem item) {
    _items.add(item);
  }
}

WishlistItem createTestWishlistItem({
  String id = 'item-1',
  String title = 'Game Title',
  String? imagePath,
  String? imageUrl,
  String? price,
  String? purchaseUrl,
  String players = '2-4',
  String time = '30 min',
  String? tag,
  String? category,
}) {
  return WishlistItem(
    id: id,
    title: title,
    imagePath: imagePath,
    imageUrl: imageUrl,
    price: price,
    purchaseUrl: purchaseUrl,
    players: players,
    time: time,
    tag: tag,
    category: category,
    createdAt: DateTime.now(),
  );
}

void main() {
  group('WishlistProvider - State', () {
    late WishlistProvider wishlistProvider;
    late MockWishlistRepository mockRepository;

    setUp(() {
      mockRepository = MockWishlistRepository();
      wishlistProvider = WishlistProvider(repository: mockRepository);
    });

    test('should have empty items list initially', () {
      expect(wishlistProvider.items, isEmpty);
    });

    test('should not be loading initially', () {
      expect(wishlistProvider.isLoading, false);
    });
  });

  group('WishlistProvider - loadItems', () {
    late WishlistProvider wishlistProvider;
    late MockWishlistRepository mockRepository;

    setUp(() {
      mockRepository = MockWishlistRepository();
      wishlistProvider = WishlistProvider(repository: mockRepository);
    });

    test('should load items from repository', () async {
      mockRepository.addTestItem(
        createTestWishlistItem(id: '1', title: 'Game 1'),
      );
      mockRepository.addTestItem(
        createTestWishlistItem(id: '2', title: 'Game 2'),
      );

      await wishlistProvider.loadItems();

      expect(wishlistProvider.items.length, 2);
      expect(wishlistProvider.isLoading, false);
    });

    test('should set isLoading during load', () async {
      mockRepository.addTestItem(createTestWishlistItem());

      final future = wishlistProvider.loadItems();

      expect(wishlistProvider.isLoading, true);

      await future;

      expect(wishlistProvider.isLoading, false);
    });

    test('should have empty list when no items', () async {
      await wishlistProvider.loadItems();

      expect(wishlistProvider.items, isEmpty);
    });
  });

  group('WishlistProvider - addItem', () {
    late WishlistProvider wishlistProvider;
    late MockWishlistRepository mockRepository;

    setUp(() async {
      mockRepository = MockWishlistRepository();
      wishlistProvider = WishlistProvider(repository: mockRepository);
      await wishlistProvider.loadItems();
    });

    test('should add item to repository', () async {
      final newItem = createTestWishlistItem(id: 'new-1', title: 'New Game');

      await wishlistProvider.addItem(newItem);

      expect(wishlistProvider.items.length, 1);
      expect(wishlistProvider.items.first.title, 'New Game');
    });

    test('should reload items after adding', () async {
      final newItem = createTestWishlistItem(id: 'new-1', title: 'New Game');

      await wishlistProvider.addItem(newItem);

      expect(wishlistProvider.items.any((i) => i.title == 'New Game'), true);
    });
  });

  group('WishlistProvider - updateItem', () {
    late WishlistProvider wishlistProvider;
    late MockWishlistRepository mockRepository;

    setUp(() async {
      mockRepository = MockWishlistRepository();
      mockRepository.addTestItem(
        createTestWishlistItem(id: '1', title: 'Original Title'),
      );

      wishlistProvider = WishlistProvider(repository: mockRepository);
      await wishlistProvider.loadItems();
    });

    test('should update item and reload', () async {
      final updatedItem = createTestWishlistItem(
        id: '1',
        title: 'Updated Title',
      );

      await wishlistProvider.updateItem(updatedItem);

      expect(wishlistProvider.items.first.title, 'Updated Title');
    });
  });

  group('WishlistProvider - deleteItem', () {
    late WishlistProvider wishlistProvider;
    late MockWishlistRepository mockRepository;

    setUp(() async {
      mockRepository = MockWishlistRepository();
      mockRepository.addTestItem(
        createTestWishlistItem(id: '1', title: 'Game 1'),
      );
      mockRepository.addTestItem(
        createTestWishlistItem(id: '2', title: 'Game 2'),
      );

      wishlistProvider = WishlistProvider(repository: mockRepository);
      await wishlistProvider.loadItems();
    });

    test('should remove item from list', () async {
      await wishlistProvider.deleteItem('1');

      expect(wishlistProvider.items.length, 1);
      expect(wishlistProvider.items.any((i) => i.id == '1'), false);
    });

    test('should keep other items when deleting', () async {
      await wishlistProvider.deleteItem('1');

      expect(wishlistProvider.items.any((i) => i.id == '2'), true);
    });
  });

  group('WishlistProvider - getItemById', () {
    late WishlistProvider wishlistProvider;
    late MockWishlistRepository mockRepository;

    setUp(() async {
      mockRepository = MockWishlistRepository();
      mockRepository.addTestItem(
        createTestWishlistItem(id: '1', title: 'Game 1'),
      );
      mockRepository.addTestItem(
        createTestWishlistItem(id: '2', title: 'Game 2'),
      );

      wishlistProvider = WishlistProvider(repository: mockRepository);
      await wishlistProvider.loadItems();
    });

    test('should return item when exists', () async {
      final item = await wishlistProvider.getItemById('1');

      expect(item, isNotNull);
      expect(item!.title, 'Game 1');
    });

    test('should return null when item does not exist', () async {
      final item = await wishlistProvider.getItemById('non-existent');

      expect(item, isNull);
    });
  });
}
