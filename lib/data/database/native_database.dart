import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'database_interface.dart';

class NativeDatabase implements DatabaseInterface {
  Database? _database;
  static const String _dbName = 'boardpocket.db';

  @override
  Future<String> getDatabasePath() async {
    final db = await database;
    return db.path;
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(_dbName);
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

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE games ADD COLUMN wins INTEGER DEFAULT 0');
      await db.execute('ALTER TABLE games ADD COLUMN losses INTEGER DEFAULT 0');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT';
    const intType = 'INTEGER';
    const realType = 'REAL';

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

    await db.execute('''
      CREATE TABLE players (
        id $idType,
        name $textType NOT NULL,
        created_at $intType NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE settings (
        key $textType PRIMARY KEY,
        value $textType NOT NULL
      )
    ''');

    await db.insert('settings', {'key': 'dark_mode', 'value': 'true'});
    await db.insert('settings', {'key': 'language', 'value': 'en'});
    await db.insert('settings', {'key': 'initialized', 'value': 'true'});
  }

  @override
  Future<String> insertGame(Map<String, dynamic> game) async {
    final db = await database;
    await db.insert('games', game);
    return game['id'] as String;
  }

  @override
  Future<List<Map<String, dynamic>>> getAllGames() async {
    final db = await database;
    return await db.query('games', orderBy: 'created_at DESC');
  }

  @override
  Future<List<Map<String, dynamic>>> searchGames(String query) async {
    final db = await database;
    return await db.query(
      'games',
      where: 'title LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'created_at DESC',
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getGamesByCategory(String category) async {
    final db = await database;
    return await db.query(
      'games',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'created_at DESC',
    );
  }

  @override
  Future<List<String>> getDistinctCategories() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT DISTINCT category FROM games ORDER BY category ASC',
    );
    return result.map((e) => e['category'] as String).toList();
  }

  @override
  Future<Map<String, dynamic>?> getGameById(String id) async {
    final db = await database;
    final results = await db.query('games', where: 'id = ?', whereArgs: [id]);
    return results.isNotEmpty ? results.first : null;
  }

  @override
  Future<int> updateGame(String id, Map<String, dynamic> game) async {
    final db = await database;
    return await db.update('games', game, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<int> deleteGame(String id) async {
    final db = await database;
    return await db.delete('games', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<String> insertWishlistItem(Map<String, dynamic> item) async {
    final db = await database;
    await db.insert('wishlist', item);
    return item['id'] as String;
  }

  @override
  Future<List<Map<String, dynamic>>> getAllWishlistItems() async {
    final db = await database;
    return await db.query('wishlist', orderBy: 'created_at DESC');
  }

  @override
  Future<int> updateWishlistItem(String id, Map<String, dynamic> item) async {
    final db = await database;
    return await db.update('wishlist', item, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<int> deleteWishlistItem(String id) async {
    final db = await database;
    return await db.delete('wishlist', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<String> insertPlayer(Map<String, dynamic> player) async {
    final db = await database;
    await db.insert('players', player);
    return player['id'] as String;
  }

  @override
  Future<List<Map<String, dynamic>>> getAllPlayers() async {
    final db = await database;
    return await db.query('players', orderBy: 'created_at DESC');
  }

  @override
  Future<int> deletePlayer(String id) async {
    final db = await database;
    return await db.delete('players', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<Map<String, dynamic>> exportAllData() async {
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

  @override
  Future<void> importAllData(Map<String, dynamic> data) async {
    final db = await database;

    await db.transaction((txn) async {
      await txn.delete('games');
      await txn.delete('wishlist');
      await txn.delete('players');
      await txn.delete('settings');

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

  @override
  Future<void> close() async {
    final db = await database;
    db.close();
  }
}
