import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/song.dart';
import '../../../domain/repositories/song_repository.dart';
import '../../../widgets/artwork_widget.dart';
import '../../../widgets/empty_state.dart';

class AlbumsTab extends StatelessWidget {
  final void Function(Song song)? onSongTap;

  const AlbumsTab({super.key, this.onSongTap});

  @override
  Widget build(BuildContext context) {
    final songRepo = context.watch<SongRepository>();

    return FutureBuilder<Map<String, List<Song>>>(
      future: songRepo.getSongsByAlbum(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final albumMap = snapshot.data!;
        if (albumMap.isEmpty) {
          return const EmptyState(
            icon: Icons.album_outlined,
            title: 'No Albums Found',
            message: 'Your music library does not contain any albums yet.',
          );
        }

        final albumEntries = albumMap.entries.toList();

        return GridView.builder(
          padding: const EdgeInsets.all(16.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            childAspectRatio: 0.8,
          ),
          itemCount: albumEntries.length,
          itemBuilder: (context, index) {
            final entry = albumEntries[index];
            final albumName = entry.key;
            final songs = entry.value;
            final representativeSong = songs.first;

            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                _showAlbumSongsModal(context, albumName, songs);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: SizedBox(
                      width: double.infinity,
                      child: ArtworkWidget(
                        songId: representativeSong.id,
                        size: double.infinity,
                        borderRadius: 12,
                        fallbackIcon: Icons.album_rounded,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    albumName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  Text(
                    '${representativeSong.artist} • ${songs.length} tracks',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAlbumSongsModal(
    BuildContext context,
    String albumName,
    List<Song> songs,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: Text(albumName),
          ),
          body: ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              return ListTile(
                leading: ArtworkWidget(songId: song.id, size: 40),
                title: Text(song.displayTitle),
                subtitle: Text(song.artist),
                onTap: () {
                  Navigator.pop(context);
                  onSongTap?.call(song);
                },
              );
            },
          ),
        );
      },
    );
  }
}
