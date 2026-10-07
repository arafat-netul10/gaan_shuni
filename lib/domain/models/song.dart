/// Core domain model representing a music file in the library.
///
/// Immutable. Uses [copyWith] for state updates.
/// [displayTitle] falls back to filename when title metadata is missing.
class Song {
  final int id;
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
  final String? artworkPath;
  final bool hasLyrics;
  final DateTime dateAdded;
  final DateTime dateModified;
  final bool isFavorite;
  final int playCount;
  final DateTime? lastPlayedAt;

  const Song({
    required this.id,
    required this.filePath,
    required this.fileName,
    required this.title,
    this.artist = 'Unknown',
    this.album = 'Unknown',
    this.albumArtist,
    this.genre,
    this.trackNumber,
    required this.durationMs,
    required this.fileSize,
    required this.format,
    this.bitrate,
    this.sampleRate,
    this.hasArtwork = false,
    this.artworkPath,
    this.hasLyrics = false,
    required this.dateAdded,
    required this.dateModified,
    this.isFavorite = false,
    this.playCount = 0,
    this.lastPlayedAt,
  });

  /// Display title — uses file name as fallback if title is empty.
  String get displayTitle => title.isNotEmpty ? title : fileName;

  /// Folder path extracted from the full file path.
  String get folderPath {
    final lastSep = filePath.lastIndexOf('/');
    if (lastSep == -1) {
      // Try Windows separator
      final lastBackslash = filePath.lastIndexOf(r'\');
      if (lastBackslash == -1) return filePath;
      return filePath.substring(0, lastBackslash);
    }
    return filePath.substring(0, lastSep);
  }

  Song copyWith({
    int? id,
    String? filePath,
    String? fileName,
    String? title,
    String? artist,
    String? album,
    String? albumArtist,
    String? genre,
    int? trackNumber,
    int? durationMs,
    int? fileSize,
    String? format,
    int? bitrate,
    int? sampleRate,
    bool? hasArtwork,
    String? artworkPath,
    bool? hasLyrics,
    DateTime? dateAdded,
    DateTime? dateModified,
    bool? isFavorite,
    int? playCount,
    DateTime? lastPlayedAt,
  }) {
    return Song(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      albumArtist: albumArtist ?? this.albumArtist,
      genre: genre ?? this.genre,
      trackNumber: trackNumber ?? this.trackNumber,
      durationMs: durationMs ?? this.durationMs,
      fileSize: fileSize ?? this.fileSize,
      format: format ?? this.format,
      bitrate: bitrate ?? this.bitrate,
      sampleRate: sampleRate ?? this.sampleRate,
      hasArtwork: hasArtwork ?? this.hasArtwork,
      artworkPath: artworkPath ?? this.artworkPath,
      hasLyrics: hasLyrics ?? this.hasLyrics,
      dateAdded: dateAdded ?? this.dateAdded,
      dateModified: dateModified ?? this.dateModified,
      isFavorite: isFavorite ?? this.isFavorite,
      playCount: playCount ?? this.playCount,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Song && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Song(id: $id, title: $title, artist: $artist)';
}
