import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boardpocket/data/repositories/settings_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsRepository', () {
    late SettingsRepository settingsRepository;

    setUp(() {
      settingsRepository = SettingsRepository();
    });

    tearDown(() {
      SharedPreferences.setMockInitialValues({});
    });

    test('should return default dark mode as true', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final result = await settingsRepository.getDarkMode();

      expect(result, true);
    });

    test('should return set dark mode value', () async {
      SharedPreferences.setMockInitialValues({'dark_mode': false});
      final prefs = await SharedPreferences.getInstance();

      final result = await settingsRepository.getDarkMode();

      expect(result, false);
    });

    test('should set dark mode value', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await settingsRepository.setDarkMode(false);

      final result = prefs.getBool('dark_mode');
      expect(result, false);
    });

    test('should return default language as en', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final result = await settingsRepository.getLanguage();

      expect(result, 'en');
    });

    test('should return set language value', () async {
      SharedPreferences.setMockInitialValues({'language': 'pt'});
      final prefs = await SharedPreferences.getInstance();

      final result = await settingsRepository.getLanguage();

      expect(result, 'pt');
    });

    test('should set language value', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await settingsRepository.setLanguage('es');

      final result = prefs.getString('language');
      expect(result, 'es');
    });

    test('should store and retrieve dark mode correctly', () async {
      SharedPreferences.setMockInitialValues({});

      await settingsRepository.setDarkMode(true);
      final result = await settingsRepository.getDarkMode();

      expect(result, true);
    });

    test('should store and retrieve language correctly', () async {
      SharedPreferences.setMockInitialValues({});

      await settingsRepository.setLanguage('de');
      final result = await settingsRepository.getLanguage();

      expect(result, 'de');
    });
  });
}
