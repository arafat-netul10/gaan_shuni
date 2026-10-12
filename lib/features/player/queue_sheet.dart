import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/utils/duration_formatter.dart';
import '../../widgets/artwork_widget.dart';
import 'player_provider.dart';

/// Draggable modal sheet for inspecting and reordering the current playback queue.
class QueueSheet extends StatelessWidget {
  const QueueSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const QueueSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final player = context.watch<PlayerProvider>();
    final queue = player.queue;
    final currentSong = player.currentSong;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            // Drag handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Row(
                children: [
                  Text(
                    'Playback Queue',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${queue.length} tracks',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: queue.isEmpty
                  ? const Center(
                      child: Text('Queue is empty'),
                    )
                  : ReorderableListView.builder(
                      scrollController: scrollController,
                      itemCount: queue.length,
                      // ignore: deprecated_member_use
                      onReorder: (oldIndex, newIndex) =>
                          player.reorderQueue(oldIndex, newIndex),
                      itemBuilder: (context, index) {
                        final song = queue[index];
                        final isCurrent = currentSong?.id == song.id;

                        return ListTile(
                          key: ValueKey('queue_${song.id}_$index'),
                          leading: ArtworkWidget(
                            songId: song.id,
                            size: 40,
                          ),
                          title: Text(
                            song.displayTitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                              color: isCurrent
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onSurface,
                            ),
                          ),
                          subtitle: Text(
                            '${song.artist} • ${DurationFormatter.format(song.durationMs)}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18),
                                onPressed: () => player.removeFromQueue(index),
                              ),
                              const Icon(Icons.drag_handle_rounded, size: 20),
                            ],
                          ),
                          onTap: () {
                            player.playSong(song, contextQueue: queue);
                          },
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}
