/// Raw discovered song representation before database insertion.
class DiscoveredAudioFile {
  final String filePath;
  final String fileName;
  final String title;
  final String artist;
  final String album;
  final String? albumArtist;
  final String? genre;
  final int? trackNumber;
  final int durationMs;
  final int fileSize;
  final String format;
  final int? bitrate;
  final int? sampleRate;
  final bool hasArtwork;
  final bool hasLyrics;
  final int dateAdded;
  final int dateModified;

  const DiscoveredAudioFile({
    required this.filePath,
    required this.fileName,
    required this.title,
    required this.artist,
    required this.album,
    this.albumArtist,
    this.genre,
    this.trackNumber,
    required this.durationMs,
    required this.fileSize,
    required this.format,
    this.bitrate,
    this.sampleRate,
    this.hasArtwork = false,
    this.hasLyrics = false,
    required this.dateAdded,
    required this.dateModified,
  });
}

/// Abstract contract for discovering and scanning audio files on the host device.
abstract class MusicScannerService {
  /// Scans for local music files and yields progress (scanned, total).
  Future<List<DiscoveredAudioFile>> scanMusic({
    void Function(int current, int total)? onProgress,
  });
}
