import 'package:drift/drift.dart';

import 'playlists_table.dart';
import 'songs_table.dart';

/// Junction table linking playlists to songs with explicit ordering.
///
/// [sortOrder] preserves manual user ordering (must not be overwritten
/// by automatic sorting per the product spec).
@DataClassName('PlaylistSongEntity')
class PlaylistSongs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get playlistId => integer().references(Playlists, #id)();
  IntColumn get songId => integer().references(Songs, #id)();
  IntColumn get sortOrder => integer()();
}
