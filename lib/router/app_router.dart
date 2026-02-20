import 'package:go_router/go_router.dart';
import '../presentation/screens/screens.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const CollectionScreen()),
    GoRoute(
      path: '/add-game',
      builder: (context, state) => const AddGameScreen(),
    ),
    GoRoute(
      path: '/edit-game/:id',
      builder: (context, state) =>
          AddGameScreen(gameId: state.pathParameters['id']),
    ),
    GoRoute(
      path: '/game-detail/:id',
      builder: (context, state) =>
          GameDetailScreen(gameId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/randomizer',
      builder: (context, state) => const RandomizerScreen(),
    ),
    GoRoute(
      path: '/randomizer-finger',
      builder: (context, state) => const FingerPickerScreen(),
    ),
    GoRoute(
      path: '/randomizer-name',
      builder: (context, state) => const NameDrawScreen(),
    ),
    GoRoute(
      path: '/ranking',
      builder: (context, state) => const RankingScreen(),
    ),
    GoRoute(
      path: '/randomizer-challenge',
      builder: (context, state) => const ChallengeScreen(),
    ),
    GoRoute(
      path: '/randomizer-game',
      builder: (context, state) => const RandomGamePickerScreen(),
    ),
    GoRoute(
      path: '/wishlist',
      builder: (context, state) => const WishlistScreen(),
    ),
    GoRoute(
      path: '/add-wishlist',
      builder: (context, state) => const AddWishlistScreen(),
    ),
    GoRoute(
      path: '/edit-wishlist/:id',
      builder: (context, state) =>
          AddWishlistScreen(itemId: state.pathParameters['id']),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
    GoRoute(
      path: '/privacy-policy',
      builder: (context, state) => const PrivacyPolicyScreen(),
    ),
  ],
);
