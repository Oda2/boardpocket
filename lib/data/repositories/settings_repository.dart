import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const String _darkModeKey = 'dark_mode';
  static const String _languageKey = 'language';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get _preferences async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<bool> getDarkMode() async {
    final prefs = await _preferences;
    return prefs.getBool(_darkModeKey) ?? true;
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await _preferences;
    await prefs.setBool(_darkModeKey, value);
  }

  Future<String> getLanguage() async {
    final prefs = await _preferences;
    return prefs.getString(_languageKey) ?? 'en';
  }

  Future<void> setLanguage(String value) async {
    final prefs = await _preferences;
    await prefs.setString(_languageKey, value);
  }
}
