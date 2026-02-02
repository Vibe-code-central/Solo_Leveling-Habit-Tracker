import 'package:flutter/material.dart';
import 'package:solo_leveling/core/theme/app_theme.dart';
import 'package:solo_leveling/presentation/widgets/system/system_clipper.dart';

class SystemDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final VoidCallback onConfirm;
  final VoidCallback? onCancel;
  final Color? primaryColor;
  final IconData? icon;

  const SystemDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onConfirm,
    this.onCancel,
    this.confirmText = 'CONFIRM',
    this.cancelText = 'CANCEL',
    this.primaryColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final color = primaryColor ?? AppTheme.primaryPurple;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: SystemContainer(
        padding: const EdgeInsets.all(24),
        backgroundColor: AppTheme.systemBlack,
        borderColor: color,
        cutSize: 20,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                if (icon != null) ...[
                  Icon(icon, color: color, size: 28),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontFamily: 'Orbitron',
                          fontWeight: FontWeight.bold,
                          color: color,
                          letterSpacing: 1.5,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Content
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
            ),

            const SizedBox(height: 24),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onCancel != null) ...[
                  TextButton(
                    onPressed: onCancel,
                    child: Text(
                      cancelText,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontFamily: 'Rajdhani',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                ElevatedButton(
                  onPressed: onConfirm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color.withOpacity(0.2),
                    foregroundColor: color,
                    shape: BeveledRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                      side: BorderSide(color: color),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                  child: Text(
                    confirmText,
                    style: const TextStyle(
                      fontFamily: 'Rajdhani',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
