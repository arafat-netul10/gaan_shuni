import 'package:flutter/material.dart';

import '../../domain/models/song.dart';
import 'tabs/albums_tab.dart';
import 'tabs/artists_tab.dart';
import 'tabs/playlists_tab.dart';
import 'tabs/songs_tab.dart';

class LibraryScreen extends StatelessWidget {
  final void Function(Song song)? onSongTap;

  const LibraryScreen({super.key, this.onSongTap});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Library'),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(text: 'Tracks'),
              Tab(text: 'Albums'),
              Tab(text: 'Artists'),
              Tab(text: 'Playlists'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SongsTab(onSongTap: onSongTap),
            AlbumsTab(onSongTap: onSongTap),
            ArtistsTab(onSongTap: onSongTap),
            PlaylistsTab(onSongTap: onSongTap),
          ],
        ),
      ),
    );
  }
}
