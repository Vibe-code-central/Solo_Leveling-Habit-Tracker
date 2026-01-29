import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../core/theme/app_theme.dart';
import 'system_clipper.dart';

class SystemGlassPanel extends StatelessWidget {
  final Widget child;
  final double blur;
  final double opacity;
  final Color borderColor;

  const SystemGlassPanel({
    super.key,
    required this.child,
    this.blur = 10.0,
    this.opacity = 0.2,
    this.borderColor = AppTheme.systemCyan,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: SystemEdgeClipper(cutSize: 10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          decoration: BoxDecoration(
            color: AppTheme.systemNavy.withOpacity(opacity),
            border: Border.all(
              color: borderColor.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: SystemContainer(
            // Use nested SystemContainer just for the angled border painting if needed,
            // or just use the container decoration above.
            // To keep it simple and clean, we'll just return the child wrapped in padding here,
            // relying on the parent ClipPath for shape.
            backgroundColor: Colors.transparent,
            borderColor: borderColor,
            cutSize: 10,
            child: child,
          ),
        ),
      ),
    );
  }
}
