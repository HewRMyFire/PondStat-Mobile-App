import 'package:flutter/material.dart';
import 'dart:math' as math;

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
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double t = _controller.value;

        // Calculate bubble positions
        final double bubble1X = 10 * math.cos(t * 2 * math.pi);
        final double bubble1Y = 10 * math.sin(t * 2 * math.pi);
        final double bubble2X = 10 * math.sin(t * 2 * math.pi);
        final double bubble2Y = 15 * math.cos(t * 2 * math.pi);

        return ClipPath(
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
                // Bubble 1
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

                // Bubble 2
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

                // Text Content
                Align(
                  alignment: const Alignment(0.0, -0.0),
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

class WaveClipper extends CustomClipper<Path> {
  final double animationValue;

  WaveClipper({required this.animationValue});

  @override
  Path getClip(Size size) {
    var path = Path();

    // Calculate dynamic heights
    double waveHeight1 = 40 + (10 * math.sin(animationValue * 2 * math.pi));
    double waveHeight2 = 40 + (10 * math.cos(animationValue * 2 * math.pi));

    path.lineTo(0, size.height - waveHeight1);

    // First Curve
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 40);

    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    // Second Curve
    var secondControlPoint = Offset(
      size.width * 3 / 4,
      size.height - 80 + (15 * math.sin(animationValue * 2 * math.pi)),
    );
    var secondEndPoint = Offset(size.width, size.height - waveHeight2);

    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(WaveClipper oldClipper) {
    return true;
  }
}