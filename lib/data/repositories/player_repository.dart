import '../../data/database/database_helper.dart';
import '../../data/models/player.dart';

class PlayerRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<Player> create(Player player) async {
    await _db.insertPlayer(player.toMap());
    return player;
  }

  Future<List<Player>> getAll() async {
    final maps = await _db.getAllPlayers();
    return maps.map((map) => Player.fromMap(map)).toList();
  }

  Future<void> delete(String id) async {
    await _db.deletePlayer(id);
  }
}
