import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:boardpocket/presentation/screens/name_draw_screen.dart';
import 'package:boardpocket/presentation/providers/player_provider.dart';
import 'package:boardpocket/data/models/player.dart';
import 'package:boardpocket/data/repositories/interfaces/player_repository_interface.dart';
import 'package:boardpocket/core/i18n/app_localizations.dart';

class MockPlayerRepository implements IPlayerRepository {
  @override
  Future<Player> create(Player player) async => player;
  @override
  Future<List<Player>> getAll() async => [];
  @override
  Future<void> delete(String id) async {}
}

Widget createTestWidget({required PlayerProvider playerProvider}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<PlayerProvider>.value(value: playerProvider),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: const NameDrawScreen(),
    ),
  );
}

void main() {
  group('NameDrawScreen - Basic Rendering', () {
    late PlayerProvider playerProvider;
    late MockPlayerRepository mockRepository;

    setUp(() {
      mockRepository = MockPlayerRepository();
      playerProvider = PlayerProvider(repository: mockRepository);
    });

    testWidgets('should render without errors', (tester) async {
      await tester.pumpWidget(createTestWidget(playerProvider: playerProvider));
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should have SafeArea', (tester) async {
      await tester.pumpWidget(createTestWidget(playerProvider: playerProvider));
      await tester.pumpAndSettle();
      expect(find.byType(SafeArea), findsWidgets);
    });

    testWidgets('should have TextField', (tester) async {
      await tester.pumpWidget(createTestWidget(playerProvider: playerProvider));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('should have Column', (tester) async {
      await tester.pumpWidget(createTestWidget(playerProvider: playerProvider));
      await tester.pumpAndSettle();
      expect(find.byType(Column), findsWidgets);
    });
  });
}
