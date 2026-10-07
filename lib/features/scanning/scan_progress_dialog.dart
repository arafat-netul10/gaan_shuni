import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/library_provider.dart';

/// Modal or inline dialog showing music scanning and indexing progress.
class ScanProgressDialog extends StatelessWidget {
  const ScanProgressDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const ScanProgressDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final libraryProvider = context.watch<LibraryProvider>();
    final status = libraryProvider.status;

    // Auto-dismiss when completed or failed
    if (status == ScanStatus.completed ||
        status == ScanStatus.error ||
        status == ScanStatus.permissionDenied ||
        status == ScanStatus.permissionPermanentlyDenied) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
      });
    }

    final isScanning = status == ScanStatus.scanning;
    final isIndexing = status == ScanStatus.indexing;

    return PopScope(
      canPop: false,
      child: AlertDialog(
        title: Text(
          isIndexing ? 'Indexing Library...' : 'Scanning Music...',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isScanning && libraryProvider.totalToScan > 0) ...[
              LinearProgressIndicator(
                value: libraryProvider.scanProgress,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 12),
              Text(
                'Found ${libraryProvider.scannedCount} of ${libraryProvider.totalToScan} tracks',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ] else ...[
              const LinearProgressIndicator(),
              const SizedBox(height: 12),
              Text(
                isIndexing
                    ? 'Saving tracks to your database...'
                    : 'Searching for audio files...',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
