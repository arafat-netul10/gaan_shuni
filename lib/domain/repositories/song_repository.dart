import '../models/song.dart';
import '../models/enums.dart';

/// Repository interface for song/library operations.
///
/// Abstracts database access. Implementations handle Drift queries
/// and convert between DB entities and domain models.
abstract class SongRepository {
  /// Returns all songs, optionally sorted.
  Future<List<Song>> getAllSongs({
    SortField sortBy = SortField.title,
    SortOrder order = SortOrder.ascending,
  });

  /// Returns a song by its database ID.
  Future<Song?> getSongById(int id);

  /// Returns a song by its file path (unique).
  Future<Song?> getSongByPath(String filePath);

  /// Inserts a new song. Returns the assigned ID.
  Future<int> insertSong(Song song);

  /// Inserts multiple songs in a batch.
  Future<void> insertSongs(List<Song> songs);

  /// Updates an existing song.
  Future<void> updateSong(Song song);

  /// Deletes a song by ID.
  Future<void> deleteSong(int id);

  /// Deletes a song by file path.
  Future<void> deleteSongByPath(String filePath);

  /// Searches songs by query across title, artist, album, genre, fileName.
  Future<List<Song>> searchSongs(String query);

  /// Returns all favorited songs.
  Future<List<Song>> getFavorites();

  /// Toggles the favorite status of a song.
  Future<void> toggleFavorite(int songId);

  /// Returns recently played songs (by last_played_at, descending).
  Future<List<Song>> getRecentlyPlayed({int limit = 50});

  /// Returns recently added songs (by date_added, descending).
  Future<List<Song>> getRecentlyAdded({int limit = 50});

  /// Records a play event: increments play_count, sets last_played_at.
  Future<void> recordPlay(int songId);

  /// Returns total number of songs in the library.
  Future<int> getSongCount();

  /// Returns all unique album names with a representative song for artwork.
  Future<Map<String, List<Song>>> getSongsByAlbum();

  /// Returns all unique artist names with their songs.
  Future<Map<String, List<Song>>> getSongsByArtist();

  /// Returns all unique genre names with their songs.
  Future<Map<String, List<Song>>> getSongsByGenre();

  /// Returns all unique folder paths with their songs.
  Future<Map<String, List<Song>>> getSongsByFolder();

  /// Returns all file paths currently indexed.
  Future<Set<String>> getAllIndexedPaths();

  /// Reactive stream of all songs.
  Stream<List<Song>> watchAllSongs();

  /// Reactive stream of favorites.
  Stream<List<Song>> watchFavorites();
}
