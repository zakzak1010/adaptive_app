import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';

class PlaylistDetails extends StatelessWidget {
  const PlaylistDetails({required this.playlistId, required this.playlistName, super.key});
  final String playlistId;
  final String playlistName;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthedUserPlaylists>(
      builder: (context, playlists, _) {
        final playlistItems = playlists.playlistItems(playlistId: playlistId);
        if (playlistItems.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        return _PlaylistDetailsListView(playlistItems: playlistItems);
      },
    );
  }
}

class _PlaylistDetailsListView extends StatelessWidget {
  const _PlaylistDetailsListView({
    required this.playlistItems,
  });

  final List<PlaylistItem> playlistItems;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: playlistItems.length,
      itemBuilder: (context, index) {
        final playlistItem = playlistItems[index];
        final videoTitle = playlistItem.snippet?.title ?? 'Título no disponible';
        final thumbnailUrl = playlistItem.snippet?.thumbnails?.high?.url;
        final videoId = playlistItem.snippet?.resourceId?.videoId;

        return ListTile(
          leading: thumbnailUrl != null
              ? Image.network(thumbnailUrl, width: 100, fit: BoxFit.cover)
              : const SizedBox(width: 100, child: Icon(Icons.image)),
          title: Text(videoTitle),
          subtitle: Text(playlistItem.snippet?.videoOwnerChannelTitle ?? ''),
          onTap: () {
            debugPrint('Tapped item index $index with videoId: $videoId');
            if (videoId != null && videoId.isNotEmpty) {
              // Aquí podrías navegar al reproductor de video
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('VideoId no disponible para este elemento')),
              );
            }
          },
        );
      },
    );
  }
}
