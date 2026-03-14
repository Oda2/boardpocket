import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_interface.dart';

class WebDatabase implements DatabaseInterface {
  SharedPreferences? _prefs;
  final Map<String, List<Map<String, dynamic>>> _memoryStorage = {
    'games': [],
    'wishlist': [],
    'players': [],
    'settings': [],
  };

  bool _initialized = false;

  @override
  Future<String> getDatabasePath() async {
    throw Exception('Web storage does not have a path');
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _loadFromPrefs();
    _initialized = true;
  }

  void _loadFromPrefs() {
    if (_prefs == null) return;

    final gamesJson = _prefs!.getString('games_data');
    final wishlistJson = _prefs!.getString('wishlist_data');
    final playersJson = _prefs!.getString('players_data');

    if (gamesJson != null) {
      _memoryStorage['games'] = List<Map<String, dynamic>>.from(
        json.decode(gamesJson),
      );
    }
    if (wishlistJson != null) {
      _memoryStorage['wishlist'] = List<Map<String, dynamic>>.from(
        json.decode(wishlistJson),
      );
    }
    if (playersJson != null) {
      _memoryStorage['players'] = List<Map<String, dynamic>>.from(
        json.decode(playersJson),
      );
    }
  }

  Future<void> _saveToPrefs() async {
    if (_prefs == null) return;

    await _prefs!.setString('games_data', json.encode(_memoryStorage['games']));
    await _prefs!.setString(
      'wishlist_data',
      json.encode(_memoryStorage['wishlist']),
    );
    await _prefs!.setString(
      'players_data',
      json.encode(_memoryStorage['players']),
    );
  }

  @override
  Future<String> insertGame(Map<String, dynamic> game) async {
    await _ensureInitialized();
    _memoryStorage['games']!.add(game);
    await _saveToPrefs();
    return game['id'] as String;
  }

  @override
  Future<List<Map<String, dynamic>>> getAllGames() async {
    await _ensureInitialized();
    return List<Map<String, dynamic>>.from(_memoryStorage['games']!)..sort(
      (a, b) => (b['created_at'] as int).compareTo(a['created_at'] as int),
    );
  }

  @override
  Future<List<Map<String, dynamic>>> searchGames(String query) async {
    await _ensureInitialized();
    return _memoryStorage['games']!
        .where(
          (g) => (g['title'] as String).toLowerCase().contains(
            query.toLowerCase(),
          ),
        )
        .toList()
      ..sort(
        (a, b) => (b['created_at'] as int).compareTo(a['created_at'] as int),
      );
  }

  @override
  Future<List<Map<String, dynamic>>> getGamesByCategory(String category) async {
    await _ensureInitialized();
    return _memoryStorage['games']!
        .where((g) => g['category'] == category)
        .toList()
      ..sort(
        (a, b) => (b['created_at'] as int).compareTo(a['created_at'] as int),
      );
  }

  @override
  Future<List<String>> getDistinctCategories() async {
    await _ensureInitialized();
    final categories = _memoryStorage['games']!
        .map((g) => g['category'] as String)
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }

  @override
  Future<Map<String, dynamic>?> getGameById(String id) async {
    await _ensureInitialized();
    try {
      return _memoryStorage['games']!.firstWhere((g) => g['id'] == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<int> updateGame(String id, Map<String, dynamic> game) async {
    await _ensureInitialized();
    final index = _memoryStorage['games']!.indexWhere((g) => g['id'] == id);
    if (index >= 0) {
      _memoryStorage['games']![index] = {
        ..._memoryStorage['games']![index],
        ...game,
      };
      await _saveToPrefs();
      return 1;
    }
    return 0;
  }

  @override
  Future<int> deleteGame(String id) async {
    await _ensureInitialized();
    final initialLength = _memoryStorage['games']!.length;
    _memoryStorage['games']!.removeWhere((g) => g['id'] == id);
    final removed = initialLength - _memoryStorage['games']!.length;
    await _saveToPrefs();
    return removed > 0 ? 1 : 0;
  }

  @override
  Future<String> insertWishlistItem(Map<String, dynamic> item) async {
    await _ensureInitialized();
    _memoryStorage['wishlist']!.add(item);
    await _saveToPrefs();
    return item['id'] as String;
  }

  @override
  Future<List<Map<String, dynamic>>> getAllWishlistItems() async {
    await _ensureInitialized();
    return List<Map<String, dynamic>>.from(_memoryStorage['wishlist']!)..sort(
      (a, b) => (b['created_at'] as int).compareTo(a['created_at'] as int),
    );
  }

  @override
  Future<int> updateWishlistItem(String id, Map<String, dynamic> item) async {
    await _ensureInitialized();
    final index = _memoryStorage['wishlist']!.indexWhere((w) => w['id'] == id);
    if (index >= 0) {
      _memoryStorage['wishlist']![index] = {
        ..._memoryStorage['wishlist']![index],
        ...item,
      };
      await _saveToPrefs();
      return 1;
    }
    return 0;
  }

  @override
  Future<int> deleteWishlistItem(String id) async {
    await _ensureInitialized();
    final initialLength = _memoryStorage['wishlist']!.length;
    _memoryStorage['wishlist']!.removeWhere((w) => w['id'] == id);
    final removed = initialLength - _memoryStorage['wishlist']!.length;
    await _saveToPrefs();
    return removed > 0 ? 1 : 0;
  }

  @override
  Future<String> insertPlayer(Map<String, dynamic> player) async {
    await _ensureInitialized();
    _memoryStorage['players']!.add(player);
    await _saveToPrefs();
    return player['id'] as String;
  }

  @override
  Future<List<Map<String, dynamic>>> getAllPlayers() async {
    await _ensureInitialized();
    return List<Map<String, dynamic>>.from(_memoryStorage['players']!)..sort(
      (a, b) => (b['created_at'] as int).compareTo(a['created_at'] as int),
    );
  }

  @override
  Future<int> deletePlayer(String id) async {
    await _ensureInitialized();
    final initialLength = _memoryStorage['players']!.length;
    _memoryStorage['players']!.removeWhere((p) => p['id'] == id);
    final removed = initialLength - _memoryStorage['players']!.length;
    await _saveToPrefs();
    return removed > 0 ? 1 : 0;
  }

  @override
  Future<Map<String, dynamic>> exportAllData() async {
    await _ensureInitialized();
    return {
      'games': _memoryStorage['games'],
      'wishlist': _memoryStorage['wishlist'],
      'players': _memoryStorage['players'],
      'settings': [],
      'export_date': DateTime.now().toIso8601String(),
      'version': 1,
    };
  }

  @override
  Future<void> importAllData(Map<String, dynamic> data) async {
    await _ensureInitialized();
    if (data['games'] != null) {
      _memoryStorage['games'] = List<Map<String, dynamic>>.from(
        data['games'] as List,
      );
    }
    if (data['wishlist'] != null) {
      _memoryStorage['wishlist'] = List<Map<String, dynamic>>.from(
        data['wishlist'] as List,
      );
    }
    if (data['players'] != null) {
      _memoryStorage['players'] = List<Map<String, dynamic>>.from(
        data['players'] as List,
      );
    }
    await _saveToPrefs();
  }

  @override
  Future<void> close() async {
    await _saveToPrefs();
  }
}
