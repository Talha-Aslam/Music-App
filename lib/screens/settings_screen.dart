import 'package:flutter/material.dart';
import '../widgets/glassmorphic_container.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = true;
  bool _autoPlay = false;
  bool _showVisualizer = true;
  double _visualizerIntensity = 1.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.95),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Customize your music experience',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),

          // Appearance Section
          _buildSectionHeader('Appearance'),
          const SizedBox(height: 16),
          _buildSettingTile(
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            subtitle: 'Use dark theme',
            trailing: Switch(
              value: _darkMode,
              onChanged: (value) {
                setState(() {
                  _darkMode = value;
                });
              },
              activeColor: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 12),
          _buildSettingTile(
            icon: Icons.graphic_eq,
            title: 'Show Visualizer',
            subtitle: 'Display audio visualizer',
            trailing: Switch(
              value: _showVisualizer,
              onChanged: (value) {
                setState(() {
                  _showVisualizer = value;
                });
              },
              activeColor: Colors.blueAccent,
            ),
          ),
          const SizedBox(height: 12),
          _buildSettingTile(
            icon: Icons.tune,
            title: 'Visualizer Intensity',
            subtitle: 'Adjust visualizer sensitivity',
            trailing: SizedBox(
              width: 100,
              child: Slider(
                value: _visualizerIntensity,
                onChanged: (value) {
                  setState(() {
                    _visualizerIntensity = value;
                  });
                },
                min: 0.1,
                max: 2.0,
                activeColor: Colors.blueAccent,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Playback Section
          _buildSectionHeader('Playback'),
          const SizedBox(height: 16),
          _buildSettingTile(
            icon: Icons.play_arrow,
            title: 'Auto Play',
            subtitle: 'Start playing when song is selected',
            trailing: Switch(
              value: _autoPlay,
              onChanged: (value) {
                setState(() {
                  _autoPlay = value;
                });
              },
              activeColor: Colors.blueAccent,
            ),
          ),

          const SizedBox(height: 32),

          // About Section
          _buildSectionHeader('About'),
          const SizedBox(height: 16),
          _buildSettingTile(
            icon: Icons.info,
            title: 'Version',
            subtitle: '1.0.0',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _buildSettingTile(
            icon: Icons.code,
            title: 'Open Source',
            subtitle: 'View on GitHub',
            onTap: () {},
          ),
          const SizedBox(height: 12),
          _buildSettingTile(
            icon: Icons.bug_report,
            title: 'Report Bug',
            subtitle: 'Send feedback',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
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
          style: TextStyle(
            color: Colors.white.withOpacity(0.95),
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 12,
          ),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
