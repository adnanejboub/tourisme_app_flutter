// lib/features/presentation/widgets/animated_logo_widget.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;

class AnimatedLogoWidget extends StatefulWidget {
  final double size;
  final Color? color;

  const AnimatedLogoWidget({
    Key? key,
    this.size = 100,
    this.color,
  }) : super(key: key);

  @override
  _AnimatedLogoWidgetState createState() => _AnimatedLogoWidgetState();
}

class _AnimatedLogoWidgetState extends State<AnimatedLogoWidget>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: Duration(seconds: 8),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_rotationController, _pulseController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: RotationTransition(
            turns: _rotationAnimation,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.white,
                    Colors.white.withOpacity(0.8),
                    Colors.white.withOpacity(0.6),
                  ],
                  stops: [0.0, 0.7, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    spreadRadius: 8,
                    blurRadius: 20,
                    offset: Offset(0, 0),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Outer ring
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                    ),
                  ),

                  // Inner content
                  Center(
                    child: Icon(
                      Icons.explore,
                      size: widget.size * 0.5,
                      color: widget.color ?? Color(0xFF1E88E5),
                    ),
                  ),

                  // Moroccan pattern overlay
                  Positioned.fill(
                    child: CustomPaint(
                      painter: MoroccanPatternPainter(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }
}

class MoroccanPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Color(0xFF1E88E5).withOpacity(0.2)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = size.width / 3;

    // Draw geometric pattern
    for (int i = 0; i < 8; i++) {
      final double angle = (i * 45) * (3.14159 / 180);
      final double x1 = centerX + (radius * 0.5) * cos(angle);
      final double y1 = centerY + (radius * 0.5) * sin(angle);
      final double x2 = centerX + radius * cos(angle);
      final double y2 = centerY + radius * sin(angle);

      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }

    // Draw center circle
    canvas.drawCircle(
      Offset(centerX, centerY),
      radius * 0.3,
      paint..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// Helper function for cos calculation
double cos(double angle) {
  return math.cos(angle);
}

// Helper function for sin calculation
double sin(double angle) {
  return math.sin(angle);
}

