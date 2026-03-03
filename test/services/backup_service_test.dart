import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';
import 'package:boardpocket/data/services/backup_service.dart';

void main() {
  group('BackupService', () {
    late BackupService backupService;

    setUp(() {
      backupService = BackupService();
    });

    test('should have exportToJson method', () {
      expect(backupService.exportToJson, isNotNull);
    });

    test('should have importFromJson method', () {
      expect(backupService.importFromJson, isNotNull);
    });

    test('should have shareBackup method', () {
      expect(backupService.shareBackup, isNotNull);
    });

    test('should have exportToFile method', () {
      expect(backupService.exportToFile, isNotNull);
    });

    test('should have importFromFile method', () {
      expect(backupService.importFromFile, isNotNull);
    });

    test('should have getDatabasePath method', () {
      expect(backupService.getDatabasePath, isNotNull);
    });

    test('should have shareDatabase method', () {
      expect(backupService.shareDatabase, isNotNull);
    });
  });
}
