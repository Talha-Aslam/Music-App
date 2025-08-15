import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../utils/helpers/album_art_generator.dart';

class CircularAudioSpectrum extends StatefulWidget {
  final bool isPlaying;
  final double size;
  final Widget child;
  final List<double>? audioData;
  final Color? spectrumColor;
  final String? songName; // Add song name for dynamic colors

  const CircularAudioSpectrum({
    Key? key,
    required this.isPlaying,
    required this.size,
    required this.child,
    this.audioData,
    this.spectrumColor,
    this.songName,
  }) : super(key: key);

  @override
  State<CircularAudioSpectrum> createState() => _CircularAudioSpectrumState();
}

class _CircularAudioSpectrumState extends State<CircularAudioSpectrum>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _spectrumController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  final List<double> _spectrumData =
      List.filled(48, 0.0); // Reduced from 60 to 48 for better performance
  final math.Random _random = math.Random();
  List<Color> _dynamicColors = [
    Colors.white,
    Colors.white70
  ]; // Cache dynamic colors

  @override
  void initState() {
    super.initState();

    // Set dynamic colors based on song
    _updateDynamicColors();

    // Optimized rotation animation - slower for smoother appearance
    _rotationController = AnimationController(
      vsync: this,
      duration:
          const Duration(seconds: 30), // Slower rotation for smoother look
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(_rotationController);

    // Optimized pulse animation
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000), // Slightly slower pulse
    );
    _pulseAnimation = Tween<double>(
      begin: 0.97,
      end: 1.03,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Optimized spectrum data animation - reduced frequency for smoother performance
    _spectrumController = AnimationController(
      vsync: this,
      duration:
          const Duration(milliseconds: 100), // Faster updates but fewer bars
    )..addListener(_updateSpectrum);

    if (widget.isPlaying) {
      _startAnimations();
    }
  }

  void _updateDynamicColors() {
    if (widget.songName != null) {
      _dynamicColors =
          AlbumArtGenerator.getGradientColorsFromSongName(widget.songName!);
    } else {
      _dynamicColors = [Colors.white, Colors.white.withOpacity(0.7)];
    }
  }

  Color get _primarySpectrumColor {
    if (widget.spectrumColor != null) return widget.spectrumColor!;
    return _dynamicColors.isNotEmpty ? _dynamicColors[0] : Colors.white;
  }

  Color get _secondarySpectrumColor {
    return _dynamicColors.length > 1
        ? _dynamicColors[1]
        : _primarySpectrumColor.withOpacity(0.7);
  }

  void _startAnimations() {
    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
    _spectrumController.repeat();
  }

  void _stopAnimations() {
    _rotationController.stop();
    _pulseController.stop();
    _spectrumController.stop();
  }

  void _updateSpectrum() {
    if (widget.isPlaying && mounted) {
      setState(() {
        for (int i = 0; i < _spectrumData.length; i++) {
          if (widget.audioData != null && widget.audioData!.isNotEmpty) {
            // Use real audio data if available
            final dataIndex =
                ((i / _spectrumData.length) * widget.audioData!.length).floor();
            _spectrumData[i] =
                (widget.audioData![dataIndex] / 255.0).clamp(0.0, 1.0);
          } else {
            // Generate simulated data
            final baseIntensity = 0.3 + (_random.nextDouble() * 0.7);
            final frequency = i / _spectrumData.length;
            final bassBoost = frequency < 0.3 ? 1.5 : 1.0;
            _spectrumData[i] = (baseIntensity * bassBoost).clamp(0.0, 1.0);
          }
        }
      });
    }
  }

  @override
  void didUpdateWidget(CircularAudioSpectrum oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _startAnimations();
      } else {
        _stopAnimations();
      }
    }
    // Update colors if song changed
    if (widget.songName != oldWidget.songName) {
      _updateDynamicColors();
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _spectrumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Circular audio spectrum
          AnimatedBuilder(
            animation:
                Listenable.merge([_rotationAnimation, _spectrumController]),
            builder: (context, child) {
              return CustomPaint(
                size: Size(widget.size, widget.size),
                painter: CircularSpectrumPainter(
                  spectrumData: _spectrumData,
                  rotation: _rotationAnimation.value,
                  isPlaying: widget.isPlaying,
                  primaryColor: _primarySpectrumColor,
                  secondaryColor: _secondarySpectrumColor,
                ),
              );
            },
          ),

          // Pulsing center content
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Container(
                  width: widget.size * 0.6,
                  height: widget.size * 0.6,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: widget.isPlaying
                        ? [
                            BoxShadow(
                              color: _primarySpectrumColor.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ]
                        : [],
                  ),
                  child: ClipOval(child: widget.child),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class CircularSpectrumPainter extends CustomPainter {
  final List<double> spectrumData;
  final double rotation;
  final bool isPlaying;
  final Color primaryColor;
  final Color secondaryColor;

  CircularSpectrumPainter({
    required this.spectrumData,
    required this.rotation,
    required this.isPlaying,
    required this.primaryColor,
    required this.secondaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isPlaying) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final innerRadius = radius * 0.75;
    final maxBarHeight = radius * 0.2;

    for (int i = 0; i < spectrumData.length; i++) {
      final angle = (i / spectrumData.length) * 2 * math.pi + rotation;
      final intensity = spectrumData[i];
      final barHeight = maxBarHeight * intensity;

      // Calculate positions
      final startX = center.dx + math.cos(angle) * innerRadius;
      final startY = center.dy + math.sin(angle) * innerRadius;
      final endX = center.dx + math.cos(angle) * (innerRadius + barHeight);
      final endY = center.dy + math.sin(angle) * (innerRadius + barHeight);

      // Create enhanced gradient effect based on intensity and position
      final normalizedAngle =
          (angle + math.pi) / (2 * math.pi); // Normalize angle to 0-1
      final gradientColors = [
        Color.lerp(primaryColor, secondaryColor, normalizedAngle)!
            .withOpacity(0.9),
        Color.lerp(secondaryColor, primaryColor, normalizedAngle)!
            .withOpacity(0.6),
        primaryColor.withOpacity(0.3),
      ];

      // Paint the spectrum bar with enhanced gradient
      final paint = Paint()
        ..shader = LinearGradient(
          colors: gradientColors,
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(Rect.fromPoints(
          Offset(startX, startY),
          Offset(endX, endY),
        ))
        ..strokeWidth =
            2.5 + (intensity * 1.5) // Slightly reduced for smoothness
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );

      // Add optimized glow effect only for high intensity
      if (intensity > 0.6) {
        final glowPaint = Paint()
          ..color = primaryColor.withOpacity(0.2 * intensity)
          ..strokeWidth = (2.5 + (intensity * 1.5)) * 1.5
          ..strokeCap = StrokeCap.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

        canvas.drawLine(
          Offset(startX, startY),
          Offset(endX, endY),
          glowPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CircularSpectrumPainter oldDelegate) {
    return oldDelegate.rotation != rotation ||
        oldDelegate.isPlaying != isPlaying ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor ||
        !_listEquals(oldDelegate.spectrumData, spectrumData);
  }

  bool _listEquals(List<double> a, List<double> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
