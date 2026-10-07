import 'package:drift/drift.dart';

import '../../../domain/models/enums.dart';
import '../../../domain/models/song.dart';
import '../../../domain/repositories/song_repository.dart';
import '../database/app_database.dart';

/// Drift-backed implementation of [SongRepository].
///
/// Converts between Drift [SongEntity] and domain [Song] model.
class DriftSongRepository implements SongRepository {
  final AppDatabase _db;

  DriftSongRepository(this._db);

  // ─── Mapping ───

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

  SongsCompanion _toCompanion(Song s) {
    return SongsCompanion(
      filePath: Value(s.filePath),
      fileName: Value(s.fileName),
      title: Value(s.title),
      artist: Value(s.artist),
      album: Value(s.album),
      albumArtist: Value(s.albumArtist),
      genre: Value(s.genre),
      trackNumber: Value(s.trackNumber),
      durationMs: Value(s.durationMs),
      fileSize: Value(s.fileSize),
      format: Value(s.format),
      bitrate: Value(s.bitrate),
      sampleRate: Value(s.sampleRate),
      hasArtwork: Value(s.hasArtwork),
      artworkPath: Value(s.artworkPath),
      hasLyrics: Value(s.hasLyrics),
      dateAdded: Value(s.dateAdded),
      dateModified: Value(s.dateModified),
      isFavorite: Value(s.isFavorite),
      playCount: Value(s.playCount),
      lastPlayedAt: Value(s.lastPlayedAt),
    );
  }

  // ─── Queries ───

  @override
  Future<List<Song>> getAllSongs({
    SortField sortBy = SortField.title,
    SortOrder order = SortOrder.ascending,
  }) async {
    final query = _db.select(_db.songs);
    query.orderBy([
      (t) => _sortFieldToOrdering(t, sortBy, order),
    ]);
    final entities = await query.get();
    return entities.map(_toSong).toList();
  }

  OrderingTerm _sortFieldToOrdering(
    $SongsTable t,
    SortField field,
    SortOrder order,
  ) {
    final mode =
        order == SortOrder.ascending ? OrderingMode.asc : OrderingMode.desc;
    return switch (field) {
      SortField.title => OrderingTerm(expression: t.title, mode: mode),
      SortField.artist => OrderingTerm(expression: t.artist, mode: mode),
      SortField.album => OrderingTerm(expression: t.album, mode: mode),
      SortField.dateAdded => OrderingTerm(expression: t.dateAdded, mode: mode),
      SortField.duration => OrderingTerm(expression: t.durationMs, mode: mode),
      SortField.fileName => OrderingTerm(expression: t.fileName, mode: mode),
      SortField.custom => OrderingTerm(expression: t.id, mode: mode),
    };
  }

  @override
  Future<Song?> getSongById(int id) async {
    final query = _db.select(_db.songs)
      ..where((t) => t.id.equals(id));
    final entity = await query.getSingleOrNull();
    return entity != null ? _toSong(entity) : null;
  }

  @override
  Future<Song?> getSongByPath(String filePath) async {
    final query = _db.select(_db.songs)
      ..where((t) => t.filePath.equals(filePath));
    final entity = await query.getSingleOrNull();
    return entity != null ? _toSong(entity) : null;
  }

  @override
  Future<int> insertSong(Song song) async {
    return _db.into(_db.songs).insert(_toCompanion(song));
  }

  @override
  Future<void> insertSongs(List<Song> songs) async {
    await _db.batch((batch) {
      batch.insertAll(
        _db.songs,
        songs.map(_toCompanion).toList(),
        mode: InsertMode.insertOrIgnore,
      );
    });
  }

  @override
  Future<void> updateSong(Song song) async {
    await (_db.update(_db.songs)..where((t) => t.id.equals(song.id)))
        .write(_toCompanion(song));
  }

  @override
  Future<void> deleteSong(int id) async {
    await (_db.delete(_db.songs)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> deleteSongByPath(String filePath) async {
    await (_db.delete(_db.songs)..where((t) => t.filePath.equals(filePath)))
        .go();
  }

  @override
  Future<List<Song>> searchSongs(String query) async {
    if (query.isEmpty) return [];
    final pattern = '%$query%';
    final q = _db.select(_db.songs)
      ..where((t) =>
          t.title.like(pattern) |
          t.artist.like(pattern) |
          t.album.like(pattern) |
          t.genre.like(pattern) |
          t.fileName.like(pattern));
    final entities = await q.get();
    return entities.map(_toSong).toList();
  }

  @override
  Future<List<Song>> getFavorites() async {
    final query = _db.select(_db.songs)
      ..where((t) => t.isFavorite.equals(true))
      ..orderBy([(t) => OrderingTerm.asc(t.title)]);
    return (await query.get()).map(_toSong).toList();
  }

  @override
  Future<void> toggleFavorite(int songId) async {
    final song = await getSongById(songId);
    if (song == null) return;
    await (_db.update(_db.songs)..where((t) => t.id.equals(songId)))
        .write(SongsCompanion(isFavorite: Value(!song.isFavorite)));
  }

  @override
  Future<List<Song>> getRecentlyPlayed({int limit = 50}) async {
    final query = _db.select(_db.songs)
      ..where((t) => t.lastPlayedAt.isNotNull())
      ..orderBy([(t) => OrderingTerm.desc(t.lastPlayedAt)])
      ..limit(limit);
    return (await query.get()).map(_toSong).toList();
  }

  @override
  Future<List<Song>> getRecentlyAdded({int limit = 50}) async {
    final query = _db.select(_db.songs)
      ..orderBy([(t) => OrderingTerm.desc(t.dateAdded)])
      ..limit(limit);
    return (await query.get()).map(_toSong).toList();
  }

  @override
  Future<void> recordPlay(int songId) async {
    final now = DateTime.now();

    // Update song's play count and last played timestamp
    await (_db.update(_db.songs)..where((t) => t.id.equals(songId))).write(
      SongsCompanion.custom(
        playCount: _db.songs.playCount + const Constant(1),
        lastPlayedAt: Variable(now),
      ),
    );

    // Insert play history entry
    await _db.into(_db.playHistory).insert(
          PlayHistoryCompanion.insert(songId: songId, playedAt: now),
        );
  }

  @override
  Future<int> getSongCount() async {
    final count = _db.songs.id.count();
    final query = _db.selectOnly(_db.songs)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  @override
  Future<Map<String, List<Song>>> getSongsByAlbum() async {
    final songs = await getAllSongs(sortBy: SortField.album);
    final map = <String, List<Song>>{};
    for (final song in songs) {
      map.putIfAbsent(song.album, () => []).add(song);
    }
    return map;
  }

  @override
  Future<Map<String, List<Song>>> getSongsByArtist() async {
    final songs = await getAllSongs(sortBy: SortField.artist);
    final map = <String, List<Song>>{};
    for (final song in songs) {
      map.putIfAbsent(song.artist, () => []).add(song);
    }
    return map;
  }

  @override
  Future<Map<String, List<Song>>> getSongsByGenre() async {
    final songs = await getAllSongs(sortBy: SortField.title);
    final map = <String, List<Song>>{};
    for (final song in songs) {
      final genre = song.genre ?? 'Unknown';
      map.putIfAbsent(genre, () => []).add(song);
    }
    return map;
  }

  @override
  Future<Map<String, List<Song>>> getSongsByFolder() async {
    final songs = await getAllSongs(sortBy: SortField.fileName);
    final map = <String, List<Song>>{};
    for (final song in songs) {
      map.putIfAbsent(song.folderPath, () => []).add(song);
    }
    return map;
  }

  @override
  Future<Set<String>> getAllIndexedPaths() async {
    final query = _db.selectOnly(_db.songs)
      ..addColumns([_db.songs.filePath]);
    final rows = await query.get();
    return rows.map((row) => row.read(_db.songs.filePath)!).toSet();
  }

  @override
  Stream<List<Song>> watchAllSongs() {
    final query = _db.select(_db.songs)
      ..orderBy([(t) => OrderingTerm.asc(t.title)]);
    return query.watch().map((rows) => rows.map(_toSong).toList());
  }

  @override
  Stream<List<Song>> watchFavorites() {
    final query = _db.select(_db.songs)
      ..where((t) => t.isFavorite.equals(true))
      ..orderBy([(t) => OrderingTerm.asc(t.title)]);
    return query.watch().map((rows) => rows.map(_toSong).toList());
  }
}
