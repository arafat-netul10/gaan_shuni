import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:provider/provider.dart';

import '../../domain/models/song.dart';
import '../../domain/repositories/song_repository.dart';
import '../../widgets/artwork_widget.dart';
import '../../widgets/empty_state.dart';

class FoldersScreen extends StatelessWidget {
  final void Function(Song song)? onSongTap;

  const FoldersScreen({super.key, this.onSongTap});

  @override
  Widget build(BuildContext context) {
    final songRepo = context.watch<SongRepository>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Folders'),
      ),
      body: FutureBuilder<Map<String, List<Song>>>(
        future: songRepo.getSongsByFolder(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final folderMap = snapshot.data!;
          if (folderMap.isEmpty) {
            return const EmptyState(
              icon: Icons.folder_off_outlined,
              title: 'No Folders Found',
              message: 'Scan your device to view your physical music folders.',
            );
          }

          final entries = folderMap.entries.toList();

          return ListView.builder(
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              final folderPath = entry.key;
              final folderName = p.basename(folderPath);
              final songs = entry.value;

              return ListTile(
                leading: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary.withAlpha(20),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.folder_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                title: Text(
                  folderName.isNotEmpty ? folderName : folderPath,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  '$folderPath\n${songs.length} ${songs.length == 1 ? 'song' : 'songs'}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  _showFolderSongsModal(context, folderName, songs);
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showFolderSongsModal(
    BuildContext context,
    String folderName,
    List<Song> songs,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return Scaffold(
          appBar: AppBar(
            title: Text(folderName),
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
