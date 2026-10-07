import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/library_provider.dart';

/// Screen presented when audio access permission has not been granted.
class PermissionOnboardingScreen extends StatelessWidget {
  final VoidCallback? onGranted;

  const PermissionOnboardingScreen({super.key, this.onGranted});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final libraryProvider = context.watch<LibraryProvider>();
    final status = libraryProvider.status;

    final isPermanentlyDenied =
        status == ScanStatus.permissionPermanentlyDenied;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(25),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.folder_open_rounded,
                  size: 50,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Access Your Music',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 14),
              Text(
                'Gaan Shuni needs access to your local audio files to index and play the music stored on your device.\n\n'
                'We respect your privacy: your music is completely offline and never uploaded anywhere.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              if (isPermanentlyDenied) ...[
                Text(
                  'Permission was permanently denied in system settings. Please enable audio/storage access manually.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.settings_rounded),
                    label: const Text('Open App Settings'),
                    onPressed: () => libraryProvider.openAppSettings(),
                  ),
                ),
              ] else ...[
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () async {
                      await libraryProvider.scanLibrary();
                      if (context.mounted &&
                          libraryProvider.status == ScanStatus.completed) {
                        onGranted?.call();
                      }
                    },
                    child: libraryProvider.status == ScanStatus.scanning ||
                            libraryProvider.status == ScanStatus.indexing
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Grant Music Access',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }
}
