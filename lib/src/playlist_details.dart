import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_state.dart';
import 'video_player_screen.dart';

class PlaylistDetails extends StatelessWidget {
  const PlaylistDetails({
    required this.playlistId,
    required this.playlistName,
    super.key,
  });

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

        return _PlaylistDetailsListView(
          playlistItems: playlistItems,
        );
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
          onTap: () async {
            if (videoId != null && videoId.isNotEmpty) {
              if (Platform.isMacOS || Platform.isWindows) {
                // Desktop → abrir en navegador
                final url = Uri.parse('https://www.youtube.com/watch?v=$videoId');
                if (await canLaunchUrl(url)) {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No se pudo abrir el navegador')),
                  );
                }
              } else {
                // Móvil / Web → reproducir dentro de la app
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => VideoPlayerScreen(videoId: videoId),
                  ),
                );
              }
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
