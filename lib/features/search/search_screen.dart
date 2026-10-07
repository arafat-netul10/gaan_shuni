import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/models/song.dart';
import '../../domain/repositories/song_repository.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/song_tile.dart';

class SearchScreen extends StatefulWidget {
  final void Function(Song song)? onSongTap;

  const SearchScreen({super.key, this.onSongTap});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Song> _searchResults = [];
  bool _hasSearched = false;

  Future<void> _performSearch(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
      });
      return;
    }

    final repo = context.read<SongRepository>();
    final results = await repo.searchSongs(trimmed);
    setState(() {
      _searchResults = results;
      _hasSearched = true;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final songRepo = context.read<SongRepository>();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search songs, artists, albums...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: theme.hintColor),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () {
                      _searchController.clear();
                      _performSearch('');
                    },
                  )
                : null,
          ),
          onChanged: _performSearch,
        ),
      ),
      body: !_hasSearched
          ? const EmptyState(
              icon: Icons.search_rounded,
              title: 'Search Your Library',
              message: 'Find songs, artists, and albums instantly.',
            )
          : _searchResults.isEmpty
              ? const EmptyState(
                  icon: Icons.search_off_rounded,
                  title: 'No Matches Found',
                  message: 'Try searching with a different term.',
                )
              : ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final song = _searchResults[index];
                    return SongTile(
                      song: song,
                      onTap: () => widget.onSongTap?.call(song),
                      onFavoriteToggle: () async {
                        await songRepo.toggleFavorite(song.id);
                        _performSearch(_searchController.text);
                      },
                    );
                  },
                ),
    );
  }
}
