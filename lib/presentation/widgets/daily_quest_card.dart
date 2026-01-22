import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/habit.dart';

class DailyQuestCard extends StatelessWidget {
  final Habit habit;
  final VoidCallback onComplete;
  final VoidCallback? onUndo;
  final bool isDemonTrap;

  const DailyQuestCard({
    super.key,
    required this.habit,
    required this.onComplete,
    this.onUndo,
    this.isDemonTrap = false,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = isDemonTrap ? habit.isFailedToday : habit.isCompletedToday;
    final cardColor = _getCardColor();
    final tierColor = _getTierColor();

    return GestureDetector(
      onTap: () {
        if (isCompleted) {
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
            colors: [
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
            color: isCompleted ? AppTheme.emeraldGreen : cardColor.withOpacity(0.5),
            width: isCompleted ? 3 : 1,
          ),
          boxShadow: isCompleted ? [
            BoxShadow(
              color: AppTheme.emeraldGreen.withOpacity(0.4),
              blurRadius: 20,
              spreadRadius: 3,
            ),
          ] : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Large Checkbox
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
                  ? Icon(Icons.check, color: Colors.white, size: 32)
                  : Icon(
                      isDemonTrap ? Icons.warning_outlined : Icons.radio_button_unchecked,
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
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                        if (habit.currentStreak > 0 && !isDemonTrap) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.local_fire_department, color: AppTheme.amberGold, size: 16),
                          Text(
                            '${habit.currentStreak}',
                            style: TextStyle(
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
                        color: isCompleted ? AppTheme.emeraldGreen : Colors.white,
                        decoration: isCompleted ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    const SizedBox(height: 4),
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
                            color: isDemonTrap ? AppTheme.crimsonRed : AppTheme.emeraldGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (habit.statRewards.isNotEmpty && !isDemonTrap) ...[
                          const SizedBox(width: 12),
                          Icon(Icons.trending_up, color: AppTheme.electricBlue, size: 14),
                          const SizedBox(width: 4),
                          Text(
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
      .scale(begin: const Offset(1, 1), end: const Offset(1.05, 1.05), duration: 200.ms)
      .then()
      .scale(begin: const Offset(1.05, 1.05), end: const Offset(1, 1), duration: 200.ms)
      .shimmer(duration: 800.ms, color: AppTheme.emeraldGreen.withOpacity(0.5)),
    );
  }

  Widget _buildRewardInfo() {
    if (isDemonTrap) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.remove, color: AppTheme.crimsonRed, size: 14),
              const SizedBox(width: 4),
              Text(
                '${habit.getTotalXPPenalty()} XP',
                style: TextStyle(
                  color: AppTheme.crimsonRed,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              if (habit.hpDamage > 0) ...[
                const SizedBox(width: 8),
                Icon(Icons.favorite, color: AppTheme.crimsonRed, size: 14),
                const SizedBox(width: 2),
                Text(
                  '-${habit.hpDamage}',
                  style: TextStyle(
                    color: AppTheme.crimsonRed,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
          if (habit.debuffName != null)
            Text(
              'Debuff: ${habit.debuffName}',
              style: TextStyle(
                color: AppTheme.crimsonRed.withOpacity(0.8),
                fontSize: 10,
              ),
            ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.add, color: AppTheme.emeraldGreen, size: 14),
              const SizedBox(width: 4),
              Text(
                '${habit.getTotalXPReward()} XP',
                style: TextStyle(
                  color: AppTheme.emeraldGreen,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              if (habit.statRewards.isNotEmpty) ...[
                const SizedBox(width: 8),
                ...habit.statRewards.entries.map((entry) => Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Text(
                    '+${entry.value} ${entry.key.toUpperCase()}',
                    style: TextStyle(
                      color: AppTheme.electricBlue,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                )),
              ],
            ],
          ),
          if (habit.streakBonus > 0)
            Text(
              'Streak Bonus: +${habit.streakBonus} XP/day',
              style: TextStyle(
                color: AppTheme.amberGold.withOpacity(0.8),
                fontSize: 10,
              ),
            ),
        ],
      );
    }
  }

  Widget _buildStreakProgressBar() {
    final nextMilestone = _getNextStreakMilestone(habit.currentStreak);
    final progress = habit.currentStreak / nextMilestone;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Next milestone: $nextMilestone days',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 10,
              ),
            ),
            Text(
              '${habit.currentStreak}/$nextMilestone',
              style: TextStyle(
                color: AppTheme.amberGold,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: AppTheme.darkBg,
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.amberGold,
                    AppTheme.amberGold.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  int _getNextStreakMilestone(int currentStreak) {
    const milestones = [7, 14, 30, 60, 100, 365];
    for (final milestone in milestones) {
      if (currentStreak < milestone) return milestone;
    }
    return ((currentStreak ~/ 365) + 1) * 365;
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
        return const Color(0xFF8B0000); // Dark red
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
          style: TextStyle(color: AppTheme.amberGold),
        ),
        content: Text(
          'This will reverse the ${isDemonTrap ? "penalties" : "rewards"}. Are you sure?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (onUndo != null) onUndo!();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.amberGold),
            child: Text('UNDO'),
          ),
        ],
      ),
    );
  }
}