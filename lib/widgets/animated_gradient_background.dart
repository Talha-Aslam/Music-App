import 'package:flutter/material.dart';

class AnimatedGradientBackground extends StatefulWidget {
  final Widget child;

  const AnimatedGradientBackground({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<AnimatedGradientBackground> createState() =>
      _AnimatedGradientBackgroundState();
}

class _AnimatedGradientBackgroundState extends State<AnimatedGradientBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _secondaryController;
  late Animation<double> _animation;
  late Animation<double> _secondaryAnimation;

  @override
  void initState() {
    super.initState();
    
    // Main gradient animation
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    // Secondary animation for more depth
    _secondaryController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat(reverse: true);
    _secondaryAnimation = CurvedAnimation(parent: _secondaryController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    _secondaryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Primary animated gradient
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.lerp(
                        const Color(0xFF667eea),
                        const Color(0xFF764ba2),
                        _animation.value,
                      )!,
                      Color.lerp(
                        const Color(0xFF764ba2),
                        const Color(0xFFf093fb),
                        _animation.value,
                      )!,
                      Color.lerp(
                        const Color(0xFFf093fb),
                        const Color(0xFF4facfe),
                        _animation.value,
                      )!,
                    ],
                  ),
                ),
              );
            },
          ),
          
          // Secondary overlay gradient for depth
          AnimatedBuilder(
            animation: _secondaryAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.5,
                    colors: [
                      Colors.transparent,
                      Color.lerp(
                        Colors.purple.withOpacity(0.1),
                        Colors.blue.withOpacity(0.1),
                        _secondaryAnimation.value,
                      )!,
                      Colors.transparent,
                    ],
                  ),
                ),
              );
            },
          ),

          // Subtle animated orb
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Positioned(
                top: 100 + (50 * _animation.value),
                right: 50 + (30 * _animation.value),
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.white.withOpacity(0.05),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

          // Another subtle animated orb
          AnimatedBuilder(
            animation: _secondaryAnimation,
            builder: (context, child) {
              return Positioned(
                bottom: 200 + (40 * _secondaryAnimation.value),
                left: 30 + (50 * _secondaryAnimation.value),
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Colors.cyan.withOpacity(0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Content with safe area
          SafeArea(
            child: widget.child,
          ),
        ],
      ),
    );
  }
}
