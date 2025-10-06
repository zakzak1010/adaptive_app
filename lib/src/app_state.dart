import 'package:flutter/foundation.dart';
import 'package:googleapis/youtube/v3.dart';

class AuthedUserPlaylists extends ChangeNotifier {
  final Map<String, List<PlaylistItem>> _playlistItems = {};

  List<PlaylistItem> playlistItems({required String playlistId}) =>
      _playlistItems[playlistId] ?? [];

  void setPlaylistItems(String playlistId, List<PlaylistItem> items) {
    _playlistItems[playlistId] = items;
    notifyListeners();
  }
}
