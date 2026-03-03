import '../../models/wishlist_item.dart';

abstract class IWishlistRepository {
  Future<WishlistItem> create(WishlistItem item);
  Future<List<WishlistItem>> getAll();
  Future<WishlistItem?> getById(String id);
  Future<void> update(WishlistItem item);
  Future<void> delete(String id);
}
