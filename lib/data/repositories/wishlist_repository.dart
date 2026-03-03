import '../database/database_helper.dart';
import '../models/wishlist_item.dart';
import 'interfaces/wishlist_repository_interface.dart';

class WishlistRepository implements IWishlistRepository {
  final DatabaseHelper _db;

  WishlistRepository({DatabaseHelper? databaseHelper})
    : _db = databaseHelper ?? DatabaseHelper.instance;

  @override
  Future<WishlistItem> create(WishlistItem item) async {
    await _db.insertWishlistItem(item.toMap());
    return item;
  }

  @override
  Future<List<WishlistItem>> getAll() async {
    final maps = await _db.getAllWishlistItems();
    return maps.map((map) => WishlistItem.fromMap(map)).toList();
  }

  @override
  Future<WishlistItem?> getById(String id) async {
    final maps = await _db.getAllWishlistItems();
    final map = maps.firstWhere((m) => m['id'] == id, orElse: () => {});
    if (map.isEmpty) return null;
    return WishlistItem.fromMap(map);
  }

  @override
  Future<void> update(WishlistItem item) async {
    await _db.updateWishlistItem(item.id, item.toMap());
  }

  @override
  Future<void> delete(String id) async {
    await _db.deleteWishlistItem(id);
  }
}
