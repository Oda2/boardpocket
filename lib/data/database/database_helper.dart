import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static bool _initialized = false;

  // Web fallback storage
  SharedPreferences? _prefs;
  final Map<String, List<Map<String, dynamic>>> _memoryStorage = {
    'games': [],
    'wishlist': [],
    'players': [],
    'settings': [],
  };

  DatabaseHelper._init();

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    if (kIsWeb) {
      try {
        // Try to initialize for web
        databaseFactory = databaseFactoryFfiWeb;
      } catch (e) {
        print(
          'Warning: sqflite ffi web initialization failed, using memory fallback: $e',
        );
      }
      // Always use shared preferences for web storage fallback
      _prefs = await SharedPreferences.getInstance();
      _loadFromPrefs();
    }

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

  bool get _isWebMode => kIsWeb;

  Future<Database> get database async {
    if (_isWebMode) {
      throw Exception('Use memory storage on web');
    }

    if (_database != null) return _database!;
    await _ensureInitialized();
    _database = await _initDB('boardpocket.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add wins and losses columns to games table
      await db.execute('ALTER TABLE games ADD COLUMN wins INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE games ADD COLUMN losses INTEGER DEFAULT 0');
    }
  }

  Future _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT';
    const intType = 'INTEGER';
    const realType = 'REAL';

    // Games table
    await db.execute('''
      CREATE TABLE games (
        id $idType,
        title $textType NOT NULL,
        image_path $textType,
        players $textType NOT NULL,
        time $textType NOT NULL,
        category $textType NOT NULL,
        min_players $intType,
        max_players $intType,
        play_time $intType,
        complexity $realType,
        total_plays $intType DEFAULT 0,
        wins $intType DEFAULT 0,
        losses $intType DEFAULT 0,
        win_rate $realType DEFAULT 0.0,
        last_played $intType,
        created_at $intType NOT NULL,
        updated_at $intType NOT NULL
      )
    ''');

    // Wishlist table
    await db.execute('''
      CREATE TABLE wishlist (
        id $idType,
        title $textType NOT NULL,
        image_path $textType,
        image_url $textType,
        price $textType,
        purchase_url $textType,
        players $textType NOT NULL,
        time $textType NOT NULL,
        tag $textType,
        category $textType,
        created_at $intType NOT NULL
      )
    ''');

    // Players table (for Name Draw)
    await db.execute('''
      CREATE TABLE players (
        id $idType,
        name $textType NOT NULL,
        created_at $intType NOT NULL
      )
    ''');

    // Settings table
    await db.execute('''
      CREATE TABLE settings (
        key $textType PRIMARY KEY,
        value $textType NOT NULL
      )
    ''');

    // Insert default settings
    await db.insert('settings', {'key': 'dark_mode', 'value': 'true'});
    await db.insert('settings', {'key': 'language', 'value': 'en'});
    await db.insert('settings', {'key': 'initialized', 'value': 'true'});
  }

  // Games CRUD - Web compatible
  Future<String> insertGame(Map<String, dynamic> game) async {
    if (_isWebMode) {
      await _ensureInitialized();
      _memoryStorage['games']!.add(game);
      await _saveToPrefs();
      return game['id'] as String;
    }

    final db = await database;
    await db.insert('games', game);
    return game['id'] as String;
  }

  Future<List<Map<String, dynamic>>> getAllGames() async {
    if (_isWebMode) {
      await _ensureInitialized();
      return List<Map<String, dynamic>>.from(_memoryStorage['games']!)..sort(
        (a, b) => (b['created_at'] as int).compareTo(a['created_at'] as int),
      );
    }

    final db = await database;
    return await db.query('games', orderBy: 'created_at DESC');
  }

  Future<List<Map<String, dynamic>>> searchGames(String query) async {
    if (_isWebMode) {
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

    final db = await database;
    return await db.query(
      'games',
      where: 'title LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'created_at DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getGamesByCategory(String category) async {
    if (_isWebMode) {
      await _ensureInitialized();
      return _memoryStorage['games']!
          .where((g) => g['category'] == category)
          .toList()
        ..sort(
          (a, b) => (b['created_at'] as int).compareTo(a['created_at'] as int),
        );
    }

    final db = await database;
    return await db.query(
      'games',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'created_at DESC',
    );
  }

  Future<List<String>> getDistinctCategories() async {
    if (_isWebMode) {
      await _ensureInitialized();
      final categories = _memoryStorage['games']!
          .map((g) => g['category'] as String)
          .toSet()
          .toList();
      categories.sort();
      return categories;
    }

    final db = await database;
    final result = await db.rawQuery(
      'SELECT DISTINCT category FROM games ORDER BY category ASC',
    );
    return result.map((e) => e['category'] as String).toList();
  }

  Future<Map<String, dynamic>?> getGameById(String id) async {
    if (_isWebMode) {
      await _ensureInitialized();
      try {
        return _memoryStorage['games']!.firstWhere((g) => g['id'] == id);
      } catch (e) {
        return null;
      }
    }

    final db = await database;
    final results = await db.query('games', where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> updateGame(String id, Map<String, dynamic> game) async {
    if (_isWebMode) {
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

    final db = await database;
    return await db.update('games', game, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteGame(String id) async {
    if (_isWebMode) {
      await _ensureInitialized();
      final initialLength = _memoryStorage['games']!.length;
      _memoryStorage['games']!.removeWhere((g) => g['id'] == id);
      final removed = initialLength - _memoryStorage['games']!.length;
      await _saveToPrefs();
      return removed > 0 ? 1 : 0;
    }

    final db = await database;
    return await db.delete('games', where: 'id = ?', whereArgs: [id]);
  }

  // Wishlist CRUD - Web compatible
  Future<String> insertWishlistItem(Map<String, dynamic> item) async {
    if (_isWebMode) {
      await _ensureInitialized();
      _memoryStorage['wishlist']!.add(item);
      await _saveToPrefs();
      return item['id'] as String;
    }

    final db = await database;
    await db.insert('wishlist', item);
    return item['id'] as String;
  }

  Future<List<Map<String, dynamic>>> getAllWishlistItems() async {
    if (_isWebMode) {
      await _ensureInitialized();
      return List<Map<String, dynamic>>.from(_memoryStorage['wishlist']!)..sort(
        (a, b) => (b['created_at'] as int).compareTo(a['created_at'] as int),
      );
    }

    final db = await database;
    return await db.query('wishlist', orderBy: 'created_at DESC');
  }

  Future<int> updateWishlistItem(String id, Map<String, dynamic> item) async {
    if (_isWebMode) {
      await _ensureInitialized();
      final index = _memoryStorage['wishlist']!.indexWhere(
        (w) => w['id'] == id,
      );
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

    final db = await database;
    return await db.update('wishlist', item, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteWishlistItem(String id) async {
    if (_isWebMode) {
      await _ensureInitialized();
      final initialLength = _memoryStorage['wishlist']!.length;
      _memoryStorage['wishlist']!.removeWhere((w) => w['id'] == id);
      final removed = initialLength - _memoryStorage['wishlist']!.length;
      await _saveToPrefs();
      return removed > 0 ? 1 : 0;
    }

    final db = await database;
    return await db.delete('wishlist', where: 'id = ?', whereArgs: [id]);
  }

  // Players CRUD - Web compatible
  Future<String> insertPlayer(Map<String, dynamic> player) async {
    if (_isWebMode) {
      await _ensureInitialized();
      _memoryStorage['players']!.add(player);
      await _saveToPrefs();
      return player['id'] as String;
    }

    final db = await database;
    await db.insert('players', player);
    return player['id'] as String;
  }

  Future<List<Map<String, dynamic>>> getAllPlayers() async {
    if (_isWebMode) {
      await _ensureInitialized();
      return List<Map<String, dynamic>>.from(_memoryStorage['players']!)..sort(
        (a, b) => (b['created_at'] as int).compareTo(a['created_at'] as int),
      );
    }

    final db = await database;
    return await db.query('players', orderBy: 'created_at DESC');
  }

  Future<int> deletePlayer(String id) async {
    if (_isWebMode) {
      await _ensureInitialized();
      final initialLength = _memoryStorage['players']!.length;
      _memoryStorage['players']!.removeWhere((p) => p['id'] == id);
      final removed = initialLength - _memoryStorage['players']!.length;
      await _saveToPrefs();
      return removed > 0 ? 1 : 0;
    }

    final db = await database;
    return await db.delete('players', where: 'id = ?', whereArgs: [id]);
  }

  // Settings - handled by SettingsRepository with SharedPreferences now
  Future<String?> getSetting(String key) async {
    // This is now handled by SettingsRepository, keeping for compatibility
    return null;
  }

  Future<int> setSetting(String key, String value) async {
    // This is now handled by SettingsRepository, keeping for compatibility
    return 0;
  }

  // Backup/Restore - Web compatible
  Future<Map<String, dynamic>> exportAllData() async {
    if (_isWebMode) {
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

    final db = await database;

    final games = await db.query('games');
    final wishlist = await db.query('wishlist');
    final players = await db.query('players');
    final settings = await db.query('settings');

    return {
      'games': games,
      'wishlist': wishlist,
      'players': players,
      'settings': settings,
      'export_date': DateTime.now().toIso8601String(),
      'version': 1,
    };
  }

  Future<void> importAllData(Map<String, dynamic> data) async {
    if (_isWebMode) {
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
      return;
    }

    final db = await database;

    await db.transaction((txn) async {
      // Clear existing data
      await txn.delete('games');
      await txn.delete('wishlist');
      await txn.delete('players');
      await txn.delete('settings');

      // Insert imported data
      if (data['games'] != null) {
        for (final game in data['games'] as List) {
          await txn.insert('games', game as Map<String, dynamic>);
        }
      }

      if (data['wishlist'] != null) {
        for (final item in data['wishlist'] as List) {
          await txn.insert('wishlist', item as Map<String, dynamic>);
        }
      }

      if (data['players'] != null) {
        for (final player in data['players'] as List) {
          await txn.insert('players', player as Map<String, dynamic>);
        }
      }

      if (data['settings'] != null) {
        for (final setting in data['settings'] as List) {
          await txn.insert('settings', setting as Map<String, dynamic>);
        }
      }
    });
  }

  Future close() async {
    if (_isWebMode) {
      await _saveToPrefs();
      return;
    }

    final db = await database;
    db.close();
  }
}
