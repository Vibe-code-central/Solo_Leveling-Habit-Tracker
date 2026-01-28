import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solo_leveling/core/theme/app_theme.dart';

import 'package:solo_leveling/presentation/providers/habit_provider.dart';
import 'package:solo_leveling/presentation/providers/user_provider.dart';

class WeeklyBossCard extends StatelessWidget {
  const WeeklyBossCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<HabitProvider, UserProvider>(
      builder: (context, habitProvider, userProvider, child) {
        final boss = habitProvider.getCurrentWeeklyBoss();
        final progress = habitProvider.getWeeklyBossProgress(boss);
        final isDefeated = habitProvider.isWeeklyBossDefeated(userProvider);

        // Calculate progress percentage
        final progressPercent =
            (progress / boss.targetCompletions).clamp(0.0, 1.0);

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 24),
          decoration: BoxDecoration(
            color: isDefeated
                ? AppTheme.primaryPurple.withOpacity(0.1)
                : AppTheme.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDefeated
                  ? AppTheme.primaryPurple
                  : AppTheme.crimsonRed.withOpacity(0.5),
              width: isDefeated ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    (isDefeated ? AppTheme.primaryPurple : AppTheme.crimsonRed)
                        .withOpacity(0.2),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            children: [
              // Background Design Elements
              Positioned(
                right: -20,
                top: -20,
                child: Opacity(
                  opacity: 0.1,
                  child: Text(
                    boss.icon,
                    style: const TextStyle(fontSize: 150),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Row
                    Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: (isDefeated
                                    ? AppTheme.primaryPurple
                                    : AppTheme.crimsonRed)
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: isDefeated
                                    ? AppTheme.primaryPurple
                                    : AppTheme.crimsonRed),
                          ),
                          child: Center(
                            child: Text(
                              boss.icon,
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "WEEK ${boss.id.hashCode % 4 + 1} BOSS",
                                style: TextStyle(
                                  color: isDefeated
                                      ? AppTheme.primaryPurple
                                      : AppTheme.crimsonRed,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                boss.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        if (isDefeated)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryPurple,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.check,
                                    color: Colors.white, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  "SLAIN",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Description
                    Text(
                      boss.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textSecondary,
                            height: 1.5,
                          ),
                    ),

                    const SizedBox(height: 20),

                    // Progress & Rewards Display
                    if (!isDefeated) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "COMBAT PROGRESS",
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "$progress / ${boss.targetCompletions}",
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progressPercent,
                          minHeight: 8,
                          backgroundColor: AppTheme.darkBg,
                          valueColor:
                              AlwaysStoppedAnimation(AppTheme.crimsonRed),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Rewards Preview
                      Row(
                        children: [
                          _buildRewardChip(
                              icon: Icons.star,
                              label: "+${boss.xpReward} XP",
                              color: AppTheme.amberGold),
                          const SizedBox(width: 8),
                          if (boss.statRewards.isNotEmpty)
                            _buildRewardChip(
                              icon: Icons.auto_graph,
                              label:
                                  "+${boss.statRewards.values.first} ${boss.statRewards.keys.first.toUpperCase()}",
                              color: AppTheme.electricBlue,
                            ),
                        ],
                      ),
                    ] else ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.darkBg.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            "Boss defeated! Rewards claimed.",
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRewardChip(
      {required IconData icon, required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
