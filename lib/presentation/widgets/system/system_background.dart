import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'dart:math' as math;

class SystemBackground extends StatelessWidget {
  final Widget child;

  const SystemBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.systemBlack,
      body: Stack(
        children: [
          // 1. Hexagonal Grid Pattern
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: CustomPaint(
                painter: HexGridPainter(),
              ),
            ),
          ),

          // 2. Radial Vignette (Darkening edges)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.5,
                  colors: [
                    Colors.transparent,
                    AppTheme.systemBlack.withOpacity(0.8),
                  ],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
          ),

          // 3. Content
          SafeArea(child: child),
        ],
      ),
    );
  }
}

class HexGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.systemCyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const double hexSize = 40.0;
    final double width = size.width;
    final double height = size.height;

    final double xOffset = hexSize * math.sqrt(3);
    final double yOffset = hexSize * 1.5;

    for (double y = 0; y < height + hexSize; y += yOffset) {
      for (double x = 0; x < width + hexSize; x += xOffset) {
        bool isOddRow = (y / yOffset).round().isOdd;
        double xPos = isOddRow ? x + xOffset / 2 : x;

        _drawHexagon(canvas, paint, Offset(xPos, y), hexSize / 1.2);
      }
    }
  }

  void _drawHexagon(Canvas canvas, Paint paint, Offset center, double radius) {
    final Path path = Path();
    for (int i = 0; i < 6; i++) {
      double angle = (60 * i + 30) * math.pi / 180;
      double x = center.dx + radius * math.cos(angle);
      double y = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
