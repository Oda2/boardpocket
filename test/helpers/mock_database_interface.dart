import 'package:boardpocket/data/database/database_interface.dart';

class MockDatabaseInterface implements DatabaseInterface {
  final List<Map<String, dynamic>> _games = [];
  final List<Map<String, dynamic>> _wishlist = [];
  final List<Map<String, dynamic>> _players = [];

  bool shouldThrowOnExport = false;
  bool shouldThrowOnImport = false;

  @override
  Future<String> getDatabasePath() async => '/mock/path';

  @override
  Future<String> insertGame(Map<String, dynamic> game) async {
    _games.add(game);
    return game['id'] as String;
  }

  @override
  Future<List<Map<String, dynamic>>> getAllGames() async {
    return List.from(_games);
  }

  @override
  Future<List<Map<String, dynamic>>> searchGames(String query) async {
    return _games
        .where(
          (g) => (g['title'] as String).toLowerCase().contains(
            query.toLowerCase(),
          ),
        )
        .toList();
  }

  @override
  Future<List<Map<String, dynamic>>> getGamesByCategory(String category) async {
    return _games.where((g) => g['category'] == category).toList();
  }

  @override
  Future<List<String>> getDistinctCategories() async {
    return _games.map((g) => g['category'] as String).toSet().toList();
  }

  @override
  Future<Map<String, dynamic>?> getGameById(String id) async {
    try {
      return _games.firstWhere((g) => g['id'] == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<int> updateGame(String id, Map<String, dynamic> game) async {
    final index = _games.indexWhere((g) => g['id'] == id);
    if (index >= 0) {
      _games[index] = {..._games[index], ...game};
      return 1;
    }
    return 0;
  }

  @override
  Future<int> deleteGame(String id) async {
    final initialLength = _games.length;
    _games.removeWhere((g) => g['id'] == id);
    return initialLength - _games.length;
  }

  @override
  Future<String> insertWishlistItem(Map<String, dynamic> item) async {
    _wishlist.add(item);
    return item['id'] as String;
  }

  @override
  Future<List<Map<String, dynamic>>> getAllWishlistItems() async {
    return List.from(_wishlist);
  }

  @override
  Future<int> updateWishlistItem(String id, Map<String, dynamic> item) async {
    final index = _wishlist.indexWhere((w) => w['id'] == id);
    if (index >= 0) {
      _wishlist[index] = {..._wishlist[index], ...item};
      return 1;
    }
    return 0;
  }

  @override
  Future<int> deleteWishlistItem(String id) async {
    final initialLength = _wishlist.length;
    _wishlist.removeWhere((w) => w['id'] == id);
    return initialLength - _wishlist.length;
  }

  @override
  Future<String> insertPlayer(Map<String, dynamic> player) async {
    _players.add(player);
    return player['id'] as String;
  }

  @override
  Future<List<Map<String, dynamic>>> getAllPlayers() async {
    return List.from(_players);
  }

  @override
  Future<int> deletePlayer(String id) async {
    final initialLength = _players.length;
    _players.removeWhere((p) => p['id'] == id);
    return initialLength - _players.length;
  }

  @override
  Future<Map<String, dynamic>> exportAllData() async {
    if (shouldThrowOnExport) {
      throw Exception('Export error');
    }
    return {
      'games': _games,
      'wishlist': _wishlist,
      'players': _players,
      'settings': [],
      'export_date': DateTime.now().toIso8601String(),
      'version': 1,
    };
  }

  @override
  Future<void> importAllData(Map<String, dynamic> data) async {
    if (shouldThrowOnImport) {
      throw Exception('Import error');
    }
    if (data['games'] != null) {
      _games.clear();
      _games.addAll(List<Map<String, dynamic>>.from(data['games'] as List));
    }
    if (data['wishlist'] != null) {
      _wishlist.clear();
      _wishlist.addAll(
        List<Map<String, dynamic>>.from(data['wishlist'] as List),
      );
    }
    if (data['players'] != null) {
      _players.clear();
      _players.addAll(List<Map<String, dynamic>>.from(data['players'] as List));
    }
  }

  @override
  Future<void> close() async {}

  void clearGames() => _games.clear();
  void clearWishlist() => _wishlist.clear();
  void clearPlayers() => _players.clear();
}
