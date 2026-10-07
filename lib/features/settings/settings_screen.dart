import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_constants.dart';
import '../../providers/library_provider.dart';
import '../../providers/theme_provider.dart';
import '../scanning/scan_progress_dialog.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final libraryProvider = context.watch<LibraryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSectionHeader(theme, 'Appearance'),
          ListTile(
            leading: const Icon(Icons.brightness_6_rounded),
            title: const Text('Theme Mode'),
            subtitle: Text(
              switch (themeProvider.themeMode) {
                ThemeMode.system => 'Follow system settings',
                ThemeMode.light => 'Light theme',
                ThemeMode.dark => 'Dark theme',
              },
            ),
            trailing: PopupMenuButton<ThemeMode>(
              initialValue: themeProvider.themeMode,
              onSelected: themeProvider.setThemeMode,
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: ThemeMode.system,
                  child: Text('System default'),
                ),
                PopupMenuItem(
                  value: ThemeMode.light,
                  child: Text('Light'),
                ),
                PopupMenuItem(
                  value: ThemeMode.dark,
                  child: Text('Dark'),
                ),
              ],
            ),
          ),
          const Divider(),

          _buildSectionHeader(theme, 'Library & Scanning'),
          ListTile(
            leading: const Icon(Icons.sync_rounded),
            title: const Text('Rescan Device Music'),
            subtitle: const Text('Search for newly added audio files'),
            onTap: () {
              ScanProgressDialog.show(context);
              libraryProvider.scanLibrary();
            },
          ),
          ListTile(
            leading: const Icon(Icons.folder_open_rounded),
            title: const Text('Library Statistics'),
            subtitle: Text('${libraryProvider.songCount} indexed songs'),
          ),
          const Divider(),

          _buildSectionHeader(theme, 'Privacy & Storage'),
          ListTile(
            leading: const Icon(Icons.security_rounded),
            title: const Text('Privacy First'),
            subtitle: const Text(
              'Gaan Shuni operates completely offline. No tracking, telemetry, or file uploads.',
            ),
          ),
          const Divider(),

          _buildSectionHeader(theme, 'About'),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text(AppConstants.appName),
            subtitle: const Text('Version 1.0.0 — Modern, minimal local music player'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(ThemeData theme, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
