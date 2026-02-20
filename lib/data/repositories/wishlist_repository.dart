import '../../data/database/database_helper.dart';
import '../../data/models/wishlist_item.dart';

class WishlistRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<WishlistItem> create(WishlistItem item) async {
    await _db.insertWishlistItem(item.toMap());
    return item;
  }

  Future<List<WishlistItem>> getAll() async {
    final maps = await _db.getAllWishlistItems();
    return maps.map((map) => WishlistItem.fromMap(map)).toList();
  }

  Future<WishlistItem?> getById(String id) async {
    final maps = await _db.getAllWishlistItems();
    final map = maps.firstWhere((m) => m['id'] == id, orElse: () => {});
    if (map.isEmpty) return null;
    return WishlistItem.fromMap(map);
  }

  Future<void> update(WishlistItem item) async {
    await _db.updateWishlistItem(item.id, item.toMap());
  }

  Future<void> delete(String id) async {
    await _db.deleteWishlistItem(id);
  }
}
