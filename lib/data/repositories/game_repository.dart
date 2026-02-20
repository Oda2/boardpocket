import '../../data/database/database_helper.dart';
import '../../data/models/game.dart';

class GameRepository {
  final DatabaseHelper _db = DatabaseHelper.instance;

  Future<Game> create(Game game) async {
    await _db.insertGame(game.toMap());
    return game;
  }

  Future<List<Game>> getAll() async {
    final maps = await _db.getAllGames();
    return maps.map((map) => Game.fromMap(map)).toList();
  }

  Future<List<Game>> search(String query) async {
    final maps = await _db.searchGames(query);
    return maps.map((map) => Game.fromMap(map)).toList();
  }

  Future<List<Game>> getByCategory(String category) async {
    final maps = await _db.getGamesByCategory(category);
    return maps.map((map) => Game.fromMap(map)).toList();
  }

  Future<List<String>> getCategories() async {
    return await _db.getDistinctCategories();
  }

  Future<Game?> getById(String id) async {
    final map = await _db.getGameById(id);
    return map != null ? Game.fromMap(map) : null;
  }

  Future<void> update(Game game) async {
    final updatedGame = game.copyWith(updatedAt: DateTime.now());
    await _db.updateGame(game.id, updatedGame.toMap());
  }

  Future<void> delete(String id) async {
    await _db.deleteGame(id);
  }

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

  Future<void> recordWin(String id) async {
    final game = await getById(id);
    if (game != null) {
      final updatedGame = game.recordWin();
      await update(updatedGame);
    }
  }

  Future<void> recordLoss(String id) async {
    final game = await getById(id);
    if (game != null) {
      final updatedGame = game.recordLoss();
      await update(updatedGame);
    }
  }

  Future<List<Game>> getAllGames() async {
    return await getAll();
  }
}
