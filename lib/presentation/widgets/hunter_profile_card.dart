import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/user_profile.dart';

class HunterProfileCard extends StatelessWidget {
  final UserProfile userProfile;
  final AnimationController glowAnimation;

  const HunterProfileCard({
    super.key,
    required this.userProfile,
    required this.glowAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.cardBg,
            AppTheme.primaryPurple.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.primaryPurple.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPurple.withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with name and rank
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      _getRankColor(),
                      _getRankColor().withOpacity(0.3),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: _getRankColor().withOpacity(0.5),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    _getClassImagePath(),
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userProfile.name,
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                    Text(
                      userProfile.title,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.electricBlue,
                          ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getRankColor().withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getRankColor(),
                    width: 1,
                  ),
                ),
                child: Text(
                  _getRankDisplayName(),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getRankColor(),
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Level and XP Progress
          Row(
            children: [
              Text(
                'Level ${userProfile.level}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              Text(
                '${userProfile.currentXP} / ${userProfile.xpForNextLevel} XP',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // XP Progress Bar
          _buildXPProgressBar(),

          const SizedBox(height: 20),

          // HP and MP Bars
          Row(
            children: [
              Expanded(
                child: _buildResourceBar(
                  'HP',
                  userProfile.currentHP,
                  userProfile.maxHP,
                  AppTheme.crimsonRed,
                  Icons.favorite,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildResourceBar(
                  'MP',
                  userProfile.currentMP,
                  userProfile.maxMP,
                  AppTheme.electricBlue,
                  Icons.flash_on,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Primary Stats
          _buildStatsGrid(),
        ],
      ),
    );
  }

  Widget _buildXPProgressBar() {
    // Calculate progress based on totalXP to show effective total exp (can be negative)
    // If totalXP is negative, show negative progress extending to the left
    final currentProgress = userProfile.xpProgress;
    final totalXP = userProfile.totalXP;
    final xpForNextLevel = userProfile.xpForNextLevel;

    // Calculate effective progress: if totalXP is negative, show negative progress
    // Clamp negative progress to reasonable bounds (max -1.0 to extend one full bar width to the left)
    final effectiveProgress = totalXP < 0
        ? (totalXP / xpForNextLevel)
            .clamp(-1.0, 0.0) // Negative progress clamped to -1.0 max
        : currentProgress;

    final isNegative = effectiveProgress < 0;
    final absProgress = effectiveProgress.abs();

    return LayoutBuilder(
      builder: (context, constraints) {
        final barWidth = constraints.maxWidth;
        final progressWidth = isNegative
            ? (absProgress * barWidth).clamp(
                0.0, barWidth * 2.0) // Can extend up to 2x width to the left
            : (effectiveProgress.clamp(0.0, 1.0) * barWidth);

        return Container(
          height: 8,
          decoration: BoxDecoration(
            color: AppTheme.darkBg,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Progress bar (can extend left if negative)
              Positioned(
                left: isNegative ? barWidth - progressWidth : 0,
                top: 0,
                bottom: 0,
                width: progressWidth,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: isNegative
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      end: isNegative
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                      colors: isNegative
                          ? [
                              AppTheme.crimsonRed.withOpacity(0.7),
                              AppTheme.crimsonRed,
                            ]
                          : [
                              AppTheme.primaryPurple,
                              AppTheme.electricBlue,
                            ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              // Animated shimmer overlay (only for positive progress)
              if (!isNegative && effectiveProgress > 0)
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  width: progressWidth,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ).animate(onPlay: (controller) => controller.repeat()).shimmer(
                    duration: 2000.ms, color: Colors.white.withOpacity(0.3)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResourceBar(
      String label, int current, int max, Color color, IconData icon) {
    final percentage = current / max;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const Spacer(),
            Text(
              '$current/$max',
              style: TextStyle(
                color: AppTheme.textSecondary,
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
            widthFactor: percentage,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    final stats = userProfile.stats;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryPurple.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PRIMARY STATS',
            style: TextStyle(
              color: AppTheme.primaryPurple,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                  child: _buildStatItem(
                      'STR', stats.strength, Icons.fitness_center)),
              Expanded(
                  child: _buildStatItem('AGI', stats.agility, Icons.flash_on)),
              Expanded(
                  child: _buildStatItem('VIT', stats.vitality, Icons.favorite)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                  child: _buildStatItem(
                      'INT', stats.intelligence, Icons.psychology)),
              Expanded(
                  child: _buildStatItem('SEN', stats.sense, Icons.visibility)),
              Expanded(
                  child: _buildStatItem(
                      'WIL', stats.willpower, Icons.psychology_alt)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, int value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.textSecondary,
          size: 16,
        ),
        const SizedBox(height: 4),
        Text(
          value.toString(),
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Color _getRankColor() {
    switch (userProfile.rank) {
      case HunterRank.eRank:
        return Colors.grey;
      case HunterRank.dRank:
        return Colors.brown;
      case HunterRank.cRank:
        return Colors.green;
      case HunterRank.bRank:
        return Colors.blue;
      case HunterRank.aRank:
        return Colors.purple;
      case HunterRank.sRank:
        return Colors.orange;
      case HunterRank.specialSRank:
        return Colors.red;
    }
  }

  String _getRankDisplayName() {
    switch (userProfile.rank) {
      case HunterRank.eRank:
        return 'E-RANK';
      case HunterRank.dRank:
        return 'D-RANK';
      case HunterRank.cRank:
        return 'C-RANK';
      case HunterRank.bRank:
        return 'B-RANK';
      case HunterRank.aRank:
        return 'A-RANK';
      case HunterRank.sRank:
        return 'S-RANK';
      case HunterRank.specialSRank:
        return 'SPECIAL S-RANK';
    }
  }

  String _getClassImagePath() {
    switch (userProfile.hunterClass) {
      case HunterClass.warrior:
        return 'assets/images/warrior_avatar.png';
      case HunterClass.mage:
        return 'assets/images/mage_avatar.png';
      case HunterClass.assassin:
        return 'assets/images/assassin_avatar.png';
    }
  }
}
