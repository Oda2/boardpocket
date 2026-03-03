import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:boardpocket/presentation/screens/add_game_screen.dart';
import 'package:boardpocket/presentation/providers/game_provider.dart';
import 'package:boardpocket/data/models/game.dart';
import 'package:boardpocket/data/repositories/interfaces/game_repository_interface.dart';
import 'package:boardpocket/core/i18n/app_localizations.dart';

class MockGameRepository implements IGameRepository {
  Game? _mockGame;

  void setMockGame(Game? game) => _mockGame = game;

  @override
  Future<Game> create(Game game) async => game;
  @override
  Future<List<Game>> getAll() async => _mockGame != null ? [_mockGame!] : [];
  @override
  Future<List<Game>> search(String query) async => [];
  @override
  Future<List<Game>> getByCategory(String category) async => [];
  @override
  Future<List<String>> getCategories() async => ['Strategy', 'Party'];
  @override
  Future<Game?> getById(String id) async => _mockGame;
  @override
  Future<void> update(Game game) async => _mockGame = game;
  @override
  Future<void> delete(String id) async => _mockGame = null;
  @override
  Future<void> recordPlay(String id, bool won) async {}
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

void main() {
  group('AddGameScreen - Basic Rendering', () {
    late GameProvider gameProvider;
    late MockGameRepository mockRepository;

    setUp(() {
      mockRepository = MockGameRepository();
      gameProvider = GameProvider(repository: mockRepository);
    });

    testWidgets('should render without errors', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const AddGameScreen(),
          gameProvider: gameProvider,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should have SingleChildScrollView', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const AddGameScreen(),
          gameProvider: gameProvider,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('should have TextFields', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const AddGameScreen(),
          gameProvider: gameProvider,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('should have ElevatedButton', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const AddGameScreen(),
          gameProvider: gameProvider,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should have Column', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const AddGameScreen(),
          gameProvider: gameProvider,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Column), findsWidgets);
    });
  });
}
