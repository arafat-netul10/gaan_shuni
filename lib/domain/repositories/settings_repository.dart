import 'package:flutter/material.dart' show ThemeMode;

/// Repository interface for application settings (key-value persistence).
abstract class SettingsRepository {
  /// Returns the saved theme mode. Defaults to [ThemeMode.system].
  Future<ThemeMode> getThemeMode();

  /// Saves the selected theme mode.
  Future<void> setThemeMode(ThemeMode mode);

  /// Returns whether this is the first app launch.
  Future<bool> isFirstLaunch();

  /// Marks the first launch as complete.
  Future<void> setFirstLaunchComplete();

  /// Returns the default sort field name, or null.
  Future<String?> getDefaultSortField();

  /// Sets the default sort field.
  Future<void> setDefaultSortField(String field);

  /// Returns the default sort order name, or null.
  Future<String?> getDefaultSortOrder();

  /// Sets the default sort order.
  Future<void> setDefaultSortOrder(String order);
}
