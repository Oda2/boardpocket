import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/data/models/game.dart';
import 'package:boardpocket/presentation/viewmodels/game_detail_viewmodel.dart';
import 'package:boardpocket/data/repositories/interfaces/game_repository_interface.dart';

class MockGameRepository implements IGameRepository {
  Game? _mockGame;

  void setMockGame(Game game) {
    _mockGame = game;
  }

  @override
  Future<Game> create(Game game) async => game;

  @override
  Future<List<Game>> getAll() async => _mockGame != null ? [_mockGame!] : [];

  @override
  Future<List<Game>> search(String query) async => [];

  @override
  Future<List<Game>> getByCategory(String category) async => [];

  @override
  Future<List<String>> getCategories() async => [];

  @override
  Future<Game?> getById(String id) async => _mockGame;

  @override
  Future<void> update(Game game) async {
    _mockGame = game;
  }

  @override
  Future<void> delete(String id) async {
    _mockGame = null;
  }

  @override
  Future<void> recordPlay(String id, bool won) async {
    if (_mockGame != null) {
      _mockGame = won ? _mockGame!.recordWin() : _mockGame!.recordLoss();
    }
  }
}

void main() {
  group('GameDetailViewModel', () {
    late GameDetailViewModel viewModel;
    late MockGameRepository mockRepository;

    setUp(() {
      mockRepository = MockGameRepository();
      viewModel = GameDetailViewModel(
        repository: mockRepository,
        gameId: 'test-game-1',
      );
    });

    test('should have no game initially', () {
      expect(viewModel.game, isNull);
      expect(viewModel.hasGame, false);
    });

    test('should not be loading initially', () {
      expect(viewModel.isLoading, false);
    });

    test('should have no error initially', () {
      expect(viewModel.error, isNull);
    });

    test('should load game successfully', () async {
      final testGame = Game(
        id: 'test-game-1',
        title: 'Catan',
        players: '3-4',
        time: '60 min',
        category: 'Strategy',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      mockRepository.setMockGame(testGame);

      await viewModel.loadGame();

      expect(viewModel.game, isNotNull);
      expect(viewModel.game!.title, 'Catan');
      expect(viewModel.isLoading, false);
      expect(viewModel.error, isNull);
    });

    test('should record win correctly', () async {
      final testGame = Game(
        id: 'test-game-1',
        title: 'Catan',
        players: '3-4',
        time: '60 min',
        category: 'Strategy',
        totalPlays: 5,
        wins: 3,
        losses: 2,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      mockRepository.setMockGame(testGame);
      await viewModel.loadGame();

      await viewModel.recordWin();

      expect(viewModel.game!.wins, 4);
      expect(viewModel.game!.totalPlays, 6);
    });

    test('should record loss correctly', () async {
      final testGame = Game(
        id: 'test-game-1',
        title: 'Catan',
        players: '3-4',
        time: '60 min',
        category: 'Strategy',
        totalPlays: 5,
        wins: 3,
        losses: 2,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      mockRepository.setMockGame(testGame);
      await viewModel.loadGame();

      await viewModel.recordLoss();

      expect(viewModel.game!.losses, 3);
      expect(viewModel.game!.totalPlays, 6);
    });

    test('should delete game', () async {
      final testGame = Game(
        id: 'test-game-1',
        title: 'Catan',
        players: '3-4',
        time: '60 min',
        category: 'Strategy',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      mockRepository.setMockGame(testGame);

      await viewModel.deleteGame();

      expect(viewModel.game, isNull);
    });
  });
}
