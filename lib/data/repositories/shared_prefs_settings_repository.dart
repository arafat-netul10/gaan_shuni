import 'package:flutter/material.dart' show ThemeMode;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/repositories/settings_repository.dart';

/// SharedPreferences-backed implementation of [SettingsRepository].
///
/// Used for lightweight key-value settings that don't need a database.
class SharedPrefsSettingsRepository implements SettingsRepository {
  final SharedPreferences _prefs;

  SharedPrefsSettingsRepository(this._prefs);

  @override
  Future<ThemeMode> getThemeMode() async {
    final value = _prefs.getString(AppConstants.keyThemeMode);
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  @override
  Future<void> setThemeMode(ThemeMode mode) async {
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _prefs.setString(AppConstants.keyThemeMode, value);
  }

  @override
  Future<bool> isFirstLaunch() async {
    return _prefs.getBool(AppConstants.keyFirstLaunch) ?? true;
  }

  @override
  Future<void> setFirstLaunchComplete() async {
    await _prefs.setBool(AppConstants.keyFirstLaunch, false);
  }

  @override
  Future<String?> getDefaultSortField() async {
    return _prefs.getString(AppConstants.keyDefaultSortField);
  }

  @override
  Future<void> setDefaultSortField(String field) async {
    await _prefs.setString(AppConstants.keyDefaultSortField, field);
  }

  @override
  Future<String?> getDefaultSortOrder() async {
    return _prefs.getString(AppConstants.keyDefaultSortOrder);
  }

  @override
  Future<void> setDefaultSortOrder(String order) async {
    await _prefs.setString(AppConstants.keyDefaultSortOrder, order);
  }
}
