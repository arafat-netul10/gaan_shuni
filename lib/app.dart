import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'domain/models/song.dart';
import 'features/folders/folders_screen.dart';
import 'features/home/home_screen.dart';
import 'features/library/library_screen.dart';
import 'features/player/mini_player.dart';
import 'features/player/player_provider.dart';
import 'features/search/search_screen.dart';
import 'features/settings/settings_screen.dart';
import 'providers/library_provider.dart';
import 'providers/theme_provider.dart';

class GaanShuniApp extends StatelessWidget {
  const GaanShuniApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'Gaan Shuni',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const MainNavigationShell(),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  void _onPlaySong(BuildContext context, Song song, {List<Song>? contextQueue}) {
    final librarySongs = context.read<LibraryProvider>().songs;
    context.read<PlayerProvider>().playSong(
          song,
          contextQueue: contextQueue ?? librarySongs,
        );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const HomeScreen(),
      LibraryScreen(
        onSongTap: (song) => _onPlaySong(context, song),
      ),
      FoldersScreen(
        onSongTap: (song) => _onPlaySong(context, song),
      ),
      SearchScreen(
        onSongTap: (song) => _onPlaySong(context, song),
      ),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.library_music_outlined),
                selectedIcon: Icon(Icons.library_music_rounded),
                label: 'Library',
              ),
              NavigationDestination(
                icon: Icon(Icons.folder_outlined),
                selectedIcon: Icon(Icons.folder_rounded),
                label: 'Folders',
              ),
              NavigationDestination(
                icon: Icon(Icons.search_outlined),
                selectedIcon: Icon(Icons.search_rounded),
                label: 'Search',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings_rounded),
                label: 'Settings',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
