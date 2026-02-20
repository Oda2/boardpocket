import 'package:flutter/material.dart';
import '../../data/repositories/settings_repository.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repository = SettingsRepository();

  bool _isDarkMode = true;
  String _language = 'en';
  bool _isLoading = false;

  bool get isDarkMode => _isDarkMode;
  String get language => _language;
  bool get isLoading => _isLoading;

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    _isDarkMode = await _repository.getDarkMode();
    _language = await _repository.getLanguage();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    await _repository.setDarkMode(value);
    notifyListeners();
  }

  Future<void> setLanguage(String value) async {
    _language = value;
    await _repository.setLanguage(value);
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    await setDarkMode(!_isDarkMode);
  }
}
