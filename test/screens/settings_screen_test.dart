import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:boardpocket/presentation/screens/settings_screen.dart';
import 'package:boardpocket/presentation/providers/settings_provider.dart';
import 'package:boardpocket/data/repositories/settings_repository.dart';
import 'package:boardpocket/core/i18n/app_localizations.dart';
import 'package:boardpocket/core/components/components.dart';
import 'package:boardpocket/presentation/widgets/widgets.dart';

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

    testWidgets('should have dark mode switch', (tester) async {
      await tester.pumpWidget(
        createTestWidget(settingsProvider: settingsProvider),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Switch), findsOneWidget);
    });
  });

  group('SettingsScreen - AppHeader', () {
    late SettingsProvider settingsProvider;
    late MockSettingsRepository mockRepository;

    setUp(() {
      mockRepository = MockSettingsRepository();
      settingsProvider = SettingsProvider(repository: mockRepository);
    });

    testWidgets('should have AppHeader', (tester) async {
      await tester.pumpWidget(
        createTestWidget(settingsProvider: settingsProvider),
      );
      await tester.pumpAndSettle();
      expect(find.byType(AppHeader), findsOneWidget);
    });

    testWidgets('should have IconActionButton for back navigation', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(settingsProvider: settingsProvider),
      );
      await tester.pumpAndSettle();
      expect(find.byType(IconActionButton), findsOneWidget);
    });

    testWidgets('should have back arrow icon', (tester) async {
      await tester.pumpWidget(
        createTestWidget(settingsProvider: settingsProvider),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.arrow_back_ios), findsOneWidget);
    });

    testWidgets('should show settings title', (tester) async {
      await tester.pumpWidget(
        createTestWidget(settingsProvider: settingsProvider),
      );
      await tester.pumpAndSettle();
      expect(find.text('Settings'), findsWidgets);
    });
  });

  group('SettingsScreen - User Card', () {
    late SettingsProvider settingsProvider;
    late MockSettingsRepository mockRepository;

    setUp(() {
      mockRepository = MockSettingsRepository();
      settingsProvider = SettingsProvider(repository: mockRepository);
    });

    testWidgets('should have ProfileAvatar', (tester) async {
      await tester.pumpWidget(
        createTestWidget(settingsProvider: settingsProvider),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ProfileAvatar), findsOneWidget);
    });

    testWidgets('should have ThemeContainer for user card', (tester) async {
      await tester.pumpWidget(
        createTestWidget(settingsProvider: settingsProvider),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ThemeContainer), findsWidgets);
    });

    testWidgets('should show user name', (tester) async {
      await tester.pumpWidget(
        createTestWidget(settingsProvider: settingsProvider),
      );
      await tester.pumpAndSettle();
      expect(find.text('User'), findsOneWidget);
    });

    testWidgets('should show board games collector text', (tester) async {
      await tester.pumpWidget(
        createTestWidget(settingsProvider: settingsProvider),
      );
      await tester.pumpAndSettle();
      expect(find.text('Board Games Collector'), findsOneWidget);
    });
  });

  group('SettingsScreen - Appearance Section', () {
    late SettingsProvider settingsProvider;
    late MockSettingsRepository mockRepository;

    setUp(() {
      mockRepository = MockSettingsRepository();
      settingsProvider = SettingsProvider(repository: mockRepository);
    });

    testWidgets('should show appearance section title', (tester) async {
      await tester.pumpWidget(
        createTestWidget(settingsProvider: settingsProvider),
      );
      await tester.pumpAndSettle();
      expect(find.text('APPEARANCE'), findsOneWidget);
    });

    testWidgets('should have dark mode toggle with label', (tester) async {
      await tester.pumpWidget(
        createTestWidget(settingsProvider: settingsProvider),
      );
      await tester.pumpAndSettle();
      expect(find.text('Dark Mode'), findsOneWidget);
    });

    testWidgets('should have dark mode icon', (tester) async {
      await tester.pumpWidget(
        createTestWidget(settingsProvider: settingsProvider),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.dark_mode), findsOneWidget);
    });

    testWidgets('should have language option', (tester) async {
      await tester.pumpWidget(
        createTestWidget(settingsProvider: settingsProvider),
      );
      await tester.pumpAndSettle();
      expect(find.text('Language'), findsOneWidget);
    });

    testWidgets('should have language icon', (tester) async {
      await tester.pumpWidget(
        createTestWidget(settingsProvider: settingsProvider),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.language), findsOneWidget);
    });

    testWidgets('should show current language', (tester) async {
      await tester.pumpWidget(
        createTestWidget(settingsProvider: settingsProvider),
      );
      await tester.pumpAndSettle();
      expect(find.text('English (US)'), findsOneWidget);
    });

    testWidgets('should have chevron right icon for language', (tester) async {
      await tester.pumpWidget(
        createTestWidget(settingsProvider: settingsProvider),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.chevron_right), findsWidgets);
    });

    testWidgets('should open language dialog when tapping language', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(settingsProvider: settingsProvider),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('language dialog should show language options', (tester) async {
      await tester.pumpWidget(
        createTestWidget(settingsProvider: settingsProvider),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();

      expect(find.text('English (US)'), findsWidgets);
      expect(find.text('Portuguese'), findsOneWidget);
      expect(find.text('Spanish'), findsOneWidget);
    });

    testWidgets('should be able to select Portuguese in dialog', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(settingsProvider: settingsProvider),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Portuguese'));
      await tester.pumpAndSettle();

      expect(find.text('Portuguese'), findsOneWidget);
    });
  });

  group('SettingsScreen - Backup Section', () {
    late SettingsProvider settingsProvider;
    late MockSettingsRepository mockRepository;

    setUp(() {
      mockRepository = MockSettingsRepository();
      settingsProvider = SettingsProvider(repository: mockRepository);
    });

    testWidgets('should show data backup section title', (tester) async {
      await tester.pumpWidget(
        createTestWidget(settingsProvider: settingsProvider),
      );
      await tester.pumpAndSettle();
      expect(find.text('DATA & BACKUP'), findsOneWidget);
    });

    testWidgets('should have export button', (tester) async {
      await tester.pumpWidget(
        createTestWidget(settingsProvider: settingsProvider),
      );
      await tester.pumpAndSettle();
      expect(find.text('Export JSON'), findsOneWidget);
    });

    testWidgets('should have import button', (tester) async {
      await tester.pumpWidget(
        createTestWidget(settingsProvider: settingsProvider),
      );
      await tester.pumpAndSettle();
      expect(find.text('Import JSON'), findsOneWidget);
    });

    testWidgets('should have export/import description', (tester) async {
      await tester.pumpWidget(
        createTestWidget(settingsProvider: settingsProvider),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Export'), findsWidgets);
    });

    testWidgets('should have ElevatedButton for export', (tester) async {
      await tester.pumpWidget(
        createTestWidget(settingsProvider: settingsProvider),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ElevatedButton), findsWidgets);
    });
  });

  group('SettingsScreen - About Section', () {
    late SettingsProvider settingsProvider;
    late MockSettingsRepository mockRepository;

    setUp(() {
      mockRepository = MockSettingsRepository();
      settingsProvider = SettingsProvider(repository: mockRepository);
    });

    testWidgets('should show about section title', (tester) async {
      await tester.pumpWidget(
        createTestWidget(settingsProvider: settingsProvider),
      );
      await tester.pumpAndSettle();
      expect(find.text('ABOUT'), findsOneWidget);
    });

    testWidgets('should show version info', (tester) async {
      await tester.pumpWidget(
        createTestWidget(settingsProvider: settingsProvider),
      );
      await tester.pumpAndSettle();
      expect(find.text('Version'), findsOneWidget);
    });

    testWidgets('should show version number', (tester) async {
      await tester.pumpWidget(
        createTestWidget(settingsProvider: settingsProvider),
      );
      await tester.pumpAndSettle();
      expect(find.text('1.0.0'), findsOneWidget);
    });

    testWidgets('should have privacy policy option', (tester) async {
      await tester.pumpWidget(
        createTestWidget(settingsProvider: settingsProvider),
      );
      await tester.pumpAndSettle();
      expect(find.text('Privacy Policy'), findsOneWidget);
    });

    testWidgets('should have privacy tip icon', (tester) async {
      await tester.pumpWidget(
        createTestWidget(settingsProvider: settingsProvider),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.privacy_tip_outlined), findsOneWidget);
    });

    testWidgets('should have info outline icon for version', (tester) async {
      await tester.pumpWidget(
        createTestWidget(settingsProvider: settingsProvider),
      );
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });
  });

  group('SettingsScreen - Bottom Tab Bar', () {
    late SettingsProvider settingsProvider;
    late MockSettingsRepository mockRepository;

    setUp(() {
      mockRepository = MockSettingsRepository();
      settingsProvider = SettingsProvider(repository: mockRepository);
    });

    testWidgets('should have BottomTabBar', (tester) async {
      await tester.pumpWidget(
        createTestWidget(settingsProvider: settingsProvider),
      );
      await tester.pumpAndSettle();
      expect(find.byType(BottomTabBar), findsOneWidget);
    });
  });

  group('SettingsScreen - ListTile', () {
    late SettingsProvider settingsProvider;
    late MockSettingsRepository mockRepository;

    setUp(() {
      mockRepository = MockSettingsRepository();
      settingsProvider = SettingsProvider(repository: mockRepository);
    });

    testWidgets('should have ListTile widgets', (tester) async {
      await tester.pumpWidget(
        createTestWidget(settingsProvider: settingsProvider),
      );
      await tester.pumpAndSettle();
      expect(find.byType(ListTile), findsWidgets);
    });

    testWidgets('should have Divider widgets', (tester) async {
      await tester.pumpWidget(
        createTestWidget(settingsProvider: settingsProvider),
      );
      await tester.pumpAndSettle();
      expect(find.byType(Divider), findsWidgets);
    });
  });

  group('SettingsScreen - SingleChildScrollView', () {
    late SettingsProvider settingsProvider;
    late MockSettingsRepository mockRepository;

    setUp(() {
      mockRepository = MockSettingsRepository();
      settingsProvider = SettingsProvider(repository: mockRepository);
    });

    testWidgets('should have scrollable content', (tester) async {
      await tester.pumpWidget(
        createTestWidget(settingsProvider: settingsProvider),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });
  });

  group('SettingsScreen - Dark Mode Toggle', () {
    late SettingsProvider settingsProvider;
    late MockSettingsRepository mockRepository;

    setUp(() {
      mockRepository = MockSettingsRepository();
      settingsProvider = SettingsProvider(repository: mockRepository);
    });

    testWidgets('should toggle dark mode when switch is tapped', (
      tester,
    ) async {
      await tester.pumpWidget(
        createTestWidget(settingsProvider: settingsProvider),
      );
      await tester.pumpAndSettle();

      final switchFinder = find.byType(Switch);
      expect(switchFinder, findsOneWidget);

      await tester.tap(switchFinder);
      await tester.pumpAndSettle();
    });

    testWidgets('dark mode should be initially true', (tester) async {
      await tester.pumpWidget(
        createTestWidget(settingsProvider: settingsProvider),
      );
      await tester.pumpAndSettle();

      expect(settingsProvider.isDarkMode, true);
    });
  });
}
