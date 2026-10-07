import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../domain/models/enums.dart';
import '../../../domain/models/song.dart';
import '../../../domain/repositories/song_repository.dart';
import '../../../providers/library_provider.dart';
import '../../../widgets/empty_state.dart';
import '../../../widgets/song_tile.dart';
import '../../scanning/scan_progress_dialog.dart';
import '../../song_details/song_details_dialog.dart';

class SongsTab extends StatelessWidget {
  final void Function(Song song)? onSongTap;

  const SongsTab({super.key, this.onSongTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final libraryProvider = context.watch<LibraryProvider>();
    final songRepo = context.read<SongRepository>();
    final songs = libraryProvider.songs;

    if (songs.isEmpty) {
      return EmptyState(
        icon: Icons.music_off_rounded,
        title: 'No Songs Found',
        message: 'Scan your device to index and play your local music.',
        actionLabel: 'Scan Library',
        onAction: () {
          ScanProgressDialog.show(context);
          libraryProvider.scanLibrary();
        },
      );
    }

    return Column(
      children: [
        // Header with count and sorting button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Text(
                '${songs.length} Tracks',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                icon: const Icon(Icons.sort_rounded, size: 18),
                label: Text(_sortLabel(libraryProvider.sortField)),
                onPressed: () => _showSortModal(context, libraryProvider),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        // Song list
        Expanded(
          child: ListView.builder(
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              return SongTile(
                song: song,
                onTap: () => onSongTap?.call(song),
                onFavoriteToggle: () async {
                  await songRepo.toggleFavorite(song.id);
                },
                onMenuAction: (action) {
                  if (action == 'details') {
                    SongDetailsDialog.show(context, song);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }

  String _sortLabel(SortField field) {
    return switch (field) {
      SortField.title => 'Title',
      SortField.artist => 'Artist',
      SortField.album => 'Album',
      SortField.dateAdded => 'Date Added',
      SortField.duration => 'Duration',
      SortField.fileName => 'File Name',
      SortField.custom => 'Default',
    };
  }

  void _showSortModal(BuildContext context, LibraryProvider provider) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Sort Tracks By',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              ...SortField.values.map((field) {
                final isSelected = provider.sortField == field;
                return ListTile(
                  leading: Icon(
                    isSelected ? Icons.check_circle_rounded : Icons.circle_outlined,
                    color: isSelected ? Theme.of(context).colorScheme.primary : null,
                  ),
                  title: Text(_sortLabel(field)),
                  onTap: () {
                    final newOrder = isSelected && provider.sortOrder == SortOrder.ascending
                        ? SortOrder.descending
                        : SortOrder.ascending;
                    provider.setSorting(field, newOrder);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
