import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/user_profile.dart';

class ActiveDebuffBanner extends StatelessWidget {
  final List<ActiveDebuff> activeDebuffs;

  const ActiveDebuffBanner({
    super.key,
    required this.activeDebuffs,
  });

  @override
  Widget build(BuildContext context) {
    // Filter out expired debuffs
    final validDebuffs = activeDebuffs.where((d) => !d.isExpired).toList();
    
    if (validDebuffs.isEmpty) {
      return const SizedBox.shrink();
    }

    // Get the highest severity debuff (should only be one now, but just in case)
    final debuff = validDebuffs.first;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.crimsonRed.withOpacity(0.2),
            AppTheme.crimsonRed.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.crimsonRed.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.crimsonRed.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        children: [
          // Warning Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.crimsonRed.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.warning_rounded,
              color: AppTheme.crimsonRed,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          
          // Debuff Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ACTIVE DEBUFF',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.crimsonRed.withOpacity(0.8),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  debuff.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  debuff.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                _buildTimeRemaining(debuff),
              ],
            ),
          ),
        ],
      ),
    )
    .animate()
    .fadeIn(duration: 400.ms)
    .slideY(begin: -0.2, duration: 300.ms)
    .shimmer(
      duration: 2000.ms,
      color: AppTheme.crimsonRed.withOpacity(0.3),
    );
  }

  Widget _buildTimeRemaining(ActiveDebuff debuff) {
    final now = DateTime.now();
    final remaining = debuff.expiresAt.difference(now);
    
    String timeText;
    Color timeColor;
    
    if (remaining.isNegative) {
      timeText = 'Expired';
      timeColor = AppTheme.textSecondary;
    } else if (remaining.inHours > 24) {
      final days = remaining.inDays;
      timeText = '$days day${days > 1 ? 's' : ''} remaining';
      timeColor = AppTheme.textSecondary;
    } else if (remaining.inHours > 0) {
      final hours = remaining.inHours;
      final minutes = remaining.inMinutes % 60;
      timeText = '${hours}h ${minutes}m remaining';
      timeColor = AppTheme.amberGold;
    } else {
      final minutes = remaining.inMinutes;
      timeText = '$minutes minutes remaining';
      timeColor = AppTheme.crimsonRed;
    }
    
    return Row(
      children: [
        Icon(
          Icons.timer_outlined,
          size: 14,
          color: timeColor,
        ),
        const SizedBox(width: 4),
        Text(
          timeText,
          style: TextStyle(
            fontSize: 12,
            color: timeColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
