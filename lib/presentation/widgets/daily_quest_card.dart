import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/habit.dart';

class DailyQuestCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onComplete;
  final VoidCallback? onUndo;
  final VoidCallback? onIncrement; // For counter-based habits
  final VoidCallback? onDecrement; // For counter-based habits
  final bool isDemonTrap;
  final bool isDeadlinePassed;

  const DailyQuestCard({
    super.key,
    required this.habit,
    required this.onComplete,
    this.onUndo,
    this.onIncrement,
    this.onDecrement,
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
      onTap: habit.isCounterBased
          ? null // Disable tap for counter-based habits
          : () {
              // ANTI-CHEAT: Can't complete after deadline
              if (isFailed) {
                ScaffoldMessenger.of(context)
                  ..clearSnackBars()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(
                          '⏰ DEADLINE PASSED - XP LOST. No second chances.'),
                      backgroundColor: AppTheme.crimsonRed,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                return;
              }

              if (isCompleted) {
                // ANTI-CHEAT: No undo after deadline
                if (isDeadlinePassed) {
                  ScaffoldMessenger.of(context)
                    ..clearSnackBars()
                    ..showSnackBar(
                      SnackBar(
                        content: Text(
                            'Cannot undo after deadline. Stay disciplined.'),
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
              // MISSED STATE: Softer amber clock (not harsh red cross)
              if (isFailed)
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: AppTheme.amberGold.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppTheme.amberGold.withOpacity(0.6), width: 3),
                  ),
                  child: Icon(Icons.schedule,
                      color: AppTheme.amberGold.withOpacity(0.8), size: 28),
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
                    // Header row with tier badge and streak
                    Row(
                      children: [
                        // MISSED badge (softer than FAILED)
                        if (isFailed)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.amberGold.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: AppTheme.amberGold.withOpacity(0.6),
                                  width: 1),
                            ),
                            child: Text(
                              '⏰ MISSED',
                              style: TextStyle(
                                color: AppTheme.amberGold.withOpacity(0.9),
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
                                ? AppTheme.amberGold.withOpacity(0.7)
                                : (isCompleted
                                    ? AppTheme.emeraldGreen
                                    : Colors.white),
                            decoration: (isCompleted || isFailed)
                                ? TextDecoration.lineThrough
                                : null,
                            decorationColor: isFailed
                                ? AppTheme.amberGold.withOpacity(0.5)
                                : null,
                          ),
                    ),
                    const SizedBox(height: 8),

                    // COUNTER UI for water habit
                    if (habit.isCounterBased)
                      ..._buildCounterUI()
                    // NORMAL XP/STAT UI for other habits
                    else
                      ..._buildNormalUI(isFailed, isCompleted),
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

  /// Build counter UI for water tracking
  List<Widget> _buildCounterUI() {
    final progress =
        habit.maxCount > 0 ? habit.currentCount / habit.maxCount : 0.0;
    final ml = habit.currentCount * 250;
    final totalMl = habit.maxCount * 250;
    final xpEarned = habit.currentCount * habit.xpPerCount;
    final xpRemaining =
        (habit.maxCount - habit.currentCount) * habit.xpPerCount;

    return [
      // Progress text
      Row(
        children: [
          const Icon(Icons.water_drop, color: AppTheme.electricBlue, size: 16),
          const SizedBox(width: 4),
          Text(
            '${habit.currentCount}/${habit.maxCount} glasses',
            style: TextStyle(
              color: AppTheme.electricBlue,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '($ml / $totalMl ml)',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),

      // Progress bar
      ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: LinearProgressIndicator(
          value: progress,
          minHeight: 8,
          backgroundColor: Colors.grey[800],
          valueColor: AlwaysStoppedAnimation<Color>(
            progress >= 1.0 ? AppTheme.emeraldGreen : AppTheme.electricBlue,
          ),
        ),
      ),
      const SizedBox(height: 12),

      // Counter controls
      Row(
        children: [
          // Decrement button
          InkWell(
            onTap: habit.currentCount > 0 ? onDecrement : null,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: habit.currentCount > 0
                    ? AppTheme.crimsonRed.withOpacity(0.2)
                    : Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: habit.currentCount > 0
                      ? AppTheme.crimsonRed
                      : Colors.grey[700]!,
                ),
              ),
              child: Icon(
                Icons.remove,
                color: habit.currentCount > 0
                    ? AppTheme.crimsonRed
                    : Colors.grey[600],
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Count display
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.darkBg.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${habit.currentCount} glasses',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Increment button
          InkWell(
            onTap: habit.currentCount < habit.maxCount ? onIncrement : null,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: habit.currentCount < habit.maxCount
                    ? AppTheme.emeraldGreen.withOpacity(0.2)
                    : Colors.grey[800],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: habit.currentCount < habit.maxCount
                      ? AppTheme.emeraldGreen
                      : Colors.grey[700]!,
                ),
              ),
              child: Icon(
                Icons.add,
                color: habit.currentCount < habit.maxCount
                    ? AppTheme.emeraldGreen
                    : Colors.grey[600],
                size: 20,
              ),
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),

      // XP display
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle,
                  color: AppTheme.emeraldGreen, size: 14),
              const SizedBox(width: 4),
              Text(
                '$xpEarned XP earned',
                style: const TextStyle(
                  color: AppTheme.emeraldGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          if (xpRemaining > 0)
            Row(
              children: [
                const Icon(Icons.pending, color: AppTheme.amberGold, size: 14),
                const SizedBox(width: 4),
                Text(
                  '$xpRemaining XP left',
                  style: const TextStyle(
                    color: AppTheme.amberGold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
        ],
      ),
    ];
  }

  /// Build normal UI for non-counter habits
  List<Widget> _buildNormalUI(bool isFailed, bool isCompleted) {
    return [
      const SizedBox(height: 4),
      // MISSED XP (softer language than "LOST")
      if (isFailed)
        Row(
          children: [
            Icon(Icons.hourglass_empty,
                color: AppTheme.amberGold.withOpacity(0.8), size: 16),
            const SizedBox(width: 4),
            Text(
              '${habit.xpPenalty} XP not earned',
              style: TextStyle(
                color: AppTheme.amberGold.withOpacity(0.9),
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                '⏰ Opportunity Missed',
                style: TextStyle(
                  color: AppTheme.amberGold.withOpacity(0.7),
                  fontSize: 12,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        )
      else
        Row(
          children: [
            Icon(
              isDemonTrap ? Icons.remove : Icons.add,
              color: isDemonTrap ? AppTheme.crimsonRed : AppTheme.emeraldGreen,
              size: 16,
            ),
            const SizedBox(width: 4),
            Text(
              '${isDemonTrap ? habit.getTotalXPPenalty() : habit.getTotalXPReward()} XP',
              style: TextStyle(
                color:
                    isDemonTrap ? AppTheme.crimsonRed : AppTheme.emeraldGreen,
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
    ];
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
