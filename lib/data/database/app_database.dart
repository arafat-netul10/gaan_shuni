import 'package:drift/drift.dart';

import 'tables/songs_table.dart';
import 'tables/playlists_table.dart';
import 'tables/playlist_songs_table.dart';
import 'tables/play_history_table.dart';
import 'tables/queue_items_table.dart';
import 'tables/scan_errors_table.dart';

part 'app_database.g.dart';

/// Central Drift database for Gaan Shuni's music library.
///
/// Tables:
/// - [Songs] — indexed music files
/// - [Playlists] — user-created playlists
/// - [PlaylistSongs] — playlist↔song junction with ordering
/// - [PlayHistory] — playback history log
/// - [QueueItems] — persisted playback queue
/// - [ScanErrors] — files that failed scanning
@DriftDatabase(tables: [
  Songs,
  Playlists,
  PlaylistSongs,
  PlayHistory,
  QueueItems,
  ScanErrors,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
      },
      onUpgrade: (Migrator m, int from, int to) async {
        // Future migrations go here.
        // Use `if (from < 2) { ... }` pattern for incremental upgrades.
      },
    );
  }
}
