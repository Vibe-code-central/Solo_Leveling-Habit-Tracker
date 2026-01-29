import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'system_clipper.dart';

class SystemGlowButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;
  final Color? color;
  final double? width;

  const SystemGlowButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.color,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor =
        color ?? (isPrimary ? AppTheme.systemCyan : AppTheme.systemPurple);

    Widget button = GestureDetector(
      onTap: onPressed,
      child: GlowDecorator(
        glowColor: buttonColor,
        child: SystemContainer(
          backgroundColor: buttonColor.withOpacity(0.1),
          borderColor: buttonColor,
          cutSize: 10,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Center(
            child: Text(
              text.toUpperCase(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: buttonColor,
                fontSize: 16,
                letterSpacing: 2.0,
                shadows: [
                  Shadow(
                    color: buttonColor.withOpacity(0.8),
                    blurRadius: 10,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (width != null) {
      return SizedBox(width: width, child: button);
    }

    return button;
  }
}

class GlowDecorator extends StatelessWidget {
  final Widget child;
  final Color glowColor;
  final double blurRadius;
  final double spreadRadius;

  const GlowDecorator({
    super.key,
    required this.child,
    this.glowColor = AppTheme.systemCyan,
    this.blurRadius = 15.0,
    this.spreadRadius = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.3),
            blurRadius: blurRadius,
            spreadRadius: spreadRadius,
          ),
        ],
      ),
      child: child,
    );
  }
}
