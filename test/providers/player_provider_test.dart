import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/data/models/player.dart';
import 'package:boardpocket/presentation/providers/player_provider.dart';
import 'package:boardpocket/data/repositories/interfaces/player_repository_interface.dart';

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

  void addTestPlayer(Player player) {
    _players.add(player);
  }
}

Player createTestPlayer({String id = 'player-1', String name = 'Player One'}) {
  return Player(id: id, name: name, createdAt: DateTime.now());
}

void main() {
  group('PlayerProvider - State', () {
    late PlayerProvider playerProvider;
    late MockPlayerRepository mockRepository;

    setUp(() {
      mockRepository = MockPlayerRepository();
      playerProvider = PlayerProvider(repository: mockRepository);
    });

    test('should have empty players list initially', () {
      expect(playerProvider.players, isEmpty);
    });

    test('should have null winner initially', () {
      expect(playerProvider.winner, isNull);
    });

    test('should not be drawing initially', () {
      expect(playerProvider.isDrawing, false);
    });
  });

  group('PlayerProvider - loadPlayers', () {
    late PlayerProvider playerProvider;
    late MockPlayerRepository mockRepository;

    setUp(() {
      mockRepository = MockPlayerRepository();
      playerProvider = PlayerProvider(repository: mockRepository);
    });

    test('should load players from repository', () async {
      mockRepository.addTestPlayer(createTestPlayer(id: '1', name: 'Alice'));
      mockRepository.addTestPlayer(createTestPlayer(id: '2', name: 'Bob'));

      await playerProvider.loadPlayers();

      expect(playerProvider.players.length, 2);
    });

    test('should have empty list when no players', () async {
      await playerProvider.loadPlayers();

      expect(playerProvider.players, isEmpty);
    });
  });

  group('PlayerProvider - addPlayer', () {
    late PlayerProvider playerProvider;
    late MockPlayerRepository mockRepository;

    setUp(() async {
      mockRepository = MockPlayerRepository();
      playerProvider = PlayerProvider(repository: mockRepository);
      await playerProvider.loadPlayers();
    });

    test('should add player to repository', () async {
      await playerProvider.addPlayer('Alice');

      expect(playerProvider.players.length, 1);
      expect(playerProvider.players.first.name, 'Alice');
    });

    test('should generate unique id for new player', () async {
      await playerProvider.addPlayer('Alice');

      expect(playerProvider.players.first.id, isNotEmpty);
    });
  });

  group('PlayerProvider - deletePlayer', () {
    late PlayerProvider playerProvider;
    late MockPlayerRepository mockRepository;

    setUp(() async {
      mockRepository = MockPlayerRepository();
      mockRepository.addTestPlayer(createTestPlayer(id: '1', name: 'Alice'));
      mockRepository.addTestPlayer(createTestPlayer(id: '2', name: 'Bob'));

      playerProvider = PlayerProvider(repository: mockRepository);
      await playerProvider.loadPlayers();
    });

    test('should remove player from list', () async {
      await playerProvider.deletePlayer('1');

      expect(playerProvider.players.length, 1);
      expect(playerProvider.players.any((p) => p.id == '1'), false);
    });

    test('should keep other players when deleting', () async {
      await playerProvider.deletePlayer('1');

      expect(playerProvider.players.any((p) => p.id == '2'), true);
    });
  });

  group('PlayerProvider - drawWinner', () {
    late PlayerProvider playerProvider;
    late MockPlayerRepository mockRepository;

    setUp(() async {
      mockRepository = MockPlayerRepository();
      mockRepository.addTestPlayer(createTestPlayer(id: '1', name: 'Alice'));
      mockRepository.addTestPlayer(createTestPlayer(id: '2', name: 'Bob'));
      mockRepository.addTestPlayer(createTestPlayer(id: '3', name: 'Charlie'));

      playerProvider = PlayerProvider(repository: mockRepository);
      await playerProvider.loadPlayers();
    });

    test('should set isDrawing to true when drawing', () {
      playerProvider.drawWinner();

      expect(playerProvider.isDrawing, true);
    });

    test('should set winner after delay', () async {
      playerProvider.drawWinner();

      await Future.delayed(const Duration(seconds: 1));

      expect(playerProvider.winner, isNotNull);
      expect(['Alice', 'Bob', 'Charlie'], contains(playerProvider.winner));
    });

    test('should set isDrawing back to false after drawing', () async {
      playerProvider.drawWinner();

      await Future.delayed(const Duration(seconds: 1));

      expect(playerProvider.isDrawing, false);
    });

    test('should do nothing when no players', () {
      final emptyProvider = PlayerProvider(repository: MockPlayerRepository());
      emptyProvider.drawWinner();

      expect(emptyProvider.winner, isNull);
      expect(emptyProvider.isDrawing, false);
    });
  });

  group('PlayerProvider - clearWinner', () {
    late PlayerProvider playerProvider;
    late MockPlayerRepository mockRepository;

    setUp(() async {
      mockRepository = MockPlayerRepository();
      mockRepository.addTestPlayer(createTestPlayer(id: '1', name: 'Alice'));

      playerProvider = PlayerProvider(repository: mockRepository);
      await playerProvider.loadPlayers();
    });

    test('should clear winner', () async {
      playerProvider.drawWinner();
      await Future.delayed(const Duration(seconds: 1));

      playerProvider.clearWinner();

      expect(playerProvider.winner, isNull);
    });

    test('should notify listeners when clearing winner', () {
      bool notified = false;
      playerProvider.addListener(() {
        notified = true;
      });

      playerProvider.clearWinner();

      expect(notified, true);
    });
  });
}
