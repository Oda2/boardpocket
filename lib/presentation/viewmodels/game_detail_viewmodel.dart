import '../../data/models/game.dart';
import '../../data/repositories/interfaces/game_repository_interface.dart';

class GameDetailViewModel {
  final IGameRepository _repository;
  final String gameId;

  Game? _game;
  bool _isLoading = false;
  String? _error;

  GameDetailViewModel({
    required IGameRepository repository,
    required this.gameId,
  }) : _repository = repository;

  Game? get game => _game;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasGame => _game != null;

  Future<void> loadGame() async {
    _isLoading = true;
    _error = null;

    try {
      _game = await _repository.getById(gameId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
    }
  }

  Future<void> recordWin() async {
    if (_game == null) return;
    await _repository.recordPlay(gameId, true);
    await loadGame();
  }

  Future<void> recordLoss() async {
    if (_game == null) return;
    await _repository.recordPlay(gameId, false);
    await loadGame();
  }

  Future<void> deleteGame() async {
    await _repository.delete(gameId);
  }
}
