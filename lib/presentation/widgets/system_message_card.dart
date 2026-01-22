import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';

class SystemMessageCard extends StatelessWidget {
  final double completionRate;
  final int xpEarned;
  final int xpLost;

  const SystemMessageCard({
    super.key,
    required this.completionRate,
    required this.xpEarned,
    required this.xpLost,
  });

  @override
  Widget build(BuildContext context) {
    final message = _generateSystemMessage();
    final messageColor = _getMessageColor();
    final messageIcon = _getMessageIcon();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.cardBg,
            messageColor.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: messageColor.withOpacity(0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: messageColor.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // System Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: messageColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  messageIcon,
                  color: messageColor,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '「SYSTEM NOTIFICATION」',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: messageColor,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Orbitron',
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // System Message
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.darkBg.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: messageColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textPrimary,
                height: 1.4,
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Daily Stats
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Completion Rate',
                  '${(completionRate * 100).toInt()}%',
                  _getCompletionColor(completionRate),
                  Icons.check_circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  'XP Earned',
                  '+$xpEarned',
                  AppTheme.emeraldGreen,
                  Icons.add_circle,
                ),
              ),
              if (xpLost > 0) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatItem(
                    'XP Lost',
                    '-$xpLost',
                    AppTheme.crimsonRed,
                    Icons.remove_circle,
                  ),
                ),
              ],
            ],
          ),
          
          // Progress Bar
          const SizedBox(height: 12),
          _buildProgressBar(),
        ],
      ),
    )
    .animate()
    .fadeIn(duration: 500.ms)
    .slideY(begin: 0.2, duration: 300.ms, curve: Curves.easeOut);
  }

  Widget _buildStatItem(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Daily Progress',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
            Text(
              '${(completionRate * 100).toInt()}%',
              style: TextStyle(
                color: _getCompletionColor(completionRate),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: AppTheme.darkBg,
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: completionRate,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _getCompletionColor(completionRate),
                    _getCompletionColor(completionRate).withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.2)),
      ],
    );
  }

  String _generateSystemMessage() {
    final now = DateTime.now();
    final hour = now.hour;
    
    if (completionRate == 0.0) {
      if (hour < 12) {
        return "Good morning, Hunter. Your daily quests await. Begin your training to grow stronger.";
      } else if (hour < 18) {
        return "The day progresses, Hunter. Complete your quests to avoid penalties and gain power.";
      } else {
        return "⚠️ WARNING: Time is running short. Complete your remaining quests before midnight or face consequences.";
      }
    } else if (completionRate < 0.5) {
      if (hour < 18) {
        return "Progress detected, Hunter. Continue your training to unlock your true potential.";
      } else {
        return "⚠️ CAUTION: You are behind schedule. Push harder to complete your daily objectives.";
      }
    } else if (completionRate < 1.0) {
      return "Excellent progress, Hunter. You are on the path to greatness. Complete the remaining quests for maximum rewards.";
    } else {
      return "🎉 OUTSTANDING! All daily quests completed. You have proven yourself worthy of the Shadow Monarch's power. Rest well, Hunter.";
    }
  }

  Color _getMessageColor() {
    if (completionRate == 0.0) {
      final hour = DateTime.now().hour;
      return hour >= 18 ? AppTheme.crimsonRed : AppTheme.electricBlue;
    } else if (completionRate < 0.5) {
      return AppTheme.amberGold;
    } else if (completionRate < 1.0) {
      return AppTheme.primaryPurple;
    } else {
      return AppTheme.emeraldGreen;
    }
  }

  IconData _getMessageIcon() {
    if (completionRate == 0.0) {
      final hour = DateTime.now().hour;
      return hour >= 18 ? Icons.warning : Icons.info;
    } else if (completionRate < 0.5) {
      return Icons.schedule;
    } else if (completionRate < 1.0) {
      return Icons.trending_up;
    } else {
      return Icons.check_circle;
    }
  }

  Color _getCompletionColor(double rate) {
    if (rate == 0.0) return AppTheme.textSecondary;
    if (rate < 0.3) return AppTheme.crimsonRed;
    if (rate < 0.7) return AppTheme.amberGold;
    if (rate < 1.0) return AppTheme.electricBlue;
    return AppTheme.emeraldGreen;
  }
}