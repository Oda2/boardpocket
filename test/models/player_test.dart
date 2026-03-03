import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/data/models/player.dart';

void main() {
  group('Player Model', () {
    late Player player;
    late DateTime createdAt;

    setUp(() {
      createdAt = DateTime(2024, 1, 1, 10, 0);
      player = Player(id: '1', name: 'John Doe', createdAt: createdAt);
    });

    test('should create Player with all properties', () {
      expect(player.id, '1');
      expect(player.name, 'John Doe');
      expect(player.createdAt, createdAt);
    });

    test('should convert Player to Map', () {
      final map = player.toMap();

      expect(map['id'], '1');
      expect(map['name'], 'John Doe');
      expect(map['created_at'], createdAt.millisecondsSinceEpoch);
    });

    test('should create Player from Map', () {
      final map = {'id': '2', 'name': 'Jane Doe', 'created_at': 1704067200000};

      final playerFromMap = Player.fromMap(map);

      expect(playerFromMap.id, '2');
      expect(playerFromMap.name, 'Jane Doe');
      expect(playerFromMap.createdAt.millisecondsSinceEpoch, 1704067200000);
    });

    test('should copy Player with modified properties', () {
      final copiedPlayer = player.copyWith(name: 'John Smith');

      expect(copiedPlayer.id, '1');
      expect(copiedPlayer.name, 'John Smith');
      expect(copiedPlayer.createdAt, createdAt);
    });

    test('should copy Player with modified id', () {
      final copiedPlayer = player.copyWith(id: '2');

      expect(copiedPlayer.id, '2');
      expect(copiedPlayer.name, 'John Doe');
    });

    test('should copy Player with modified createdAt', () {
      final newDate = DateTime(2024, 2, 1);
      final copiedPlayer = player.copyWith(createdAt: newDate);

      expect(copiedPlayer.id, '1');
      expect(copiedPlayer.name, 'John Doe');
      expect(copiedPlayer.createdAt, newDate);
    });
  });
}
