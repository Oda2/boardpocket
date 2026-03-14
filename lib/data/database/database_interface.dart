abstract class DatabaseInterface {
  Future<String> getDatabasePath();
  Future<String> insertGame(Map<String, dynamic> game);
  Future<List<Map<String, dynamic>>> getAllGames();
  Future<List<Map<String, dynamic>>> searchGames(String query);
  Future<List<Map<String, dynamic>>> getGamesByCategory(String category);
  Future<List<String>> getDistinctCategories();
  Future<Map<String, dynamic>?> getGameById(String id);
  Future<int> updateGame(String id, Map<String, dynamic> game);
  Future<int> deleteGame(String id);

  Future<String> insertWishlistItem(Map<String, dynamic> item);
  Future<List<Map<String, dynamic>>> getAllWishlistItems();
  Future<int> updateWishlistItem(String id, Map<String, dynamic> item);
  Future<int> deleteWishlistItem(String id);

  Future<String> insertPlayer(Map<String, dynamic> player);
  Future<List<Map<String, dynamic>>> getAllPlayers();
  Future<int> deletePlayer(String id);

  Future<Map<String, dynamic>> exportAllData();
  Future<void> importAllData(Map<String, dynamic> data);

  Future<void> close();
}
