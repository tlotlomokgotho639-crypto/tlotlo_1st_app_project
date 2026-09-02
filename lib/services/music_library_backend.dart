import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class MusicLibraryBackend {
  static const _tracksKey = 'pulse_tracks';
  static const _playlistsKey = 'pulse_playlists';

  Future<SharedPreferences> get _preferences => SharedPreferences.getInstance();

  Future<List<Map<String, dynamic>>> loadTracks() async {
    final preferences = await _preferences;
    final values = preferences.getStringList(_tracksKey) ?? <String>[];
    return values
        .map((value) => Map<String, dynamic>.from(jsonDecode(value) as Map))
        .toList();
  }

  Future<void> saveTracks(List<Map<String, dynamic>> tracks) async {
    final preferences = await _preferences;
    await preferences.setStringList(
      _tracksKey,
      tracks.map(jsonEncode).toList(),
    );
  }

  Future<List<String>> loadPlaylists() async {
    final preferences = await _preferences;
    return preferences.getStringList(_playlistsKey) ?? <String>[];
  }

  Future<void> savePlaylists(List<String> playlists) async {
    final preferences = await _preferences;
    await preferences.setStringList(_playlistsKey, playlists);
  }
}
