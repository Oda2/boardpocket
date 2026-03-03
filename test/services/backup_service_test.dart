import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/data/services/backup_service.dart';
import 'package:boardpocket/data/database/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class MockDatabaseHelper implements DatabaseHelper {
  final Map<String, List<Map<String, dynamic>>> _data = {
    'games': [],
    'wishlist': [],
    'players': [],
    'settings': [],
  };

  bool shouldThrowOnExport = false;
  bool shouldThrowOnImport = false;
  String? dbPath;

  @override
  Future<Database> get database async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, dynamic>> exportAllData() async {
    if (shouldThrowOnExport) {
      throw Exception('Export error');
    }
    return {
      'games': _data['games'],
      'wishlist': _data['wishlist'],
      'players': _data['players'],
      'settings': _data['settings'],
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
      _data['games'] = List<Map<String, dynamic>>.from(data['games'] as List);
    }
    if (data['wishlist'] != null) {
      _data['wishlist'] = List<Map<String, dynamic>>.from(
        data['wishlist'] as List,
      );
    }
    if (data['players'] != null) {
      _data['players'] = List<Map<String, dynamic>>.from(
        data['players'] as List,
      );
    }
  }

  @override
  Future<String> getDatabasePath() async {
    return dbPath ?? '/mock/path/boardpocket.db';
  }

  // Unimplemented methods - not needed for tests
  @override
  Future<String> insertGame(Map<String, dynamic> game) async => '';
  @override
  Future<List<Map<String, dynamic>>> getAllGames() async => [];
  @override
  Future<List<Map<String, dynamic>>> searchGames(String query) async => [];
  @override
  Future<List<Map<String, dynamic>>> getGamesByCategory(
    String category,
  ) async => [];
  @override
  Future<List<String>> getDistinctCategories() async => [];
  @override
  Future<Map<String, dynamic>?> getGameById(String id) async => null;
  @override
  Future<int> updateGame(String id, Map<String, dynamic> game) async => 0;
  @override
  Future<int> deleteGame(String id) async => 0;
  @override
  Future<String> insertWishlistItem(Map<String, dynamic> item) async => '';
  @override
  Future<List<Map<String, dynamic>>> getAllWishlistItems() async => [];
  @override
  Future<int> updateWishlistItem(String id, Map<String, dynamic> item) async =>
      0;
  @override
  Future<int> deleteWishlistItem(String id) async => 0;
  @override
  Future<String> insertPlayer(Map<String, dynamic> player) async => '';
  @override
  Future<List<Map<String, dynamic>>> getAllPlayers() async => [];
  @override
  Future<int> deletePlayer(String id) async => 0;
  @override
  Future<String?> getSetting(String key) async => null;
  @override
  Future<int> setSetting(String key, String value) async => 0;
  @override
  Future<void> close() async {}

  // Helper methods for testing
  void addGame(Map<String, dynamic> game) {
    _data['games']!.add(game);
  }

  void addWishlistItem(Map<String, dynamic> item) {
    _data['wishlist']!.add(item);
  }

  void addPlayer(Map<String, dynamic> player) {
    _data['players']!.add(player);
  }

  void clear() {
    _data['games']!.clear();
    _data['wishlist']!.clear();
    _data['players']!.clear();
  }
}

void main() {
  group('BackupService - exportToJson', () {
    late MockDatabaseHelper mockDb;
    late BackupService backupService;

    setUp(() {
      mockDb = MockDatabaseHelper();
      backupService = BackupService(db: mockDb);
    });

    test('should export data as JSON string', () async {
      mockDb.addGame({'id': '1', 'title': 'Game 1', 'players': '2-4'});

      final result = await backupService.exportToJson();

      expect(result, isA<String>());
      final decoded = jsonDecode(result) as Map<String, dynamic>;
      expect(decoded['games'], isA<List>());
      expect((decoded['games'] as List).length, 1);
    });

    test('should include export_date in exported JSON', () async {
      final result = await backupService.exportToJson();

      final decoded = jsonDecode(result) as Map<String, dynamic>;
      expect(decoded['export_date'], isNotNull);
    });

    test('should include version in exported JSON', () async {
      final result = await backupService.exportToJson();

      final decoded = jsonDecode(result) as Map<String, dynamic>;
      expect(decoded['version'], 1);
    });

    test('should export all data sections', () async {
      mockDb.addGame({'id': '1'});
      mockDb.addWishlistItem({'id': '2'});
      mockDb.addPlayer({'id': '3'});

      final result = await backupService.exportToJson();

      final decoded = jsonDecode(result) as Map<String, dynamic>;
      expect(decoded.containsKey('games'), isTrue);
      expect(decoded.containsKey('wishlist'), isTrue);
      expect(decoded.containsKey('players'), isTrue);
      expect(decoded.containsKey('settings'), isTrue);
      expect(decoded.containsKey('export_date'), isTrue);
      expect(decoded.containsKey('version'), isTrue);
    });

    test('should export empty lists when no data', () async {
      final result = await backupService.exportToJson();

      final decoded = jsonDecode(result) as Map<String, dynamic>;
      expect((decoded['games'] as List).isEmpty, isTrue);
      expect((decoded['wishlist'] as List).isEmpty, isTrue);
      expect((decoded['players'] as List).isEmpty, isTrue);
    });

    test('should handle export error gracefully', () async {
      mockDb.shouldThrowOnExport = true;

      expect(() => backupService.exportToJson(), throwsException);
    });
  });

  group('BackupService - importFromJson', () {
    late MockDatabaseHelper mockDb;
    late BackupService backupService;

    setUp(() {
      mockDb = MockDatabaseHelper();
      backupService = BackupService(db: mockDb);
    });

    test('should import data from JSON string', () async {
      final jsonString = jsonEncode({
        'games': [
          {'id': '1', 'title': 'Game 1'},
        ],
        'wishlist': [],
        'players': [],
        'settings': [],
      });

      await backupService.importFromJson(jsonString);

      expect(mockDb._data['games']?.length, 1);
    });

    test('should import games data', () async {
      final jsonString = jsonEncode({
        'games': [
          {'id': '1', 'title': 'Game 1'},
          {'id': '2', 'title': 'Game 2'},
        ],
        'wishlist': [],
        'players': [],
        'settings': [],
      });

      await backupService.importFromJson(jsonString);

      expect(mockDb._data['games']?.length, 2);
    });

    test('should import wishlist data', () async {
      final jsonString = jsonEncode({
        'games': [],
        'wishlist': [
          {'id': '1', 'title': 'Wishlist Item 1'},
        ],
        'players': [],
        'settings': [],
      });

      await backupService.importFromJson(jsonString);

      expect(mockDb._data['wishlist']?.length, 1);
    });

    test('should import players data', () async {
      final jsonString = jsonEncode({
        'games': [],
        'wishlist': [],
        'players': [
          {'id': '1', 'name': 'Player 1'},
        ],
        'settings': [],
      });

      await backupService.importFromJson(jsonString);

      expect(mockDb._data['players']?.length, 1);
    });

    test('should handle empty JSON structure', () async {
      final jsonString = jsonEncode({});

      await backupService.importFromJson(jsonString);

      expect(mockDb._data['games']?.isEmpty, isTrue);
    });

    test('should throw on invalid JSON', () async {
      expect(
        () => backupService.importFromJson('invalid json'),
        throwsA(isA<FormatException>()),
      );
    });

    test('should overwrite existing data on import', () async {
      mockDb.addGame({'id': 'old', 'title': 'Old Game'});

      final jsonString = jsonEncode({
        'games': [
          {'id': 'new', 'title': 'New Game'},
        ],
        'wishlist': [],
        'players': [],
        'settings': [],
      });

      await backupService.importFromJson(jsonString);

      expect(mockDb._data['games']?.length, 1);
      expect(mockDb._data['games']?.first['id'], 'new');
    });

    test('should handle import error gracefully', () async {
      mockDb.shouldThrowOnImport = true;

      final jsonString = jsonEncode({
        'games': [
          {'id': '1'},
        ],
        'wishlist': [],
        'players': [],
        'settings': [],
      });

      expect(() => backupService.importFromJson(jsonString), throwsException);
    });
  });

  group('BackupService - getDatabasePath', () {
    late MockDatabaseHelper mockDb;
    late BackupService backupService;

    setUp(() {
      mockDb = MockDatabaseHelper();
      mockDb.dbPath = '/test/path/boardpocket.db';
      backupService = BackupService(db: mockDb);
    });

    test('should return database path', () async {
      final result = await backupService.getDatabasePath();

      expect(result, '/test/path/boardpocket.db');
    });

    test('should return default path when not set', () async {
      mockDb.dbPath = null;

      final result = await backupService.getDatabasePath();

      expect(result, '/mock/path/boardpocket.db');
    });
  });

  group('BackupService - shareBackup', () {
    late MockDatabaseHelper mockDb;

    setUp(() {
      mockDb = MockDatabaseHelper();
    });

    test('should have shareBackup method', () {
      final backupService = BackupService(db: mockDb);

      expect(backupService.shareBackup, isNotNull);
    });

    test('should be async method', () async {
      final backupService = BackupService(db: mockDb);

      // Just verify the method is async
      expect(backupService.shareBackup(), isA<Future<void>>());
    }, skip: true);
  });

  group('BackupService - exportToFile', () {
    late MockDatabaseHelper mockDb;

    setUp(() {
      mockDb = MockDatabaseHelper();
    });

    test('should have exportToFile method', () {
      final backupService = BackupService(db: mockDb);

      expect(backupService.exportToFile, isNotNull);
    });

    test('should be async method', () async {
      final backupService = BackupService(db: mockDb);

      expect(backupService.exportToFile(), isA<Future<void>>());
    }, skip: true);
  });

  group('BackupService - importFromFile', () {
    late MockDatabaseHelper mockDb;

    setUp(() {
      mockDb = MockDatabaseHelper();
    });

    test('should have importFromFile method', () {
      final backupService = BackupService(db: mockDb);

      expect(backupService.importFromFile, isNotNull);
    });

    test('should return Future<bool>', () async {
      final backupService = BackupService(db: mockDb);

      expect(backupService.importFromFile(), isA<Future<bool>>());
    });
  });

  group('BackupService - shareDatabase', () {
    late MockDatabaseHelper mockDb;

    setUp(() {
      mockDb = MockDatabaseHelper();
    });

    test('should have shareDatabase method', () {
      final backupService = BackupService(db: mockDb);

      expect(backupService.shareDatabase, isNotNull);
    });

    test('should be async method', () async {
      final backupService = BackupService(db: mockDb);

      expect(backupService.shareDatabase(), isA<Future<void>>());
    }, skip: true);
  });

  group('BackupService - JSON roundtrip', () {
    late MockDatabaseHelper mockDb;
    late BackupService backupService;

    setUp(() {
      mockDb = MockDatabaseHelper();
      backupService = BackupService(db: mockDb);
    });

    test('should preserve data through export and import', () async {
      final originalData = {
        'games': [
          {'id': '1', 'title': 'Game 1', 'players': '2-4'},
          {'id': '2', 'title': 'Game 2', 'players': '1-8'},
        ],
        'wishlist': [
          {'id': 'w1', 'title': 'Wishlist Item 1'},
        ],
        'players': [
          {'id': 'p1', 'name': 'Player 1'},
        ],
        'settings': [],
      };

      // First import
      await backupService.importFromJson(jsonEncode(originalData));

      // Export
      final exportedJson = await backupService.exportToJson();
      final exported = jsonDecode(exportedJson) as Map<String, dynamic>;

      // Verify data was preserved
      expect((exported['games'] as List).length, 2);
      expect((exported['wishlist'] as List).length, 1);
      expect((exported['players'] as List).length, 1);
    });

    test('should handle complex data structures', () async {
      final complexData = {
        'games': [
          {
            'id': '1',
            'title': 'Game with special chars',
            'players': '2-4',
            'category': 'Strategy',
            'min_players': 2,
            'max_players': 4,
          },
        ],
        'wishlist': [
          {
            'id': 'w1',
            'title': 'Wishlist Item',
            'price': '\$49.99',
            'purchase_url': 'https://example.com',
          },
        ],
        'players': [
          {'id': 'p1', 'name': 'Player 1'},
        ],
        'settings': [],
      };

      await backupService.importFromJson(jsonEncode(complexData));
      final result = await backupService.exportToJson();
      final decoded = jsonDecode(result) as Map<String, dynamic>;

      expect(decoded['games'][0]['title'], 'Game with special chars');
      expect(decoded['wishlist'][0]['price'], '\$49.99');
    });
  });

  group('BackupService - constructor', () {
    test('should accept database parameter', () {
      final mockDb = MockDatabaseHelper();
      final backupService = BackupService(db: mockDb);

      expect(backupService, isNotNull);
    });

    test('should use default database when not provided', () {
      final backupService = BackupService();

      expect(backupService, isNotNull);
    });
  });
}
