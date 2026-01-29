import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

/// A clipper that cuts the corners of a widget at a 45-degree angle.
/// The [cutSize] determines how much of the corner is cut off.
class SystemEdgeClipper extends CustomClipper<Path> {
  final double cutSize;

  SystemEdgeClipper({this.cutSize = 10.0});

  @override
  Path getClip(Size size) {
    var path = Path();
    path.moveTo(cutSize, 0);
    path.lineTo(size.width - cutSize, 0);
    path.lineTo(size.width, cutSize);
    path.lineTo(size.width, size.height - cutSize);
    path.lineTo(size.width - cutSize, size.height);
    path.lineTo(cutSize, size.height);
    path.lineTo(0, size.height - cutSize);
    path.lineTo(0, cutSize);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

/// A container that applies the [SystemEdgeClipper] and a border.
class SystemContainer extends StatelessWidget {
  final Widget child;
  final double width;
  final double? height;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color backgroundColor;
  final Color borderColor;
  final double borderWith;
  final double cutSize;
  final bool useGradient;
  final VoidCallback? onTap;

  const SystemContainer({
    super.key,
    required this.child,
    this.width = double.infinity,
    this.height,
    this.padding = const EdgeInsets.all(16),
    this.margin = EdgeInsets.zero,
    this.backgroundColor = AppTheme.systemNavy,
    this.borderColor = AppTheme.systemCyan,
    this.borderWith = 1.0,
    this.cutSize = 10.0,
    this.useGradient = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Container(
      width: width,
      height: height,
      margin: margin,
      child: Stack(
        children: [
          // Background and Clip
          ClipPath(
            clipper: SystemEdgeClipper(cutSize: cutSize),
            child: Container(
              padding: padding,
              decoration: BoxDecoration(
                color: backgroundColor,
                gradient: useGradient
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          backgroundColor,
                          backgroundColor.withOpacity(0.6),
                        ],
                      )
                    : null,
              ),
              child: child,
            ),
          ),

          // Border overlay
          IgnorePointer(
            child: CustomPaint(
              size: Size(width, height ?? 0),
              painter: _SystemBorderPainter(
                color: borderColor.withOpacity(0.5),
                width: borderWith,
                cutSize: cutSize,
              ),
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}

class _SystemBorderPainter extends CustomPainter {
  final Color color;
  final double width;
  final double cutSize;

  _SystemBorderPainter({
    required this.color,
    required this.width,
    required this.cutSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width;

    var path = Path();
    path.moveTo(cutSize, 0);
    path.lineTo(size.width - cutSize, 0);
    path.lineTo(size.width, cutSize);
    path.lineTo(size.width, size.height - cutSize);
    path.lineTo(size.width - cutSize, size.height);
    path.lineTo(cutSize, size.height);
    path.lineTo(0, size.height - cutSize);
    path.lineTo(0, cutSize);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
