import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/song.dart';
import '../../../domain/repositories/song_repository.dart';
import '../../../widgets/artwork_widget.dart';
import '../../../widgets/empty_state.dart';

class ArtistsTab extends StatelessWidget {
  final void Function(Song song)? onSongTap;

  const ArtistsTab({super.key, this.onSongTap});

  @override
  Widget build(BuildContext context) {
    final songRepo = context.watch<SongRepository>();

    return FutureBuilder<Map<String, List<Song>>>(
      future: songRepo.getSongsByArtist(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final artistMap = snapshot.data!;
        if (artistMap.isEmpty) {
          return const EmptyState(
            icon: Icons.person_off_outlined,
            title: 'No Artists Found',
            message: 'Your music library does not contain any artists yet.',
          );
        }

        final artistEntries = artistMap.entries.toList();

        return ListView.builder(
          itemCount: artistEntries.length,
          itemBuilder: (context, index) {
            final entry = artistEntries[index];
            final artistName = entry.key;
            final songs = entry.value;

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary.withAlpha(30),
                child: Icon(
                  Icons.person_rounded,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: Text(
                artistName,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                '${songs.length} ${songs.length == 1 ? 'song' : 'songs'}',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () {
                _showArtistSongsModal(context, artistName, songs);
              },
            );
          },
        );
      },
    );
  }

  void _showArtistSongsModal(
    BuildContext context,
    String artistName,
    List<Song> songs,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: Text(artistName),
          ),
          body: ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              return ListTile(
                leading: ArtworkWidget(songId: song.id, size: 40),
                title: Text(song.displayTitle),
                subtitle: Text(song.album),
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
