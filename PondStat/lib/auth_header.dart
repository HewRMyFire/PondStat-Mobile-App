import 'package:flutter/material.dart';
import 'dart:math' as math;

// A reusable header widget for authentication screens (Login/Signup).
// Displays a title, subtitle, and an animated wave background with floating bubbles.
class AuthHeader extends StatefulWidget {
  final String title;
  final String subtitle;

  const AuthHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  State<AuthHeader> createState() => _AuthHeaderState();
}

class _AuthHeaderState extends State<AuthHeader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    // Initialize the controller to run indefinitely for the continuous wave effect.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5), // One full cycle takes 5 seconds
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose(); // Always dispose controllers to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // 't' represents the current progress of the animation (0.0 to 1.0)
        final double t = _controller.value;

        // This creates a gentle "floating" effect.
        final double bubble1X = 10 * math.cos(t * 2 * math.pi);
        final double bubble1Y = 10 * math.sin(t * 2 * math.pi);
        final double bubble2X = 10 * math.sin(t * 2 * math.pi);
        final double bubble2Y = 15 * math.cos(t * 2 * math.pi);

        return ClipPath(
          // Applies the custom wave shape defined in WaveClipper
          clipper: WaveClipper(animationValue: t),
          child: Container(
            width: double.infinity,
            height: 260,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor,
                  primaryColor.withOpacity(0.8),
                ],
              ),
            ),
            child: Stack(
              children: [
                // Decorative Floating Bubble 1
                Positioned(
                  top: -50,
                  left: -50,
                  child: Transform.translate(
                    offset: Offset(bubble1X, bubble1Y),
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),

                // Decorative Floating Bubble 2
                Positioned(
                  top: 50,
                  right: -30,
                  child: Transform.translate(
                    offset: Offset(bubble2X, bubble2Y),
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),

                // Main Text Content
                Align(
                  alignment: const Alignment(0.0, -0.0), // Slightly above center
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          shadows: [
                            Shadow(
                              offset: Offset(0, 2),
                              blurRadius: 4.0,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        widget.subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 18.0,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Custom Clipper to create the animated wave shape at the bottom of the header.
class WaveClipper extends CustomClipper<Path> {
  final double animationValue;

  WaveClipper({required this.animationValue});

  @override
  Path getClip(Size size) {
    var path = Path();

    // Calculate dynamic heights for the start and end points of the wave
    // based on the current animation value.
    double waveHeight1 = 40 + (10 * math.sin(animationValue * 2 * math.pi));
    double waveHeight2 = 40 + (10 * math.cos(animationValue * 2 * math.pi));

    // Start drawing from the top-left (0,0 is implicit), down to the wave start height
    path.lineTo(0, size.height - waveHeight1);

    // Bezier curve control point (bottom-left area)
    var firstControlPoint = Offset(size.width / 4, size.height);
    // Bezier curve end point (middle of the screen width)
    var firstEndPoint = Offset(size.width / 2, size.height - 40);

    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    // The second control point moves vertically based on animation to create the "waving" motion
    var secondControlPoint = Offset(
      size.width * 3 / 4,
      size.height - 80 + (15 * math.sin(animationValue * 2 * math.pi))
    );
    var secondEndPoint = Offset(size.width, size.height - waveHeight2);

    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    // Close the path back to the top-right and top-left
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(WaveClipper oldClipper) {
    // Return true to redraw the clip whenever the animation value changes
    return true;
  }
}