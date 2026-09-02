import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'services/music_library_backend.dart';

void main() => runApp(const PulseApp());
  class Track {
    final String title;
    final String artist;
    final String? path;
    final Uint8List? bytes;
    final Color color;

    const Track({required this.title, required this.artist, required this.color, this.path, this.bytes});

    Map<String, dynamic> toMap() => {
          'title': title,
          'artist': artist,
          'path': path,
          'bytes': bytes == null ? null : base64Encode(bytes!),
          'color': color.toARGB32(),
        };

    factory Track.fromMap(Map<String, dynamic> map) => Track(
          title: map['title'] as String,
          artist: map['artist'] as String? ?? 'Local file',
          path: map['path'] as String?,
          bytes: map['bytes'] == null ? null : base64Decode(map['bytes'] as String),
          color: Color((map['color'] as num?)?.toInt() ?? 0xFFE95D38),
        );
  }

  class PulseApp extends StatelessWidget {
    const PulseApp({super.key});

    @override
    Widget build(BuildContext context) {
      return MaterialApp(
        title: 'Pulse Music',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0B0D12),
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE95D38), brightness: Brightness.dark),
          fontFamily: 'Arial',
        ),
        home: const MusicHomePage(),
      );
    }
  }

  class MusicHomePage extends StatefulWidget {
    const MusicHomePage({super.key});

    @override
    State<MusicHomePage> createState() => _MusicHomePageState();
  }

  class _MusicHomePageState extends State<MusicHomePage> {
    final AudioPlayer _player = AudioPlayer();
    final MusicLibraryBackend _backend = MusicLibraryBackend();
    final TextEditingController _searchController = TextEditingController();
    final List<Track> _starterTracks = const [
      Track(title: 'Midnight Drive', artist: 'Neon Coast', color: Color(0xFFE95D38)),
      Track(title: 'Slow Motion', artist: 'Mila June', color: Color(0xFF5B63D8)),
      Track(title: 'Afterglow', artist: 'The Paper Suns', color: Color(0xFFB98238)),
      Track(title: 'Open Skies', artist: 'Atlas Bloom', color: Color(0xFF348A7A)),
    ];

    late List<Track> _library;
    Track? _currentTrack;
    StreamSubscription<Duration>? _positionSubscription;
    StreamSubscription<PlayerState>? _stateSubscription;
    Duration _position = Duration.zero;
    Duration _duration = const Duration(minutes: 3, seconds: 42);
    bool _isPlaying = false;
    bool _isShuffle = false;
    bool _isRepeat = false;
    double _volume = 0.8;
    int _selectedTab = 0;
    List<String> _playlists = <String>[];

    @override
    void initState() {
      super.initState();
      _library = [..._starterTracks];
      _currentTrack = _library.first;
      unawaited(_loadLibrary());
      _positionSubscription = _player.onPositionChanged.listen((position) {
        if (mounted) setState(() => _position = position);
      });
      _stateSubscription = _player.onPlayerStateChanged.listen((state) {
        if (mounted) setState(() => _isPlaying = state == PlayerState.playing);
      });
      _player.onDurationChanged.listen((duration) {
        if (mounted) setState(() => _duration = duration);
      });
    }

    Future<void> _loadLibrary() async {
      final savedTracks = await _backend.loadTracks();
      final savedPlaylists = await _backend.loadPlaylists();
      if (!mounted) return;
      setState(() {
        _library = [...savedTracks.map(Track.fromMap), ..._starterTracks];
        _currentTrack = _library.first;
        _playlists = savedPlaylists;
      });
    }

    @override
    void dispose() {
      _positionSubscription?.cancel();
      _stateSubscription?.cancel();
      _searchController.dispose();
      _player.dispose();
      super.dispose();
    }

    Future<void> _togglePlayback() async {
      final track = _currentTrack;
      if (track == null) return;
      if (track.path == null && track.bytes == null) {
        setState(() => _isPlaying = !_isPlaying);
      } else if (_isPlaying) {
        await _player.pause();
      } else {
        await _player.resume();
      }
    }

    Future<void> _selectTrack(Track track) async {
      setState(() {
        _currentTrack = track;
        _position = Duration.zero;
        _isPlaying = track.path == null;
      });
      if (track.path != null || track.bytes != null) {
        await _player.play(track.path != null ? DeviceFileSource(track.path!) : BytesSource(track.bytes!));
        await _player.setVolume(_volume);
      }
    }

    Future<void> _importMusic() async {
      final result = await FilePicker.platform.pickFiles(type: FileType.audio, allowMultiple: true, withData: true);
      if (!mounted || result == null) return;
      final imported = result.files.where((file) => file.path != null).map((file) {
        return Track(
          title: file.name.replaceFirst(RegExp(r'\.[^.]+$'), ''),
          artist: 'Local file',
          path: file.path,
          bytes: file.bytes,
          color: const Color(0xFFE95D38),
        );
      }).toList();
      setState(() => _library = [...imported, ..._library]);
      await _backend.saveTracks(_library.where((track) => track.path != null || track.bytes != null).map((track) => track.toMap()).toList());
    }

    String _greeting() {
      final hour = DateTime.now().hour;
      if (hour < 12) return 'GOOD MORNING';
      if (hour < 18) return 'GOOD AFTERNOON';
      return 'GOOD EVENING';
    }

    @override
    Widget build(BuildContext context) {
      final query = _searchController.text.toLowerCase();
      final visibleTracks = _library.where((track) => track.title.toLowerCase().contains(query) || track.artist.toLowerCase().contains(query)).toList();
      return Scaffold(
        body: SafeArea(
          child: LayoutBuilder(builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            return Row(children: [
              if (wide) _SideBar(selectedTab: _selectedTab, onTabSelected: (tab) => setState(() => _selectedTab = tab)),
              Expanded(child: Column(children: [
                _TopBar(controller: _searchController, onChanged: (_) => setState(() {}), onImport: _importMusic),
                _TabBar(selectedTab: _selectedTab, onTabSelected: (tab) => setState(() => _selectedTab = tab)),
                Expanded(child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(wide ? 48 : 20, 24, wide ? 48 : 20, 160),
                  child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1100), child: _selectedTab == 0 ? _buildHome(visibleTracks) : _buildEmptyTab())),
                )),
              ])),
            ]);
          }),
        ),
        bottomNavigationBar: _PlayerBar(track: _currentTrack!, position: _position, duration: _duration, isPlaying: _isPlaying, isShuffle: _isShuffle, isRepeat: _isRepeat, volume: _volume, onPlay: _togglePlayback, onShuffle: () => setState(() => _isShuffle = !_isShuffle), onRepeat: () => setState(() => _isRepeat = !_isRepeat), onSeek: (value) async { setState(() => _position = value); if (_currentTrack?.path != null || _currentTrack?.bytes != null) await _player.seek(value); }, onVolume: (value) { setState(() => _volume = value); _player.setVolume(value); }),
      );
    }

    Widget _buildHome(List<Track> visibleTracks) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_greeting(), style: const TextStyle(color: Color(0xFFE95D38), fontWeight: FontWeight.bold, letterSpacing: 2, fontSize: 12)),
          const SizedBox(height: 8),
          const Text('Your sound,\nyour space.', style: TextStyle(fontSize: 42, height: 1.05, fontWeight: FontWeight.w800)),
          const SizedBox(height: 28),
          _NowPlayingHero(track: _currentTrack!, isPlaying: _isPlaying, onPlay: _togglePlayback),
          const SizedBox(height: 38),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Your library', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), Text('${visibleTracks.length} tracks', style: TextStyle(color: Colors.white.withValues(alpha: .5)))]),
          const SizedBox(height: 14),
          ...visibleTracks.map((track) => _TrackRow(track: track, active: track == _currentTrack, onTap: () => _selectTrack(track))),
        ]);

    Widget _buildEmptyTab() {
      final title = _selectedTab == 1 ? 'Playlists' : 'Albums';
      if (_selectedTab == 1) {
        return Padding(
          padding: const EdgeInsets.only(top: 30),
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text('Your playlists', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                FilledButton.icon(onPressed: _createPlaylist, icon: const Icon(Icons.add), label: const Text('New playlist')),
              ]),
              const SizedBox(height: 20),
              if (_playlists.isEmpty)
                const Text('Create a playlist for every mood.', style: TextStyle(color: Colors.white54))
              else
                ..._playlists.map((name) => ListTile(leading: const Icon(Icons.queue_music, color: Color(0xFFE95D38)), title: Text(name), subtitle: const Text('Your saved playlist'))),
            ],
          ),
        );
      }
      return Padding(padding: const EdgeInsets.only(top: 90), child: Center(child: Column(children: [const Icon(Icons.album_outlined, size: 54, color: Color(0xFFE95D38)), const SizedBox(height: 18), Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)), const SizedBox(height: 8), const Text('Albums will appear as your library grows.', style: TextStyle(color: Colors.white54))])));
    }

    Future<void> _createPlaylist() async {
      final controller = TextEditingController();
      final name = await showDialog<String>(context: context, builder: (context) => AlertDialog(title: const Text('New playlist'), content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(hintText: 'Playlist name')), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')), FilledButton(onPressed: () => Navigator.pop(context, controller.text.trim()), child: const Text('Create'))]));
      controller.dispose();
      if (!mounted || name == null || name.isEmpty) return;
      setState(() => _playlists = [..._playlists, name]);
      await _backend.savePlaylists(_playlists);
    }
  }

  class _TabBar extends StatelessWidget {
    final int selectedTab;
    final ValueChanged<int> onTabSelected;
    const _TabBar({required this.selectedTab, required this.onTabSelected});

    @override
    Widget build(BuildContext context) => Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 0),
          child: Row(
            children: [
              _tab('Songs', Icons.music_note, 0),
              _tab('Playlists', Icons.queue_music, 1),
              _tab('Albums', Icons.album_outlined, 2),
            ],
          ),
        );

    Widget _tab(String label, IconData icon, int tab) => Padding(
          padding: const EdgeInsets.only(right: 22),
          child: TextButton.icon(
            onPressed: () => onTabSelected(tab),
            icon: Icon(icon, size: 18),
            label: Text(label),
            style: TextButton.styleFrom(
              foregroundColor: selectedTab == tab ? const Color(0xFFE95D38) : Colors.white54,
            ),
          ),
        );
  }

  class _SideBar extends StatelessWidget {
    final int selectedTab;
    final ValueChanged<int> onTabSelected;
    const _SideBar({required this.selectedTab, required this.onTabSelected});

    @override
    Widget build(BuildContext context) => Container(width: 220, padding: const EdgeInsets.fromLTRB(24, 30, 16, 24), decoration: const BoxDecoration(border: Border(right: BorderSide(color: Color(0xFF20232B)))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [Icon(Icons.graphic_eq, color: Color(0xFFE95D38), size: 28), SizedBox(width: 10), Text('PULSE', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 3, fontSize: 17))]),
          const SizedBox(height: 56), const Text('MENU', style: TextStyle(fontSize: 11, color: Colors.white38, letterSpacing: 1.5)), const SizedBox(height: 16),
          item(Icons.home_outlined, 'Home', 0), item(Icons.explore_outlined, 'Discover', 1), item(Icons.album_outlined, 'Albums', 2), item(Icons.people_outline, 'Artists', 3), const Spacer(), item(Icons.settings_outlined, 'Settings', 4),
        ]));

    Widget item(IconData icon, String label, int tab) => InkWell(onTap: () => onTabSelected(tab), borderRadius: BorderRadius.circular(10), child: Container(margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), decoration: BoxDecoration(color: selectedTab == tab ? const Color(0xFF242832) : Colors.transparent, borderRadius: BorderRadius.circular(10)), child: Row(children: [Icon(icon, size: 20, color: selectedTab == tab ? const Color(0xFFE95D38) : Colors.white60), const SizedBox(width: 12), Text(label, style: TextStyle(color: selectedTab == tab ? Colors.white : Colors.white60, fontWeight: selectedTab == tab ? FontWeight.bold : FontWeight.normal))])));
  }

  class _TopBar extends StatelessWidget {
    final TextEditingController controller;
    final ValueChanged<String> onChanged;
    final VoidCallback onImport;
    const _TopBar({required this.controller, required this.onChanged, required this.onImport});

    @override
    Widget build(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(24, 24, 24, 0), child: Row(children: [Expanded(child: TextField(controller: controller, onChanged: onChanged, decoration: InputDecoration(hintText: 'Search your music', prefixIcon: const Icon(Icons.search), filled: true, fillColor: const Color(0xFF161920), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)))), const SizedBox(width: 12), IconButton(onPressed: onImport, tooltip: 'Import music', icon: const Icon(Icons.add_circle_outline, size: 28))]));
  }

  class _NowPlayingHero extends StatelessWidget {
    final Track track;
    final bool isPlaying;
    final VoidCallback onPlay;
    const _NowPlayingHero({required this.track, required this.isPlaying, required this.onPlay});

    @override
    Widget build(BuildContext context) => Container(height: 230, padding: const EdgeInsets.all(24), decoration: BoxDecoration(gradient: LinearGradient(colors: [track.color, const Color(0xFF171A22)], begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(18)), child: Row(children: [Container(width: 178, height: 178, decoration: BoxDecoration(color: Colors.black26, borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.music_note, size: 72, color: Colors.white70)), const SizedBox(width: 24), Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('NOW PLAYING', style: TextStyle(fontSize: 11, letterSpacing: 2, color: Colors.white70)), const SizedBox(height: 10), Text(track.title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)), const SizedBox(height: 5), Text(track.artist, style: const TextStyle(color: Colors.white70)), const SizedBox(height: 18), IconButton.filled(onPressed: onPlay, icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow))]))]));
  }

  class _TrackRow extends StatelessWidget {
    final Track track;
    final bool active;
    final VoidCallback onTap;
    const _TrackRow({required this.track, required this.active, required this.onTap});

    @override
    Widget build(BuildContext context) => ListTile(onTap: onTap, contentPadding: const EdgeInsets.symmetric(vertical: 5), leading: Container(width: 48, height: 48, decoration: BoxDecoration(color: track.color, borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.music_note, color: Colors.white70)), title: Text(track.title, style: TextStyle(fontWeight: active ? FontWeight.bold : FontWeight.normal)), subtitle: Text(track.artist, style: const TextStyle(color: Colors.white54)), trailing: active ? const Icon(Icons.equalizer, color: Color(0xFFE95D38)) : const Icon(Icons.more_horiz, color: Colors.white38));
  }

  class _PlayerBar extends StatelessWidget {
    final Track track;
    final Duration position;
    final Duration duration;
    final bool isPlaying;
    final bool isShuffle;
    final bool isRepeat;
    final double volume;
    final VoidCallback onPlay;
    final VoidCallback onShuffle;
    final VoidCallback onRepeat;
    final ValueChanged<Duration> onSeek;
    final ValueChanged<double> onVolume;
    const _PlayerBar({required this.track, required this.position, required this.duration, required this.isPlaying, required this.isShuffle, required this.isRepeat, required this.volume, required this.onPlay, required this.onShuffle, required this.onRepeat, required this.onSeek, required this.onVolume});

    @override
    Widget build(BuildContext context) {
      final double max = duration.inMilliseconds.toDouble().clamp(1.0, double.infinity);
      final double value = position.inMilliseconds.toDouble().clamp(0.0, max);
      return Material(
        color: const Color(0xFF151820),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Slider(
                  value: value,
                  max: max,
                  onChanged: (newValue) => onSeek(Duration(milliseconds: newValue.round())),
                  activeColor: const Color(0xFFE95D38),
                  inactiveColor: Colors.white12,
                ),
                Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(color: track.color, borderRadius: BorderRadius.circular(6)),
                      child: const Icon(Icons.music_note, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(track.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          Text(track.artist, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ),
                    IconButton(onPressed: onShuffle, icon: Icon(Icons.shuffle, color: isShuffle ? const Color(0xFFE95D38) : Colors.white54)),
                    IconButton(onPressed: onRepeat, icon: Icon(Icons.repeat, color: isRepeat ? const Color(0xFFE95D38) : Colors.white54)),
                    IconButton.filled(onPressed: onPlay, icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow)),
                    const SizedBox(width: 14),
                    const Icon(Icons.volume_down, size: 18, color: Colors.white54),
                    SizedBox(width: 100, child: Slider(value: volume, onChanged: onVolume, activeColor: Colors.white70, inactiveColor: Colors.white12)),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
}