import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:solo_leveling/data/models/achievement.dart';
import '../../data/models/habit.dart';
import '../../data/models/user_profile.dart';
import '../../data/services/notification_service.dart';
import 'user_provider.dart';

class HabitProvider extends ChangeNotifier {
  List<Habit> _habits = [];
  bool _isLoading = false;

  // Auto-penalty tracking (Persisted in 'settings' box)
  Box? _settingsBox;
  late Box<Habit> _habitBox;

  List<Habit> get habits => _habits;
  List<Habit> get goodHabits =>
      _habits.where((h) => h.type == HabitType.good && h.isActive).toList();
  List<Habit> get badHabits =>
      _habits.where((h) => h.type == HabitType.bad && h.isActive).toList();
  bool get isLoading => _isLoading;

  bool get redemptionRequired {
    if (_settingsBox == null) return false;
    // Check if redemption is required TODAY
    final storedVal = _settingsBox!
        .get('redemption_required_${_getTodayKey()}', defaultValue: false);
    return storedVal;
  }

  // Check if today is the "Setup Day" (First day of use)
  bool get isSetupDay {
    if (_settingsBox == null) return false;
    final setupEpoch = _settingsBox!.get('setup_date_epoch', defaultValue: 0);
    if (setupEpoch == 0) return false; // Should not happen after init

    final setupDate = DateTime.fromMillisecondsSinceEpoch(setupEpoch);
    final now = DateTime.now();

    return setupDate.year == now.year &&
        setupDate.month == now.month &&
        setupDate.day == now.day;
  }

  // Get morning habits only
  List<Habit> get morningHabits => _habits
      .where((h) => h.id.startsWith('morning_') && h.type == HabitType.good)
      .toList();

  // Check if all morning habits are complete
  bool get allMorningHabitsComplete =>
      morningHabits.isNotEmpty &&
      morningHabits.every((h) => h.isCompletedToday);

  Future<void> loadHabits() async {
    _isLoading = true;
    notifyListeners();

    try {
      _habitBox = Hive.box<Habit>('habits');
      _settingsBox = Hive.box('settings'); // Opened in main.dart

      if (_habitBox.isEmpty) {
        await _initializeDefaultHabits();
      } else {
        _habits = _habitBox.values.toList();
      }

      // Initial check for time travel / reset
      await _checkDailyResetAndGhostDays();
    } catch (e) {
      debugPrint('Error loading habits: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _getTodayKey() {
    final now = DateTime.now();
    return '${now.year}_${now.month}_${now.day}';
  }

  String _getDateKey(DateTime date) {
    return '${date.year}_${date.month}_${date.day}';
  }

  // 🛡️ ANTI-CHEAT & DAILY RESET LOGIC
  Future<void> _checkDailyResetAndGhostDays() async {
    if (_settingsBox == null) return;

    final now = DateTime.now();

    // 🕰️ TIME TRAVEL CHECK
    final lastKnownTimeEpoch =
        _settingsBox!.get('last_known_time_epoch', defaultValue: 0);
    if (now.millisecondsSinceEpoch < lastKnownTimeEpoch - 60000) {
      // 1 min buffer
      debugPrint(
          "TIME TRAVEL DETECTED! Current: $now, Last: ${DateTime.fromMillisecondsSinceEpoch(lastKnownTimeEpoch)}");
    }
    await _settingsBox!
        .put('last_known_time_epoch', now.millisecondsSinceEpoch);

    final lastCheckEpoch =
        _settingsBox!.get('last_penalty_check_epoch', defaultValue: 0);
    if (lastCheckEpoch == 0) {
      // First run ever, set baseline
      await _settingsBox!
          .put('last_penalty_check_epoch', now.millisecondsSinceEpoch);
    }
  }

  /// AUTOMATIC PENALTY CHECK - Call this periodically or on app resume
  Future<void> checkAndApplyAutomaticPenalties(
      UserProvider userProvider) async {
    if (_settingsBox == null) return;

    // 🛡️ SETUP DAY PROTECTION
    // If this is the first day (Setup Day), DO NOT apply any penalties.
    // Give the user time to set up their habits and get ready for tomorrow.
    if (isSetupDay) {
      debugPrint("SETUP DAY: Penalties are disabled for today.");
      return;
    }

    final now = DateTime.now();
    final hour = now.hour;
    final todayKey = _getTodayKey();

    // 🕰️ TIME TRAVEL UPDATE
    await _settingsBox!
        .put('last_known_time_epoch', now.millisecondsSinceEpoch);

    // ═══════════════════════════════════════════════════════════
    // 1. RETROACTIVE PENALTY CHECKS (Ghost Days & Sleep-Through)
    // ═══════════════════════════════════════════════════════════
    final lastCheckEpoch =
        _settingsBox!.get('last_penalty_check_epoch', defaultValue: 0);

    if (lastCheckEpoch != 0) {
      final lastCheckDate = DateTime.fromMillisecondsSinceEpoch(lastCheckEpoch);
      final lastCheckKey = _getDateKey(lastCheckDate);

      // If today is different from last check
      if (todayKey != lastCheckKey) {
        // A. SLEEP-THROUGH CHECK: Did we leave debt yesterday?
        final wasRedemptionRequired = _settingsBox!
            .get('redemption_required_$lastCheckKey', defaultValue: false);
        final wasRedemptionDone = _settingsBox!
            .get('redemption_done_$lastCheckKey', defaultValue: false);

        if (wasRedemptionRequired && !wasRedemptionDone) {
          // Check if we already punished for this sleep-through (to avoid loop)
          final sleepThroughPunished = _settingsBox!
              .get('sleep_through_punished_$lastCheckKey', defaultValue: false);

          if (!sleepThroughPunished) {
            debugPrint("SLEEP-THROUGH DETECTED for $lastCheckKey");
            await _applyShadowExecutionPenalty(userProvider);
            await NotificationService.showPenaltyNotification(
                'SLEEP-THROUGH EXECUTION', 250);
            await _settingsBox!
                .put('sleep_through_punished_$lastCheckKey', true);
          }
        }

        // B. GHOST DAY CHECK: Did we skip entire intermediate days?
        // Difference in days. If I checked on 1st, and today is 3rd, diff is 2. (Skipped 2nd).
        // Using midnight-normalized dates for correct day difference
        final lastDateMidnight = DateTime(
            lastCheckDate.year, lastCheckDate.month, lastCheckDate.day);
        final todayMidnight = DateTime(now.year, now.month, now.day);
        final daysDiff = todayMidnight.difference(lastDateMidnight).inDays;

        if (daysDiff > 1) {
          // Missed days exist
          final ghostDays = daysDiff - 1;

          // Check if already punished for these ghost days (basic check)
          final lastGhostCheck =
              _settingsBox!.get('last_ghost_check_epoch', defaultValue: 0);

          if (now.millisecondsSinceEpoch - lastGhostCheck > 1000 * 60 * 60) {
            // Don't spam
            debugPrint("GHOST DAYS DETECTED: $ghostDays missed days");

            // STRICT PENALTY: 300 Damage + XP Loss per day
            final totalPenaltyXP = ghostDays * 300;
            final totalDamage = ghostDays * 100;

            if (totalPenaltyXP > 0) {
              await userProvider.loseXP(totalPenaltyXP,
                  source: 'Ghost Days ($ghostDays) Penalty');
              await userProvider.takeDamage(totalDamage);
              await NotificationService.showPenaltyNotification(
                  'GHOST PENALTY', totalPenaltyXP);
              await _settingsBox!
                  .put('last_ghost_check_epoch', now.millisecondsSinceEpoch);
            }
          }
        }
      }
    }

    // Update last check time
    await _settingsBox!
        .put('last_penalty_check_epoch', now.millisecondsSinceEpoch);

    // ═══════════════════════════════════════════════════════════
    // 2. TODAY'S 10 AM CHECK: Morning Incomplete
    // ═══════════════════════════════════════════════════════════
    final morningPenaltyApplied = _settingsBox!
        .get('morning_penalty_applied_$todayKey', defaultValue: false);

    if (hour >= 10 && !morningPenaltyApplied && !allMorningHabitsComplete) {
      await _applyMorningIncompletePenalty(userProvider);

      await _settingsBox!.put('morning_penalty_applied_$todayKey', true);
      await _settingsBox!.put('redemption_required_$todayKey', true);
      notifyListeners();
    }

    // ═══════════════════════════════════════════════════════════
    // 3. TODAY'S 10 PM CHECK: Shadow Execution
    // ═══════════════════════════════════════════════════════════
    final redemptionRequired =
        _settingsBox!.get('redemption_required_$todayKey', defaultValue: false);
    final redemptionDone =
        _settingsBox!.get('redemption_done_$todayKey', defaultValue: false);

    // Sync consistency
    final redemptionHabit = _habits.firstWhere(
        (h) => h.id == 'evening_redemption_pushups',
        orElse: () => _habits.first);
    final isHabitDone = redemptionHabit.isCompletedToday;

    if (isHabitDone && !redemptionDone) {
      await _settingsBox!.put('redemption_done_$todayKey', true);
    }

    // If deadline passed, redemption needed, and NOT done
    if (hour >= 22 && redemptionRequired && !isHabitDone) {
      // Check if already executed today
      final executionApplied = _settingsBox!
          .get('shadow_execution_applied_$todayKey', defaultValue: false);

      if (!executionApplied) {
        await _applyShadowExecutionPenalty(userProvider);
        await _settingsBox!.put('shadow_execution_applied_$todayKey', true);
      }
    }
  }

  /// Apply Morning Incomplete penalty automatically
  Future<void> _applyMorningIncompletePenalty(UserProvider userProvider) async {
    // XP Penalty
    await userProvider.loseXP(50, source: 'Morning Incomplete - Auto Penalty');

    // Stat Penalties
    await userProvider.updateStats({'willpower': -2, 'agility': -1});

    // HP Damage
    await userProvider.takeDamage(50);

    // Apply debuff
    final debuff = ActiveDebuff(
      name: 'Morning Fog',
      description:
          'AUTO-APPLIED: Missed 10 AM deadline. -20% XP, -15% Willpower for 24h',
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
      statModifiers: {
        'xpMultiplier': 0.80,
        'willpowerMultiplier': 0.85,
      },
    );
    await userProvider.addDebuff(debuff);

    // Show notification
    await NotificationService.showPenaltyNotification(
      'MORNING INCOMPLETE',
      50,
    );
  }

  /// Apply Shadow Execution penalty automatically - DEVASTATING
  Future<void> _applyShadowExecutionPenalty(UserProvider userProvider) async {
    // Massive XP Penalty
    await userProvider.loseXP(250, source: 'SHADOW EXECUTION - Auto Penalty');

    // Stat Penalties
    await userProvider.updateStats({
      'willpower': -5,
      'strength': -3,
      'agility': -2,
      'vitality': -2,
    });

    // HP & MP Damage
    await userProvider.takeDamage(300);
    await userProvider.consumeMP(200);

    // Apply devastating debuff
    final debuff = ActiveDebuff(
      name: "Failure's Mark",
      description:
          '💀 SHADOW EXECUTED. -50% XP, -30% all stats for 72h. No escape.',
      expiresAt: DateTime.now().add(const Duration(hours: 72)),
      statModifiers: {
        'xpMultiplier': 0.50,
        'strengthMultiplier': 0.70,
        'agilityMultiplier': 0.70,
        'vitalityMultiplier': 0.70,
        'intelligenceMultiplier': 0.70,
        'senseMultiplier': 0.70,
        'willpowerMultiplier': 0.70,
      },
    );
    await userProvider.addDebuff(debuff);

    // Show notification
    await NotificationService.showPenaltyNotification(
      'SHADOW EXECUTION',
      250,
    );
  }

  Future<void> _initializeDefaultHabits() async {
    _habits = Habit.getDefaultHabits();
    await _habitBox.clear();
    for (int i = 0; i < _habits.length; i++) {
      await _habitBox.put(i, _habits[i]);
    }

    // Save SETUP DATE (Today)
    if (_settingsBox != null) {
      await _settingsBox!
          .put('setup_date_epoch', DateTime.now().millisecondsSinceEpoch);
    }
  }

  Future<void> completeHabit(String habitId, UserProvider userProvider) async {
    final habitIndex = _habits.indexWhere((h) => h.id == habitId);
    if (habitIndex == -1) return;

    final habit = _habits[habitIndex];

    // Prevent double completion
    if (habit.isCompletedToday) return;

    habit.markCompleted();

    // Apply rewards
    final totalXP = habit.getTotalXPReward();
    await userProvider.gainXP(totalXP, source: 'Habit: ${habit.name}');

    if (habit.statRewards.isNotEmpty) {
      await userProvider.updateStats(habit.statRewards);
    }

    // Check for streak achievements
    _checkStreakAchievements(habit, userProvider);

    await _saveHabits();
    notifyListeners();
  }

  Future<void> uncompleteHabit(
      String habitId, UserProvider userProvider) async {
    final habitIndex = _habits.indexWhere((h) => h.id == habitId);
    if (habitIndex == -1) return;

    final habit = _habits[habitIndex];

    if (!habit.isCompletedToday) return;

    // Remove rewards
    final totalXP = habit.getTotalXPReward();
    await userProvider.loseXP(totalXP, source: 'Undo: ${habit.name}');

    if (habit.statRewards.isNotEmpty) {
      final negativeRewards = <String, int>{};
      habit.statRewards.forEach((stat, reward) {
        negativeRewards[stat] = -reward;
      });
      await userProvider.updateStats(negativeRewards);
    }

    habit.unmarkCompleted();

    await _saveHabits();
    notifyListeners();
  }

  Future<void> failHabit(String habitId, UserProvider userProvider) async {
    final habitIndex = _habits.indexWhere((h) => h.id == habitId);
    if (habitIndex == -1) return;

    final habit = _habits[habitIndex];

    // Prevent double failure
    if (habit.isFailedToday) return;

    habit.markFailed();

    // Apply penalties
    if (habit.type == HabitType.bad) {
      final totalXPPenalty = habit.getTotalXPPenalty();
      await userProvider.loseXP(totalXPPenalty,
          source: 'Failed: ${habit.name}');

      if (habit.statPenalties.isNotEmpty) {
        final negativePenalties = <String, int>{};
        habit.statPenalties.forEach((stat, penalty) {
          negativePenalties[stat] = -penalty;
        });
        await userProvider.updateStats(negativePenalties);
      }

      if (habit.hpDamage > 0) {
        await userProvider.takeDamage(habit.hpDamage);
      }

      if (habit.mpDrain > 0) {
        await userProvider.consumeMP(habit.mpDrain);
      }

      // Apply debuff if specified
      if (habit.debuffName != null) {
        await _applyDebuff(habit, userProvider);
      }

      await NotificationService.showPenaltyNotification(
          habit.name, totalXPPenalty);
    }

    // Check for penalty zone
    await _checkPenaltyZone(userProvider);

    await _saveHabits();
    notifyListeners();
  }

  Future<void> unfailHabit(String habitId, UserProvider userProvider) async {
    final habitIndex = _habits.indexWhere((h) => h.id == habitId);
    if (habitIndex == -1) return;

    final habit = _habits[habitIndex];

    if (!habit.isFailedToday) return;

    // Reverse penalties
    if (habit.type == HabitType.bad) {
      final totalXPPenalty = habit.getTotalXPPenalty();
      await userProvider.gainXP(totalXPPenalty, source: 'Undo: ${habit.name}');

      if (habit.statPenalties.isNotEmpty) {
        await userProvider.updateStats(habit.statPenalties);
      }

      if (habit.hpDamage > 0) {
        userProvider.userProfile!.heal(habit.hpDamage);
        await userProvider.userProfile!.save();
      }

      if (habit.mpDrain > 0) {
        userProvider.userProfile!.restoreMP(habit.mpDrain);
        await userProvider.userProfile!.save();
      }

      // Remove debuff when unfailing
      if (habit.debuffName != null) {
        userProvider.userProfile!.activeDebuffs.removeWhere(
          (d) => d.name == habit.debuffName,
        );
        await userProvider.userProfile!.save();
      }
    }

    habit.unmarkFailed();

    await _saveHabits();
    notifyListeners();
  }

  Future<void> _applyDebuff(Habit habit, UserProvider userProvider) async {
    final debuff = ActiveDebuff(
      name: habit.debuffName!,
      description: _getDebuffDescription(habit.debuffName!),
      expiresAt: DateTime.now().add(_getDebuffDuration(habit.debuffName!)),
      statModifiers: _getDebuffModifiers(habit.debuffName!),
    );

    await userProvider.addDebuff(debuff);
  }

  String _getDebuffDescription(String debuffName) {
    switch (debuffName) {
      case "Demon's Grip":
        return '25% XP reduction for 36h';
      case 'Time Void':
        return 'Lose 1 day of progress (30h)';
      case 'Weakened State':
        return '-20% Strength for 36h';
      case 'Sluggish Start':
        return '-15% XP for 24h';
      case 'Mounting Dread':
        return 'Anxiety meter increases (24h)';
      case 'Mind Fog':
        return '-10% Intelligence for 24h';
      case 'Corrupted State':
        return 'Severe corruption (7 days)';
      case 'Entertainment Haze':
        return '-20% productivity (36h)';
      case 'Disorganized':
        return 'Next day planning disabled (24h)';
      case 'Fatigue':
        return '-20% all stats for 30h';
      // Morning Routine Debuffs
      case 'Light Sluggish':
        return 'Missed morning habit. -10% XP for 12h';
      case 'Morning Fog':
        return 'Missed 2 habits! -20% XP, -15% Willpower for 24h';
      case 'Discipline Collapse':
        return 'Missed 3+ habits! -35% XP, -25% Willpower for 48h';
      // NUCLEAR OPTION
      case "Failure's Mark":
        return '💀 SHADOW EXECUTED. -50% all gains, -30% all stats for 72h';
      default:
        return 'Negative effect applied';
    }
  }

  Duration _getDebuffDuration(String debuffName) {
    switch (debuffName) {
      case "Demon's Grip":
        return const Duration(hours: 36);
      case 'Sluggish Start':
        return const Duration(hours: 24);
      case 'Fatigue':
        return const Duration(hours: 30);
      case 'Weakened State':
        return const Duration(hours: 36);
      case 'Entertainment Haze':
        return const Duration(hours: 36);
      case 'Mind Fog':
        return const Duration(hours: 24);
      case 'Disorganized':
        return const Duration(hours: 24);
      case 'Time Void':
        return const Duration(hours: 30);
      case 'Mounting Dread':
        return const Duration(hours: 24);
      case 'Corrupted State':
        return const Duration(days: 7);
      // Morning Routine Debuffs - Progressive durations
      case 'Light Sluggish':
        return const Duration(hours: 12);
      case 'Morning Fog':
        return const Duration(hours: 24);
      case 'Discipline Collapse':
        return const Duration(hours: 48);
      // NUCLEAR OPTION - 3 full days
      case "Failure's Mark":
        return const Duration(hours: 72);
      default:
        return const Duration(hours: 24);
    }
  }

  Map<String, double> _getDebuffModifiers(String debuffName) {
    switch (debuffName) {
      case "Demon's Grip":
        return {'xpMultiplier': 0.75};
      case 'Weakened State':
        return {'strengthMultiplier': 0.8};
      case 'Sluggish Start':
        return {'xpMultiplier': 0.85};
      case 'Mind Fog':
        return {'intelligenceMultiplier': 0.9};
      case 'Entertainment Haze':
        return {'productivityMultiplier': 0.8};
      case 'Fatigue':
        return {
          'strengthMultiplier': 0.8,
          'agilityMultiplier': 0.8,
          'vitalityMultiplier': 0.8,
          'intelligenceMultiplier': 0.8,
          'senseMultiplier': 0.8,
          'willpowerMultiplier': 0.8,
        };
      // Morning Routine Debuffs - Progressive penalties
      case 'Light Sluggish':
        return {'xpMultiplier': 0.90};
      case 'Morning Fog':
        return {
          'xpMultiplier': 0.80,
          'willpowerMultiplier': 0.85,
        };
      case 'Discipline Collapse':
        return {
          'xpMultiplier': 0.65,
          'willpowerMultiplier': 0.75,
          'agilityMultiplier': 0.80,
        };
      // NUCLEAR OPTION - Devastating penalties for 3 days
      case "Failure's Mark":
        return {
          'xpMultiplier': 0.50, // HALF XP gains
          'strengthMultiplier': 0.70,
          'agilityMultiplier': 0.70,
          'vitalityMultiplier': 0.70,
          'intelligenceMultiplier': 0.70,
          'senseMultiplier': 0.70,
          'willpowerMultiplier': 0.70,
        };
      default:
        return {};
    }
  }

  void _checkStreakAchievements(Habit habit, UserProvider userProvider) {
    final achievements = userProvider.achievements;

    for (final achievement in achievements) {
      if (!achievement.isUnlocked &&
          achievement.category == AchievementCategory.flameKeeper) {
        if (habit.currentStreak >= achievement.targetValue) {
          achievement.updateProgress(habit.currentStreak);
        }
      }
    }
  }

  Future<void> _checkPenaltyZone(UserProvider userProvider) async {
    // Basic logic for Penalty Zone (optional future feature)
  }

  Future<void> _saveHabits() async {
    for (int i = 0; i < _habits.length; i++) {
      await _habitBox.put(i, _habits[i]);
    }
  }

  // ═══════════════════════════════════════════════════════════
  // STATS & HELPERS (Restored)
  // ═══════════════════════════════════════════════════════════

  Future<void> addCustomHabit(Habit habit) async {
    _habits.add(habit);
    await _habitBox.add(habit);
    notifyListeners();
  }

  double getTodayCompletionRate() {
    if (goodHabits.isEmpty) return 0.0;
    final completedCount = goodHabits.where((h) => h.isCompletedToday).length;
    return completedCount / goodHabits.length;
  }

  int getTodayXPEarned() {
    return goodHabits
        .where((h) => h.isCompletedToday)
        .fold(0, (sum, h) => sum + h.getTotalXPReward());
  }

  int getTodayXPLost() {
    return badHabits
        .where((h) => h.isFailedToday)
        .fold(0, (sum, h) => sum + h.getTotalXPPenalty());
  }

  Map<String, int> getWeeklyStats() {
    final now = DateTime.now();
    int completions = 0;
    int failures = 0;

    // Calculate stats for last 7 days
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));

      // Good habits completed
      for (final habit in goodHabits) {
        if (habit.completedDates.any((d) =>
            d.year == date.year &&
            d.month == date.month &&
            d.day == date.day)) {
          completions++;
        }
      }

      // Failures (Bad habits triggered)
      for (final habit in badHabits) {
        if (habit.completedDates.any((d) =>
            d.year == date.year &&
            d.month == date.month &&
            d.day == date.day)) {
          failures++;
        }
      }
    }

    return {'completions': completions, 'failures': failures};
  }

  Future<void> resetHabits() async {
    // 1. Clear Settings (Resets Setup Day, Time Travel checks, etc.)
    if (_settingsBox != null) {
      await _settingsBox!.clear();
    }

    // 2. Clear Habits
    await _habitBox.clear();
    _habits.clear();

    // 3. Re-initialize defaults (New setup day will be set)
    await _initializeDefaultHabits();

    notifyListeners();
  }
}
