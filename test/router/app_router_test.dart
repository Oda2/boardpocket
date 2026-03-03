import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:boardpocket/router/app_router.dart';
import 'package:boardpocket/presentation/screens/screens.dart';

class MockGoRouterState implements GoRouterState {
  @override
  final String matchedLocation = '';

  @override
  final Uri uri = Uri.parse('/');

  @override
  final Map<String, String> pathParameters;

  @override
  final Map<String, String> queryParameters = {};

  @override
  final Object? extra;

  @override
  final String? errorMessage;

  @override
  final String? fullPath;

  @override
  final String? name;

  @override
  final GoException? error;

  @override
  final ValueKey<String> pageKey = const ValueKey<String>('test');

  @override
  final String? path;

  @override
  final GoRoute? topRoute;

  MockGoRouterState({
    this.pathParameters = const {},
    this.extra,
    this.errorMessage,
    this.fullPath,
    this.name,
    this.error,
    this.path,
    this.topRoute,
  });

  @override
  String namedLocation(
    String name, {
    String? fragment,
    Map<String, String>? pathParameters,
    Map<String, String>? queryParameters,
  }) {
    return '/';
  }
}

class MockBuildContext implements BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  group('appRouter - Route Configuration', () {
    test('should have correct number of routes', () {
      final routes = appRouter.configuration.routes
          .whereType<GoRoute>()
          .toList();
      expect(routes.length, 15);
    });

    test('should have root route', () {
      final routes = appRouter.configuration.routes;
      final rootRoute = routes.whereType<GoRoute>().firstWhere(
        (r) => r.path == '/',
      );
      expect(rootRoute.path, '/');
    });

    test('should have add-game route', () {
      final routes = appRouter.configuration.routes
          .whereType<GoRoute>()
          .toList();
      final addGameRoute = routes.firstWhere((r) => r.path == '/add-game');
      expect(addGameRoute.path, '/add-game');
    });

    test('should have edit-game route with path parameter', () {
      final routes = appRouter.configuration.routes
          .whereType<GoRoute>()
          .toList();
      final editGameRoute = routes.firstWhere(
        (r) => r.path == '/edit-game/:id',
      );
      expect(editGameRoute.path, '/edit-game/:id');
    });

    test('should have game-detail route with path parameter', () {
      final routes = appRouter.configuration.routes
          .whereType<GoRoute>()
          .toList();
      final gameDetailRoute = routes.firstWhere(
        (r) => r.path == '/game-detail/:id',
      );
      expect(gameDetailRoute.path, '/game-detail/:id');
    });

    test('should have randomizer route', () {
      final routes = appRouter.configuration.routes
          .whereType<GoRoute>()
          .toList();
      final randomizerRoute = routes.firstWhere((r) => r.path == '/randomizer');
      expect(randomizerRoute.path, '/randomizer');
    });

    test('should have randomizer-finger route', () {
      final routes = appRouter.configuration.routes
          .whereType<GoRoute>()
          .toList();
      final fingerRoute = routes.firstWhere(
        (r) => r.path == '/randomizer-finger',
      );
      expect(fingerRoute.path, '/randomizer-finger');
    });

    test('should have randomizer-name route', () {
      final routes = appRouter.configuration.routes
          .whereType<GoRoute>()
          .toList();
      final nameRoute = routes.firstWhere((r) => r.path == '/randomizer-name');
      expect(nameRoute.path, '/randomizer-name');
    });

    test('should have ranking route', () {
      final routes = appRouter.configuration.routes
          .whereType<GoRoute>()
          .toList();
      final rankingRoute = routes.firstWhere((r) => r.path == '/ranking');
      expect(rankingRoute.path, '/ranking');
    });

    test('should have randomizer-challenge route', () {
      final routes = appRouter.configuration.routes
          .whereType<GoRoute>()
          .toList();
      final challengeRoute = routes.firstWhere(
        (r) => r.path == '/randomizer-challenge',
      );
      expect(challengeRoute.path, '/randomizer-challenge');
    });

    test('should have randomizer-game route', () {
      final routes = appRouter.configuration.routes
          .whereType<GoRoute>()
          .toList();
      final randomGameRoute = routes.firstWhere(
        (r) => r.path == '/randomizer-game',
      );
      expect(randomGameRoute.path, '/randomizer-game');
    });

    test('should have wishlist route', () {
      final routes = appRouter.configuration.routes
          .whereType<GoRoute>()
          .toList();
      final wishlistRoute = routes.firstWhere((r) => r.path == '/wishlist');
      expect(wishlistRoute.path, '/wishlist');
    });

    test('should have add-wishlist route', () {
      final routes = appRouter.configuration.routes
          .whereType<GoRoute>()
          .toList();
      final addWishlistRoute = routes.firstWhere(
        (r) => r.path == '/add-wishlist',
      );
      expect(addWishlistRoute.path, '/add-wishlist');
    });

    test('should have edit-wishlist route with path parameter', () {
      final routes = appRouter.configuration.routes
          .whereType<GoRoute>()
          .toList();
      final editWishlistRoute = routes.firstWhere(
        (r) => r.path == '/edit-wishlist/:id',
      );
      expect(editWishlistRoute.path, '/edit-wishlist/:id');
    });

    test('should have settings route', () {
      final routes = appRouter.configuration.routes
          .whereType<GoRoute>()
          .toList();
      final settingsRoute = routes.firstWhere((r) => r.path == '/settings');
      expect(settingsRoute.path, '/settings');
    });

    test('should have privacy-policy route', () {
      final routes = appRouter.configuration.routes
          .whereType<GoRoute>()
          .toList();
      final privacyRoute = routes.firstWhere(
        (r) => r.path == '/privacy-policy',
      );
      expect(privacyRoute.path, '/privacy-policy');
    });

    test('should have all expected routes defined', () {
      final routes = appRouter.configuration.routes
          .whereType<GoRoute>()
          .toList();
      final paths = routes.map((r) => r.path).toSet();

      expect(paths.contains('/'), isTrue);
      expect(paths.contains('/add-game'), isTrue);
      expect(paths.contains('/edit-game/:id'), isTrue);
      expect(paths.contains('/game-detail/:id'), isTrue);
      expect(paths.contains('/randomizer'), isTrue);
      expect(paths.contains('/randomizer-finger'), isTrue);
      expect(paths.contains('/randomizer-name'), isTrue);
      expect(paths.contains('/ranking'), isTrue);
      expect(paths.contains('/randomizer-challenge'), isTrue);
      expect(paths.contains('/randomizer-game'), isTrue);
      expect(paths.contains('/wishlist'), isTrue);
      expect(paths.contains('/add-wishlist'), isTrue);
      expect(paths.contains('/edit-wishlist/:id'), isTrue);
      expect(paths.contains('/settings'), isTrue);
      expect(paths.contains('/privacy-policy'), isTrue);
      expect(paths.length, 15);
    });
  });

  group('appRouter - Route Builders', () {
    test('root route should have CollectionScreen builder', () {
      final routes = appRouter.configuration.routes
          .whereType<GoRoute>()
          .toList();
      final rootRoute = routes.firstWhere((r) => r.path == '/');
      expect(rootRoute.builder, isNotNull);
    });

    test('add-game route should have AddGameScreen builder', () {
      final routes = appRouter.configuration.routes
          .whereType<GoRoute>()
          .toList();
      final addGameRoute = routes.firstWhere((r) => r.path == '/add-game');
      expect(addGameRoute.builder, isNotNull);
    });

    test('edit-game route should have AddGameScreen builder with gameId', () {
      final routes = appRouter.configuration.routes
          .whereType<GoRoute>()
          .toList();
      final editGameRoute = routes.firstWhere(
        (r) => r.path == '/edit-game/:id',
      );
      expect(editGameRoute.builder, isNotNull);
    });

    test('game-detail route should have GameDetailScreen builder', () {
      final routes = appRouter.configuration.routes
          .whereType<GoRoute>()
          .toList();
      final gameDetailRoute = routes.firstWhere(
        (r) => r.path == '/game-detail/:id',
      );
      expect(gameDetailRoute.builder, isNotNull);
    });

    test('randomizer route should have RandomizerScreen builder', () {
      final routes = appRouter.configuration.routes
          .whereType<GoRoute>()
          .toList();
      final randomizerRoute = routes.firstWhere((r) => r.path == '/randomizer');
      expect(randomizerRoute.builder, isNotNull);
    });

    test('randomizer-finger route should have FingerPickerScreen builder', () {
      final routes = appRouter.configuration.routes
          .whereType<GoRoute>()
          .toList();
      final fingerRoute = routes.firstWhere(
        (r) => r.path == '/randomizer-finger',
      );
      expect(fingerRoute.builder, isNotNull);
    });

    test('randomizer-name route should have NameDrawScreen builder', () {
      final routes = appRouter.configuration.routes
          .whereType<GoRoute>()
          .toList();
      final nameRoute = routes.firstWhere((r) => r.path == '/randomizer-name');
      expect(nameRoute.builder, isNotNull);
    });

    test('ranking route should have RankingScreen builder', () {
      final routes = appRouter.configuration.routes
          .whereType<GoRoute>()
          .toList();
      final rankingRoute = routes.firstWhere((r) => r.path == '/ranking');
      expect(rankingRoute.builder, isNotNull);
    });

    test('randomizer-challenge route should have ChallengeScreen builder', () {
      final routes = appRouter.configuration.routes
          .whereType<GoRoute>()
          .toList();
      final challengeRoute = routes.firstWhere(
        (r) => r.path == '/randomizer-challenge',
      );
      expect(challengeRoute.builder, isNotNull);
    });

    test(
      'randomizer-game route should have RandomGamePickerScreen builder',
      () {
        final routes = appRouter.configuration.routes
            .whereType<GoRoute>()
            .toList();
        final randomGameRoute = routes.firstWhere(
          (r) => r.path == '/randomizer-game',
        );
        expect(randomGameRoute.builder, isNotNull);
      },
    );

    test('wishlist route should have WishlistScreen builder', () {
      final routes = appRouter.configuration.routes
          .whereType<GoRoute>()
          .toList();
      final wishlistRoute = routes.firstWhere((r) => r.path == '/wishlist');
      expect(wishlistRoute.builder, isNotNull);
    });

    test('add-wishlist route should have AddWishlistScreen builder', () {
      final routes = appRouter.configuration.routes
          .whereType<GoRoute>()
          .toList();
      final addWishlistRoute = routes.firstWhere(
        (r) => r.path == '/add-wishlist',
      );
      expect(addWishlistRoute.builder, isNotNull);
    });

    test(
      'edit-wishlist route should have AddWishlistScreen builder with itemId',
      () {
        final routes = appRouter.configuration.routes
            .whereType<GoRoute>()
            .toList();
        final editWishlistRoute = routes.firstWhere(
          (r) => r.path == '/edit-wishlist/:id',
        );
        expect(editWishlistRoute.builder, isNotNull);
      },
    );

    test('settings route should have SettingsScreen builder', () {
      final routes = appRouter.configuration.routes
          .whereType<GoRoute>()
          .toList();
      final settingsRoute = routes.firstWhere((r) => r.path == '/settings');
      expect(settingsRoute.builder, isNotNull);
    });

    test('privacy-policy route should have PrivacyPolicyScreen builder', () {
      final routes = appRouter.configuration.routes
          .whereType<GoRoute>()
          .toList();
      final privacyRoute = routes.firstWhere(
        (r) => r.path == '/privacy-policy',
      );
      expect(privacyRoute.builder, isNotNull);
    });
  });

  group('appRouter - Route Builders Return Correct Screens', () {
    final mockContext = MockBuildContext();

    test('root route builder returns CollectionScreen', () {
      final routes = appRouter.configuration.routes
          .whereType<GoRoute>()
          .toList();
      final rootRoute = routes.firstWhere((r) => r.path == '/');
      final widget = rootRoute.builder!(mockContext, MockGoRouterState());
      expect(widget, isA<CollectionScreen>());
    });

    test('add-game route builder returns AddGameScreen', () {
      final routes = appRouter.configuration.routes
          .whereType<GoRoute>()
          .toList();
      final addGameRoute = routes.firstWhere((r) => r.path == '/add-game');
      final widget = addGameRoute.builder!(mockContext, MockGoRouterState());
      expect(widget, isA<AddGameScreen>());
    });

    test('edit-game route builder returns AddGameScreen with gameId', () {
      final routes = appRouter.configuration.routes
          .whereType<GoRoute>()
          .toList();
      final editGameRoute = routes.firstWhere(
        (r) => r.path == '/edit-game/:id',
      );
      final state = MockGoRouterState(pathParameters: {'id': 'game123'});
      final widget =
          editGameRoute.builder!(mockContext, state) as AddGameScreen;
      expect(widget.gameId, 'game123');
    });

    test('game-detail route builder returns GameDetailScreen with gameId', () {
      final routes = appRouter.configuration.routes
          .whereType<GoRoute>()
          .toList();
      final gameDetailRoute = routes.firstWhere(
        (r) => r.path == '/game-detail/:id',
      );
      final state = MockGoRouterState(pathParameters: {'id': 'game456'});
      final widget =
          gameDetailRoute.builder!(mockContext, state) as GameDetailScreen;
      expect(widget.gameId, 'game456');
    });

    test('randomizer route builder returns RandomizerScreen', () {
      final routes = appRouter.configuration.routes
          .whereType<GoRoute>()
          .toList();
      final randomizerRoute = routes.firstWhere((r) => r.path == '/randomizer');
      final widget = randomizerRoute.builder!(mockContext, MockGoRouterState());
      expect(widget, isA<RandomizerScreen>());
    });

    test('randomizer-finger route builder returns FingerPickerScreen', () {
      final routes = appRouter.configuration.routes
          .whereType<GoRoute>()
          .toList();
      final fingerRoute = routes.firstWhere(
        (r) => r.path == '/randomizer-finger',
      );
      final widget = fingerRoute.builder!(mockContext, MockGoRouterState());
      expect(widget, isA<FingerPickerScreen>());
    });

    test('randomizer-name route builder returns NameDrawScreen', () {
      final routes = appRouter.configuration.routes
          .whereType<GoRoute>()
          .toList();
      final nameRoute = routes.firstWhere((r) => r.path == '/randomizer-name');
      final widget = nameRoute.builder!(mockContext, MockGoRouterState());
      expect(widget, isA<NameDrawScreen>());
    });

    test('ranking route builder returns RankingScreen', () {
      final routes = appRouter.configuration.routes
          .whereType<GoRoute>()
          .toList();
      final rankingRoute = routes.firstWhere((r) => r.path == '/ranking');
      final widget = rankingRoute.builder!(mockContext, MockGoRouterState());
      expect(widget, isA<RankingScreen>());
    });

    test('randomizer-challenge route builder returns ChallengeScreen', () {
      final routes = appRouter.configuration.routes
          .whereType<GoRoute>()
          .toList();
      final challengeRoute = routes.firstWhere(
        (r) => r.path == '/randomizer-challenge',
      );
      final widget = challengeRoute.builder!(mockContext, MockGoRouterState());
      expect(widget, isA<ChallengeScreen>());
    });

    test('randomizer-game route builder returns RandomGamePickerScreen', () {
      final routes = appRouter.configuration.routes
          .whereType<GoRoute>()
          .toList();
      final randomGameRoute = routes.firstWhere(
        (r) => r.path == '/randomizer-game',
      );
      final widget = randomGameRoute.builder!(mockContext, MockGoRouterState());
      expect(widget, isA<RandomGamePickerScreen>());
    });

    test('wishlist route builder returns WishlistScreen', () {
      final routes = appRouter.configuration.routes
          .whereType<GoRoute>()
          .toList();
      final wishlistRoute = routes.firstWhere((r) => r.path == '/wishlist');
      final widget = wishlistRoute.builder!(mockContext, MockGoRouterState());
      expect(widget, isA<WishlistScreen>());
    });

    test('add-wishlist route builder returns AddWishlistScreen', () {
      final routes = appRouter.configuration.routes
          .whereType<GoRoute>()
          .toList();
      final addWishlistRoute = routes.firstWhere(
        (r) => r.path == '/add-wishlist',
      );
      final widget = addWishlistRoute.builder!(
        mockContext,
        MockGoRouterState(),
      );
      expect(widget, isA<AddWishlistScreen>());
    });

    test(
      'edit-wishlist route builder returns AddWishlistScreen with itemId',
      () {
        final routes = appRouter.configuration.routes
            .whereType<GoRoute>()
            .toList();
        final editWishlistRoute = routes.firstWhere(
          (r) => r.path == '/edit-wishlist/:id',
        );
        final state = MockGoRouterState(pathParameters: {'id': 'wishlist789'});
        final widget =
            editWishlistRoute.builder!(mockContext, state) as AddWishlistScreen;
        expect(widget.itemId, 'wishlist789');
      },
    );

    test('settings route builder returns SettingsScreen', () {
      final routes = appRouter.configuration.routes
          .whereType<GoRoute>()
          .toList();
      final settingsRoute = routes.firstWhere((r) => r.path == '/settings');
      final widget = settingsRoute.builder!(mockContext, MockGoRouterState());
      expect(widget, isA<SettingsScreen>());
    });

    test('privacy-policy route builder returns PrivacyPolicyScreen', () {
      final routes = appRouter.configuration.routes
          .whereType<GoRoute>()
          .toList();
      final privacyRoute = routes.firstWhere(
        (r) => r.path == '/privacy-policy',
      );
      final widget = privacyRoute.builder!(mockContext, MockGoRouterState());
      expect(widget, isA<PrivacyPolicyScreen>());
    });
  });
}
