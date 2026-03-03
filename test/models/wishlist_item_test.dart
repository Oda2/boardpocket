import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/data/models/wishlist_item.dart';

void main() {
  group('WishlistItem Model', () {
    late WishlistItem wishlistItem;
    late DateTime createdAt;

    setUp(() {
      createdAt = DateTime(2024, 1, 1, 10, 0);
      wishlistItem = WishlistItem(
        id: '1',
        title: 'Catan',
        imagePath: '/path/to/image.jpg',
        imageUrl: 'https://example.com/image.jpg',
        price: '\$49.99',
        purchaseUrl: 'https://store.example.com/catan',
        players: '3-4',
        time: '60-120 min',
        tag: 'Must Buy',
        category: 'Strategy',
        createdAt: createdAt,
      );
    });

    test('should create WishlistItem with all properties', () {
      expect(wishlistItem.id, '1');
      expect(wishlistItem.title, 'Catan');
      expect(wishlistItem.imagePath, '/path/to/image.jpg');
      expect(wishlistItem.imageUrl, 'https://example.com/image.jpg');
      expect(wishlistItem.price, '\$49.99');
      expect(wishlistItem.purchaseUrl, 'https://store.example.com/catan');
      expect(wishlistItem.players, '3-4');
      expect(wishlistItem.time, '60-120 min');
      expect(wishlistItem.tag, 'Must Buy');
      expect(wishlistItem.category, 'Strategy');
      expect(wishlistItem.createdAt, createdAt);
    });

    test('should create WishlistItem with default values', () {
      final item = WishlistItem(
        id: '2',
        title: 'Test Game',
        createdAt: createdAt,
      );

      expect(item.id, '2');
      expect(item.title, 'Test Game');
      expect(item.imagePath, isNull);
      expect(item.imageUrl, isNull);
      expect(item.price, isNull);
      expect(item.purchaseUrl, isNull);
      expect(item.players, '2-4');
      expect(item.time, '60m');
      expect(item.tag, isNull);
      expect(item.category, isNull);
    });

    test('should convert WishlistItem to Map', () {
      final map = wishlistItem.toMap();

      expect(map['id'], '1');
      expect(map['title'], 'Catan');
      expect(map['image_path'], '/path/to/image.jpg');
      expect(map['image_url'], 'https://example.com/image.jpg');
      expect(map['price'], '\$49.99');
      expect(map['purchase_url'], 'https://store.example.com/catan');
      expect(map['players'], '3-4');
      expect(map['time'], '60-120 min');
      expect(map['tag'], 'Must Buy');
      expect(map['category'], 'Strategy');
      expect(map['created_at'], createdAt.millisecondsSinceEpoch);
    });

    test('should create WishlistItem from Map', () {
      final map = {
        'id': '2',
        'title': 'Ticket to Ride',
        'image_path': '/path/to/ttr.jpg',
        'image_url': 'https://example.com/ttr.jpg',
        'price': '\$44.99',
        'purchase_url': 'https://store.example.com/ttr',
        'players': '2-5',
        'time': '45-60 min',
        'tag': 'Family',
        'category': 'Family',
        'created_at': 1704067200000,
      };

      final itemFromMap = WishlistItem.fromMap(map);

      expect(itemFromMap.id, '2');
      expect(itemFromMap.title, 'Ticket to Ride');
      expect(itemFromMap.imagePath, '/path/to/ttr.jpg');
      expect(itemFromMap.imageUrl, 'https://example.com/ttr.jpg');
      expect(itemFromMap.price, '\$44.99');
      expect(itemFromMap.purchaseUrl, 'https://store.example.com/ttr');
      expect(itemFromMap.players, '2-5');
      expect(itemFromMap.time, '45-60 min');
      expect(itemFromMap.tag, 'Family');
      expect(itemFromMap.category, 'Family');
    });

    test('should create WishlistItem from Map with null optional fields', () {
      final map = {
        'id': '3',
        'title': 'Test Game',
        'image_path': null,
        'image_url': null,
        'price': null,
        'purchase_url': null,
        'players': null,
        'time': null,
        'tag': null,
        'category': null,
        'created_at': 1704067200000,
      };

      final itemFromMap = WishlistItem.fromMap(map);

      expect(itemFromMap.id, '3');
      expect(itemFromMap.title, 'Test Game');
      expect(itemFromMap.imagePath, isNull);
      expect(itemFromMap.imageUrl, isNull);
      expect(itemFromMap.price, isNull);
      expect(itemFromMap.purchaseUrl, isNull);
      expect(itemFromMap.players, '2-4');
      expect(itemFromMap.time, '60m');
      expect(itemFromMap.tag, isNull);
      expect(itemFromMap.category, isNull);
    });

    test('should copy WishlistItem with modified properties', () {
      final copiedItem = wishlistItem.copyWith(
        title: 'Catan: Extended',
        price: '\$59.99',
      );

      expect(copiedItem.id, '1');
      expect(copiedItem.title, 'Catan: Extended');
      expect(copiedItem.price, '\$59.99');
      expect(copiedItem.imagePath, '/path/to/image.jpg');
      expect(copiedItem.players, '3-4');
    });

    test('should copy WishlistItem with modified optional fields', () {
      final copiedItem = wishlistItem.copyWith(
        title: 'Catan: Extended',
        price: '\$59.99',
      );

      expect(copiedItem.id, '1');
      expect(copiedItem.title, 'Catan: Extended');
      expect(copiedItem.price, '\$59.99');
      expect(copiedItem.imagePath, '/path/to/image.jpg');
      expect(copiedItem.players, '3-4');
    });
  });
}
