import 'package:flutter/material.dart';
import '../../data/models/models.dart';
import '../../data/repositories/repositories.dart';

class WishlistProvider extends ChangeNotifier {
  final WishlistRepository _repository = WishlistRepository();

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
