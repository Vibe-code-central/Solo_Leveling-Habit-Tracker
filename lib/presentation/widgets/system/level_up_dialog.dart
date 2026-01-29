import 'package:flutter/material.dart';
import 'package:solo_leveling/core/theme/app_theme.dart';
import 'package:solo_leveling/presentation/widgets/system/system_clipper.dart';
import 'package:solo_leveling/presentation/widgets/system/glow_widgets.dart';

class LevelUpDialog extends StatelessWidget {
  final int newLevel;
  final VoidCallback onConfirm;

  const LevelUpDialog({
    super.key,
    required this.newLevel,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: SystemContainer(
        padding: const EdgeInsets.all(24),
        backgroundColor: AppTheme.systemBlack,
        borderColor: AppTheme.systemGold,
        cutSize: 20,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with Glow
            GlowDecorator(
              glowColor: AppTheme.systemGold,
              blurRadius: 20,
              child: Icon(
                Icons.keyboard_double_arrow_up,
                color: AppTheme.systemGold,
                size: 64,
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'LEVEL UP!',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontFamily: 'Orbitron',
                    fontWeight: FontWeight.bold,
                    color: AppTheme.systemGold,
                    letterSpacing: 2,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'You have reached Level $newLevel',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.systemWhite,
                    fontWeight: FontWeight.bold,
                  ),
            ),

            const SizedBox(height: 24),

            // Stats Increase Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.systemGold.withOpacity(0.1),
                border: Border.all(color: AppTheme.systemGold.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildStatRow(context, 'All Stats', '+2-3'),
                  _buildStatRow(context, 'Max HP', '+50'),
                  _buildStatRow(context, 'Max MP', '+25'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Confirm Button
            SystemGlowButton(
              text: 'ACCEPT',
              onPressed: onConfirm,
              color: AppTheme.systemGold,
              width: 150,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.systemGold,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
