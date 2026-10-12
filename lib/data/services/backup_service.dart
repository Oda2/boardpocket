import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../database/database_helper.dart';
import '../database/database_interface.dart';

class BackupService {
  DatabaseInterface? _dbOverride;

  DatabaseInterface get _db => _dbOverride ?? DatabaseHelper.instance;

  BackupService({DatabaseInterface? db}) : _dbOverride = db;

  Future<String> exportToJson() async {
    final data = await _db.exportAllData();
    return jsonEncode(data);
  }

  Future<void> importFromJson(String jsonString) async {
    final data = jsonDecode(jsonString) as Map<String, dynamic>;
    await _db.importAllData(data);
  }

  Future<void> shareBackup() async {
    final jsonData = await exportToJson();
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/boardpocket_backup.json');
    await file.writeAsString(jsonData);

    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], subject: 'BoardPocket Backup'),
    );
  }

  Future<void> exportToFile() async {
    final jsonData = await exportToJson();
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/boardpocket_backup_$timestamp.json');
    await file.writeAsString(jsonData);
  }

  Future<bool> importFromFile() async {
    try {
      // file_picker 13 returns a single PlatformFile (null when cancelled).
      final picked = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (picked == null) return false;

      // readAsBytes() works on both web and mobile/desktop.
      final jsonString = utf8.decode(await picked.readAsBytes());
      await importFromJson(jsonString);
      return true;
    } catch (e) {
      print('Error importing backup: $e');
      return false;
    }
  }

  Future<String> getDatabasePath() async {
    return await _db.getDatabasePath();
  }

  Future<void> shareDatabase() async {
    final dbPath = await getDatabasePath();
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(dbPath)],
        subject: 'BoardPocket Database Backup',
      ),
    );
  }
}
