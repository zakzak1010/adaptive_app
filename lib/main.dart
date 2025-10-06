import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'src/app_state.dart';
import 'src/playlist_details.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthedUserPlaylists()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Adaptive YouTube App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.red),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final playlists = [
      {'id': 'PLT8cXkO9LRZw267SXNMuDWR8TMcj7VKsw', 'name': 'Flutter Tutorials'},
      {'id': 'PLT8cXkO9LRZw2GycQf7q6w1X4YQkCJX1_', 'name': 'Music Playlist'},
      {'id': 'PLT8cXkO9LRZz8hc5a0nrbJ6Yzc5qZKp9f', 'name': 'Tech Talks'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Playlists de YouTube'),
      ),
      body: ListView.builder(
        itemCount: playlists.length,
        itemBuilder: (context, index) {
          final playlist = playlists[index];
          return ListTile(
            leading: const Icon(Icons.playlist_play, color: Colors.red),
            title: Text(playlist['name'] ?? 'Sin nombre'),
            subtitle: Text('ID: ${playlist['id']}'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PlaylistDetails(
                    playlistId: playlist['id']!,
                    playlistName: playlist['name']!,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
