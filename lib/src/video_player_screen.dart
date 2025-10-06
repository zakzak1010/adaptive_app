import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoId;

  const VideoPlayerScreen({Key? key, required this.videoId}) : super(key: key);

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = YoutubePlayerController.fromVideoId(
      videoId: widget.videoId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showFullscreenButton: true,
        enableCaption: true,
      ),
    );
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Reproduciendo video')),
      body: YoutubePlayerScaffold(
        controller: _controller,
        builder: (context, player) {
          return Center(
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: player,
            ),
          );
        },
      ),
    );
  }
}
