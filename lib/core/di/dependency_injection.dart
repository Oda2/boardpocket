import 'package:provider/provider.dart';

import '../../data/database/database_helper.dart';
import '../../data/repositories/game_repository.dart';
import '../../data/repositories/player_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/wishlist_repository.dart';
import '../../data/repositories/interfaces/game_repository_interface.dart';
import '../../data/repositories/interfaces/player_repository_interface.dart';
import '../../data/repositories/interfaces/wishlist_repository_interface.dart';
import '../../data/models/game.dart';
import '../../data/models/wishlist_item.dart';
import '../../data/models/player.dart';
import '../../presentation/providers/game_provider.dart';
import '../../presentation/providers/player_provider.dart';
import '../../presentation/providers/settings_provider.dart';
import '../../presentation/providers/wishlist_provider.dart';
import '../../presentation/providers/challenge_provider.dart';

class DependencyInjection {
  static final DependencyInjection _instance = DependencyInjection._internal();
  factory DependencyInjection() => _instance;
  DependencyInjection._internal();

  late final DatabaseHelper _databaseHelper;

  IGameRepository? gameRepository;
  IWishlistRepository? wishlistRepository;
  IPlayerRepository? playerRepository;
  SettingsRepository? settingsRepository;

  bool _initialized = false;

  Future<void> init({DatabaseHelper? databaseHelper}) async {
    if (_initialized) return;

    _databaseHelper = databaseHelper ?? DatabaseHelper.instance;

    gameRepository = GameRepository(databaseHelper: _databaseHelper);
    wishlistRepository = WishlistRepository(databaseHelper: _databaseHelper);
    playerRepository = PlayerRepository(databaseHelper: _databaseHelper);
    settingsRepository = SettingsRepository();

    _initialized = true;
  }

  void resetForTesting() {
    _initialized = false;
    gameRepository = MockGameRepository();
    wishlistRepository = MockWishlistRepository();
    playerRepository = MockPlayerRepository();
    settingsRepository = MockSettingsRepository();
  }
}

class MockGameRepository implements IGameRepository {
  final List<Game> _games = [];

  @override
  Future<Game> create(Game game) async {
    _games.add(game);
    return game;
  }

  @override
  Future<List<Game>> getAll() async => List.from(_games);

  @override
  Future<List<Game>> search(String query) async {
    return _games
        .where((g) => g.title.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<List<Game>> getByCategory(String category) async {
    return _games.where((g) => g.category == category).toList();
  }

  @override
  Future<List<String>> getCategories() async {
    return _games.map((g) => g.category).toSet().toList();
  }

  @override
  Future<Game?> getById(String id) async {
    try {
      return _games.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> update(Game game) async {
    final index = _games.indexWhere((g) => g.id == game.id);
    if (index >= 0) _games[index] = game;
  }

  @override
  Future<void> delete(String id) async {
    _games.removeWhere((g) => g.id == id);
  }

  @override
  Future<void> recordPlay(String id, bool won) async {
    final game = await getById(id);
    if (game != null) {
      final updated = won ? game.recordWin() : game.recordLoss();
      await update(updated);
    }
  }
}

class MockWishlistRepository implements IWishlistRepository {
  final List<WishlistItem> _items = [];

  @override
  Future<WishlistItem> create(WishlistItem item) async {
    _items.add(item);
    return item;
  }

  @override
  Future<List<WishlistItem>> getAll() async => List.from(_items);

  @override
  Future<WishlistItem?> getById(String id) async {
    try {
      return _items.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> update(WishlistItem item) async {
    final index = _items.indexWhere((i) => i.id == item.id);
    if (index >= 0) _items[index] = item;
  }

  @override
  Future<void> delete(String id) async {
    _items.removeWhere((i) => i.id == id);
  }
}

class MockPlayerRepository implements IPlayerRepository {
  final List<Player> _players = [];

  @override
  Future<Player> create(Player player) async {
    _players.add(player);
    return player;
  }

  @override
  Future<List<Player>> getAll() async => List.from(_players);

  @override
  Future<void> delete(String id) async {
    _players.removeWhere((p) => p.id == id);
  }
}

class MockSettingsRepository implements SettingsRepository {
  bool _isDarkMode = true;
  String _language = 'en';

  @override
  Future<bool> getDarkMode() async => _isDarkMode;

  @override
  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
  }

  @override
  Future<String> getLanguage() async => _language;

  @override
  Future<void> setLanguage(String value) async {
    _language = value;
  }
}

List<ChangeNotifierProvider> getProviders() {
  final di = DependencyInjection();

  return [
    ChangeNotifierProvider(
      create: (_) => GameProvider(repository: di.gameRepository!),
    ),
    ChangeNotifierProvider(
      create: (_) => WishlistProvider(repository: di.wishlistRepository!),
    ),
    ChangeNotifierProvider(
      create: (_) => PlayerProvider(repository: di.playerRepository!),
    ),
    ChangeNotifierProvider(
      create: (_) =>
          SettingsProvider(repository: di.settingsRepository!)..loadSettings(),
    ),
    ChangeNotifierProvider(create: (_) => ChallengeProvider()),
  ];
}
