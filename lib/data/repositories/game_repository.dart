import '../database/database_helper.dart';
import '../database/database_interface.dart';
import '../models/game.dart';
import 'interfaces/game_repository_interface.dart';

class GameRepository implements IGameRepository {
  final DatabaseInterface _db;

  GameRepository({DatabaseInterface? databaseHelper})
    : _db = databaseHelper ?? DatabaseHelper.instance;

  @override
  Future<Game> create(Game game) async {
    await _db.insertGame(game.toMap());
    return game;
  }

  @override
  Future<List<Game>> getAll() async {
    final maps = await _db.getAllGames();
    return maps.map((map) => Game.fromMap(map)).toList();
  }

  @override
  Future<List<Game>> search(String query) async {
    final maps = await _db.searchGames(query);
    return maps.map((map) => Game.fromMap(map)).toList();
  }

  @override
  Future<List<Game>> getByCategory(String category) async {
    final maps = await _db.getGamesByCategory(category);
    return maps.map((map) => Game.fromMap(map)).toList();
  }

  @override
  Future<List<String>> getCategories() async {
    return await _db.getDistinctCategories();
  }

  @override
  Future<Game?> getById(String id) async {
    final map = await _db.getGameById(id);
    return map != null ? Game.fromMap(map) : null;
  }

  @override
  Future<void> update(Game game) async {
    final updatedGame = game.copyWith(updatedAt: DateTime.now());
    await _db.updateGame(game.id, updatedGame.toMap());
  }

  @override
  Future<void> delete(String id) async {
    await _db.deleteGame(id);
  }

  @override
  Future<void> recordPlay(String id, bool won) async {
    final game = await getById(id);
    if (game != null) {
      Game updatedGame;
      if (won) {
        updatedGame = game.recordWin();
      } else {
        updatedGame = game.recordLoss();
      }
      await update(updatedGame);
    }
  }
}
