import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:shimmer/shimmer.dart';
import 'package:glassmorphism/glassmorphism.dart' as gm;
import 'package:google_fonts/google_fonts.dart';
import '../services/audio_service.dart';
import '../widgets/glassmorphic_container.dart' as gc;
import 'enhanced_music_player_screen.dart';

class HomeScreen extends StatefulWidget {
  final AudioService audioService;

  const HomeScreen({Key? key, required this.audioService}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _scaleController.forward();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: AnimationLimiter(
          child: SingleChildScrollView(
            // Make the entire body scrollable
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                  20.0, 20.0, 20.0, 120.0), // Added bottom padding for nav bar
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with animated greeting
                  AnimationConfiguration.staggeredList(
                    position: 0,
                    duration: const Duration(milliseconds: 800),
                    child: SlideAnimation(
                      verticalOffset: -50.0,
                      child: FadeInAnimation(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      AnimatedTextKit(
                                        animatedTexts: [
                                          TypewriterAnimatedText(
                                            _getGreeting(),
                                            textStyle: GoogleFonts.poppins(
                                              fontSize: 28,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                            speed: const Duration(
                                                milliseconds: 100),
                                          ),
                                        ],
                                        totalRepeatCount: 1,
                                      ),
                                      const SizedBox(height: 8),
                                      Shimmer.fromColors(
                                        baseColor: Colors.white60,
                                        highlightColor: Colors.white,
                                        child: Text(
                                          'Ready to vibe with some music?',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            color: Colors.white70,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Animated music icon
                                ScaleTransition(
                                  scale: _scaleAnimation,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white.withOpacity(0.2),
                                          Colors.white.withOpacity(0.1),
                                        ],
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.music_note_rounded,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Quick Actions Grid
                  SizedBox(
                    height: 300, // Fixed height for grid
                    child: AnimationLimiter(
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1.1, // Make cells slightly taller
                        children: [
                          // Shuffle All
                          AnimationConfiguration.staggeredGrid(
                            position: 0,
                            columnCount: 2,
                            duration: const Duration(milliseconds: 800),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: _buildActionCard(
                                  icon: Icons.shuffle_rounded,
                                  title: 'Shuffle All',
                                  subtitle: 'Random vibes',
                                  gradientColors: [
                                    Colors.orange.withOpacity(0.8),
                                    Colors.red.withOpacity(0.6),
                                  ],
                                  onTap: () =>
                                      widget.audioService.shufflePlaylist(),
                                ),
                              ),
                            ),
                          ),

                          // Favorites
                          AnimationConfiguration.staggeredGrid(
                            position: 1,
                            columnCount: 2,
                            duration: const Duration(milliseconds: 800),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: _buildActionCard(
                                  icon: Icons.favorite_rounded,
                                  title: 'Favorites',
                                  subtitle: 'Your loves',
                                  gradientColors: [
                                    Colors.pink.withOpacity(0.8),
                                    Colors.purple.withOpacity(0.6),
                                  ],
                                  onTap: () {
                                    // Navigate to favorites
                                  },
                                ),
                              ),
                            ),
                          ),

                          // Add Music
                          AnimationConfiguration.staggeredGrid(
                            position: 2,
                            columnCount: 2,
                            duration: const Duration(milliseconds: 800),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: _buildActionCard(
                                  icon: Icons.add_rounded,
                                  title: 'Add Music',
                                  subtitle: 'Import songs',
                                  gradientColors: [
                                    Colors.green.withOpacity(0.8),
                                    Colors.teal.withOpacity(0.6),
                                  ],
                                  onTap: () =>
                                      widget.audioService.pickAndLoadSongs(),
                                ),
                              ),
                            ),
                          ),

                          // Browse Library
                          AnimationConfiguration.staggeredGrid(
                            position: 3,
                            columnCount: 2,
                            duration: const Duration(milliseconds: 800),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: _buildActionCard(
                                  icon: Icons.library_music_rounded,
                                  title: 'Library',
                                  subtitle: 'Browse all',
                                  gradientColors: [
                                    Colors.blue.withOpacity(0.8),
                                    Colors.indigo.withOpacity(0.6),
                                  ],
                                  onTap: () {
                                    // Navigate to library tab
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Recently Played Section
                  Container(
                    height: 160, // Increased height to prevent overflow
                    child: AnimationConfiguration.staggeredList(
                      position: 4,
                      duration: const Duration(milliseconds: 800),
                      child: SlideAnimation(
                        verticalOffset: 50.0,
                        child: FadeInAnimation(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Recently Played',
                                style: GoogleFonts.poppins(
                                  fontSize: 18, // Slightly smaller
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12), // Reduced spacing
                              Expanded(
                                // Use Expanded to fill remaining space
                                child: StreamBuilder<List<String>>(
                                  stream: widget.audioService.songsStream,
                                  builder: (context, snapshot) {
                                    if (!snapshot.hasData ||
                                        snapshot.data!.isEmpty) {
                                      return _buildEmptyState();
                                    }

                                    return ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemCount:
                                          snapshot.data!.length.clamp(0, 5),
                                      itemBuilder: (context, index) {
                                        final song = snapshot.data![index];
                                        return _buildRecentlyPlayedCard(
                                            song, index);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<Color> gradientColors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: gm.GlassmorphicContainer(
        width: double.infinity,
        height: double.infinity,
        borderRadius: 20,
        blur: 20,
        alignment: Alignment.center,
        border: 2,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
        child: Container(
          padding: const EdgeInsets.all(16), // Reduced padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Important: minimize size
            children: [
              Container(
                padding: const EdgeInsets.all(12), // Reduced padding
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: gradientColors,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 24, // Slightly smaller icon
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8), // Reduced spacing
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14, // Smaller font
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
                maxLines: 1, // Limit to 1 line
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 10, // Smaller font
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
                maxLines: 1, // Limit to 1 line
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentlyPlayedCard(String song, int index) {
    final fileName = song.split('/').last.replaceAll('.mp3', '');

    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 600),
      child: SlideAnimation(
        horizontalOffset: 100.0,
        child: FadeInAnimation(
          child: GestureDetector(
            onTap: () async {
              // Play the song and navigate to enhanced music player
              await widget.audioService.loadSong(index);
              widget.audioService.play();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EnhancedMusicPlayerScreen(
                    audioService: widget.audioService,
                  ),
                ),
              );
            },
            child: Container(
              width: 100,
              margin: const EdgeInsets.only(right: 12),
              child: gc.GlassmorphicContainer(
                width: 100,
                height: 90, // Further reduced height
                child: Padding(
                  padding: const EdgeInsets.all(6), // Minimal padding
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min, // Minimize size
                    children: [
                      const Icon(
                        Icons.music_note_rounded,
                        size: 20, // Smaller icon
                        color: Colors.white,
                      ),
                      const SizedBox(height: 4), // Minimal spacing
                      Text(
                        fileName,
                        style: GoogleFonts.poppins(
                          fontSize: 8, // Much smaller font
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: gc.GlassmorphicContainer(
        width: double.infinity,
        height: null, // Let it size itself
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min, // Important: minimize size
            children: [
              const Icon(
                Icons.music_off_rounded,
                size: 24, // Even smaller icon
                color: Colors.white54,
              ),
              Text(
                'No music yet',
                style: GoogleFonts.poppins(
                  fontSize: 10, // Smaller font
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
