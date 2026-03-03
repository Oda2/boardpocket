import 'package:flutter/material.dart';
import '../../data/models/models.dart';
import '../../data/repositories/interfaces/wishlist_repository_interface.dart';

class WishlistProvider extends ChangeNotifier {
  final IWishlistRepository _repository;

  WishlistProvider({required IWishlistRepository repository})
    : _repository = repository;

  List<WishlistItem> _items = [];
  bool _isLoading = false;

  List<WishlistItem> get items => _items;
  bool get isLoading => _isLoading;

  Future<void> loadItems() async {
    _isLoading = true;
    notifyListeners();

    _items = await _repository.getAll();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addItem(WishlistItem item) async {
    await _repository.create(item);
    await loadItems();
  }

  Future<void> updateItem(WishlistItem item) async {
    await _repository.update(item);
    await loadItems();
  }

  Future<void> deleteItem(String id) async {
    await _repository.delete(id);
    await loadItems();
  }

  Future<WishlistItem?> getItemById(String id) async {
    return await _repository.getById(id);
  }
}
