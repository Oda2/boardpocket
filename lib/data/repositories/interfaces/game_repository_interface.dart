import '../../models/game.dart';

abstract class IGameRepository {
  Future<Game> create(Game game);
  Future<List<Game>> getAll();
  Future<List<Game>> search(String query);
  Future<List<Game>> getByCategory(String category);
  Future<List<String>> getCategories();
  Future<Game?> getById(String id);
  Future<void> update(Game game);
  Future<void> delete(String id);
  Future<void> recordPlay(String id, bool won);
}
