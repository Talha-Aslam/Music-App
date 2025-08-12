import 'package:flutter/material.dart';
import '../services/audio_service.dart';

class PlayerControls extends StatelessWidget {
  final AudioService audioService;

  const PlayerControls({
    Key? key,
    required this.audioService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isPlaying = audioService.isPlaying;
    final bool hasPlaylist = audioService.playlist.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.skip_previous_rounded,
                  color: Colors.white.withOpacity(0.8)),
              iconSize: 36,
              onPressed: hasPlaylist ? audioService.previous : null,
            ),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.pinkAccent, Colors.blueAccent],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.pink.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: Icon(
                  isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: Colors.white,
                ),
                iconSize: 48,
                onPressed: hasPlaylist
                    ? () {
                        if (isPlaying) {
                          audioService.pause();
                        } else {
                          audioService.play();
                        }
                      }
                    : null,
              ),
            ),
            IconButton(
              icon: Icon(Icons.skip_next_rounded,
                  color: Colors.white.withOpacity(0.8)),
              iconSize: 36,
              onPressed: hasPlaylist ? audioService.next : null,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Shuffle & Repeat Controls
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(
                Icons.shuffle,
                color:
                    audioService.isShuffle ? Colors.blueAccent : Colors.white38,
              ),
              onPressed:
                  hasPlaylist ? () => audioService.toggleShuffle() : null,
            ),
            IconButton(
              icon: Icon(
                Icons.repeat,
                color:
                    audioService.isRepeat ? Colors.blueAccent : Colors.white38,
              ),
              onPressed: hasPlaylist ? () => audioService.toggleRepeat() : null,
            ),
          ],
        ),
      ],
    );
  }
}
