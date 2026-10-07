import 'song.dart';

/// Domain model for a user-created playlist.
class Playlist {
  final int id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Song> songs;

  const Playlist({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.songs = const [],
  });

  int get songCount => songs.length;

  Playlist copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Song>? songs,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      songs: songs ?? this.songs,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Playlist && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Playlist(id: $id, name: $name, songs: $songCount)';
}
