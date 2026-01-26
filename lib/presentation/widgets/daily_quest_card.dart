import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/habit.dart';

class DailyQuestCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onComplete;
  final VoidCallback? onUndo;
  final bool isDemonTrap;
  final bool isDeadlinePassed;

  const DailyQuestCard({
    super.key,
    required this.habit,
    required this.onComplete,
    this.onUndo,
    this.isDemonTrap = false,
    this.isDeadlinePassed = false,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted =
        isDemonTrap ? habit.isFailedToday : habit.isCompletedToday;
    final cardColor = _getCardColor();
    final tierColor = _getTierColor();

    // FAILED state: deadline passed and not completed (for good habits only)
    final isFailed = isDeadlinePassed && !isCompleted && !isDemonTrap;

    return GestureDetector(
      onTap: () {
        // ANTI-CHEAT: Can't complete after deadline
        if (isFailed) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('⏰ DEADLINE PASSED - XP LOST. No second chances.'),
              backgroundColor: AppTheme.crimsonRed,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }

        if (isCompleted) {
          // ANTI-CHEAT: No undo after deadline
          if (isDeadlinePassed) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Cannot undo after deadline. Stay disciplined.'),
                backgroundColor: AppTheme.crimsonRed,
                behavior: SnackBarBehavior.floating,
              ),
            );
            return;
          }
          _showUndoDialog(context);
        } else {
          onComplete();
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isFailed
                ? [
                    AppTheme.crimsonRed.withOpacity(0.3),
                    AppTheme.crimsonRed.withOpacity(0.1)
                  ]
                : [
                    isCompleted
                        ? AppTheme.emeraldGreen.withOpacity(0.2)
                        : cardColor.withOpacity(0.1),
                    isCompleted
                        ? AppTheme.emeraldGreen.withOpacity(0.1)
                        : cardColor.withOpacity(0.05),
                  ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isFailed
                ? AppTheme.crimsonRed
                : (isCompleted
                    ? AppTheme.emeraldGreen
                    : cardColor.withOpacity(0.5)),
            width: (isFailed || isCompleted) ? 3 : 1,
          ),
          boxShadow: isFailed
              ? [
                  BoxShadow(
                    color: AppTheme.crimsonRed.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 3,
                  ),
                ]
              : (isCompleted
                  ? [
                      BoxShadow(
                        color: AppTheme.emeraldGreen.withOpacity(0.4),
                        blurRadius: 20,
                        spreadRadius: 3,
                      ),
                    ]
                  : null),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // FAILED STATE: Red X
              if (isFailed)
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.crimsonRed,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.crimsonRed, width: 3),
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 32),
                )
              // Normal checkbox
              else
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? AppTheme.emeraldGreen
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isCompleted ? AppTheme.emeraldGreen : cardColor,
                      width: 3,
                    ),
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 32)
                      : Icon(
                          isDemonTrap
                              ? Icons.warning_outlined
                              : Icons.radio_button_unchecked,
                          color: cardColor,
                          size: 28,
                        ),
                ),

              const SizedBox(width: 16),

              // Quest Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        // FAILED badge
                        if (isFailed)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.crimsonRed.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: AppTheme.crimsonRed, width: 1),
                            ),
                            child: const Text(
                              '💀 FAILED',
                              style: TextStyle(
                                color: AppTheme.crimsonRed,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          )
                        else
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: tierColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: tierColor, width: 1),
                            ),
                            child: Text(
                              _getTierDisplayName(),
                              style: TextStyle(
                                color: tierColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        if (habit.currentStreak > 0 &&
                            !isDemonTrap &&
                            !isFailed) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.local_fire_department,
                              color: AppTheme.amberGold, size: 16),
                          Text(
                            '${habit.currentStreak}',
                            style: const TextStyle(
                              color: AppTheme.amberGold,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      habit.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isFailed
                                ? AppTheme.crimsonRed
                                : (isCompleted
                                    ? AppTheme.emeraldGreen
                                    : Colors.white),
                            decoration: (isCompleted || isFailed)
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                    ),
                    const SizedBox(height: 4),
                    // LOST XP for failed habits
                    if (isFailed)
                      Row(
                        children: [
                          const Icon(Icons.remove,
                              color: AppTheme.crimsonRed, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            '-${habit.xpPenalty} XP LOST',
                            style: const TextStyle(
                              color: AppTheme.crimsonRed,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '⏰ Deadline Passed',
                            style: TextStyle(
                              color: AppTheme.crimsonRed.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        children: [
                          Icon(
                            isDemonTrap ? Icons.remove : Icons.add,
                            color: isDemonTrap
                                ? AppTheme.crimsonRed
                                : AppTheme.emeraldGreen,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${isDemonTrap ? habit.getTotalXPPenalty() : habit.getTotalXPReward()} XP',
                            style: TextStyle(
                              color: isDemonTrap
                                  ? AppTheme.crimsonRed
                                  : AppTheme.emeraldGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (habit.statRewards.isNotEmpty && !isDemonTrap) ...[
                            const SizedBox(width: 12),
                            const Icon(Icons.trending_up,
                                color: AppTheme.electricBlue, size: 14),
                            const SizedBox(width: 4),
                            const Text(
                              'Stats',
                              style: TextStyle(
                                color: AppTheme.electricBlue,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )
          .animate(target: isCompleted ? 1 : 0)
          .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.05, 1.05),
              duration: 200.ms)
          .then()
          .scale(
              begin: const Offset(1.05, 1.05),
              end: const Offset(1, 1),
              duration: 200.ms)
          .shimmer(
              duration: 800.ms, color: AppTheme.emeraldGreen.withOpacity(0.5)),
    );
  }

  Color _getCardColor() {
    if (isDemonTrap) {
      return AppTheme.crimsonRed;
    }

    switch (habit.tier) {
      case HabitTier.s:
        return AppTheme.amberGold;
      case HabitTier.a:
        return AppTheme.primaryPurple;
      case HabitTier.b:
        return AppTheme.electricBlue;
      case HabitTier.c:
        return AppTheme.emeraldGreen;
      default:
        return AppTheme.primaryPurple;
    }
  }

  Color _getTierColor() {
    switch (habit.tier) {
      case HabitTier.s:
        return AppTheme.amberGold;
      case HabitTier.a:
        return AppTheme.primaryPurple;
      case HabitTier.b:
        return AppTheme.electricBlue;
      case HabitTier.c:
        return AppTheme.emeraldGreen;
      case HabitTier.severe:
        return AppTheme.crimsonRed;
      case HabitTier.catastrophic:
        return const Color(0xFF8B0000);
    }
  }

  String _getTierDisplayName() {
    switch (habit.tier) {
      case HabitTier.s:
        return 'S-TIER';
      case HabitTier.a:
        return 'A-TIER';
      case HabitTier.b:
        return 'B-TIER';
      case HabitTier.c:
        return 'C-TIER';
      case HabitTier.severe:
        return 'SEVERE';
      case HabitTier.catastrophic:
        return 'CATASTROPHIC';
    }
  }

  void _showUndoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'UNDO ${isDemonTrap ? "TRAP" : "QUEST"}?',
          style: const TextStyle(color: AppTheme.amberGold),
        ),
        content: Text(
          'This will reverse the ${isDemonTrap ? "penalties" : "rewards"}. Are you sure?',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (onUndo != null) onUndo!();
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.amberGold),
            child: const Text('UNDO'),
          ),
        ],
      ),
    );
  }
}
