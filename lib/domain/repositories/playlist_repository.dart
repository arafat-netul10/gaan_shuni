import '../models/playlist.dart';
import '../models/song.dart';

/// Repository interface for playlist operations.
abstract class PlaylistRepository {
  /// Returns all playlists (without songs loaded).
  Future<List<Playlist>> getAllPlaylists();

  /// Returns a playlist by ID with its songs loaded.
  Future<Playlist?> getPlaylistById(int id);

  /// Creates a new playlist. Returns the assigned ID.
  Future<int> createPlaylist(String name);

  /// Renames a playlist.
  Future<void> renamePlaylist(int id, String newName);

  /// Deletes a playlist and its song associations.
  Future<void> deletePlaylist(int id);

  /// Returns songs in a playlist, ordered by sort_order.
  Future<List<Song>> getPlaylistSongs(int playlistId);

  /// Adds a song to a playlist. Appends at the end.
  Future<void> addSongToPlaylist(int playlistId, int songId);

  /// Removes a song from a playlist.
  Future<void> removeSongFromPlaylist(int playlistId, int songId);

  /// Reorders songs in a playlist. [songIds] is the new order.
  Future<void> reorderPlaylistSongs(int playlistId, List<int> songIds);

  /// Reactive stream of all playlists.
  Stream<List<Playlist>> watchAllPlaylists();
}
