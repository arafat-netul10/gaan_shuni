/// Application-wide constants.
class AppConstants {
  AppConstants._();

  static const String appName = 'Gaan Shuni';
  static const String appVersion = '1.0.0';

  // Database
  static const String databaseName = 'gaan_shuni.sqlite';

  // Library limits
  static const int recentlyPlayedLimit = 50;
  static const int recentlyAddedLimit = 50;

  // Supported audio formats
  static const List<String> supportedFormats = [
    'mp3',
    'm4a',
    'aac',
    'wav',
    'ogg',
  ];

  // SharedPreferences keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyFirstLaunch = 'first_launch';
  static const String keyDefaultSortField = 'default_sort_field';
  static const String keyDefaultSortOrder = 'default_sort_order';
  static const String keyLastPlaybackPosition = 'last_playback_position';
  static const String keyRepeatMode = 'repeat_mode';
  static const String keyShuffleEnabled = 'shuffle_enabled';
  static const String keyLastSongId = 'last_song_id';
}
