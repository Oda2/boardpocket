import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:boardpocket/core/di/dependency_injection.dart';
import 'package:boardpocket/data/models/game.dart';
import 'package:boardpocket/data/models/wishlist_item.dart';
import 'package:boardpocket/data/models/player.dart';

void main() {
  group('DependencyInjection', () {
    test('singleton returns same instance', () {
      final instance1 = DependencyInjection();
      final instance2 = DependencyInjection();

      expect(identical(instance1, instance2), isTrue);
    });

    group('init', () {
      test('should initialize only once', () async {
        final di = DependencyInjection();
        await di.init();

        await di.init();
      });

      test(
        'should allow init to be called multiple times without error',
        () async {
          final di = DependencyInjection();
          await di.init();
          await di.init();
        },
      );
    });

    group('resetForTesting', () {
      test('should reset repositories to mocks', () {
        final di = DependencyInjection();
        di.resetForTesting();

        expect(di.gameRepository, isA<MockGameRepository>());
        expect(di.wishlistRepository, isA<MockWishlistRepository>());
        expect(di.playerRepository, isA<MockPlayerRepository>());
        expect(di.settingsRepository, isA<MockSettingsRepository>());
      });
    });

    group('getProviders', () {
      test('should return list of providers', () {
        final di = DependencyInjection();
        di.resetForTesting();
        final providers = getProviders();

        expect(providers, isA<List<ChangeNotifierProvider>>());
        expect(providers.length, equals(5));
      });
    });
  });

  group('MockGameRepository', () {
    late MockGameRepository repository;

    setUp(() {
      repository = MockGameRepository();
    });

    test('create should add game to list', () async {
      final game = Game(
        id: '1',
        title: 'Test Game',
        players: '2-4',
        time: '60m',
        category: 'Strategy',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final result = await repository.create(game);

      expect(result, equals(game));
      expect((await repository.getAll()).length, equals(1));
    });

    test('getAll should return all games', () async {
      final game1 = Game(
        id: '1',
        title: 'Game 1',
        players: '2-4',
        time: '60m',
        category: 'Strategy',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final game2 = Game(
        id: '2',
        title: 'Game 2',
        players: '1-2',
        time: '30m',
        category: 'Party',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.create(game1);
      await repository.create(game2);

      final games = await repository.getAll();

      expect(games.length, equals(2));
    });

    test('search should filter games by title', () async {
      final game1 = Game(
        id: '1',
        title: 'Chess',
        players: '2',
        time: '60m',
        category: 'Strategy',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final game2 = Game(
        id: '2',
        title: 'Checkers',
        players: '2',
        time: '30m',
        category: 'Strategy',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.create(game1);
      await repository.create(game2);

      final results = await repository.search('chess');

      expect(results.length, equals(1));
      expect(results.first.title, equals('Chess'));
    });

    test('getByCategory should filter games by category', () async {
      final game1 = Game(
        id: '1',
        title: 'Chess',
        players: '2',
        time: '60m',
        category: 'Strategy',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final game2 = Game(
        id: '2',
        title: 'Uno',
        players: '2-10',
        time: '30m',
        category: 'Party',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.create(game1);
      await repository.create(game2);

      final results = await repository.getByCategory('Strategy');

      expect(results.length, equals(1));
      expect(results.first.title, equals('Chess'));
    });

    test('getCategories should return unique categories', () async {
      final game1 = Game(
        id: '1',
        title: 'Chess',
        players: '2',
        time: '60m',
        category: 'Strategy',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final game2 = Game(
        id: '2',
        title: 'Checkers',
        players: '2',
        time: '30m',
        category: 'Strategy',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.create(game1);
      await repository.create(game2);

      final categories = await repository.getCategories();

      expect(categories.length, equals(1));
      expect(categories.first, equals('Strategy'));
    });

    test('getById should return game by id', () async {
      final game = Game(
        id: 'test-id',
        title: 'Test Game',
        players: '2-4',
        time: '60m',
        category: 'Strategy',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.create(game);

      final result = await repository.getById('test-id');

      expect(result, isNotNull);
      expect(result!.id, equals('test-id'));
    });

    test('getById should return null for non-existent id', () async {
      final result = await repository.getById('non-existent');

      expect(result, isNull);
    });

    test('update should modify existing game', () async {
      final game = Game(
        id: '1',
        title: 'Original',
        players: '2-4',
        time: '60m',
        category: 'Strategy',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.create(game);

      final updatedGame = Game(
        id: '1',
        title: 'Updated',
        players: '2-4',
        time: '60m',
        category: 'Strategy',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.update(updatedGame);

      final result = await repository.getById('1');
      expect(result!.title, equals('Updated'));
    });

    test('delete should remove game', () async {
      final game = Game(
        id: '1',
        title: 'To Delete',
        players: '2-4',
        time: '60m',
        category: 'Strategy',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.create(game);
      expect((await repository.getAll()).length, equals(1));

      await repository.delete('1');

      expect((await repository.getAll()).length, equals(0));
    });

    test('recordPlay should update wins', () async {
      final game = Game(
        id: '1',
        title: 'Test Game',
        players: '2-4',
        time: '60m',
        category: 'Strategy',
        wins: 0,
        losses: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.create(game);

      await repository.recordPlay('1', true);

      final result = await repository.getById('1');
      expect(result!.wins, equals(1));
    });

    test('recordPlay should update losses', () async {
      final game = Game(
        id: '1',
        title: 'Test Game',
        players: '2-4',
        time: '60m',
        category: 'Strategy',
        wins: 0,
        losses: 0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.create(game);

      await repository.recordPlay('1', false);

      final result = await repository.getById('1');
      expect(result!.losses, equals(1));
    });
  });

  group('MockWishlistRepository', () {
    late MockWishlistRepository repository;

    setUp(() {
      repository = MockWishlistRepository();
    });

    test('create should add item to list', () async {
      final item = WishlistItem(
        id: '1',
        title: 'Wishlist Game',
        category: 'Strategy',
        createdAt: DateTime.now(),
      );

      final result = await repository.create(item);

      expect(result, equals(item));
      expect((await repository.getAll()).length, equals(1));
    });

    test('getAll should return all items', () async {
      final item1 = WishlistItem(
        id: '1',
        title: 'Game 1',
        category: 'Strategy',
        createdAt: DateTime.now(),
      );
      final item2 = WishlistItem(
        id: '2',
        title: 'Game 2',
        category: 'Party',
        createdAt: DateTime.now(),
      );

      await repository.create(item1);
      await repository.create(item2);

      final items = await repository.getAll();

      expect(items.length, equals(2));
    });

    test('getById should return item by id', () async {
      final item = WishlistItem(
        id: 'test-id',
        title: 'Test Item',
        category: 'Strategy',
        createdAt: DateTime.now(),
      );

      await repository.create(item);

      final result = await repository.getById('test-id');

      expect(result, isNotNull);
      expect(result!.id, equals('test-id'));
    });

    test('getById should return null for non-existent id', () async {
      final result = await repository.getById('non-existent');

      expect(result, isNull);
    });

    test('update should modify existing item', () async {
      final item = WishlistItem(
        id: '1',
        title: 'Original',
        category: 'Strategy',
        createdAt: DateTime.now(),
      );

      await repository.create(item);

      final updatedItem = WishlistItem(
        id: '1',
        title: 'Updated',
        category: 'Strategy',
        createdAt: DateTime.now(),
      );

      await repository.update(updatedItem);

      final result = await repository.getById('1');
      expect(result!.title, equals('Updated'));
    });

    test('delete should remove item', () async {
      final item = WishlistItem(
        id: '1',
        title: 'To Delete',
        category: 'Strategy',
        createdAt: DateTime.now(),
      );

      await repository.create(item);
      expect((await repository.getAll()).length, equals(1));

      await repository.delete('1');

      expect((await repository.getAll()).length, equals(0));
    });
  });

  group('MockPlayerRepository', () {
    late MockPlayerRepository repository;

    setUp(() {
      repository = MockPlayerRepository();
    });

    test('create should add player to list', () async {
      final player = Player(
        id: '1',
        name: 'Test Player',
        createdAt: DateTime.now(),
      );

      final result = await repository.create(player);

      expect(result, equals(player));
      expect((await repository.getAll()).length, equals(1));
    });

    test('getAll should return all players', () async {
      final player1 = Player(
        id: '1',
        name: 'Player 1',
        createdAt: DateTime.now(),
      );
      final player2 = Player(
        id: '2',
        name: 'Player 2',
        createdAt: DateTime.now(),
      );

      await repository.create(player1);
      await repository.create(player2);

      final players = await repository.getAll();

      expect(players.length, equals(2));
    });

    test('delete should remove player', () async {
      final player = Player(
        id: '1',
        name: 'To Delete',
        createdAt: DateTime.now(),
      );

      await repository.create(player);
      expect((await repository.getAll()).length, equals(1));

      await repository.delete('1');

      expect((await repository.getAll()).length, equals(0));
    });
  });

  group('MockSettingsRepository', () {
    late MockSettingsRepository repository;

    setUp(() {
      repository = MockSettingsRepository();
    });

    test('getDarkMode should return default value', () async {
      final result = await repository.getDarkMode();

      expect(result, equals(true));
    });

    test('setDarkMode should update dark mode value', () async {
      await repository.setDarkMode(false);

      final result = await repository.getDarkMode();

      expect(result, equals(false));
    });

    test('getLanguage should return default value', () async {
      final result = await repository.getLanguage();

      expect(result, equals('en'));
    });

    test('setLanguage should update language value', () async {
      await repository.setLanguage('pt');

      final result = await repository.getLanguage();

      expect(result, equals('pt'));
    });
  });
}
