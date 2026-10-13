import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:boardpocket/core/components/app_button.dart';
import 'package:boardpocket/core/i18n/app_localizations.dart';
import 'package:boardpocket/data/models/game.dart';
import 'package:boardpocket/data/models/wishlist_item.dart';
import 'package:boardpocket/data/repositories/interfaces/game_repository_interface.dart';
import 'package:boardpocket/data/repositories/interfaces/wishlist_repository_interface.dart';
import 'package:boardpocket/presentation/providers/game_provider.dart';
import 'package:boardpocket/presentation/providers/wishlist_provider.dart';

class _GameRepo implements IGameRepository {
  _GameRepo(this.game);
  final Game game;
  @override
  Future<Game?> getById(String id) async => game;
  @override
  Future<List<Game>> getAll() async => [game];
  @override
  Future<void> recordPlay(String id, bool won) async {}
  @override
  Future<Game> create(Game game) async => game;
  @override
  Future<void> delete(String id) async {}
  @override
  Future<void> update(Game game) async {}
  @override
  Future<List<Game>> getByCategory(String category) async => [game];
  @override
  Future<List<String>> getCategories() async => [game.category];
  @override
  Future<List<Game>> search(String query) async => [game];
}

class _WishlistRepo implements IWishlistRepository {
  final List<WishlistItem> stored = [];

  @override
  Future<WishlistItem> create(WishlistItem item) async {
    stored.add(item);
    return item;
  }

  @override
  Future<void> delete(String id) async => stored.removeWhere((i) => i.id == id);
  @override
  Future<List<WishlistItem>> getAll() async => List.of(stored);
  @override
  Future<WishlistItem?> getById(String id) async =>
      stored.where((i) => i.id == id).firstOrNull;
  @override
  Future<void> update(WishlistItem item) async {}
}

Game _game({String title = 'Catan'}) => Game(
  id: 'g1',
  title: title,
  imagePath: 'https://images.example/cover.jpg',
  players: '3-4',
  time: '60m',
  category: 'Strategy',
  createdAt: DateTime(2026),
  updatedAt: DateTime(2026),
);

void main() {
  group('WishlistProvider.findByTitle', () {
    late WishlistProvider provider;

    Future<void> seed(WishlistProvider p, List<String> titles) async {
      for (final t in titles) {
        await p.addItem(
          WishlistItem(id: t, title: t, createdAt: DateTime(2026)),
        );
      }
    }

    setUp(() {
      provider = WishlistProvider(repository: _WishlistRepo());
    });

    test('finds an exact title', () async {
      await seed(provider, ['Catan', 'Azul']);
      expect(provider.findByTitle('Catan')?.title, 'Catan');
    });

    test('ignores case and surrounding spaces', () async {
      await seed(provider, ['Ticket to Ride']);
      expect(provider.findByTitle('  tIcKeT tO rIdE '), isNotNull);
    });

    test('returns null for an unknown title', () async {
      await seed(provider, ['Catan']);
      expect(provider.findByTitle('Dixit'), isNull);
    });

    test('returns null for a blank query', () async {
      await seed(provider, ['Catan']);
      expect(provider.findByTitle('   '), isNull);
    });
  });

  group('WishlistProvider round trip', () {
    test('adding a game keeps the fields the user would retype', () async {
      final repo = _WishlistRepo();
      final provider = WishlistProvider(repository: repo);

      final game = _game();
      await provider.addItem(
        WishlistItem(
          id: 'w1',
          title: game.title,
          imagePath: game.imagePath,
          players: game.players,
          time: game.time,
          category: game.category,
          createdAt: DateTime.now(),
        ),
      );

      final stored = repo.stored.single;
      expect(stored.title, 'Catan');
      expect(stored.imagePath, 'https://images.example/cover.jpg');
      expect(stored.players, '3-4');
      expect(stored.time, '60m');
      expect(stored.category, 'Strategy');
    });
  });
}
