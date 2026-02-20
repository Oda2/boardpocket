import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../database/database_helper.dart';

class BackupService {
  final DatabaseHelper _db = DatabaseHelper.instance;

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

    await Share.shareXFiles([XFile(file.path)], subject: 'BoardPocket Backup');
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
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        final jsonString = await file.readAsString();
        await importFromJson(jsonString);
        return true;
      }
      return false;
    } catch (e) {
      print('Error importing backup: $e');
      return false;
    }
  }

  Future<String> getDatabasePath() async {
    return await _db.database.then((db) => db.path);
  }

  Future<void> shareDatabase() async {
    final dbPath = await getDatabasePath();
    await Share.shareXFiles([
      XFile(dbPath),
    ], subject: 'BoardPocket Database Backup');
  }
}
