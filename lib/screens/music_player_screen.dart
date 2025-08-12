import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../services/audio_service.dart';
import '../widgets/audio_visualizer.dart';
import '../widgets/glassmorphic_container.dart';
import '../widgets/player_controls.dart';
import '../widgets/progress_bar.dart';
import '../widgets/queue_manager_widget.dart';
import '../utils/helpers/album_art_generator.dart';

class MusicPlayerScreen extends StatefulWidget {
  const MusicPlayerScreen({Key? key}) : super(key: key);

  @override
  State<MusicPlayerScreen> createState() => _MusicPlayerScreenState();
}

class _MusicPlayerScreenState extends State<MusicPlayerScreen>
    with SingleTickerProviderStateMixin {
  final AudioService _audioService = AudioService();
  late AnimationController _visualizerUpdateController;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;
  List<double> _audioData = [];

  @override
  void initState() {
    super.initState();

    // Create controller for visualization updates
    _visualizerUpdateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50), // Update at 20fps
    )..addListener(() {
        if (_isPlaying) {
          setState(() {
            _audioData = _audioService.getAudioVisualizerData();
          });
        }
      });

    _audioService.positionStream.listen((pos) {
      setState(() {
        _position = pos;
      });
    });

    _audioService.durationStream.listen((dur) {
      setState(() {
        _duration = dur ?? Duration.zero;
      });
    });

    _audioService.playerStateStream.listen((state) {
      setState(() {
        _isPlaying = state.playing;
      });

      // Start or stop visualizer updates based on playback state
      if (state.playing) {
        _visualizerUpdateController.repeat();
      } else {
        _visualizerUpdateController.stop();
      }
    });

    _audioService.processingStateStream.listen((state) {
      if (state == ProcessingState.completed &&
          _audioService.playlist.isNotEmpty) {
        _audioService.next();
      }
    });
  }

  @override
  void dispose() {
    _visualizerUpdateController.dispose();
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentSong = _audioService.playlist.isNotEmpty
        ? _audioService.playlist[_audioService.currentIndex]
        : null;

    return Center(
      child: SingleChildScrollView(
        child: GlassmorphicContainer(
          width: 380,
          child: Column(
            mainAxisSize: MainAxisSize.min,
          children: [
            // Animated Album Art
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              child: currentSong != null
                  ? ClipRRect(
                      key: ValueKey(currentSong.path),
                      borderRadius: BorderRadius.circular(24),
                      child: AlbumArtGenerator.getPlaceholderWidget(
                        currentSong.name,
                        size: 160,
                      ),
                    )
                  : Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          colors: [Colors.purpleAccent, Colors.blueAccent],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purple.withOpacity(0.3),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.music_note_rounded,
                          size: 64, color: Colors.white),
                    ),
            ),
            const SizedBox(height: 24),

            // Song Info
            Text(
              currentSong?.title ?? 'No Song Selected',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.95),
                letterSpacing: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              currentSong?.artist ?? 'Unknown Artist',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.7),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),

            // Audio Visualizer
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: AudioVisualizer(
                isPlaying: _isPlaying,
                color: _getVisualizerColor(currentSong),
                intensity: _isPlaying ? 1.0 : 0.5,
                barCount: 24, // More bars for smoother visualization
                audioData: _isPlaying ? _audioData : null,
              ),
            ),
            const SizedBox(height: 14),

            // Select Music Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withOpacity(0.12),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              onPressed: () async {
                await _audioService.pickFiles();
                setState(() {}); // Refresh UI after picking files
              },
              child: const Text('Pick Music Files'),
            ),
            const SizedBox(height: 24),

            // Playlist ListView
            if (_audioService.playlist.isNotEmpty) _buildPlaylist(),
            const SizedBox(height: 16),

            // Player Controls
            PlayerControls(audioService: _audioService),
            const SizedBox(height: 16),

            // Queue Button
            if (_audioService.playlist.isNotEmpty)
              TextButton.icon(
                icon: const Icon(Icons.queue_music),
                label: const Text('Queue'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white70,
                ),
                onPressed: () => _showQueueManager(context),
              ),
            const SizedBox(height: 8),

            // Progress Bar
            ProgressBar(
              audioService: _audioService,
              position: _position,
              duration: _duration,
            ),
          ],
        ),
      ),
      ),
    );
  }

  void _showQueueManager(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [QueueManagerWidget(audioService: _audioService)],
          ),
        ),
      ),
    );
  }

  // Method to determine visualizer color based on song name
  Color _getVisualizerColor(dynamic song) {
    if (song == null) {
      return Colors.blueAccent; // Default color
    }

    // Get base color from song name
    final baseColor = AlbumArtGenerator.getColorFromSongName(song.name);
    
    // Add some animation based on playback position
    final colorList = [
      baseColor,
      HSLColor.fromColor(baseColor).withHue((HSLColor.fromColor(baseColor).hue + 40) % 360).toColor(),
      HSLColor.fromColor(baseColor).withLightness((HSLColor.fromColor(baseColor).lightness + 0.1).clamp(0.0, 1.0)).toColor(),
    ];

    // Use position to animate through color variations
    final seconds = _position.inSeconds;
    final colorIndex = seconds % colorList.length;
    final nextColorIndex = (colorIndex + 1) % colorList.length;

    // Smoothly transition between colors
    final progress = (_position.inMilliseconds % 1000) / 1000.0;
    return Color.lerp(
          colorList[colorIndex],
          colorList[nextColorIndex],
          progress,
        ) ??
        baseColor;
  }

  Widget _buildPlaylist() {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _audioService.playlist.length,
        itemBuilder: (context, idx) {
          final song = _audioService.playlist[idx];
          final isSelected = idx == _audioService.currentIndex;

          return GestureDetector(
            onTap: () =>
                _audioService.loadSong(idx).then((_) => _audioService.play()),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.18)
                    : Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(16),
                border: isSelected
                    ? Border.all(color: Colors.blueAccent, width: 2)
                    : null,
              ),
              child: Center(
                child: Text(
                  song.title ?? song.name,
                  style: TextStyle(
                    color: isSelected ? Colors.blueAccent : Colors.white70,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
