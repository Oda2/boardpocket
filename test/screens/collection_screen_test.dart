import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:boardpocket/presentation/screens/collection_screen.dart';
import 'package:boardpocket/presentation/providers/game_provider.dart';
import 'package:boardpocket/data/models/game.dart';
import 'package:boardpocket/data/repositories/interfaces/game_repository_interface.dart';
import 'package:boardpocket/core/i18n/app_localizations.dart';

class MockGameRepository implements IGameRepository {
  @override
  Future<Game> create(Game game) async => game;
  @override
  Future<List<Game>> getAll() async => [];
  @override
  Future<List<Game>> search(String query) async => [];
  @override
  Future<List<Game>> getByCategory(String category) async => [];
  @override
  Future<List<String>> getCategories() async => [];
  @override
  Future<Game?> getById(String id) async => null;
  @override
  Future<void> update(Game game) async {}
  @override
  Future<void> delete(String id) async {}
  @override
  Future<void> recordPlay(String id, bool won) async {}
}

Widget createTestWidget({required GameProvider gameProvider}) {
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
      home: const CollectionScreen(),
    ),
  );
}

void main() {
  group('CollectionScreen - Basic Rendering', () {
    late GameProvider gameProvider;
    late MockGameRepository mockRepository;

    setUp(() {
      mockRepository = MockGameRepository();
      gameProvider = GameProvider(repository: mockRepository);
    });

    testWidgets('should render without errors', (tester) async {
      await tester.pumpWidget(createTestWidget(gameProvider: gameProvider));
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should have SafeArea', (tester) async {
      await tester.pumpWidget(createTestWidget(gameProvider: gameProvider));
      await tester.pumpAndSettle();
      expect(find.byType(SafeArea), findsWidgets);
    });

    testWidgets('should have Stack', (tester) async {
      await tester.pumpWidget(createTestWidget(gameProvider: gameProvider));
      await tester.pumpAndSettle();
      expect(find.byType(Stack), findsWidgets);
    });

    testWidgets('should have Column', (tester) async {
      await tester.pumpWidget(createTestWidget(gameProvider: gameProvider));
      await tester.pumpAndSettle();
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('should have TextField', (tester) async {
      await tester.pumpWidget(createTestWidget(gameProvider: gameProvider));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsWidgets);
    });
  });
}
