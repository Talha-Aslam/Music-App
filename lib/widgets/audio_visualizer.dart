import 'package:flutter/material.dart';
import 'dart:math' as math;

class AudioVisualizer extends StatefulWidget {
  final bool isPlaying;
  final Color color;
  final double intensity; // Control the visualization intensity
  final int barCount;
  final List<double>? audioData; // Optional real audio data

  const AudioVisualizer({
    Key? key,
    required this.isPlaying,
    this.color = Colors.blueAccent,
    this.intensity = 1.0,
    this.barCount = 16,
    this.audioData,
  }) : super(key: key);

  @override
  State<AudioVisualizer> createState() => _AudioVisualizerState();
}

class _AudioVisualizerState extends State<AudioVisualizer>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _pulseController;
  final _random = math.Random();
  late int _barCount;
  late List<double> _barHeights;
  late List<Animation<double>> _barAnimations;

  @override
  void initState() {
    super.initState();
    _barCount = widget.barCount;

    // Create main animation controller for overall tempo
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850), // Slower base animation
    );

    // Create pulse animation controller for pulse effect
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000), // Slower pulse
    );

    // Generate initial bar heights with minimum values
    _barHeights = List.generate(_barCount, (index) => _generateBarHeight(0.2));

    // Create individual animations for each bar with different curves and durations
    _barAnimations = List.generate(_barCount, (index) {
      // Use different curves for different bars to create more natural effect
      final curves = [
        Curves.easeInOut,
        Curves.easeOutSine,
        Curves.easeInQuad,
        Curves.elasticOut
      ];

      // Different bars have different animation characteristics

      return Tween<double>(
        begin: 0.2,
        end: 0.9,
      ).animate(
        CurvedAnimation(
          parent: _mainController,
          curve: Interval(
            _random.nextDouble() * 0.5, // Random start time
            0.5 + _random.nextDouble() * 0.5, // Random end time
            curve: curves[index % curves.length],
          ),
        ),
      );
    });

    if (widget.isPlaying) {
      _startAnimation();
    }

    // Use addListener on both controllers
    _mainController.addListener(() => setState(() {}));
    _pulseController.addListener(() => _updateBars());
  }

  @override
  void didUpdateWidget(AudioVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isPlaying && !_mainController.isAnimating) {
      _startAnimation();
    } else if (!widget.isPlaying && _mainController.isAnimating) {
      _pauseAnimation();
    }

    // Update bar count if changed
    if (widget.barCount != oldWidget.barCount) {
      setState(() {
        _barCount = widget.barCount;
        _barHeights =
            List.generate(_barCount, (index) => _generateBarHeight(0.2));
      });
    }
  }

  void _startAnimation() {
    _mainController.repeat(reverse: true);
    _pulseController.repeat(reverse: true);
  }

  void _pauseAnimation() {
    _mainController.stop();
    _pulseController.stop();
  }

  void _updateBars() {
    if (widget.isPlaying && mounted) {
      setState(() {
        // Only update some bars each time for more natural effect
        final barsToUpdate = _random.nextInt(_barCount ~/ 2) + 1;
        final indices = List.generate(_barCount, (index) => index)..shuffle();

        for (var i = 0; i < barsToUpdate; i++) {
          final idx = indices[i];
          _barHeights[idx] = _generateBarHeight(0.1);
        }
      });
    }
  }

  double _generateBarHeight(double? minHeight) {
    final min = minHeight ?? 0.1;

    // Use intensity factor to control the visualizer's intensity
    final maxHeight = 0.3 + (0.7 * widget.intensity);

    return min + _random.nextDouble() * maxHeight;
  }

  @override
  void dispose() {
    _mainController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use pulse controller value to create a pulsing effect
    final pulseValue = _pulseController.value;
    final baseColor = widget.color;

    return SizedBox(
      height: 50,
      width: 240,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(_barCount, (index) {
          // Create dynamic height based on both animation and manual heights
          double dynamicHeight = widget.isPlaying
              ? _getBarHeight(index, pulseValue)
              : _barHeights[index] * 0.5; // Reduced height when paused

          // Apply subtle mirror effect - bars are taller in middle
          final position = index / (_barCount - 1); // 0 to 1
          final mirrorFactor =
              1.0 - (position - 0.5).abs() * 0.5; // Higher in middle

          return _buildBar(
            dynamicHeight * mirrorFactor,
            baseColor,
            index,
          );
        }),
      ),
    );
  }

  double _getBarHeight(int index, double pulseValue) {
    // Use real audio data if available
    if (widget.audioData != null && widget.audioData!.isNotEmpty) {
      // Map bar index to audio data index (which might have different length)
      final dataIndex =
          ((index / _barCount) * widget.audioData!.length).floor();
      final normalizedValue =
          widget.audioData![dataIndex] / 255.0; // Assuming 0-255 range

      // Add some animation effect even with real data
      final animationBoost = _barAnimations[index].value * 0.3;
      return (normalizedValue * 0.7 + animationBoost) * widget.intensity;
    }

    // Otherwise use simulated visualization
    final animationHeight = _barAnimations[index].value;
    final randomHeight = _barHeights[index];

    // Mix animation, random height and pulse for natural effect
    return (0.3 * animationHeight + 0.5 * randomHeight + 0.2 * pulseValue) *
        widget.intensity;
  }

  Widget _buildBar(double height, Color baseColor, int index) {
    // Create different colors based on position for gradient effect
    final hue = (baseColor.computeLuminance() > 0.5)
        ? HSVColor.fromColor(baseColor).withSaturation(0.8)
        : HSVColor.fromColor(baseColor);

    final position = index / (_barCount - 1); // 0 to 1
    final adjustedHue = HSVColor.lerp(
      hue,
      HSVColor.fromAHSV(
        1.0,
        (hue.hue + 40) % 360, // Shift hue by 40 degrees
        hue.saturation,
        hue.value,
      ),
      position,
    )!;

    // Create gradient effects
    final Color barColor = widget.isPlaying
        ? adjustedHue.toColor()
        : adjustedHue.toColor().withOpacity(0.4);

    // Dynamic glow intensity based on height
    final glowIntensity = widget.isPlaying ? 0.3 + (height * 0.5) : 0.1;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 4 + (height * 2), // Width varies with height for bigger effect
          height: 40 * height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [
                barColor,
                barColor.withOpacity(0.7),
              ],
            ),
            boxShadow: widget.isPlaying
                ? [
                    BoxShadow(
                      color: barColor.withOpacity(glowIntensity),
                      blurRadius: 8,
                      spreadRadius: 2,
                    )
                  ]
                : [],
          ),
        ),
        // Add reflection effect
        if (widget.isPlaying)
          Transform.scale(
            scaleY: -0.3, // Mirror and reduce size
            child: Container(
              width: 4 + (height * 2),
              height: 40 * height * 0.5, // Half height for reflection
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    barColor.withOpacity(0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
