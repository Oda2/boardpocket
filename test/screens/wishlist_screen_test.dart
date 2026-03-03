import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:boardpocket/presentation/screens/wishlist_screen.dart';
import 'package:boardpocket/presentation/providers/wishlist_provider.dart';
import 'package:boardpocket/data/models/wishlist_item.dart';
import 'package:boardpocket/data/repositories/interfaces/wishlist_repository_interface.dart';
import 'package:boardpocket/core/i18n/app_localizations.dart';

class MockWishlistRepository implements IWishlistRepository {
  @override
  Future<WishlistItem> create(WishlistItem item) async => item;
  @override
  Future<List<WishlistItem>> getAll() async => [];
  @override
  Future<WishlistItem?> getById(String id) async => null;
  @override
  Future<void> update(WishlistItem item) async {}
  @override
  Future<void> delete(String id) async {}
}

Widget createTestWidget({required WishlistProvider wishlistProvider}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<WishlistProvider>.value(value: wishlistProvider),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: const WishlistScreen(),
    ),
  );
}

void main() {
  group('WishlistScreen - Basic Rendering', () {
    late WishlistProvider wishlistProvider;
    late MockWishlistRepository mockRepository;

    setUp(() {
      mockRepository = MockWishlistRepository();
      wishlistProvider = WishlistProvider(repository: mockRepository);
    });

    testWidgets('should render without errors', (tester) async {
      await tester.pumpWidget(
        createTestWidget(wishlistProvider: wishlistProvider),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should have SafeArea', (tester) async {
      await tester.pumpWidget(
        createTestWidget(wishlistProvider: wishlistProvider),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SafeArea), findsWidgets);
    });

    testWidgets('should have Stack', (tester) async {
      await tester.pumpWidget(
        createTestWidget(wishlistProvider: wishlistProvider),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Stack), findsWidgets);
    });

    testWidgets('should have Column', (tester) async {
      await tester.pumpWidget(
        createTestWidget(wishlistProvider: wishlistProvider),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('should have Text widgets', (tester) async {
      await tester.pumpWidget(
        createTestWidget(wishlistProvider: wishlistProvider),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Text), findsWidgets);
    });
  });

  group('WishlistScreen - FAB', () {
    late WishlistProvider wishlistProvider;
    late MockWishlistRepository mockRepository;

    setUp(() {
      mockRepository = MockWishlistRepository();
      wishlistProvider = WishlistProvider(repository: mockRepository);
    });

    testWidgets('should have FloatingActionButton', (tester) async {
      await tester.pumpWidget(
        createTestWidget(wishlistProvider: wishlistProvider),
      );
      await tester.pumpAndSettle();
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('should have add icon in FAB', (tester) async {
      await tester.pumpWidget(
        createTestWidget(wishlistProvider: wishlistProvider),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.add), findsWidgets);
    });
  });
}
