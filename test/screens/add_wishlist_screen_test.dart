import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:boardpocket/presentation/screens/add_wishlist_screen.dart';
import 'package:boardpocket/presentation/providers/wishlist_provider.dart';
import 'package:boardpocket/data/models/wishlist_item.dart';
import 'package:boardpocket/data/repositories/interfaces/wishlist_repository_interface.dart';
import 'package:boardpocket/core/i18n/app_localizations.dart';

class MockWishlistRepository implements IWishlistRepository {
  WishlistItem? _mockItem;

  void setMockItem(WishlistItem? item) => _mockItem = item;

  @override
  Future<WishlistItem> create(WishlistItem item) async => item;
  @override
  Future<List<WishlistItem>> getAll() async =>
      _mockItem != null ? [_mockItem!] : [];
  @override
  Future<WishlistItem?> getById(String id) async => _mockItem;
  @override
  Future<void> update(WishlistItem item) async => _mockItem = item;
  @override
  Future<void> delete(String id) async => _mockItem = null;
}

Widget createTestWidget({
  required Widget child,
  required WishlistProvider wishlistProvider,
}) {
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
      home: child,
    ),
  );
}

void main() {
  group('AddWishlistScreen - Basic Rendering', () {
    late WishlistProvider wishlistProvider;
    late MockWishlistRepository mockRepository;

    setUp(() {
      mockRepository = MockWishlistRepository();
      wishlistProvider = WishlistProvider(repository: mockRepository);
    });

    testWidgets('should render without errors', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const AddWishlistScreen(),
          wishlistProvider: wishlistProvider,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should have TextFields', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const AddWishlistScreen(),
          wishlistProvider: wishlistProvider,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsWidgets);
    });

    testWidgets('should have ElevatedButton', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const AddWishlistScreen(),
          wishlistProvider: wishlistProvider,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should have Column', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const AddWishlistScreen(),
          wishlistProvider: wishlistProvider,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('should have SafeArea', (tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: const AddWishlistScreen(),
          wishlistProvider: wishlistProvider,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SafeArea), findsWidgets);
    });
  });
}
