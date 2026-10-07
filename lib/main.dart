import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'data/database/app_database.dart';
import 'data/database/connection/native.dart';
import 'data/repositories/drift_playback_state_repository.dart';
import 'data/repositories/drift_playlist_repository.dart';
import 'data/repositories/drift_song_repository.dart';
import 'data/repositories/shared_prefs_settings_repository.dart';
import 'data/services/app_permission_service.dart';
import 'data/services/device_music_scanner_service.dart';
import 'domain/repositories/playback_state_repository.dart';
import 'domain/repositories/playlist_repository.dart';
import 'domain/repositories/settings_repository.dart';
import 'domain/repositories/song_repository.dart';
import 'domain/services/music_scanner_service.dart';
import 'domain/services/permission_service.dart';
import 'features/player/audio_player_handler.dart';
import 'features/player/player_provider.dart';
import 'providers/library_provider.dart';
import 'providers/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // Initialize Drift database
  final db = AppDatabase(openConnection());

  // Instantiate repositories & services
  final settingsRepo = SharedPrefsSettingsRepository(prefs);
  final songRepo = DriftSongRepository(db);
  final playlistRepo = DriftPlaylistRepository(db);
  final playbackStateRepo = DriftPlaybackStateRepository(db, prefs);
  final permissionService = AppPermissionService();
  final scannerService = DeviceMusicScannerService();

  // Initialize background AudioHandler via audio_service
  final audioHandler = await AudioService.init(
    builder: () => GaanShuniAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.gaan_shuni.channel.audio',
      androidNotificationChannelName: 'Gaan Shuni Audio Playback',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        // Repository providers for dependency injection
        Provider<SongRepository>.value(value: songRepo),
        Provider<PlaylistRepository>.value(value: playlistRepo),
        Provider<PlaybackStateRepository>.value(value: playbackStateRepo),
        Provider<SettingsRepository>.value(value: settingsRepo),
        Provider<PermissionService>.value(value: permissionService),
        Provider<MusicScannerService>.value(value: scannerService),
        Provider<GaanShuniAudioHandler>.value(value: audioHandler),

        // App-wide state providers
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(settingsRepository: settingsRepo),
        ),
        ChangeNotifierProvider<LibraryProvider>(
          create: (_) => LibraryProvider(
            songRepository: songRepo,
            scannerService: scannerService,
            permissionService: permissionService,
          ),
        ),
        ChangeNotifierProvider<PlayerProvider>(
          create: (_) => PlayerProvider(
            audioHandler: audioHandler,
            songRepository: songRepo,
            playbackStateRepository: playbackStateRepo,
          ),
        ),
      ],
      child: const GaanShuniApp(),
    ),
  );
}
