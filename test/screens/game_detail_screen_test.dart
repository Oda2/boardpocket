import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:boardpocket/presentation/screens/game_detail_screen.dart';
import 'package:boardpocket/presentation/providers/game_provider.dart';
import 'package:boardpocket/data/models/game.dart';
import 'package:boardpocket/data/repositories/interfaces/game_repository_interface.dart';
import 'package:boardpocket/core/i18n/app_localizations.dart';

class MockGameRepository implements IGameRepository {
  Game? _mockGame;

  void setMockGame(Game? game) {
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

Widget createTestWidget({
  required Widget child,
  required GameProvider gameProvider,
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<GameProvider>.value(value: gameProvider),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: child,
    ),
  );
}

Game createTestGame({
  String id = 'game-1',
  String title = 'Catan',
  String players = '3-4',
  String time = '60 min',
  String category = 'Strategy',
  String? imagePath,
  int totalPlays = 10,
  int wins = 6,
  int losses = 4,
  DateTime? lastPlayed,
}) {
  return Game(
    id: id,
    title: title,
    players: players,
    time: time,
    category: category,
    imagePath: imagePath,
    totalPlays: totalPlays,
    wins: wins,
    losses: losses,
    lastPlayed: lastPlayed ?? DateTime.now().subtract(const Duration(days: 2)),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

void main() {
  group('GameDetailScreen - Game Display', () {
    late GameProvider gameProvider;
    late MockGameRepository mockRepository;

    setUp(() async {
      mockRepository = MockGameRepository();
      mockRepository.setMockGame(
        createTestGame(
          title: 'Catan',
          category: 'Strategy',
          players: '3-4',
          time: '60 min',
          totalPlays: 10,
          wins: 6,
          losses: 4,
        ),
      );
      gameProvider = GameProvider(repository: mockRepository);
      await gameProvider.loadGames();
    });

    testWidgets('should display game title', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GameDetailScreen(gameId: 'game-1'),
          gameProvider: gameProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Catan'), findsOneWidget);
    });

    testWidgets('should display game category', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GameDetailScreen(gameId: 'game-1'),
          gameProvider: gameProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('STRATEGY'), findsOneWidget);
    });

    testWidgets('should display total plays', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GameDetailScreen(gameId: 'game-1'),
          gameProvider: gameProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('10'), findsOneWidget);
    });
  });

  group('GameDetailScreen - Buttons', () {
    late GameProvider gameProvider;
    late MockGameRepository mockRepository;

    setUp(() async {
      mockRepository = MockGameRepository();
      mockRepository.setMockGame(
        createTestGame(
          id: 'game-1',
          title: 'Catan',
          totalPlays: 10,
          wins: 6,
          losses: 4,
        ),
      );
      gameProvider = GameProvider(repository: mockRepository);
      await gameProvider.loadGames();
    });

    testWidgets('should have edit button', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GameDetailScreen(gameId: 'game-1'),
          gameProvider: gameProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.edit), findsOneWidget);
    });

    testWidgets('should have delete button', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GameDetailScreen(gameId: 'game-1'),
          gameProvider: gameProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('should have back button', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GameDetailScreen(gameId: 'game-1'),
          gameProvider: gameProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.arrow_back_ios_new), findsOneWidget);
    });

    testWidgets('should have emoji events icon for Won button', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GameDetailScreen(gameId: 'game-1'),
          gameProvider: gameProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.emoji_events), findsOneWidget);
    });

    testWidgets('should have close icon for Lost button', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GameDetailScreen(gameId: 'game-1'),
          gameProvider: gameProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.close), findsOneWidget);
    });
  });

  group('GameDetailScreen - Delete Dialog', () {
    late GameProvider gameProvider;
    late MockGameRepository mockRepository;

    setUp(() async {
      mockRepository = MockGameRepository();
      mockRepository.setMockGame(createTestGame(id: 'game-1', title: 'Catan'));
      gameProvider = GameProvider(repository: mockRepository);
      await gameProvider.loadGames();
    });

    testWidgets('should open delete dialog when delete button tapped', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GameDetailScreen(gameId: 'game-1'),
          gameProvider: gameProvider,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
    });
  });

  group('GameDetailScreen - Layout', () {
    late GameProvider gameProvider;
    late MockGameRepository mockRepository;

    setUp(() async {
      mockRepository = MockGameRepository();
      mockRepository.setMockGame(createTestGame(id: 'game-1', title: 'Catan'));
      gameProvider = GameProvider(repository: mockRepository);
      await gameProvider.loadGames();
    });

    testWidgets('should have SliverAppBar', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GameDetailScreen(gameId: 'game-1'),
          gameProvider: gameProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SliverAppBar), findsOneWidget);
    });

    testWidgets('should have FlexibleSpaceBar', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GameDetailScreen(gameId: 'game-1'),
          gameProvider: gameProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(FlexibleSpaceBar), findsOneWidget);
    });

    testWidgets('should have CustomScrollView', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GameDetailScreen(gameId: 'game-1'),
          gameProvider: gameProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CustomScrollView), findsOneWidget);
    });

    testWidgets('should have Scaffold', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GameDetailScreen(gameId: 'game-1'),
          gameProvider: gameProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  group('GameDetailScreen - Timer and Group Icons', () {
    late GameProvider gameProvider;
    late MockGameRepository mockRepository;

    setUp(() async {
      mockRepository = MockGameRepository();
      mockRepository.setMockGame(
        createTestGame(
          id: 'game-1',
          title: 'Catan',
          players: '3-4',
          time: '60 min',
        ),
      );
      gameProvider = GameProvider(repository: mockRepository);
      await gameProvider.loadGames();
    });

    testWidgets('should have timer icon', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GameDetailScreen(gameId: 'game-1'),
          gameProvider: gameProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.timer), findsOneWidget);
    });

    testWidgets('should have group icon', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const GameDetailScreen(gameId: 'game-1'),
          gameProvider: gameProvider,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.group), findsOneWidget);
    });
  });
}
