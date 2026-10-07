import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../../domain/models/enums.dart';
import '../../../domain/models/song.dart';
import '../../../domain/repositories/playback_state_repository.dart';
import '../database/app_database.dart';

/// Implementation of [PlaybackStateRepository].
///
/// Uses Drift for queue persistence and SharedPreferences for
/// simple playback state values (position, modes).
class DriftPlaybackStateRepository implements PlaybackStateRepository {
  final AppDatabase _db;
  final SharedPreferences _prefs;

  DriftPlaybackStateRepository(this._db, this._prefs);

  // ─── Queue (Drift) ───

  Song _toSong(SongEntity e) {
    return Song(
      id: e.id,
      filePath: e.filePath,
      fileName: e.fileName,
      title: e.title,
      artist: e.artist,
      album: e.album,
      albumArtist: e.albumArtist,
      genre: e.genre,
      trackNumber: e.trackNumber,
      durationMs: e.durationMs,
      fileSize: e.fileSize,
      format: e.format,
      bitrate: e.bitrate,
      sampleRate: e.sampleRate,
      hasArtwork: e.hasArtwork,
      artworkPath: e.artworkPath,
      hasLyrics: e.hasLyrics,
      dateAdded: e.dateAdded,
      dateModified: e.dateModified,
      isFavorite: e.isFavorite,
      playCount: e.playCount,
      lastPlayedAt: e.lastPlayedAt,
    );
  }

  @override
  Future<List<QueueItem>> getQueue() async {
    final query = _db.select(_db.queueItems).join([
      innerJoin(_db.songs, _db.songs.id.equalsExp(_db.queueItems.songId)),
    ])
      ..orderBy([OrderingTerm.asc(_db.queueItems.sortOrder)]);

    final rows = await query.get();
    return rows.map((row) {
      final queueEntity = row.readTable(_db.queueItems);
      final songEntity = row.readTable(_db.songs);
      return QueueItem(
        songId: queueEntity.songId,
        song: _toSong(songEntity),
        sortOrder: queueEntity.sortOrder,
        isCurrent: queueEntity.isCurrent,
      );
    }).toList();
  }

  @override
  Future<void> saveQueue(List<QueueItem> items) async {
    await _db.transaction(() async {
      await _db.delete(_db.queueItems).go();
      for (final item in items) {
        await _db.into(_db.queueItems).insert(
              QueueItemsCompanion.insert(
                songId: item.songId,
                sortOrder: item.sortOrder,
                isCurrent: Value(item.isCurrent),
              ),
            );
      }
    });
  }

  @override
  Future<void> clearQueue() async {
    await _db.delete(_db.queueItems).go();
  }

  @override
  Future<QueueItem?> getCurrentQueueItem() async {
    final query = _db.select(_db.queueItems).join([
      innerJoin(_db.songs, _db.songs.id.equalsExp(_db.queueItems.songId)),
    ])
      ..where(_db.queueItems.isCurrent.equals(true));

    final row = await query.getSingleOrNull();
    if (row == null) return null;

    final queueEntity = row.readTable(_db.queueItems);
    final songEntity = row.readTable(_db.songs);
    return QueueItem(
      songId: queueEntity.songId,
      song: _toSong(songEntity),
      sortOrder: queueEntity.sortOrder,
      isCurrent: true,
    );
  }

  // ─── Simple state (SharedPreferences) ───

  @override
  Future<void> savePlaybackPosition(int positionMs) async {
    await _prefs.setInt(AppConstants.keyLastPlaybackPosition, positionMs);
  }

  @override
  Future<int?> getPlaybackPosition() async {
    return _prefs.getInt(AppConstants.keyLastPlaybackPosition);
  }

  @override
  Future<void> saveLastSongId(int songId) async {
    await _prefs.setInt(AppConstants.keyLastSongId, songId);
  }

  @override
  Future<int?> getLastSongId() async {
    return _prefs.getInt(AppConstants.keyLastSongId);
  }

  @override
  Future<void> saveRepeatMode(RepeatMode mode) async {
    await _prefs.setString(AppConstants.keyRepeatMode, mode.name);
  }

  @override
  Future<RepeatMode> getRepeatMode() async {
    final name = _prefs.getString(AppConstants.keyRepeatMode);
    if (name == null) return RepeatMode.off;
    return RepeatMode.values.firstWhere(
      (m) => m.name == name,
      orElse: () => RepeatMode.off,
    );
  }

  @override
  Future<void> saveShuffleEnabled(bool enabled) async {
    await _prefs.setBool(AppConstants.keyShuffleEnabled, enabled);
  }

  @override
  Future<bool> getShuffleEnabled() async {
    return _prefs.getBool(AppConstants.keyShuffleEnabled) ?? false;
  }
}
