import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glassmorphism/glassmorphism.dart';
import '../services/audio_service.dart';
import '../utils/helpers/album_art_generator.dart';
import '../screens/enhanced_music_player_screen.dart';

class NotificationPlayingBar extends StatefulWidget {
  final AudioService audioService;
  final bool isPlayerScreenOpen;

  const NotificationPlayingBar({
    Key? key,
    required this.audioService,
    this.isPlayerScreenOpen = false,
  }) : super(key: key);

  @override
  State<NotificationPlayingBar> createState() => _NotificationPlayingBarState();
}

class _NotificationPlayingBarState extends State<NotificationPlayingBar>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _playController;
  late AnimationController _progressController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _playAnimation;
  late Animation<double> _progressAnimation;

  bool _isVisible = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isPlaying = false;
  String _currentSong = '';
  String _currentArtist = '';

  @override
  void initState() {
    super.initState();

    // Animation controllers
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _playController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _playAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _playController,
      curve: Curves.elasticOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOut,
    ));

    _setupListeners();
  }

  void _setupListeners() {
    // Listen to audio service streams
    widget.audioService.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
        });
        _updateProgressAnimation();
      }
    });

    widget.audioService.durationStream.listen((duration) {
      if (mounted) {
        setState(() {
          _duration = duration ?? Duration.zero;
        });
      }
    });

    widget.audioService.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });

        if (_isPlaying) {
          _playController.forward();
          if (!_isVisible) {
            _showBar();
          }
        } else {
          _playController.reverse();
        }
      }
    });

    // Update current song info
    widget.audioService.songsStream.listen((songs) {
      if (mounted &&
          songs.isNotEmpty &&
          widget.audioService.playlist.isNotEmpty) {
        final currentSong =
            widget.audioService.playlist[widget.audioService.currentIndex];
        setState(() {
          _currentSong = currentSong.title ??
              currentSong.name.split('/').last.replaceAll('.mp3', '');
          _currentArtist = currentSong.artist ?? 'Unknown Artist';
        });
      }
    });
  }

  void _updateProgressAnimation() {
    if (_duration.inMilliseconds > 0) {
      final progress = _position.inMilliseconds / _duration.inMilliseconds;
      _progressController.animateTo(progress.clamp(0.0, 1.0));
    }
  }

  void _showBar() {
    setState(() {
      _isVisible = true;
    });
    _slideController.forward();
  }

  void _hideBar() {
    _slideController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isVisible = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _playController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Hide the bar if player screen is open or if not visible
    if (!_isVisible || widget.isPlayerScreenOpen)
      return const SizedBox.shrink();

    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 100),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    EnhancedMusicPlayerScreen(
                        audioService: widget.audioService),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 1),
                      end: Offset.zero,
                    ).animate(CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    )),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 500),
              ),
            );
            HapticFeedback.lightImpact();
          },
          onLongPress: () {
            _showQuickActions();
            HapticFeedback.mediumImpact();
          },
          child: Stack(
            children: [
              // Main bar container
              GlassmorphicContainer(
                width: double.infinity,
                height: 80,
                borderRadius: 20,
                blur: 30,
                alignment: Alignment.center,
                border: 2,
                linearGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withOpacity(0.2),
                    Colors.white.withOpacity(0.05),
                  ],
                ),
                borderGradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _getThemeColors(),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      // Album art with glow effect
                      _buildAlbumArt(),
                      const SizedBox(width: 12),

                      // Song info
                      Expanded(
                        child: _buildSongInfo(),
                      ),

                      // Control buttons
                      _buildControlButtons(),
                    ],
                  ),
                ),
              ),

              // Progress bar at bottom
              _buildProgressBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlbumArt() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _getThemeColors()[0].withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: widget.audioService.playlist.isNotEmpty
            ? AlbumArtGenerator.getPlaceholderWidget(
                _currentSong,
                size: 56,
              )
            : Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: _getThemeColors(),
                  ),
                ),
                child: const Icon(
                  Icons.music_note_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
      ),
    );
  }

  Widget _buildSongInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _currentSong.isNotEmpty ? _currentSong : 'No song playing',
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          _currentArtist,
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.white.withOpacity(0.7),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Previous button
        _buildControlButton(
          icon: Icons.skip_previous_rounded,
          size: 24,
          onTap: () {
            widget.audioService.previous();
            HapticFeedback.lightImpact();
          },
        ),
        const SizedBox(width: 8),

        // Play/Pause button with animation
        ScaleTransition(
          scale: _playAnimation,
          child: GestureDetector(
            onTap: () {
              if (_isPlaying) {
                widget.audioService.pause();
              } else {
                widget.audioService.play();
              }
              HapticFeedback.mediumImpact();
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _getThemeColors(),
                ),
                boxShadow: [
                  BoxShadow(
                    color: _getThemeColors()[0].withOpacity(0.4),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(
                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: 24,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Next button
        _buildControlButton(
          icon: Icons.skip_next_rounded,
          size: 24,
          onTap: () {
            widget.audioService.next();
            HapticFeedback.lightImpact();
          },
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required double size,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.1),
        ),
        child: Icon(
          icon,
          size: size,
          color: Colors.white.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 3,
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          color: Colors.white.withOpacity(0.1),
        ),
        child: AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _progressAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  gradient: LinearGradient(
                    colors: _getThemeColors(),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  List<Color> _getThemeColors() {
    if (_currentSong.isNotEmpty) {
      return AlbumArtGenerator.getGradientColorsFromSongName(_currentSong);
    }
    return [
      Colors.purple.withOpacity(0.8),
      Colors.blue.withOpacity(0.8),
    ];
  }

  void _showQuickActions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.8),
              Colors.black.withOpacity(0.9),
            ],
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AlbumArtGenerator.getPlaceholderWidget(
                    _currentSong,
                    size: 60,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentSong,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _currentArtist,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickActionButton(
                  icon: Icons.shuffle_rounded,
                  label: 'Shuffle',
                  onTap: () {
                    widget.audioService.shufflePlaylist();
                    Navigator.pop(context);
                  },
                ),
                _buildQuickActionButton(
                  icon: Icons.repeat_rounded,
                  label: 'Repeat',
                  onTap: () {
                    widget.audioService.toggleRepeat();
                    Navigator.pop(context);
                  },
                ),
                _buildQuickActionButton(
                  icon: Icons.queue_music_rounded,
                  label: 'Queue',
                  onTap: () {
                    Navigator.pop(context);
                    // Navigate to queue/playlist
                  },
                ),
                _buildQuickActionButton(
                  icon: Icons.close_rounded,
                  label: 'Hide',
                  onTap: () {
                    _hideBar();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: _getThemeColors(),
              ),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }
}
