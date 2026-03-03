import '../../models/player.dart';

abstract class IPlayerRepository {
  Future<Player> create(Player player);
  Future<List<Player>> getAll();
  Future<void> delete(String id);
}
