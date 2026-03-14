import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/data/repositories/player_repository.dart';
import 'package:boardpocket/data/database/database_helper.dart';
import 'package:boardpocket/data/models/player.dart';
import '../../helpers/mock_database_interface.dart';

void main() {
  late PlayerRepository repository;
  late MockDatabaseInterface mockDb;

  setUp(() {
    mockDb = MockDatabaseInterface();
    final dbHelper = DatabaseHelper.withInterface(mockDb);
    repository = PlayerRepository(databaseHelper: dbHelper);
  });

  tearDown(() {
    mockDb.clearPlayers();
  });

  group('PlayerRepository', () {
    test('create should insert player and return it', () async {
      final player = Player(id: '1', name: 'John', createdAt: DateTime.now());

      final result = await repository.create(player);

      expect(result.id, equals('1'));
      expect(result.name, equals('John'));
    });

    test('getAll should return all players', () async {
      final player1 = Player(id: '1', name: 'John', createdAt: DateTime.now());
      final player2 = Player(id: '2', name: 'Jane', createdAt: DateTime.now());

      await repository.create(player1);
      await repository.create(player2);

      final players = await repository.getAll();

      expect(players.length, equals(2));
    });

    test('delete should remove player', () async {
      final player = Player(id: '1', name: 'John', createdAt: DateTime.now());

      await repository.create(player);
      expect((await repository.getAll()).length, equals(1));

      await repository.delete('1');

      expect((await repository.getAll()).length, equals(0));
    });

    test('getAll should return empty list when no players', () async {
      final players = await repository.getAll();

      expect(players, isEmpty);
    });
  });
}
