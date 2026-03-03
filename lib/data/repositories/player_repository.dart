import '../database/database_helper.dart';
import '../models/player.dart';
import 'interfaces/player_repository_interface.dart';

class PlayerRepository implements IPlayerRepository {
  final DatabaseHelper _db;

  PlayerRepository({DatabaseHelper? databaseHelper})
    : _db = databaseHelper ?? DatabaseHelper.instance;

  @override
  Future<Player> create(Player player) async {
    await _db.insertPlayer(player.toMap());
    return player;
  }

  @override
  Future<List<Player>> getAll() async {
    final maps = await _db.getAllPlayers();
    return maps.map((map) => Player.fromMap(map)).toList();
  }

  @override
  Future<void> delete(String id) async {
    await _db.deletePlayer(id);
  }
}
