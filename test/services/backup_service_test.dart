import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/data/services/backup_service.dart';
import 'package:boardpocket/data/database/database_interface.dart';
import '../helpers/mock_database_interface.dart';

void main() {
  group('BackupService - exportToJson', () {
    late MockDatabaseInterface mockDb;
    late BackupService backupService;

    setUp(() {
      mockDb = MockDatabaseInterface();
      backupService = BackupService(db: mockDb);
    });

    test('should export data as JSON string', () async {
      await mockDb.insertGame({'id': '1', 'title': 'Game 1', 'players': '2-4'});

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
      await mockDb.insertGame({'id': '1'});
      await mockDb.insertWishlistItem({'id': '2'});
      await mockDb.insertPlayer({'id': '3'});

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
    late MockDatabaseInterface mockDb;
    late BackupService backupService;

    setUp(() {
      mockDb = MockDatabaseInterface();
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

      final games = await mockDb.getAllGames();
      expect(games.length, 1);
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

      final games = await mockDb.getAllGames();
      expect(games.length, 2);
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

      final wishlist = await mockDb.getAllWishlistItems();
      expect(wishlist.length, 1);
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

      final players = await mockDb.getAllPlayers();
      expect(players.length, 1);
    });

    test('should handle empty JSON structure', () async {
      final jsonString = jsonEncode({});

      await backupService.importFromJson(jsonString);

      final games = await mockDb.getAllGames();
      expect(games.isEmpty, isTrue);
    });

    test('should throw on invalid JSON', () async {
      expect(
        () => backupService.importFromJson('invalid json'),
        throwsA(isA<FormatException>()),
      );
    });

    test('should overwrite existing data on import', () async {
      await mockDb.insertGame({'id': 'old', 'title': 'Old Game'});

      final jsonString = jsonEncode({
        'games': [
          {'id': 'new', 'title': 'New Game'},
        ],
        'wishlist': [],
        'players': [],
        'settings': [],
      });

      await backupService.importFromJson(jsonString);

      final games = await mockDb.getAllGames();
      expect(games.length, 1);
      expect(games.first['id'], 'new');
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
    late MockDatabaseInterface mockDb;
    late BackupService backupService;

    setUp(() {
      mockDb = MockDatabaseInterface();
      backupService = BackupService(db: mockDb);
    });

    test('should return database path', () async {
      final result = await backupService.getDatabasePath();

      expect(result, '/mock/path');
    });
  });

  group('BackupService - shareBackup', () {
    test('should have shareBackup method', () {
      final mockDb = MockDatabaseInterface();
      final backupService = BackupService(db: mockDb);

      expect(backupService.shareBackup, isNotNull);
    });

    test('should be async method', () async {
      final mockDb = MockDatabaseInterface();
      final backupService = BackupService(db: mockDb);

      expect(backupService.shareBackup(), isA<Future<void>>());
    }, skip: true);
  });

  group('BackupService - exportToFile', () {
    test('should have exportToFile method', () {
      final mockDb = MockDatabaseInterface();
      final backupService = BackupService(db: mockDb);

      expect(backupService.exportToFile, isNotNull);
    });

    test('should be async method', () async {
      final mockDb = MockDatabaseInterface();
      final backupService = BackupService(db: mockDb);

      expect(backupService.exportToFile(), isA<Future<void>>());
    }, skip: true);
  });

  group('BackupService - importFromFile', () {
    test('should have importFromFile method', () {
      final mockDb = MockDatabaseInterface();
      final backupService = BackupService(db: mockDb);

      expect(backupService.importFromFile, isNotNull);
    });

    test('should return Future<bool>', () async {
      final mockDb = MockDatabaseInterface();
      final backupService = BackupService(db: mockDb);

      expect(backupService.importFromFile(), isA<Future<bool>>());
    });
  });

  group('BackupService - shareDatabase', () {
    test('should have shareDatabase method', () {
      final mockDb = MockDatabaseInterface();
      final backupService = BackupService(db: mockDb);

      expect(backupService.shareDatabase, isNotNull);
    });

    test('should be async method', () async {
      final mockDb = MockDatabaseInterface();
      final backupService = BackupService(db: mockDb);

      expect(backupService.shareDatabase(), isA<Future<void>>());
    }, skip: true);
  });

  group('BackupService - JSON roundtrip', () {
    late MockDatabaseInterface mockDb;
    late BackupService backupService;

    setUp(() {
      mockDb = MockDatabaseInterface();
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

      await backupService.importFromJson(jsonEncode(originalData));

      final exportedJson = await backupService.exportToJson();
      final exported = jsonDecode(exportedJson) as Map<String, dynamic>;

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
      final mockDb = MockDatabaseInterface();
      final backupService = BackupService(db: mockDb);

      expect(backupService, isNotNull);
    });

    test('should use default database when not provided', () {
      final backupService = BackupService();

      expect(backupService, isNotNull);
    });
  });
}
