import 'package:flutter/material.dart';

import '../../core/utils/duration_formatter.dart';
import '../../domain/models/song.dart';
import '../../widgets/artwork_widget.dart';

/// Modal dialog displaying full file metadata for a song.
class SongDetailsDialog extends StatelessWidget {
  final Song song;

  const SongDetailsDialog({super.key, required this.song});

  static Future<void> show(BuildContext context, Song song) {
    return showDialog<void>(
      context: context,
      builder: (_) => SongDetailsDialog(song: song),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          ArtworkWidget(songId: song.id, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              song.displayTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDetailRow(theme, 'Artist', song.artist),
            _buildDetailRow(theme, 'Album', song.album),
            _buildDetailRow(theme, 'Duration', DurationFormatter.format(song.durationMs)),
            _buildDetailRow(theme, 'File Size', DurationFormatter.formatFileSize(song.fileSize)),
            _buildDetailRow(theme, 'Format', song.format.toUpperCase()),
            if (song.genre != null && song.genre!.isNotEmpty)
              _buildDetailRow(theme, 'Genre', song.genre!),
            _buildDetailRow(theme, 'File Name', song.fileName),
            _buildDetailRow(theme, 'Location', song.filePath),
            _buildDetailRow(
              theme,
              'Date Added',
              song.dateAdded.toLocal().toString().split('.')[0],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            ),
          ),
          SelectableText(
            value,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}
