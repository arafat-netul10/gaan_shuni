import 'package:flutter/material.dart';

import '../domain/repositories/settings_repository.dart';

/// Provider for managing and persisting application theme mode.
class ThemeProvider extends ChangeNotifier {
  final SettingsRepository settingsRepository;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeProvider({required this.settingsRepository}) {
    _loadThemeMode();
  }

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> _loadThemeMode() async {
    _themeMode = await settingsRepository.getThemeMode();
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    await settingsRepository.setThemeMode(mode);
  }

  Future<void> toggleTheme() async {
    final newMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setThemeMode(newMode);
  }
}
