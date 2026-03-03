import 'package:flutter_test/flutter_test.dart';
import 'package:boardpocket/presentation/providers/settings_provider.dart';
import 'package:boardpocket/data/repositories/settings_repository.dart';

class MockSettingsRepository implements SettingsRepository {
  bool _isDarkMode = true;
  String _language = 'en';

  @override
  Future<bool> getDarkMode() async => _isDarkMode;

  @override
  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
  }

  @override
  Future<String> getLanguage() async => _language;

  @override
  Future<void> setLanguage(String value) async {
    _language = value;
  }

  @override
  Future<Map<String, String>> getAllSettings() async {
    return {'dark_mode': _isDarkMode.toString(), 'language': _language};
  }

  @override
  Future<String?> getSetting(String key) async => null;

  @override
  Future<void> setSetting(String key, String value) async {}

  @override
  Future<void> setSettings(Map<String, String> settings) async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsProvider', () {
    late SettingsProvider settingsProvider;
    late MockSettingsRepository mockRepository;

    setUp(() async {
      mockRepository = MockSettingsRepository();
      settingsProvider = SettingsProvider(repository: mockRepository);
    });

    test('should have default dark mode as true', () {
      expect(settingsProvider.isDarkMode, true);
    });

    test('should have default language as en', () {
      expect(settingsProvider.language, 'en');
    });

    test('should not be loading initially', () {
      expect(settingsProvider.isLoading, false);
    });

    test('should set dark mode value', () async {
      await settingsProvider.setDarkMode(false);
      expect(settingsProvider.isDarkMode, false);
    });

    test('should toggle dark mode', () async {
      expect(settingsProvider.isDarkMode, true);
      await settingsProvider.toggleDarkMode();
      expect(settingsProvider.isDarkMode, false);
      await settingsProvider.toggleDarkMode();
      expect(settingsProvider.isDarkMode, true);
    });

    test('should set language value', () async {
      await settingsProvider.setLanguage('pt');
      expect(settingsProvider.language, 'pt');
    });

    test('should notify listeners when dark mode changes', () async {
      bool notified = false;
      settingsProvider.addListener(() {
        notified = true;
      });

      await settingsProvider.setDarkMode(false);

      expect(notified, true);
    });

    test('should notify listeners when language changes', () async {
      bool notified = false;
      settingsProvider.addListener(() {
        notified = true;
      });

      await settingsProvider.setLanguage('es');

      expect(notified, true);
    });
  });
}
