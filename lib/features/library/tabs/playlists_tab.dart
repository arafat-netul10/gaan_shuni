import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/playlist.dart';
import '../../../domain/models/song.dart';
import '../../../domain/repositories/playlist_repository.dart';
import '../../../widgets/artwork_widget.dart';
import '../../../widgets/empty_state.dart';

class PlaylistsTab extends StatelessWidget {
  final void Function(Song song)? onSongTap;

  const PlaylistsTab({super.key, this.onSongTap});

  @override
  Widget build(BuildContext context) {
    final playlistRepo = context.watch<PlaylistRepository>();

    return StreamBuilder<List<Playlist>>(
      stream: playlistRepo.watchAllPlaylists(),
      builder: (context, snapshot) {
        final playlists = snapshot.data ?? [];

        return Scaffold(
          floatingActionButton: FloatingActionButton(
            mini: true,
            onPressed: () => _showCreatePlaylistDialog(context, playlistRepo),
            child: const Icon(Icons.add_rounded),
          ),
          body: playlists.isEmpty
              ? EmptyState(
                  icon: Icons.playlist_add_rounded,
                  title: 'No Playlists Yet',
                  message: 'Create custom playlists to organize your favorite music.',
                  actionLabel: 'Create Playlist',
                  onAction: () => _showCreatePlaylistDialog(context, playlistRepo),
                )
              : ListView.builder(
                  itemCount: playlists.length,
                  itemBuilder: (context, index) {
                    final pl = playlists[index];
                    return ListTile(
                      leading: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.queue_music_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      title: Text(
                        pl.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        '${pl.songs.length} tracks',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (action) async {
                          if (action == 'delete') {
                            await playlistRepo.deletePlaylist(pl.id);
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                                SizedBox(width: 8),
                                Text('Delete', style: TextStyle(color: Colors.redAccent)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      onTap: () {
                        _showPlaylistDetailsModal(context, playlistRepo, pl);
                      },
                    );
                  },
                ),
        );
      },
    );
  }

  void _showCreatePlaylistDialog(
    BuildContext context,
    PlaylistRepository playlistRepo,
  ) {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Playlist'),
        content: TextField(
          controller: textController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Playlist name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final name = textController.text.trim();
              if (name.isNotEmpty) {
                await playlistRepo.createPlaylist(name);
                if (context.mounted) Navigator.pop(context);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showPlaylistDetailsModal(
    BuildContext context,
    PlaylistRepository playlistRepo,
    Playlist playlist,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) {
        return FutureBuilder<Playlist?>(
          future: playlistRepo.getPlaylistById(playlist.id),
          builder: (context, snapshot) {
            final pl = snapshot.data ?? playlist;
            return Scaffold(
              appBar: AppBar(
                title: Text(pl.name),
              ),
              body: pl.songs.isEmpty
                  ? const Center(
                      child: Text('This playlist has no songs yet.'),
                    )
                  : ListView.builder(
                      itemCount: pl.songs.length,
                      itemBuilder: (context, index) {
                        final song = pl.songs[index];
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
      },
    );
  }
}
