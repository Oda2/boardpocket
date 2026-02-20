import 'package:flutter/material.dart';
import '../../data/models/models.dart';
import '../../data/repositories/repositories.dart';

class GameProvider extends ChangeNotifier {
  final GameRepository _repository = GameRepository();

  List<Game> _games = [];
  List<String> _categories = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = false;

  List<Game> get games => _games;
  List<String> get categories => _categories;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  List<Game> get filteredGames {
    var filtered = _games;

    if (_selectedCategory != 'All') {
      filtered = filtered
          .where((g) => g.category == _selectedCategory)
          .toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where(
            (g) => g.title.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    return filtered;
  }

  Future<void> loadGames() async {
    _isLoading = true;
    notifyListeners();

    _games = await _repository.getAll();
    await _loadCategories();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadCategories() async {
    _categories = await _repository.getCategories();
  }

  Future<void> addGame(Game game) async {
    await _repository.create(game);
    await loadGames();
  }

  Future<void> deleteGame(String id) async {
    await _repository.delete(id);
    await loadGames();
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<Game?> getGameById(String id) async {
    return await _repository.getById(id);
  }

  Future<void> recordPlay(String id, bool won) async {
    await _repository.recordPlay(id, won);
    await loadGames();
  }

  Future<void> updateGame(Game game) async {
    await _repository.update(game);
    await loadGames();
  }
}
