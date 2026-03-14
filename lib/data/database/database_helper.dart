import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'database_interface.dart';
import 'native_database.dart';
import 'web_database.dart';

class DatabaseHelper implements DatabaseInterface {
  static DatabaseHelper? _testInstance;

  static final DatabaseHelper instance = DatabaseHelper._init();

  late final DatabaseInterface _db;
  Database? _nativeDb;
  bool _initialized = false;

  DatabaseHelper();

  DatabaseHelper._init();

  factory DatabaseHelper.withInterface(DatabaseInterface interfaceImpl) {
    final db = DatabaseHelper();
    db._db = interfaceImpl;
    db._initialized = true;
    return db;
  }

  static void setTestInstance(DatabaseHelper instance) {
    _testInstance = instance;
  }

  static DatabaseHelper get testInstance {
    return _testInstance ?? instance;
  }

  Future<void> _ensureInitialized() async {
    if (_initialized) return;

    if (kIsWeb) {
      _db = WebDatabase();
    } else {
      _db = NativeDatabase();
      _nativeDb = await (_db as NativeDatabase).database;
    }

    _initialized = true;
  }

  Future<String> getDatabasePath() async {
    if (kIsWeb) {
      throw Exception('Use memory storage on web');
    }
    return 'boardpocket.db';
  }

  Future<DatabaseInterface> get database async {
    await _ensureInitialized();
    return _db;
  }

  Future<Database?> get rawDatabase async {
    await _ensureInitialized();
    return _nativeDb;
  }

  // Games CRUD
  Future<String> insertGame(Map<String, dynamic> game) async {
    final db = await database;
    return await db.insertGame(game);
  }

  Future<List<Map<String, dynamic>>> getAllGames() async {
    final db = await database;
    return await db.getAllGames();
  }

  Future<List<Map<String, dynamic>>> searchGames(String query) async {
    final db = await database;
    return await db.searchGames(query);
  }

  Future<List<Map<String, dynamic>>> getGamesByCategory(String category) async {
    final db = await database;
    return await db.getGamesByCategory(category);
  }

  Future<List<String>> getDistinctCategories() async {
    final db = await database;
    return await db.getDistinctCategories();
  }

  Future<Map<String, dynamic>?> getGameById(String id) async {
    final db = await database;
    return await db.getGameById(id);
  }

  Future<int> updateGame(String id, Map<String, dynamic> game) async {
    final db = await database;
    return await db.updateGame(id, game);
  }

  Future<int> deleteGame(String id) async {
    final db = await database;
    return await db.deleteGame(id);
  }

  // Wishlist CRUD
  Future<String> insertWishlistItem(Map<String, dynamic> item) async {
    final db = await database;
    return await db.insertWishlistItem(item);
  }

  Future<List<Map<String, dynamic>>> getAllWishlistItems() async {
    final db = await database;
    return await db.getAllWishlistItems();
  }

  Future<int> updateWishlistItem(String id, Map<String, dynamic> item) async {
    final db = await database;
    return await db.updateWishlistItem(id, item);
  }

  Future<int> deleteWishlistItem(String id) async {
    final db = await database;
    return await db.deleteWishlistItem(id);
  }

  // Players CRUD
  Future<String> insertPlayer(Map<String, dynamic> player) async {
    final db = await database;
    return await db.insertPlayer(player);
  }

  Future<List<Map<String, dynamic>>> getAllPlayers() async {
    final db = await database;
    return await db.getAllPlayers();
  }

  Future<int> deletePlayer(String id) async {
    final db = await database;
    return await db.deletePlayer(id);
  }

  // Settings - handled by SettingsRepository with SharedPreferences now
  Future<String?> getSetting(String key) async {
    return null;
  }

  Future<int> setSetting(String key, String value) async {
    return 0;
  }

  // Backup/Restore
  Future<Map<String, dynamic>> exportAllData() async {
    final db = await database;
    return await db.exportAllData();
  }

  Future<void> importAllData(Map<String, dynamic> data) async {
    final db = await database;
    return await db.importAllData(data);
  }

  Future close() async {
    if (!_initialized) return;
    final db = await database;
    return await db.close();
  }
}
