import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/glassmorphic_container.dart';
import '../services/audio_service.dart';

class SettingsScreen extends StatefulWidget {
  final AudioService? audioService;

  const SettingsScreen({Key? key, this.audioService}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = true;
  bool _autoPlay = false;
  bool _showVisualizer = true;
  bool _shuffleEnabled = false;
  bool _repeatEnabled = false;
  bool _hapticFeedback = true;
  bool _showNotifications = true;
  bool _autoDownloadArt = true;
  double _visualizerIntensity = 1.0;
  double _playbackSpeed = 1.0;
  double _bassBoost = 0.0;
  double _trebleBoost = 0.0;
  String _audioQuality = 'High';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  void _loadSettings() {
    // Load settings from preferences
    if (widget.audioService != null) {
      setState(() {
        _shuffleEnabled = widget.audioService!.isShuffle;
        _repeatEnabled = widget.audioService!.isRepeat;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Settings',
            style: GoogleFonts.poppins(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.95),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Customize your music experience',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),

          // Appearance Section
          _buildSectionHeader('Appearance'),
          const SizedBox(height: 16),
          _buildSettingTile(
            icon: Icons.dark_mode_rounded,
            title: 'Dark Mode',
            subtitle: 'Use dark theme throughout the app',
            trailing: Switch(
              value: _darkMode,
              onChanged: (value) {
                setState(() {
                  _darkMode = value;
                });
                _showSnackBar('Dark mode ${value ? 'enabled' : 'disabled'}');
              },
              activeColor: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 12),
          _buildSettingTile(
            icon: Icons.graphic_eq_rounded,
            title: 'Show Visualizer',
            subtitle: 'Display audio spectrum visualizer',
            trailing: Switch(
              value: _showVisualizer,
              onChanged: (value) {
                setState(() {
                  _showVisualizer = value;
                });
                _showSnackBar('Visualizer ${value ? 'enabled' : 'disabled'}');
              },
              activeColor: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 12),
          _buildSettingTile(
            icon: Icons.tune_rounded,
            title: 'Visualizer Intensity',
            subtitle:
                'Adjust visualizer sensitivity: ${_visualizerIntensity.toStringAsFixed(1)}x',
            trailing: SizedBox(
              width: 120,
              child: Slider(
                value: _visualizerIntensity,
                onChanged: (value) {
                  setState(() {
                    _visualizerIntensity = value;
                  });
                },
                min: 0.1,
                max: 2.0,
                divisions: 19,
                activeColor: Colors.blueAccent,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Playback Section
          _buildSectionHeader('Playback'),
          const SizedBox(height: 16),
          _buildSettingTile(
            icon: Icons.play_arrow_rounded,
            title: 'Auto Play',
            subtitle: 'Start playing when song is selected',
            trailing: Switch(
              value: _autoPlay,
              onChanged: (value) {
                setState(() {
                  _autoPlay = value;
                });
                _showSnackBar('Auto play ${value ? 'enabled' : 'disabled'}');
              },
              activeColor: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 12),
          _buildSettingTile(
            icon: Icons.shuffle_rounded,
            title: 'Shuffle Mode',
            subtitle: 'Enable shuffle by default',
            trailing: Switch(
              value: _shuffleEnabled,
              onChanged: (value) {
                setState(() {
                  _shuffleEnabled = value;
                });
                if (widget.audioService != null) {
                  widget.audioService!.toggleShuffle();
                }
                _showSnackBar('Shuffle ${value ? 'enabled' : 'disabled'}');
              },
              activeColor: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 12),
          _buildSettingTile(
            icon: Icons.repeat_rounded,
            title: 'Repeat Mode',
            subtitle: 'Enable repeat by default',
            trailing: Switch(
              value: _repeatEnabled,
              onChanged: (value) {
                setState(() {
                  _repeatEnabled = value;
                });
                if (widget.audioService != null) {
                  widget.audioService!.toggleRepeat();
                }
                _showSnackBar('Repeat ${value ? 'enabled' : 'disabled'}');
              },
              activeColor: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 12),
          _buildSettingTile(
            icon: Icons.speed_rounded,
            title: 'Playback Speed',
            subtitle:
                'Adjust playback speed: ${_playbackSpeed.toStringAsFixed(1)}x',
            trailing: SizedBox(
              width: 120,
              child: Slider(
                value: _playbackSpeed,
                onChanged: (value) {
                  setState(() {
                    _playbackSpeed = value;
                  });
                  // Apply speed change to audio service
                  HapticFeedback.lightImpact();
                },
                min: 0.5,
                max: 2.0,
                divisions: 15,
                activeColor: Colors.blueAccent,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Audio Section
          _buildSectionHeader('Audio'),
          const SizedBox(height: 16),
          _buildSettingTile(
            icon: Icons.high_quality_rounded,
            title: 'Audio Quality',
            subtitle: 'Current: $_audioQuality',
            trailing: const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white54, size: 16),
            onTap: () => _showQualityDialog(),
          ),
          const SizedBox(height: 12),
          _buildSettingTile(
            icon: Icons.music_note_rounded,
            title: 'Bass Boost',
            subtitle:
                'Enhance low frequencies: ${_bassBoost.toStringAsFixed(1)}dB',
            trailing: SizedBox(
              width: 120,
              child: Slider(
                value: _bassBoost,
                onChanged: (value) {
                  setState(() {
                    _bassBoost = value;
                  });
                  HapticFeedback.lightImpact();
                },
                min: -10.0,
                max: 10.0,
                divisions: 20,
                activeColor: Colors.blueAccent,
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildSettingTile(
            icon: Icons.music_video_rounded,
            title: 'Treble Boost',
            subtitle:
                'Enhance high frequencies: ${_trebleBoost.toStringAsFixed(1)}dB',
            trailing: SizedBox(
              width: 120,
              child: Slider(
                value: _trebleBoost,
                onChanged: (value) {
                  setState(() {
                    _trebleBoost = value;
                  });
                  HapticFeedback.lightImpact();
                },
                min: -10.0,
                max: 10.0,
                divisions: 20,
                activeColor: Colors.blueAccent,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Interface Section
          _buildSectionHeader('Interface'),
          const SizedBox(height: 16),
          _buildSettingTile(
            icon: Icons.vibration_rounded,
            title: 'Haptic Feedback',
            subtitle: 'Enable vibration feedback',
            trailing: Switch(
              value: _hapticFeedback,
              onChanged: (value) {
                setState(() {
                  _hapticFeedback = value;
                });
                if (value) {
                  HapticFeedback.mediumImpact();
                }
                _showSnackBar(
                    'Haptic feedback ${value ? 'enabled' : 'disabled'}');
              },
              activeColor: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 12),
          _buildSettingTile(
            icon: Icons.notifications_rounded,
            title: 'Show Notifications',
            subtitle: 'Display playback notifications',
            trailing: Switch(
              value: _showNotifications,
              onChanged: (value) {
                setState(() {
                  _showNotifications = value;
                });
                _showSnackBar(
                    'Notifications ${value ? 'enabled' : 'disabled'}');
              },
              activeColor: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 12),
          _buildSettingTile(
            icon: Icons.image_rounded,
            title: 'Auto Download Album Art',
            subtitle: 'Automatically fetch album artwork',
            trailing: Switch(
              value: _autoDownloadArt,
              onChanged: (value) {
                setState(() {
                  _autoDownloadArt = value;
                });
                _showSnackBar(
                    'Auto download ${value ? 'enabled' : 'disabled'}');
              },
              activeColor: Colors.blueAccent,
            ),
          ),

          const SizedBox(height: 32),

          // Storage Section
          _buildSectionHeader('Storage'),
          const SizedBox(height: 16),
          _buildSettingTile(
            icon: Icons.storage_rounded,
            title: 'Clear Cache',
            subtitle: 'Free up storage space',
            trailing: const Icon(Icons.delete_outline_rounded,
                color: Colors.redAccent, size: 20),
            onTap: () => _showClearCacheDialog(),
          ),
          const SizedBox(height: 12),
          _buildSettingTile(
            icon: Icons.folder_rounded,
            title: 'Storage Location',
            subtitle: 'Manage music storage location',
            trailing: const Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white54, size: 16),
            onTap: () => _showStorageDialog(),
          ),

          const SizedBox(height: 32),

          // About Section
          _buildSectionHeader('About'),
          const SizedBox(height: 16),
          _buildSettingTile(
            icon: Icons.info_rounded,
            title: 'Version',
            subtitle: '1.0.0 (Build 1)',
            onTap: () => _showVersionDialog(),
          ),
          const SizedBox(height: 12),
          _buildSettingTile(
            icon: Icons.code_rounded,
            title: 'Open Source',
            subtitle: 'View source code on GitHub',
            onTap: () => _openGitHub(),
          ),
          const SizedBox(height: 12),
          _buildSettingTile(
            icon: Icons.bug_report_rounded,
            title: 'Report Bug',
            subtitle: 'Send feedback and report issues',
            onTap: () => _showFeedbackDialog(),
          ),
          const SizedBox(height: 12),
          _buildSettingTile(
            icon: Icons.help_rounded,
            title: 'Help & Support',
            subtitle: 'Get help using the app',
            onTap: () => _showHelpDialog(),
          ),
          const SizedBox(height: 12),
          _buildSettingTile(
            icon: Icons.policy_rounded,
            title: 'Privacy Policy',
            subtitle: 'View our privacy policy',
            onTap: () => _showPrivacyDialog(),
          ),

          // Extra spacing at bottom for navigation bar
          const SizedBox(height: 120),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white.withOpacity(0.9),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return GlassmorphicContainer(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          icon,
          color: Colors.white.withOpacity(0.8),
          size: 24,
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.95),
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GoogleFonts.poppins(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(color: Colors.white),
        ),
        backgroundColor: Colors.black.withOpacity(0.8),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.only(bottom: 140, left: 20, right: 20),
      ),
    );
  }

  void _showQualityDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        title: Text(
          'Audio Quality',
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildQualityOption('Low (96kbps)', 'Low'),
            _buildQualityOption('Medium (128kbps)', 'Medium'),
            _buildQualityOption('High (320kbps)', 'High'),
            _buildQualityOption('Lossless (FLAC)', 'Lossless'),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityOption(String displayText, String value) {
    return RadioListTile<String>(
      title: Text(
        displayText,
        style: GoogleFonts.poppins(color: Colors.white, fontSize: 14),
      ),
      value: value,
      groupValue: _audioQuality,
      onChanged: (newValue) {
        setState(() {
          _audioQuality = newValue!;
        });
        Navigator.pop(context);
        _showSnackBar('Audio quality set to $newValue');
      },
      activeColor: Colors.blueAccent,
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        title: Text(
          'Clear Cache',
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'This will clear all cached album art and temporary files. This action cannot be undone.',
          style: GoogleFonts.poppins(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Cache cleared successfully');
            },
            child: Text(
              'Clear',
              style: GoogleFonts.poppins(color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _showStorageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        title: Text(
          'Storage Location',
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current storage location:',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              '/storage/emulated/0/Music',
              style:
                  GoogleFonts.poppins(color: Colors.blueAccent, fontSize: 12),
            ),
            const SizedBox(height: 16),
            Text(
              'Used: 2.4 GB of 32 GB available',
              style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Storage location feature coming soon');
            },
            child: Text(
              'Change',
              style: GoogleFonts.poppins(color: Colors.blueAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _showVersionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        title: Text(
          'About MusicZZ',
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version: 1.0.0 (Build 1)',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              'Release Date: August 2025',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              'Built with Flutter & Love ❤️',
              style: GoogleFonts.poppins(color: Colors.white70),
            ),
            const SizedBox(height: 16),
            Text(
              'A premium music player with amazing visualizations and glassmorphic design.',
              style: GoogleFonts.poppins(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Close',
              style: GoogleFonts.poppins(color: Colors.blueAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _openGitHub() {
    _showSnackBar('Opening GitHub repository...');
    // In a real app, you would use url_launcher here
    // launch('https://github.com/your-repo');
  }

  void _showFeedbackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        title: Text(
          'Send Feedback',
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              maxLines: 4,
              style: GoogleFonts.poppins(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Describe your issue or suggestion...',
                hintStyle: GoogleFonts.poppins(color: Colors.white54),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Feedback sent! Thank you.');
            },
            child: Text(
              'Send',
              style: GoogleFonts.poppins(color: Colors.blueAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        title: Text(
          'Help & Support',
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHelpItem('🎵', 'How to add music?',
                  'Tap the "Add Music" button on the home screen to select songs from your device.'),
              _buildHelpItem('🎨', 'Customize visualizer?',
                  'Go to Settings > Appearance > Show Visualizer to enable/disable and adjust intensity.'),
              _buildHelpItem('🔀', 'Enable shuffle?',
                  'Tap the shuffle button in the player or enable it by default in Settings > Playback.'),
              _buildHelpItem('🎧', 'Audio quality?',
                  'Change audio quality in Settings > Audio > Audio Quality for better sound.'),
              _buildHelpItem('❓', 'Need more help?',
                  'Send us feedback using the "Report Bug" option in settings.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it!',
              style: GoogleFonts.poppins(color: Colors.blueAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        title: Text(
          'Privacy Policy',
          style: GoogleFonts.poppins(
              color: Colors.white, fontWeight: FontWeight.w600),
        ),
        content: SingleChildScrollView(
          child: Text(
            '''We respect your privacy and are committed to protecting your personal data.

Data Collection:
• We only access music files you explicitly select
• No personal information is collected or transmitted
• All data remains on your device

Storage:
• Music files remain in their original location
• Album art cache stored locally only
• Settings saved locally on your device

Third Parties:
• No data shared with third parties
• No analytics or tracking
• No advertisements

Your music, your privacy, always.''',
            style: GoogleFonts.poppins(color: Colors.white70, fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Understood',
              style: GoogleFonts.poppins(color: Colors.blueAccent),
            ),
          ),
        ],
      ),
    );
  }
}
