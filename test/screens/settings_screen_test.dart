import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:boardpocket/presentation/screens/settings_screen.dart';
import 'package:boardpocket/presentation/providers/settings_provider.dart';
import 'package:boardpocket/data/repositories/settings_repository.dart';
import 'package:boardpocket/core/i18n/app_localizations.dart';

class MockSettingsRepository implements SettingsRepository {
  bool _isDarkMode = true;
  String _language = 'en';

  @override
  Future<bool> getDarkMode() async => _isDarkMode;
  @override
  Future<void> setDarkMode(bool value) async => _isDarkMode = value;
  @override
  Future<String> getLanguage() async => _language;
  @override
  Future<void> setLanguage(String value) async => _language = value;
}

Widget createTestWidget({required SettingsProvider settingsProvider}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en')],
      home: const SettingsScreen(),
    ),
  );
}

void main() {
  group('SettingsScreen - Basic Rendering', () {
    late SettingsProvider settingsProvider;
    late MockSettingsRepository mockRepository;

    setUp(() {
      mockRepository = MockSettingsRepository();
      settingsProvider = SettingsProvider(repository: mockRepository);
    });

    testWidgets('should render without errors', (tester) async {
      await tester.pumpWidget(
        createTestWidget(settingsProvider: settingsProvider),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('should have SafeArea', (tester) async {
      await tester.pumpWidget(
        createTestWidget(settingsProvider: settingsProvider),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SafeArea), findsWidgets);
    });

    testWidgets('should have Stack', (tester) async {
      await tester.pumpWidget(
        createTestWidget(settingsProvider: settingsProvider),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Stack), findsWidgets);
    });

    testWidgets('should have Column', (tester) async {
      await tester.pumpWidget(
        createTestWidget(settingsProvider: settingsProvider),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('should have Icon widgets', (tester) async {
      await tester.pumpWidget(
        createTestWidget(settingsProvider: settingsProvider),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Icon), findsWidgets);
    });
  });

  group('SettingsScreen - Controls', () {
    late SettingsProvider settingsProvider;
    late MockSettingsRepository mockRepository;

    setUp(() {
      mockRepository = MockSettingsRepository();
      settingsProvider = SettingsProvider(repository: mockRepository);
    });

    testWidgets('should have Switch widgets', (tester) async {
      await tester.pumpWidget(
        createTestWidget(settingsProvider: settingsProvider),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Switch), findsWidgets);
    });
  });
}
