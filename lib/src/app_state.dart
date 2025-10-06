import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:googleapis/youtube/v3.dart';
import 'package:http/http.dart' as http;

class AuthedUserPlaylists extends ChangeNotifier {
  set authClient(http.Client client) {
    _api = YouTubeApi(client);
    _loadPlaylists();
  }

  bool get isLoggedIn => _api != null;

  Future<void> _loadPlaylists() async {
    try {
      String? nextPageToken;
      _playlists.clear();

      do {
        final response = await _api!.playlists.list(
          ['snippet', 'contentDetails', 'id'],
          mine: true,
          maxResults: 50,
          pageToken: nextPageToken,
        );
        if (response.items != null) {
          _playlists.addAll(response.items!);
          _playlists.sort((a, b) => a.snippet!.title!
              .toLowerCase()
              .compareTo(b.snippet!.title!.toLowerCase()));
        }
        notifyListeners();
        nextPageToken = response.nextPageToken;
      } while (nextPageToken != null);
    } catch (e) {
      debugPrint('!!!!!!!!!! ERROR AL CARGAR PLAYLISTS !!!!!!!!!!');
      debugPrint(e.toString());
    }
  }

  YouTubeApi? _api;

  final List<Playlist> _playlists = [];
  List<Playlist> get playlists => UnmodifiableListView(_playlists);

  final Map<String, List<PlaylistItem>> _playlistItems = {};
  List<PlaylistItem> playlistItems({required String playlistId}) {
    if (!_playlistItems.containsKey(playlistId)) {
      _playlistItems[playlistId] = [];
      _retrievePlaylist(playlistId);
    }
    return UnmodifiableListView(_playlistItems[playlistId]!);
  }

  Future<void> _retrievePlaylist(String playlistId) async {
    try {
      String? nextPageToken;
      do {
        var response = await _api!.playlistItems.list(
          ['snippet', 'contentDetails'],
          playlistId: playlistId,
          maxResults: 25,
          pageToken: nextPageToken,
        );
        var items = response.items;
        if (items != null) {
          _playlistItems[playlistId]!.addAll(items);
        }
        notifyListeners();
        nextPageToken = response.nextPageToken;
      } while (nextPageToken != null);
    } catch (e) {
      debugPrint('!!!!!!!!!! ERROR AL CARGAR ITEMS DE LA PLAYLIST $playlistId !!!!!!!!!!');
      debugPrint(e.toString());
    }
  }

  Playlist? _selectedPlaylist;
  Playlist? get selectedPlaylist => _selectedPlaylist;

  void selectPlaylist(Playlist playlist) {
    _selectedPlaylist = playlist;
    notifyListeners();
  }
}
