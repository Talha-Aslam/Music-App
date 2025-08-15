import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/audio_service.dart';
import '../widgets/circular_audio_spectrum.dart';
import '../utils/helpers/album_art_generator.dart';

class EnhancedMusicPlayerScreen extends StatefulWidget {
  final AudioService? audioService;

  const EnhancedMusicPlayerScreen({Key? key, this.audioService})
      : super(key: key);

  @override
  State<EnhancedMusicPlayerScreen> createState() =>
      _EnhancedMusicPlayerScreenState();
}

class _EnhancedMusicPlayerScreenState extends State<EnhancedMusicPlayerScreen>
    with TickerProviderStateMixin {
  late AudioService _audioService;
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;
  bool _isShuffled = false;
  bool _isRepeated = false;
  String _currentSong = '';
  String _currentArtist = '';
  List<double> _audioData = [];

  @override
  void initState() {
    super.initState();
    _audioService = widget.audioService ?? AudioService();

    // Animation controllers
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    // Start animations
    _fadeController.forward();
    _slideController.forward();

    // Listen to audio service streams
    _setupAudioListeners();
    _updateAudioData();
  }

  void _setupAudioListeners() {
    _audioService.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
      }
    });

    _audioService.durationStream.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration ?? Duration.zero;
        });
      }
    });

    _audioService.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });
      }
    });

    // Update current song info
    if (_audioService.playlist.isNotEmpty) {
      final currentSong = _audioService.playlist[_audioService.currentIndex];
      setState(() {
        _currentSong = currentSong.title ?? 'Unknown Track';
        _currentArtist = currentSong.artist ?? 'Unknown Artist';
      });
    }
  }

  void _updateAudioData() {
    // Optimized audio data updates - reduced frequency for smoother performance
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted && _isPlaying) {
        setState(() {
          _audioData = _audioService.getAudioVisualizerData();
        });
        _updateAudioData();
      }
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              // Top Section - Back button and options
              _buildTopSection(),

              // Main Content - Circular spectrum with album art
              Expanded(
                flex: 3,
                child: _buildMainContent(),
              ),

              // Song Information
              _buildSongInfo(),

              // Progress Bar
              _buildProgressBar(),

              // Control Buttons
              _buildControlButtons(),

              // Bottom spacing
              const SizedBox(height: 120), // Space for navigation bar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
          Text(
            'Now Playing',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          GestureDetector(
            onTap: () {
              // Show options menu
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: const Icon(
                Icons.more_vert_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    final currentSongName = _audioService.playlist.isNotEmpty
        ? _audioService.playlist[_audioService.currentIndex].name
        : null;

    return Center(
      child: CircularAudioSpectrum(
        isPlaying: _isPlaying,
        size: 280,
        audioData: _audioData,
        songName: currentSongName,
        child: _buildAlbumArt(),
      ),
    );
  }

  Widget _buildAlbumArt() {
    // Get dynamic colors for the current song
    List<Color> songColors = [
      Colors.white.withOpacity(0.2),
      Colors.white.withOpacity(0.05)
    ];
    if (_audioService.playlist.isNotEmpty) {
      final songName = _audioService.playlist[_audioService.currentIndex].name;
      final generatedColors =
          AlbumArtGenerator.getGradientColorsFromSongName(songName);
      songColors = [
        generatedColors.first.withOpacity(0.3),
        generatedColors.last.withOpacity(0.1),
      ];
    }

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: songColors,
        ),
        border: Border.all(
          color: songColors.first.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
          if (_isPlaying)
            BoxShadow(
              color: songColors.first.withOpacity(0.4),
              blurRadius: 30,
              spreadRadius: 10,
            ),
        ],
      ),
      child: ClipOval(
        child: _audioService.playlist.isNotEmpty
            ? ClipOval(
                child: AlbumArtGenerator.getPlaceholderWidget(
                  _audioService.playlist[_audioService.currentIndex].name,
                  size: 180,
                ),
              )
            : Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.purple.withOpacity(0.7),
                      Colors.blue.withOpacity(0.7),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.music_note_rounded,
                  size: 80,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget _buildSongInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
      child: Column(
        children: [
          Text(
            _currentSong.isNotEmpty ? _currentSong : 'No song selected',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Text(
            _currentArtist.isNotEmpty ? _currentArtist : 'Unknown Artist',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.white,
              inactiveTrackColor: Colors.white.withOpacity(0.3),
              thumbColor: Colors.white,
              overlayColor: Colors.white.withOpacity(0.2),
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            ),
            child: Slider(
              value: _duration.inMilliseconds > 0
                  ? _position.inMilliseconds / _duration.inMilliseconds
                  : 0.0,
              onChanged: (value) {
                final newPosition = Duration(
                  milliseconds: (value * _duration.inMilliseconds).round(),
                );
                _audioService.seek(newPosition);
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatDuration(_position),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
              Text(
                _formatDuration(_duration),
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Shuffle button
          _buildControlButton(
            icon: Icons.shuffle_rounded,
            isActive: _isShuffled,
            onTap: () {
              setState(() {
                _isShuffled = !_isShuffled;
              });
              _audioService.toggleShuffle();
              HapticFeedback.lightImpact();
            },
          ),

          // Previous button
          _buildControlButton(
            icon: Icons.skip_previous_rounded,
            size: 40,
            onTap: () {
              _audioService.previous();
              HapticFeedback.mediumImpact();
            },
          ),

          // Play/Pause button
          _buildPlayButton(),

          // Next button
          _buildControlButton(
            icon: Icons.skip_next_rounded,
            size: 40,
            onTap: () {
              _audioService.next();
              HapticFeedback.mediumImpact();
            },
          ),

          // Repeat button
          _buildControlButton(
            icon: Icons.repeat_rounded,
            isActive: _isRepeated,
            onTap: () {
              setState(() {
                _isRepeated = !_isRepeated;
              });
              _audioService.toggleRepeat();
              HapticFeedback.lightImpact();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    bool isActive = false,
    double size = 30,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive
              ? Colors.white.withOpacity(0.2)
              : Colors.white.withOpacity(0.1),
          border: Border.all(
            color: isActive
                ? Colors.white.withOpacity(0.5)
                : Colors.white.withOpacity(0.2),
          ),
        ),
        child: Icon(
          icon,
          size: size,
          color: isActive ? Colors.white : Colors.white70,
        ),
      ),
    );
  }

  Widget _buildPlayButton() {
    return GestureDetector(
      onTap: () {
        if (_isPlaying) {
          _audioService.pause();
        } else {
          _audioService.play();
        }
        HapticFeedback.mediumImpact();
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.3),
              Colors.white.withOpacity(0.1),
            ],
          ),
          border: Border.all(
            color: Colors.white.withOpacity(0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(
          _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}
