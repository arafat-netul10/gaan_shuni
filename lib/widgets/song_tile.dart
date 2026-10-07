import 'package:flutter/material.dart';

import '../core/utils/duration_formatter.dart';
import '../domain/models/song.dart';
import 'artwork_widget.dart';

/// Reusable list tile for a song row.
class SongTile extends StatelessWidget {
  final Song song;
  final bool isPlaying;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final void Function(String action)? onMenuAction;

  const SongTile({
    super.key,
    required this.song,
    this.isPlaying = false,
    this.onTap,
    this.onFavoriteToggle,
    this.onMenuAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accentColor = theme.colorScheme.primary;

    return ListTile(
      onTap: onTap,
      leading: ArtworkWidget(
        songId: song.id,
        size: 48,
        borderRadius: 8,
      ),
      title: Text(
        song.displayTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: isPlaying ? FontWeight.bold : FontWeight.w500,
          color: isPlaying ? accentColor : theme.colorScheme.onSurface,
        ),
      ),
      subtitle: Row(
        children: [
          Expanded(
            child: Text(
              '${song.artist} • ${DurationFormatter.format(song.durationMs)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(
              song.isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              size: 20,
              color: song.isFavorite ? Colors.redAccent : theme.hintColor,
            ),
            onPressed: onFavoriteToggle,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, size: 20),
            padding: EdgeInsets.zero,
            onSelected: onMenuAction,
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'play_next',
                child: Row(
                  children: [
                    Icon(Icons.playlist_play_rounded, size: 20),
                    SizedBox(width: 12),
                    Text('Play Next'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'add_to_queue',
                child: Row(
                  children: [
                    Icon(Icons.queue_music_rounded, size: 20),
                    SizedBox(width: 12),
                    Text('Add to Queue'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'details',
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded, size: 20),
                    SizedBox(width: 12),
                    Text('Song Info'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
