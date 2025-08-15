import 'package:flutter/material.dart';
import '../screens/home_screen_enhanced.dart';
import '../screens/enhanced_music_player_screen.dart';
import '../screens/library_screen.dart';
import '../screens/settings_screen.dart';
import '../widgets/glassmorphic_bottom_nav_bar.dart';
import '../services/audio_service.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  late AudioService _audioService;

  final List<BottomNavItem> _navItems = [
    const BottomNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    const BottomNavItem(
      icon: Icons.play_circle_outline,
      activeIcon: Icons.play_circle_filled,
      label: 'Player',
    ),
    const BottomNavItem(
      icon: Icons.library_music_outlined,
      activeIcon: Icons.library_music_rounded,
      label: 'Library',
    ),
    const BottomNavItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      label: 'Settings',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _audioService = AudioService();
  }

  @override
  void dispose() {
    _audioService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // This allows the body to extend behind the bottom nav
      body: SafeArea(
        bottom:
            false, // Don't apply safe area to bottom since we have custom nav
        child: IndexedStack(
          index: _currentIndex,
          children: [
            HomeScreen(audioService: _audioService),
            EnhancedMusicPlayerScreen(audioService: _audioService),
            LibraryScreen(audioService: _audioService),
            const SettingsScreen(),
          ],
        ),
      ),
      bottomNavigationBar: GlassmorphicBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: _navItems,
      ),
    );
  }
}
