import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import '../utils/time_utils.dart';

class ProgressBar extends StatelessWidget {
  final AudioService audioService;
  final Duration position;
  final Duration duration;

  const ProgressBar({
    Key? key,
    required this.audioService,
    required this.position,
    required this.duration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Progress Bar (futuristic style)
        Container(
          height: 6,
          width: 220,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: LinearGradient(
              colors: [Colors.blueAccent, Colors.purpleAccent],
            ),
          ),
          child: Stack(
            children: [
              Container(
                height: 6,
                width: duration.inMilliseconds == 0
                    ? 0
                    : 220 * (position.inMilliseconds / duration.inMilliseconds),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.translucent,
                onHorizontalDragUpdate: (details) {
                  if (duration.inMilliseconds > 0) {
                    double percent = details.localPosition.dx / 220;
                    percent = percent.clamp(0.0, 1.0);
                    final seekTo = Duration(
                        milliseconds:
                            (duration.inMilliseconds * percent).toInt());
                    audioService.seek(seekTo);
                  }
                },
                child: Container(
                  height: 6,
                  width: 220,
                  color: Colors.transparent,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Time display
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              TimeUtils.formatDuration(position),
              style: TextStyle(color: Colors.white70),
            ),
            Text(
              TimeUtils.formatDuration(duration),
              style: TextStyle(color: Colors.white70),
            ),
          ],
        ),
      ],
    );
  }
}
