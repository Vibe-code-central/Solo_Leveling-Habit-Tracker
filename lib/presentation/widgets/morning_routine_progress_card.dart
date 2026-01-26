import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solo_leveling/core/theme/app_theme.dart';
import 'package:solo_leveling/data/models/habit.dart';
import 'package:solo_leveling/data/services/morning_routine_service.dart';
import 'package:solo_leveling/presentation/providers/habit_provider.dart';

/// Widget showing morning routine challenge progress
/// Displays current week, streak, active buffs/debuffs, and motivation
class MorningRoutineProgressCard extends StatelessWidget {
  const MorningRoutineProgressCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        final morningHabits = _getMorningHabits(habitProvider);
        final completedToday =
            morningHabits.where((h) => h.isCompletedToday).length;
        final totalHabits = morningHabits.length;
        final minStreak = _getMinStreak(morningHabits);
        final currentWeek = _getCurrentWeek(morningHabits);

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.cardBg,
                AppTheme.primaryPurple.withOpacity(0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _getBorderColor(completedToday, totalHabits),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _getBorderColor(completedToday, totalHabits)
                    .withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                _buildHeader(currentWeek),
                const SizedBox(height: 12),

                // Progress bar
                _buildProgressBar(completedToday, totalHabits),
                const SizedBox(height: 16),

                // Stats row
                _buildStatsRow(completedToday, totalHabits, minStreak),
                const SizedBox(height: 12),

                // Motivation message
                _buildMotivationMessage(minStreak, completedToday, totalHabits),

                // Buff/Debuff indicator
                if (minStreak >= 3 || completedToday < totalHabits) ...[
                  const SizedBox(height: 12),
                  _buildBuffDebuffIndicator(
                      minStreak, completedToday, totalHabits),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  List<Habit> _getMorningHabits(HabitProvider provider) {
    return provider.goodHabits
        .where((h) => h.id.startsWith('morning_'))
        .toList();
  }

  int _getMinStreak(List<Habit> habits) {
    if (habits.isEmpty) return 0;
    return habits.map((h) => h.currentStreak).reduce((a, b) => a < b ? a : b);
  }

  int _getCurrentWeek(List<Habit> habits) {
    if (habits.isEmpty) return 1;
    final oldestHabit =
        habits.reduce((a, b) => a.createdAt.isBefore(b.createdAt) ? a : b);
    return MorningRoutineService.getCurrentWeek(oldestHabit.createdAt);
  }

  Color _getBorderColor(int completed, int total) {
    if (completed == total && total > 0) return AppTheme.emeraldGreen;
    if (completed > 0) return AppTheme.amberGold;
    return AppTheme.primaryPurple;
  }

  Widget _buildHeader(int currentWeek) {
    final wakeTarget = MorningRoutineService.getWakeTimeTarget(currentWeek);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🌅 MORNING ROUTINE',
              style: TextStyle(
                fontFamily: 'Orbitron',
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryPurple,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Week $currentWeek • Target: $wakeTarget',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryPurple.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.5)),
          ),
          child: Text(
            'WEEK $currentWeek',
            style: TextStyle(
              fontFamily: 'Rajdhani',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryPurple,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(int completed, int total) {
    final progress = total > 0 ? completed / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Today\'s Progress',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
              ),
            ),
            Text(
              '$completed / $total habits',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: _getBorderColor(completed, total),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: Colors.grey[800],
            valueColor: AlwaysStoppedAnimation<Color>(
              _getBorderColor(completed, total),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(int completed, int total, int streak) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          icon: Icons.check_circle,
          value: '$completed',
          label: 'Done',
          color: AppTheme.emeraldGreen,
        ),
        _buildStatItem(
          icon: Icons.pending,
          value: '${total - completed}',
          label: 'Pending',
          color: AppTheme.amberGold,
        ),
        _buildStatItem(
          icon: Icons.local_fire_department,
          value: '$streak',
          label: 'Streak',
          color: streak >= 7 ? Colors.orange : AppTheme.primaryPurple,
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMotivationMessage(int streak, int completed, int total) {
    final message = MorningRoutineService.getMotivationalMessage(
      streak,
      total - completed,
    );

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.darkBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            completed == total ? Icons.emoji_events : Icons.tips_and_updates,
            color: completed == total
                ? AppTheme.amberGold
                : AppTheme.primaryPurple,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.textPrimary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBuffDebuffIndicator(int streak, int completed, int total) {
    // Show buff if streak >= 3
    if (streak >= 3) {
      final buffName = streak >= 14
          ? 'Discipline Master'
          : streak >= 7
              ? 'Weekly Warrior'
              : 'Morning Momentum';
      final buffColor = streak >= 14
          ? Colors.amber
          : streak >= 7
              ? Colors.orange
              : AppTheme.emeraldGreen;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: buffColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: buffColor.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(Icons.arrow_upward, color: buffColor, size: 18),
            const SizedBox(width: 8),
            Text(
              'ACTIVE: $buffName',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: buffColor,
              ),
            ),
            const Spacer(),
            Text(
              MorningRoutineService.getNextMilestoneInfo(streak),
              style: TextStyle(
                fontSize: 10,
                color: buffColor.withOpacity(0.8),
              ),
            ),
          ],
        ),
      );
    }

    // Show warning if habits incomplete
    if (completed < total && total > 0) {
      final pending = total - completed;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.crimsonRed.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.crimsonRed.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber, color: AppTheme.crimsonRed, size: 18),
            const SizedBox(width: 8),
            Text(
              '$pending habit${pending > 1 ? 's' : ''} remaining!',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppTheme.crimsonRed,
              ),
            ),
            const Spacer(),
            Text(
              'Complete to avoid debuff',
              style: TextStyle(
                fontSize: 10,
                color: AppTheme.crimsonRed.withOpacity(0.8),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
