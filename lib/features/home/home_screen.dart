import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/song.dart';
import '../../domain/repositories/song_repository.dart';
import '../../providers/library_provider.dart';
import '../../widgets/artwork_widget.dart';
import '../player/player_provider.dart';
import '../scanning/scan_progress_dialog.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final libraryProvider = context.watch<LibraryProvider>();
    final songRepo = context.watch<SongRepository>();
    final songCount = libraryProvider.songCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gaan Shuni'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded),
            tooltip: 'Rescan Library',
            onPressed: () {
              ScanProgressDialog.show(context);
              libraryProvider.scanLibrary();
            },
          ),
        ],
      ),
      body: songCount == 0
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.music_note_rounded,
                      size: 64,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome to Gaan Shuni',
                      style: theme.textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your offline, privacy-first local music player',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Scan Music on Device'),
                      onPressed: () {
                        ScanProgressDialog.show(context);
                        libraryProvider.scanLibrary();
                      },
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              children: [
                // Library Overview Card
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.library_music_rounded,
                            size: 36,
                            color: theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$songCount Tracks in Library',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'Offline and ready to play',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Recently Played Section
                FutureBuilder<List<Song>>(
                  future: songRepo.getRecentlyPlayed(limit: 10),
                  builder: (context, snapshot) {
                    final recentSongs = snapshot.data ?? [];
                    if (recentSongs.isEmpty) return const SizedBox.shrink();

                    return _buildHorizontalSection(
                      context: context,
                      title: 'Recently Played',
                      songs: recentSongs,
                    );
                  },
                ),

                // Favorites Section
                FutureBuilder<List<Song>>(
                  future: songRepo.getFavorites(),
                  builder: (context, snapshot) {
                    final favSongs = snapshot.data ?? [];
                    if (favSongs.isEmpty) return const SizedBox.shrink();

                    return _buildHorizontalSection(
                      context: context,
                      title: 'Favorites',
                      songs: favSongs,
                    );
                  },
                ),

                // Recently Added Section
                FutureBuilder<List<Song>>(
                  future: songRepo.getRecentlyAdded(limit: 10),
                  builder: (context, snapshot) {
                    final addedSongs = snapshot.data ?? [];
                    if (addedSongs.isEmpty) return const SizedBox.shrink();

                    return _buildHorizontalSection(
                      context: context,
                      title: 'Recently Added',
                      songs: addedSongs,
                    );
                  },
                ),
              ],
            ),
    );
  }

  Widget _buildHorizontalSection({
    required BuildContext context,
    required String title,
    required List<Song> songs,
  }) {
    final theme = Theme.of(context);
    final player = context.read<PlayerProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              return Container(
                width: 120,
                margin: const EdgeInsets.only(right: 14.0),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    player.playSong(song, contextQueue: songs);
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ArtworkWidget(
                        songId: song.id,
                        size: 120,
                        borderRadius: 12,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        song.displayTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        song.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
