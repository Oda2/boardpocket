import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/data/models/game.dart';

void main() {
  group('Game Model', () {
    late Game game;
    late DateTime createdAt;
    late DateTime updatedAt;

    setUp(() {
      createdAt = DateTime(2024, 1, 1, 10, 0);
      updatedAt = DateTime(2024, 1, 1, 10, 0);
      game = Game(
        id: '1',
        title: 'Catan',
        imagePath: '/path/to/image.jpg',
        players: '3-4',
        time: '60-120 min',
        category: 'Strategy',
        minPlayers: 3,
        maxPlayers: 4,
        playTime: 90,
        complexity: 2.3,
        totalPlays: 10,
        wins: 5,
        losses: 3,
        winRate: 62.5,
        lastPlayed: DateTime(2024, 1, 1),
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    });

    test('should create Game with all properties', () {
      expect(game.id, '1');
      expect(game.title, 'Catan');
      expect(game.imagePath, '/path/to/image.jpg');
      expect(game.players, '3-4');
      expect(game.time, '60-120 min');
      expect(game.category, 'Strategy');
      expect(game.minPlayers, 3);
      expect(game.maxPlayers, 4);
      expect(game.playTime, 90);
      expect(game.complexity, 2.3);
      expect(game.totalPlays, 10);
      expect(game.wins, 5);
      expect(game.losses, 3);
      expect(game.winRate, 62.5);
    });

    test('should convert Game to Map', () {
      final map = game.toMap();

      expect(map['id'], '1');
      expect(map['title'], 'Catan');
      expect(map['image_path'], '/path/to/image.jpg');
      expect(map['players'], '3-4');
      expect(map['time'], '60-120 min');
      expect(map['category'], 'Strategy');
      expect(map['min_players'], 3);
      expect(map['max_players'], 4);
      expect(map['play_time'], 90);
      expect(map['complexity'], 2.3);
      expect(map['total_plays'], 10);
      expect(map['wins'], 5);
      expect(map['losses'], 3);
      expect(map['win_rate'], 62.5);
      expect(map['last_played'], isNotNull);
      expect(map['created_at'], isNotNull);
      expect(map['updated_at'], isNotNull);
    });

    test('should create Game from Map', () {
      final map = {
        'id': '2',
        'title': 'Ticket to Ride',
        'image_path': '/path/to/ttr.jpg',
        'players': '2-5',
        'time': '45-60 min',
        'category': 'Family',
        'min_players': 2,
        'max_players': 5,
        'play_time': 45,
        'complexity': 1.8,
        'total_plays': 5,
        'wins': 2,
        'losses': 3,
        'win_rate': 40.0,
        'last_played': 1704067200000,
        'created_at': 1704067200000,
        'updated_at': 1704067200000,
      };

      final gameFromMap = Game.fromMap(map);

      expect(gameFromMap.id, '2');
      expect(gameFromMap.title, 'Ticket to Ride');
      expect(gameFromMap.imagePath, '/path/to/ttr.jpg');
      expect(gameFromMap.players, '2-5');
      expect(gameFromMap.time, '45-60 min');
      expect(gameFromMap.category, 'Family');
      expect(gameFromMap.minPlayers, 2);
      expect(gameFromMap.maxPlayers, 5);
      expect(gameFromMap.playTime, 45);
      expect(gameFromMap.complexity, 1.8);
      expect(gameFromMap.totalPlays, 5);
      expect(gameFromMap.wins, 2);
      expect(gameFromMap.losses, 3);
      expect(gameFromMap.winRate, 40.0);
    });

    test('should create Game from Map with null optional fields', () {
      final map = {
        'id': '3',
        'title': 'Test Game',
        'image_path': null,
        'players': '2-4',
        'time': '30 min',
        'category': 'Test',
        'min_players': null,
        'max_players': null,
        'play_time': null,
        'complexity': null,
        'total_plays': null,
        'wins': null,
        'losses': null,
        'win_rate': null,
        'last_played': null,
        'created_at': 1704067200000,
        'updated_at': 1704067200000,
      };

      final gameFromMap = Game.fromMap(map);

      expect(gameFromMap.id, '3');
      expect(gameFromMap.title, 'Test Game');
      expect(gameFromMap.imagePath, isNull);
      expect(gameFromMap.minPlayers, isNull);
      expect(gameFromMap.maxPlayers, isNull);
      expect(gameFromMap.playTime, isNull);
      expect(gameFromMap.complexity, isNull);
      expect(gameFromMap.totalPlays, 0);
      expect(gameFromMap.wins, 0);
      expect(gameFromMap.losses, 0);
      expect(gameFromMap.winRate, 0.0);
    });

    test('should copy Game with modified properties', () {
      final copiedGame = game.copyWith(title: 'Catan: Extended', wins: 6);

      expect(copiedGame.id, '1');
      expect(copiedGame.title, 'Catan: Extended');
      expect(copiedGame.wins, 6);
      expect(copiedGame.losses, 3);
      expect(copiedGame.category, 'Strategy');
    });

    test('should calculate win rate correctly', () {
      final gameWithWins = game.copyWith(wins: 5, losses: 5);
      expect(gameWithWins.calculateWinRate(), 50.0);

      final gameNoPlays = game.copyWith(wins: 0, losses: 0);
      expect(gameNoPlays.calculateWinRate(), 0.0);
    });

    test('should calculate win rate with wins only', () {
      final gameOnlyWins = Game(
        id: '1',
        title: 'Test',
        players: '2-4',
        time: '30 min',
        category: 'Test',
        wins: 10,
        losses: 0,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
      expect(gameOnlyWins.calculateWinRate(), 100.0);
    });

    test('should record win correctly', () {
      final gameWithWin = game.recordWin();

      expect(gameWithWin.wins, 6);
      expect(gameWithWin.totalPlays, 11);
      expect(gameWithWin.lastPlayed, isNotNull);
      expect(gameWithWin.updatedAt, isNotNull);
    });

    test('should record loss correctly', () {
      final gameWithLoss = game.recordLoss();

      expect(gameWithLoss.losses, 4);
      expect(gameWithLoss.totalPlays, 11);
      expect(gameWithLoss.lastPlayed, isNotNull);
      expect(gameWithLoss.updatedAt, isNotNull);
    });

    test('should record play correctly', () {
      final gameWithPlay = game.recordPlay();

      expect(gameWithPlay.totalPlays, 11);
      expect(gameWithPlay.lastPlayed, isNotNull);
      expect(gameWithPlay.updatedAt, isNotNull);
    });

    test('should calculate win rate with specific values', () {
      expect(game.calculateWinRateWith(5, 5), 50.0);
      expect(game.calculateWinRateWith(10, 0), 100.0);
      expect(game.calculateWinRateWith(0, 10), 0.0);
      expect(game.calculateWinRateWith(0, 0), 0.0);
    });
  });
}
