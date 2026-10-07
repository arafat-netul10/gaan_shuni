import '../models/enums.dart';
import '../models/song.dart';

/// Persisted queue item for playback state restoration.
class QueueItem {
  final int songId;
  final Song? song;
  final int sortOrder;
  final bool isCurrent;

  const QueueItem({
    required this.songId,
    this.song,
    required this.sortOrder,
    this.isCurrent = false,
  });
}

/// Repository interface for persisting playback state across app restarts.
///
/// Queue items are stored in the database (Drift).
/// Simple values (position, modes) are stored in SharedPreferences.
abstract class PlaybackStateRepository {
  /// Returns the persisted queue with songs loaded.
  Future<List<QueueItem>> getQueue();

  /// Saves the full queue (replaces existing).
  Future<void> saveQueue(List<QueueItem> items);

  /// Clears the persisted queue.
  Future<void> clearQueue();

  /// Returns the current queue item (the song that was playing).
  Future<QueueItem?> getCurrentQueueItem();

  /// Saves the last playback position in milliseconds.
  Future<void> savePlaybackPosition(int positionMs);

  /// Returns the last saved playback position, or null.
  Future<int?> getPlaybackPosition();

  /// Saves the last playing song ID.
  Future<void> saveLastSongId(int songId);

  /// Returns the last playing song ID, or null.
  Future<int?> getLastSongId();

  /// Saves the current repeat mode.
  Future<void> saveRepeatMode(RepeatMode mode);

  /// Returns the saved repeat mode, defaults to [RepeatMode.off].
  Future<RepeatMode> getRepeatMode();

  /// Saves whether shuffle is enabled.
  Future<void> saveShuffleEnabled(bool enabled);

  /// Returns whether shuffle was enabled, defaults to false.
  Future<bool> getShuffleEnabled();
}
