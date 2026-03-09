import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boardpocket/data/repositories/settings_repository.dart';

void main() {
  late SettingsRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repository = SettingsRepository();
  });

  group('SettingsRepository', () {
    test('getDarkMode should return default true', () async {
      final result = await repository.getDarkMode();

      expect(result, equals(true));
    });

    test('setDarkMode should update dark mode value', () async {
      await repository.setDarkMode(false);

      final result = await repository.getDarkMode();

      expect(result, equals(false));
    });

    test('getLanguage should return default en', () async {
      final result = await repository.getLanguage();

      expect(result, equals('en'));
    });

    test('setLanguage should update language value', () async {
      await repository.setLanguage('pt');

      final result = await repository.getLanguage();

      expect(result, equals('pt'));
    });

    test('setDarkMode should persist across instances', () async {
      await repository.setDarkMode(false);

      final newRepo = SettingsRepository();
      final result = await newRepo.getDarkMode();

      expect(result, equals(false));
    });

    test('setLanguage should persist across instances', () async {
      await repository.setLanguage('es');

      final newRepo = SettingsRepository();
      final result = await newRepo.getLanguage();

      expect(result, equals('es'));
    });

    test('should handle multiple language changes', () async {
      await repository.setLanguage('pt');
      expect(await repository.getLanguage(), equals('pt'));

      await repository.setLanguage('es');
      expect(await repository.getLanguage(), equals('es'));

      await repository.setLanguage('en');
      expect(await repository.getLanguage(), equals('en'));
    });

    test('should handle dark mode toggle', () async {
      expect(await repository.getDarkMode(), equals(true));

      await repository.setDarkMode(false);
      expect(await repository.getDarkMode(), equals(false));

      await repository.setDarkMode(true);
      expect(await repository.getDarkMode(), equals(true));
    });
  });
}
