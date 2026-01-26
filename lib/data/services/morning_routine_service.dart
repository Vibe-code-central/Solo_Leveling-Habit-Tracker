import 'package:flutter/material.dart';
import '../models/user_profile.dart';

/// Service to manage the 2-week morning routine challenge
/// Handles progressive buffs/debuffs based on streaks and misses
class MorningRoutineService {
  // Streak milestones for buffs
  static const int streak3DayMilestone = 3;
  static const int streak7DayMilestone = 7;
  static const int streak14DayMilestone = 14;

  // Miss thresholds for escalating debuffs
  static const int missLevel1 = 1;
  static const int missLevel2 = 2;
  static const int missLevel3 = 3;

  // ═══════════════════════════════════════════════════════════
  // PROGRESSIVE BUFF SYSTEM
  // ═══════════════════════════════════════════════════════════

  /// Get the appropriate buff based on current streak
  static ActiveBuff? getStreakBuff(int currentStreak) {
    if (currentStreak >= streak14DayMilestone) {
      return _getDisciplineMasterBuff();
    } else if (currentStreak >= streak7DayMilestone) {
      return _getWeeklyWarriorBuff();
    } else if (currentStreak >= streak3DayMilestone) {
      return _getMorningMomentumBuff();
    }
    return null;
  }

  static ActiveBuff _getMorningMomentumBuff() {
    return ActiveBuff(
      name: 'Morning Momentum',
      description: '3-day streak! +10% XP gains for 24h',
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
      statModifiers: {'xpMultiplier': 1.10},
    );
  }

  static ActiveBuff _getWeeklyWarriorBuff() {
    return ActiveBuff(
      name: 'Weekly Warrior',
      description: '7-day streak! +20% XP, +10% Willpower for 48h',
      expiresAt: DateTime.now().add(const Duration(hours: 48)),
      statModifiers: {
        'xpMultiplier': 1.20,
        'willpowerMultiplier': 1.10,
      },
    );
  }

  static ActiveBuff _getDisciplineMasterBuff() {
    return ActiveBuff(
      name: 'Discipline Master',
      description: '14-day streak! +30% XP, +15% all stats for 72h',
      expiresAt: DateTime.now().add(const Duration(hours: 72)),
      statModifiers: {
        'xpMultiplier': 1.30,
        'strengthMultiplier': 1.15,
        'agilityMultiplier': 1.15,
        'vitalityMultiplier': 1.15,
        'intelligenceMultiplier': 1.15,
        'senseMultiplier': 1.15,
        'willpowerMultiplier': 1.15,
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // PROGRESSIVE DEBUFF SYSTEM
  // ═══════════════════════════════════════════════════════════

  /// Get the appropriate debuff based on consecutive misses
  static ActiveDebuff getProgressiveDebuff(int consecutiveMisses) {
    if (consecutiveMisses >= missLevel3) {
      return _getDisciplineCollapseDebuff();
    } else if (consecutiveMisses >= missLevel2) {
      return _getMorningFogDebuff();
    } else {
      return _getLightSluggishDebuff();
    }
  }

  static ActiveDebuff _getLightSluggishDebuff() {
    return ActiveDebuff(
      name: 'Light Sluggish',
      description: 'Missed 1 habit. -10% XP gains for 12h',
      expiresAt: DateTime.now().add(const Duration(hours: 12)),
      statModifiers: {'xpMultiplier': 0.90},
    );
  }

  static ActiveDebuff _getMorningFogDebuff() {
    return ActiveDebuff(
      name: 'Morning Fog',
      description: 'Missed 2 habits! -20% XP, -15% Willpower for 24h',
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
      statModifiers: {
        'xpMultiplier': 0.80,
        'willpowerMultiplier': 0.85,
      },
    );
  }

  static ActiveDebuff _getDisciplineCollapseDebuff() {
    return ActiveDebuff(
      name: 'Discipline Collapse',
      description:
          'Missed 3+ habits! -35% XP, -25% Willpower, -20% Agility for 48h',
      expiresAt: DateTime.now().add(const Duration(hours: 48)),
      statModifiers: {
        'xpMultiplier': 0.65,
        'willpowerMultiplier': 0.75,
        'agilityMultiplier': 0.80,
      },
    );
  }

  // ═══════════════════════════════════════════════════════════
  // WEEK TRACKING
  // ═══════════════════════════════════════════════════════════

  /// Get current week (1 or 2) based on challenge start date
  static int getCurrentWeek(DateTime? challengeStartDate) {
    if (challengeStartDate == null) return 1;

    final daysSinceStart = DateTime.now().difference(challengeStartDate).inDays;
    if (daysSinceStart < 7) return 1;
    return 2;
  }

  /// Get wake time target based on current week
  static String getWakeTimeTarget(int currentWeek) {
    return currentWeek == 1 ? '6:15 AM' : '5:45 AM';
  }

  /// Get TimeOfDay for wake target
  static TimeOfDay getWakeTimeOfDay(int currentWeek) {
    return currentWeek == 1
        ? const TimeOfDay(hour: 6, minute: 15)
        : const TimeOfDay(hour: 5, minute: 45);
  }

  // ═══════════════════════════════════════════════════════════
  // MOTIVATIONAL MESSAGES
  // ═══════════════════════════════════════════════════════════

  /// Get motivational message based on streak
  static String getMotivationalMessage(int currentStreak, int totalMisses) {
    if (currentStreak >= 14) {
      return '「DISCIPLINE MASTER」You have conquered your mornings!';
    } else if (currentStreak >= 7) {
      return '「WEEKLY WARRIOR」One full week! Keep the momentum!';
    } else if (currentStreak >= 3) {
      return '「RISING HUNTER」3-day streak! The habit is forming.';
    } else if (currentStreak > 0) {
      return 'Day $currentStreak complete. ${3 - currentStreak} more for your first buff!';
    } else if (totalMisses > 0) {
      return 'Reset your streak. Tomorrow is a new day. ARISE.';
    } else {
      return 'Begin your transformation. Complete all 5 habits today.';
    }
  }

  /// Get next milestone info
  static String getNextMilestoneInfo(int currentStreak) {
    if (currentStreak >= 14) {
      return 'Maximum streak buff achieved! Maintain it.';
    } else if (currentStreak >= 7) {
      return '${14 - currentStreak} days to Discipline Master buff!';
    } else if (currentStreak >= 3) {
      return '${7 - currentStreak} days to Weekly Warrior buff!';
    } else {
      return '${3 - currentStreak} days to Morning Momentum buff!';
    }
  }

  // ═══════════════════════════════════════════════════════════
  // PROGRESS CALCULATION
  // ═══════════════════════════════════════════════════════════

  /// Calculate overall completion rate for the 14-day challenge
  static double getChallengeCompletionRate(int totalCompletedDays) {
    return (totalCompletedDays / 14.0).clamp(0.0, 1.0);
  }

  /// Check if all morning habits are complete for today
  static bool areAllMorningHabitsComplete(List<bool> habitCompletions) {
    return habitCompletions.every((complete) => complete);
  }

  /// Count completed morning habits today
  static int countCompletedHabits(List<bool> habitCompletions) {
    return habitCompletions.where((complete) => complete).length;
  }
}
