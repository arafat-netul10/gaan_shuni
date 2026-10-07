import 'package:drift/drift.dart';

import '../../../domain/models/playlist.dart';
import '../../../domain/models/song.dart';
import '../../../domain/repositories/playlist_repository.dart';
import '../database/app_database.dart';

/// Drift-backed implementation of [PlaylistRepository].
class DriftPlaylistRepository implements PlaylistRepository {
  final AppDatabase _db;

  DriftPlaylistRepository(this._db);

  // ─── Mapping ───

  Playlist _toPlaylist(PlaylistEntity e, [List<Song> songs = const []]) {
    return Playlist(
      id: e.id,
      name: e.name,
      createdAt: e.createdAt,
      updatedAt: e.updatedAt,
      songs: songs,
    );
  }

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

  // ─── Queries ───

  @override
  Future<List<Playlist>> getAllPlaylists() async {
    final query = _db.select(_db.playlists)
      ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]);
    final entities = await query.get();
    return entities.map((e) => _toPlaylist(e)).toList();
  }

  @override
  Future<Playlist?> getPlaylistById(int id) async {
    final query = _db.select(_db.playlists)
      ..where((t) => t.id.equals(id));
    final entity = await query.getSingleOrNull();
    if (entity == null) return null;

    final songs = await getPlaylistSongs(id);
    return _toPlaylist(entity, songs);
  }

  @override
  Future<int> createPlaylist(String name) async {
    final now = DateTime.now();
    return _db.into(_db.playlists).insert(
          PlaylistsCompanion.insert(
            name: name,
            createdAt: now,
            updatedAt: now,
          ),
        );
  }

  @override
  Future<void> renamePlaylist(int id, String newName) async {
    await (_db.update(_db.playlists)..where((t) => t.id.equals(id))).write(
      PlaylistsCompanion(
        name: Value(newName),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> deletePlaylist(int id) async {
    // PlaylistSongs has ON DELETE CASCADE via FK, but Drift doesn't
    // enforce FK by default — clean up manually to be safe.
    await (_db.delete(_db.playlistSongs)
          ..where((t) => t.playlistId.equals(id)))
        .go();
    await (_db.delete(_db.playlists)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<List<Song>> getPlaylistSongs(int playlistId) async {
    final query = _db.select(_db.playlistSongs).join([
      innerJoin(
        _db.songs,
        _db.songs.id.equalsExp(_db.playlistSongs.songId),
      ),
    ])
      ..where(_db.playlistSongs.playlistId.equals(playlistId))
      ..orderBy([OrderingTerm.asc(_db.playlistSongs.sortOrder)]);

    final rows = await query.get();
    return rows.map((row) => _toSong(row.readTable(_db.songs))).toList();
  }

  @override
  Future<void> addSongToPlaylist(int playlistId, int songId) async {
    // Find the next sort order
    final maxOrder = _db.playlistSongs.sortOrder.max();
    final maxQuery = _db.selectOnly(_db.playlistSongs)
      ..addColumns([maxOrder])
      ..where(_db.playlistSongs.playlistId.equals(playlistId));
    final result = await maxQuery.getSingle();
    final nextOrder = (result.read(maxOrder) ?? -1) + 1;

    await _db.into(_db.playlistSongs).insert(
          PlaylistSongsCompanion.insert(
            playlistId: playlistId,
            songId: songId,
            sortOrder: nextOrder,
          ),
        );

    // Touch the playlist's updatedAt
    await (_db.update(_db.playlists)..where((t) => t.id.equals(playlistId)))
        .write(PlaylistsCompanion(updatedAt: Value(DateTime.now())));
  }

  @override
  Future<void> removeSongFromPlaylist(int playlistId, int songId) async {
    await (_db.delete(_db.playlistSongs)
          ..where((t) =>
              t.playlistId.equals(playlistId) & t.songId.equals(songId)))
        .go();
    await (_db.update(_db.playlists)..where((t) => t.id.equals(playlistId)))
        .write(PlaylistsCompanion(updatedAt: Value(DateTime.now())));
  }

  @override
  Future<void> reorderPlaylistSongs(int playlistId, List<int> songIds) async {
    await _db.transaction(() async {
      // Delete existing order
      await (_db.delete(_db.playlistSongs)
            ..where((t) => t.playlistId.equals(playlistId)))
          .go();

      // Re-insert with new order
      for (int i = 0; i < songIds.length; i++) {
        await _db.into(_db.playlistSongs).insert(
              PlaylistSongsCompanion.insert(
                playlistId: playlistId,
                songId: songIds[i],
                sortOrder: i,
              ),
            );
      }

      await (_db.update(_db.playlists)..where((t) => t.id.equals(playlistId)))
          .write(PlaylistsCompanion(updatedAt: Value(DateTime.now())));
    });
  }

  @override
  Stream<List<Playlist>> watchAllPlaylists() {
    final query = _db.select(_db.playlists)
      ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]);
    return query.watch().map((rows) =>
        rows.map((e) => _toPlaylist(e)).toList());
  }
}
