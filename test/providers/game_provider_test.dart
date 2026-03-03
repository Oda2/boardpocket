import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/data/models/game.dart';
import 'package:boardpocket/presentation/providers/game_provider.dart';
import 'package:boardpocket/data/repositories/interfaces/game_repository_interface.dart';

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

  void addTestGame(Game game) {
    _games.add(game);
  }
}

Game createTestGame({
  String id = 'game-1',
  String title = 'Catan',
  String players = '3-4',
  String time = '60 min',
  String category = 'Strategy',
  int totalPlays = 0,
  int wins = 0,
  int losses = 0,
}) {
  return Game(
    id: id,
    title: title,
    players: players,
    time: time,
    category: category,
    totalPlays: totalPlays,
    wins: wins,
    losses: losses,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

void main() {
  group('GameProvider - State', () {
    late GameProvider gameProvider;
    late MockGameRepository mockRepository;

    setUp(() {
      mockRepository = MockGameRepository();
      gameProvider = GameProvider(repository: mockRepository);
    });

    test('should have empty games list initially', () {
      expect(gameProvider.games, isEmpty);
    });

    test('should have empty categories initially', () {
      expect(gameProvider.categories, isEmpty);
    });

    test('should have All as default category', () {
      expect(gameProvider.selectedCategory, 'All');
    });

    test('should have empty search query initially', () {
      expect(gameProvider.searchQuery, '');
    });

    test('should not be loading initially', () {
      expect(gameProvider.isLoading, false);
    });
  });

  group('GameProvider - setCategory', () {
    late GameProvider gameProvider;
    late MockGameRepository mockRepository;

    setUp(() {
      mockRepository = MockGameRepository();
      gameProvider = GameProvider(repository: mockRepository);
    });

    test('should set category', () {
      gameProvider.setCategory('Strategy');
      expect(gameProvider.selectedCategory, 'Strategy');
    });

    test('should set category back to All', () {
      gameProvider.setCategory('Family');
      gameProvider.setCategory('All');
      expect(gameProvider.selectedCategory, 'All');
    });

    test('should notify listeners when category changes', () {
      bool notified = false;
      gameProvider.addListener(() {
        notified = true;
      });

      gameProvider.setCategory('Family');

      expect(notified, true);
    });
  });

  group('GameProvider - setSearchQuery', () {
    late GameProvider gameProvider;
    late MockGameRepository mockRepository;

    setUp(() {
      mockRepository = MockGameRepository();
      gameProvider = GameProvider(repository: mockRepository);
    });

    test('should set search query', () {
      gameProvider.setSearchQuery('Catan');
      expect(gameProvider.searchQuery, 'Catan');
    });

    test('should clear search query', () {
      gameProvider.setSearchQuery('Catan');
      gameProvider.setSearchQuery('');
      expect(gameProvider.searchQuery, '');
    });

    test('should notify listeners when search query changes', () {
      bool notified = false;
      gameProvider.addListener(() {
        notified = true;
      });

      gameProvider.setSearchQuery('Test');

      expect(notified, true);
    });
  });

  group('GameProvider - loadGames', () {
    late GameProvider gameProvider;
    late MockGameRepository mockRepository;

    setUp(() {
      mockRepository = MockGameRepository();
      gameProvider = GameProvider(repository: mockRepository);
    });

    test('should load games from repository', () async {
      mockRepository.addTestGame(createTestGame(id: '1', title: 'Catan'));
      mockRepository.addTestGame(createTestGame(id: '2', title: 'Monopoly'));

      await gameProvider.loadGames();

      expect(gameProvider.games.length, 2);
      expect(gameProvider.isLoading, false);
    });

    test('should load categories from repository', () async {
      mockRepository.addTestGame(createTestGame(category: 'Strategy'));
      mockRepository.addTestGame(createTestGame(category: 'Family'));
      mockRepository.addTestGame(createTestGame(category: 'Strategy'));

      await gameProvider.loadGames();

      expect(gameProvider.categories, containsAll(['Strategy', 'Family']));
    });

    test('should set isLoading during load', () async {
      mockRepository.addTestGame(createTestGame());

      final future = gameProvider.loadGames();

      expect(gameProvider.isLoading, true);

      await future;

      expect(gameProvider.isLoading, false);
    });
  });

  group('GameProvider - filteredGames', () {
    late GameProvider gameProvider;
    late MockGameRepository mockRepository;

    setUp(() async {
      mockRepository = MockGameRepository();
      mockRepository.addTestGame(
        createTestGame(id: '1', title: 'Catan', category: 'Strategy'),
      );
      mockRepository.addTestGame(
        createTestGame(id: '2', title: 'Monopoly', category: 'Family'),
      );
      mockRepository.addTestGame(
        createTestGame(id: '3', title: 'Chess', category: 'Strategy'),
      );

      gameProvider = GameProvider(repository: mockRepository);
      await gameProvider.loadGames();
    });

    test('should return all games when no filter applied', () {
      expect(gameProvider.filteredGames.length, 3);
    });

    test('should filter games by category', () {
      gameProvider.setCategory('Strategy');

      expect(gameProvider.filteredGames.length, 2);
      expect(
        gameProvider.filteredGames.every((g) => g.category == 'Strategy'),
        true,
      );
    });

    test('should return empty list when category has no games', () {
      gameProvider.setCategory('Party');

      expect(gameProvider.filteredGames, isEmpty);
    });

    test('should filter games by search query', () {
      gameProvider.setSearchQuery('Cat');

      expect(gameProvider.filteredGames.length, 1);
      expect(gameProvider.filteredGames.first.title, 'Catan');
    });

    test('should filter games by search query case insensitive', () {
      gameProvider.setSearchQuery('CATAN');

      expect(gameProvider.filteredGames.length, 1);
    });

    test('should return empty when search has no matches', () {
      gameProvider.setSearchQuery('NonExistent');

      expect(gameProvider.filteredGames, isEmpty);
    });

    test('should combine category and search filters', () {
      gameProvider.setCategory('Strategy');
      gameProvider.setSearchQuery('Cat');

      expect(gameProvider.filteredGames.length, 1);
      expect(gameProvider.filteredGames.first.title, 'Catan');
    });

    test('should return empty when category and search conflict', () {
      gameProvider.setCategory('Family');
      gameProvider.setSearchQuery('Cat');

      expect(gameProvider.filteredGames, isEmpty);
    });

    test('should return all when category is All regardless of search', () {
      gameProvider.setCategory('All');
      gameProvider.setSearchQuery('Catan');

      expect(gameProvider.filteredGames.length, 1);
    });
  });

  group('GameProvider - addGame', () {
    late GameProvider gameProvider;
    late MockGameRepository mockRepository;

    setUp(() async {
      mockRepository = MockGameRepository();
      gameProvider = GameProvider(repository: mockRepository);
      await gameProvider.loadGames();
    });

    test('should add game to repository', () async {
      final newGame = createTestGame(id: 'new-1', title: 'New Game');

      await gameProvider.addGame(newGame);

      expect(gameProvider.games.length, 1);
      expect(gameProvider.games.first.title, 'New Game');
    });
  });

  group('GameProvider - deleteGame', () {
    late GameProvider gameProvider;
    late MockGameRepository mockRepository;

    setUp(() async {
      mockRepository = MockGameRepository();
      mockRepository.addTestGame(createTestGame(id: '1', title: 'Game 1'));
      mockRepository.addTestGame(createTestGame(id: '2', title: 'Game 2'));

      gameProvider = GameProvider(repository: mockRepository);
      await gameProvider.loadGames();
    });

    test('should remove game from list', () async {
      await gameProvider.deleteGame('1');

      expect(gameProvider.games.length, 1);
      expect(gameProvider.games.any((g) => g.id == '1'), false);
    });

    test('should keep other games when deleting', () async {
      await gameProvider.deleteGame('1');

      expect(gameProvider.games.any((g) => g.id == '2'), true);
    });
  });

  group('GameProvider - getGameById', () {
    late GameProvider gameProvider;
    late MockGameRepository mockRepository;

    setUp(() async {
      mockRepository = MockGameRepository();
      mockRepository.addTestGame(createTestGame(id: '1', title: 'Catan'));
      mockRepository.addTestGame(createTestGame(id: '2', title: 'Monopoly'));

      gameProvider = GameProvider(repository: mockRepository);
      await gameProvider.loadGames();
    });

    test('should return game when exists', () async {
      final game = await gameProvider.getGameById('1');

      expect(game, isNotNull);
      expect(game!.title, 'Catan');
    });

    test('should return null when game does not exist', () async {
      final game = await gameProvider.getGameById('non-existent');

      expect(game, isNull);
    });
  });

  group('GameProvider - recordPlay', () {
    late GameProvider gameProvider;
    late MockGameRepository mockRepository;

    setUp(() async {
      mockRepository = MockGameRepository();
      mockRepository.addTestGame(
        Game(
          id: '1',
          title: 'Catan',
          players: '3-4',
          time: '60 min',
          category: 'Strategy',
          totalPlays: 5,
          wins: 3,
          losses: 2,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      gameProvider = GameProvider(repository: mockRepository);
      await gameProvider.loadGames();
    });

    test('should record win and reload games', () async {
      await gameProvider.recordPlay('1', true);

      final game = gameProvider.games.firstWhere((g) => g.id == '1');
      expect(game.wins, 4);
      expect(game.totalPlays, 6);
    });

    test('should record loss and reload games', () async {
      await gameProvider.recordPlay('1', false);

      final game = gameProvider.games.firstWhere((g) => g.id == '1');
      expect(game.losses, 3);
      expect(game.totalPlays, 6);
    });
  });

  group('GameProvider - updateGame', () {
    late GameProvider gameProvider;
    late MockGameRepository mockRepository;

    setUp(() async {
      mockRepository = MockGameRepository();
      mockRepository.addTestGame(
        createTestGame(id: '1', title: 'Original Title'),
      );

      gameProvider = GameProvider(repository: mockRepository);
      await gameProvider.loadGames();
    });

    test('should update game and reload', () async {
      final updatedGame = createTestGame(id: '1', title: 'Updated Title');

      await gameProvider.updateGame(updatedGame);

      final game = gameProvider.games.firstWhere((g) => g.id == '1');
      expect(game.title, 'Updated Title');
    });
  });
}
