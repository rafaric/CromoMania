import 'package:flutter/material.dart';
import '../../domain/entities/album.dart';
import '../widgets/album_card.dart';

/// Album list page showing all available albums
class AlbumListPage extends StatelessWidget {
  final List<Album> albums;
  final Function(Album) onAlbumTap;

  const AlbumListPage({
    super.key,
    required this.albums,
    required this.onAlbumTap,
  });

  @override
  Widget build(BuildContext context) {
    if (albums.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: albums.length,
      itemBuilder: (context, index) {
        final album = albums[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: AlbumCard(
            album: album,
            onTap: () => onAlbumTap(album),
          ),
        );
      },
    );
  }
}