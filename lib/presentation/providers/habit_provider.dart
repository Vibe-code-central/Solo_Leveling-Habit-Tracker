import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:solo_leveling/data/models/achievement.dart';
import 'package:solo_leveling/data/models/weekly_boss.dart';
import 'package:solo_leveling/data/models/debuff.dart';
import '../../data/models/habit.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/user_inventory.dart'; // NEW: For TransactionType
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

      // MIGRATION: Ensure 'daily_reading' habit exists for existing users
      final hasReadingHabit = _habits.any((h) => h.id == 'daily_reading');
      if (!hasReadingHabit && _habitBox.isNotEmpty) {
        final readingHabit =
            Habit.getDefaultHabits().firstWhere((h) => h.id == 'daily_reading');
        _habits.add(readingHabit);
        await _habitBox.add(readingHabit);
        debugPrint("MIGRATION: Added missing 'daily_reading' habit.");
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

          // 🛡️ FIX #5: Check if already punished for THIS SPECIFIC date range
          // Use date key instead of time-based cooldown to prevent edge cases
          final lastGhostCheckKey =
              _settingsBox!.get('last_ghost_check_date_key', defaultValue: '');

          if (lastGhostCheckKey != lastCheckKey) {
            debugPrint("GHOST DAYS DETECTED: $ghostDays missed days");

            // REDUCED PENALTY: 25 XP + 10 HP per day
            final totalPenaltyXP = ghostDays * 25;
            final totalDamage = ghostDays * 10;

            if (totalPenaltyXP > 0) {
              await userProvider.loseXP(totalPenaltyXP,
                  source: 'Ghost Days ($ghostDays) Penalty');
              await userProvider.takeDamage(totalDamage);
              await NotificationService.showPenaltyNotification(
                  'GHOST PENALTY', totalPenaltyXP);
              await _settingsBox!
                  .put('last_ghost_check_date_key', lastCheckKey);
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

    // 🛡️ FIX #4: Validate redemption habit exists - fail loudly instead of fallback
    final redemptionHabitIndex =
        _habits.indexWhere((h) => h.id == 'evening_redemption_pushups');

    bool isHabitDone = false;

    if (redemptionHabitIndex == -1) {
      debugPrint(
          'ERROR: Redemption habit not found! This should never happen.');
      // If redemption habit is missing, assume redemption is NOT done
      // This prevents users from deleting the habit to bypass Shadow Execution
      await _settingsBox!.put('redemption_done_$todayKey', false);
      isHabitDone = false;
    } else {
      final redemptionHabit = _habits[redemptionHabitIndex];
      isHabitDone = redemptionHabit.isCompletedToday;

      if (isHabitDone && !redemptionDone) {
        await _settingsBox!.put('redemption_done_$todayKey', true);
      }
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

    // 🔄 DAILY COUNTER RESET: Reset all counter-based habits at day change
    if (lastCheckEpoch != 0) {
      final lastCheckDate = DateTime.fromMillisecondsSinceEpoch(lastCheckEpoch);
      final lastCheckKey = _getDateKey(lastCheckDate);

      if (todayKey != lastCheckKey) {
        // New day detected, reset counters
        for (var habit in _habits) {
          if (habit.isCounterBased) {
            habit.currentCount = 0;
          }
        }
        await _saveHabits();
      }
    }
  }

  /// Apply Morning Incomplete penalty automatically
  Future<void> _applyMorningIncompletePenalty(UserProvider userProvider) async {
    // XP Penalty
    await userProvider.loseXP(5, source: 'Morning Incomplete - Auto Penalty');

    // Stat Penalties removed as per request to minimize
    // await userProvider.updateStats({'willpower': -3, 'endurance': -2});

    // HP Damage
    await userProvider.takeDamage(5);

    // Apply debuff
    // Debuff removed as per request
    // final debuff = ActiveDebuff(...)
    // await userProvider.addDebuff(debuff);

    // Show notification
    await NotificationService.showPenaltyNotification(
      'MORNING INCOMPLETE',
      50,
    );
  }

  /// Apply Shadow Execution penalty automatically - DEVASTATING
  Future<void> _applyShadowExecutionPenalty(UserProvider userProvider) async {
    // Reduced XP Penalty
    await userProvider.loseXP(25, source: 'SHADOW EXECUTION - Auto Penalty');

    // Reduced Stat Penalties
    await userProvider.updateStats({
      'willpower': -1,
    });

    // Reduced HP & MP Damage
    await userProvider.takeDamage(30);
    await userProvider.consumeMP(20);

    // Apply devastating debuff
    // Debuff removed as per request
    // final debuff = ActiveDebuff(...)
    // await userProvider.addDebuff(debuff);

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

  Future<bool> completeHabit(String habitId, UserProvider userProvider) async {
    final habitIndex = _habits.indexWhere((h) => h.id == habitId);
    if (habitIndex == -1) return false;

    final habit = _habits[habitIndex];

    // Prevent double completion
    if (habit.isCompletedToday) return false;

    // 🛡️ ANTI-CHEAT: STRICT Time Travel Check - BLOCKS ALL ACTIONS
    if (_settingsBox != null) {
      final now = DateTime.now();
      final lastKnownTimeEpoch =
          _settingsBox!.get('last_known_time_epoch', defaultValue: 0);

      if (lastKnownTimeEpoch > 0 &&
          now.millisecondsSinceEpoch < lastKnownTimeEpoch - 120000) {
        await _settingsBox!.put('account_locked_time_anomaly', true);
        throw Exception(
            '⏰ TIME ANOMALY DETECTED!\n\nSystem time moved backwards.\n'
            'Please ensure your device time is correct before continuing.\n\n'
            'Detected: ${DateTime.fromMillisecondsSinceEpoch(lastKnownTimeEpoch)} → $now');
      }

      await _settingsBox!
          .put('last_known_time_epoch', now.millisecondsSinceEpoch);
    }

    // 🎯 Route bad habits to tier-based completion
    if (habit.type == HabitType.bad) {
      return await _completeBadHabit(habit, userProvider);
    }

    // Good habit completion (normal flow)
    habit.markCompleted();

    final totalXP = habit.getTotalXPReward();
    final leveledUp =
        await userProvider.gainXP(totalXP, source: 'Habit: ${habit.name}');

    if (habit.statRewards.isNotEmpty) {
      await userProvider.updateStats(habit.statRewards);
    }

    // 💰 NEW: Award Gold for completing habit
    final goldReward = habit.totalGoldReward;
    if (goldReward > 0) {
      await userProvider.earnGold(
        goldReward,
        'Habit: ${habit.name}',
        TransactionType.habitCompletion,
      );
    }

    _checkStreakAchievements(habit, userProvider);

    await _saveHabits();
    notifyListeners();
    return leveledUp;
  }

  // 💀 BAD HABIT TIER-BASED COMPLETION
  Future<bool> _completeBadHabit(Habit habit, UserProvider userProvider) async {
    final now = DateTime.now();

    // Check if consecutive
    if (habit.lastBadHabitDate != null) {
      final daysSince = now.difference(habit.lastBadHabitDate!).inDays;

      if (daysSince == 1) {
        // Consecutive day - escalate tier
        habit.consecutiveCompletions++;
      } else if (daysSince > 1) {
        // Not consecutive - reset to tier 1
        habit.consecutiveCompletions = 1;
      }
      // Same day would be caught by isCompletedToday check
    } else {
      // First time completing this bad habit
      habit.consecutiveCompletions = 1;
    }

    habit.lastBadHabitDate = now;
    habit.markCompleted();

    final tier = habit.getCurrentTier();

    // Apply tier-based penalties
    final xpLoss = habit.getTierXpPenalty();
    final statLoss = habit.getTierStatPenalties();

    await userProvider.loseXP(xpLoss, source: 'Bad Habit: ${habit.name}');

    if (statLoss.isNotEmpty) {
      // Apply negative stats
      final negativeStats = statLoss.map((k, v) => MapEntry(k, -v));
      await userProvider.updateStats(negativeStats);
    }

    // Apply HP/MP damage
    if (habit.hpDamage > 0) {
      userProvider.userProfile?.currentHP =
          (userProvider.userProfile!.currentHP - habit.hpDamage)
              .clamp(0, userProvider.userProfile!.maxHP);
    }
    if (habit.mpDrain > 0) {
      userProvider.userProfile?.currentMP =
          (userProvider.userProfile!.currentMP - habit.mpDrain)
              .clamp(0, userProvider.userProfile!.maxMP);
    }

    // 7-Day Bad Habit Streak Penalty (-50 XP)
    if (habit.consecutiveCompletions == 7) {
      await userProvider.loseXP(50, source: '7-Day Bad Streak: ${habit.name}');
      await NotificationService.showPenaltyNotification(
          'BAD HABIT STREAK (7 DAYS)', 50);
    }

    // Debuff Logic Removed as per request
    // Lines 473-502 removed.

    await _saveHabits();
    notifyListeners();
    return false; // Bad habits never level up
  }

  Future<void> uncompleteHabit(
      String habitId, UserProvider userProvider) async {
    final habitIndex = _habits.indexWhere((h) => h.id == habitId);
    if (habitIndex == -1) return;

    final habit = _habits[habitIndex];

    if (!habit.isCompletedToday) return;

    // 🛡️ FIX #3: Only allow uncomplete within 2 minutes to prevent timing manipulation
    if (habit.completedDates.isNotEmpty) {
      final lastCompleteTime = habit.completedDates.last;
      final timeSinceComplete = DateTime.now().difference(lastCompleteTime);

      if (timeSinceComplete.inMinutes > 2) {
        throw Exception(
            'Cannot undo habit completion after 2 minutes. This prevents timing manipulation.');
      }
    }

    // Remove rewards
    final totalXP = habit.getTotalXPReward();
    await userProvider.loseXP(totalXP, source: 'Undo: ${habit.name}');

    // 🛡️ SECURITY: Decrement daily XP counter to prevent cap bypass
    userProvider.decrementDailyXP(totalXP);

    // 🛡️ FIX: Deduct Gold on undo (was missing - free gold exploit)
    final goldReward = habit.totalGoldReward;
    if (goldReward > 0) {
      await userProvider.spendGold(goldReward, 'Undo: ${habit.name}');
    }

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

  /// Increment water counter for counter-based habits
  Future<void> incrementWaterCounter(
    String habitId,
    UserProvider userProvider,
  ) async {
    final habitIndex = _habits.indexWhere((h) => h.id == habitId);
    if (habitIndex == -1) return;

    final habit = _habits[habitIndex];

    // Only for counter-based habits
    if (!habit.isCounterBased) return;

    // Check if already at max
    if (habit.currentCount >= habit.maxCount) return;

    // 🛡️ ANTI-CHEAT: Cooldown check to prevent XP farming
    if (habit.minMinutesBetweenIncrements > 0 &&
        habit.lastCounterIncrement != null) {
      final timeSince = DateTime.now().difference(habit.lastCounterIncrement!);
      final minutesRemaining =
          habit.minMinutesBetweenIncrements - timeSince.inMinutes;

      if (minutesRemaining > 0) {
        throw Exception(
            '⏰ Please wait $minutesRemaining more minute${minutesRemaining > 1 ? 's' : ''} before next glass.\n'
            'This prevents XP farming and encourages realistic hydration pacing.');
      }
    }

    // Update cooldown timestamp
    habit.lastCounterIncrement = DateTime.now();
    habit.currentCount++;

    // Award XP per glass immediately
    await userProvider.gainXP(habit.xpPerCount,
        source: 'Water: Glass ${habit.currentCount}');

    // Award stats only when all glasses completed
    if (habit.currentCount == habit.maxCount) {
      if (habit.statRewards.isNotEmpty) {
        await userProvider.updateStats(habit.statRewards);
      }

      // Mark as completed for streak tracking
      if (!habit.isCompletedToday) {
        habit.markCompleted();
        _checkStreakAchievements(habit, userProvider);
      }
    }

    await _saveHabits();
    notifyListeners();
  }

  /// Decrement water counter for counter-based habits
  /// 🛡️ FIX: Now deducts XP to prevent increment/decrement XP farming
  Future<void> decrementWaterCounter(
      String habitId, UserProvider userProvider) async {
    final habitIndex = _habits.indexWhere((h) => h.id == habitId);
    if (habitIndex == -1) return;

    final habit = _habits[habitIndex];

    // Only for counter-based habits
    if (!habit.isCounterBased) return;

    // Check if already at 0
    if (habit.currentCount <= 0) return;

    habit.currentCount--;

    // 🛡️ FIX: Deduct XP on decrement to prevent XP farming exploit
    if (habit.xpPerCount > 0) {
      await userProvider.loseXP(habit.xpPerCount,
          source: 'Water: Glass removed');
      userProvider.decrementDailyXP(habit.xpPerCount);
    }

    // If was completed and now below max, unmark completion
    if (habit.isCompletedToday && habit.currentCount < habit.maxCount) {
      habit.unmarkCompleted();
      // Reverse stat rewards that were given at completion
      if (habit.statRewards.isNotEmpty) {
        final negativeRewards = <String, int>{};
        habit.statRewards.forEach((stat, reward) {
          negativeRewards[stat] = -reward;
        });
        await userProvider.updateStats(negativeRewards);
      }
    }

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

      // 7-Day Bad Habit Streak Penalty (-50 XP)
      if (_isBadHabitStreak(habit, 7)) {
        await userProvider.loseXP(50,
            source: '7-Day Bad Streak: ${habit.name}');
        await NotificationService.showPenaltyNotification(
            'BAD HABIT STREAK (7 DAYS)', 50);
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

    // 🛡️ FIX #2: Only allow undo within 5 minutes to prevent penalty bypass
    if (habit.failedDates.isNotEmpty) {
      final lastFailTime = habit.failedDates.last;
      final timeSinceFail = DateTime.now().difference(lastFailTime);

      if (timeSinceFail.inMinutes > 5) {
        throw Exception(
            'Cannot undo bad habit failure after 5 minutes. Penalties are permanent.');
      }
    }

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
        return {'wisdomMultiplier': 0.9, 'willpowerMultiplier': 0.9};
      case 'Entertainment Haze':
        return {'productivityMultiplier': 0.8};
      case 'Fatigue':
        return {
          'strengthMultiplier': 0.8,
          'willpowerMultiplier': 0.8,
          'charismaMultiplier': 0.8,
          'enduranceMultiplier': 0.8,
          'wisdomMultiplier': 0.8,
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
          'enduranceMultiplier': 0.80,
        };
      // NUCLEAR OPTION - Devastating penalties for 3 days
      case "Failure's Mark":
        return {
          'xpMultiplier': 0.50, // HALF XP gains
          'strengthMultiplier': 0.70,
          'willpowerMultiplier': 0.70,
          'charismaMultiplier': 0.70,
          'enduranceMultiplier': 0.70,
          'wisdomMultiplier': 0.70,
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
    for (var habit in _habits) {
      if (habit.isInBox) {
        await habit.save();
      } else {
        await _habitBox.add(habit);
      }
    }
  }

  // ═══════════════════════════════════════════════════════════
  // STATS & HELPERS (Restored)
  // ═══════════════════════════════════════════════════════════

  Future<void> addCustomHabit(Habit habit) async {
    // 🛡️ SECURITY: Validate custom habit to prevent XP farming
    if (habit.isCustom) {
      // Cap XP rewards at 50 (prevents instant max-level exploits)
      const maxCustomXP = 50;
      if (habit.xpReward > maxCustomXP) {
        throw Exception(
            '⚠️ CUSTOM HABIT LIMIT\n\nCustom habits cannot exceed $maxCustomXP XP.\n\n'
            'This prevents progression exploits while still allowing meaningful rewards.');
      }

      // Cap total stat points at 3
      final totalStats =
          habit.statRewards.values.fold(0, (sum, val) => sum + val);
      if (totalStats > 3) {
        throw Exception(
            '⚠️ STAT LIMIT\n\nCustom habits limited to +3 total stat points.\n'
            'You tried: +$totalStats points\n\n'
            'Example: +2 Strength, +1 Endurance = 3 points ✅');
      }

      // Cap individual stat bonuses at +2
      for (var entry in habit.statRewards.entries) {
        if (entry.value > 2) {
          throw Exception('⚠️ STAT LIMIT\n\nMax +2 per individual stat.\n'
              'You tried: ${entry.key} +${entry.value}');
        }
      }
    }

    _habits.add(habit);
    await _habitBox.add(habit);
    notifyListeners();
  }

  Future<void> deleteHabit(String habitId, UserProvider userProvider) async {
    final habitIndex = _habits.indexWhere((h) => h.id == habitId);
    if (habitIndex == -1) return;

    final habit = _habits[habitIndex];

    // Only allow erasing custom habits to prevent breaking game logic
    if (!habit.isCustom) {
      throw Exception('Cannot delete core system habits.');
    }

    // 🛡️ ANTI-CHEAT: Reform Phantom Habit Loophole
    if (habit.isCompletedToday) {
      final xpToRemove = habit.getTotalXPReward();
      await userProvider.loseXP(xpToRemove,
          source: 'Anti-Cheat: Deleting completed habit');

      // 🛡️ FIX: Deduct Gold on delete (was missing - free gold exploit)
      final goldReward = habit.totalGoldReward;
      if (goldReward > 0) {
        await userProvider.spendGold(
            goldReward, 'Anti-Cheat: Deleting completed habit');
      }

      if (habit.statRewards.isNotEmpty) {
        final negativeRewards = <String, int>{};
        habit.statRewards.forEach((stat, reward) {
          negativeRewards[stat] = -reward;
        });
        await userProvider.updateStats(negativeRewards);
      }
    }

    _habits.removeAt(habitIndex);

    // Hive requires key to delete, but we've been using index or auto-increment.
    // Ideally, we should delete by key.
    // If habit extends HiveObject, we can call habit.delete()
    if (habit.isInBox) {
      await habit.delete();
    } else {
      // Fallback if not in box (shouldn't happen if loaded normally)
      final keyToDelete = _habitBox.keys.firstWhere(
          (k) => _habitBox.get(k)?.id == habitId,
          orElse: () => null);
      if (keyToDelete != null) {
        await _habitBox.delete(keyToDelete);
      }
    }

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

    for (var habit in _habits) {
      // Calculate completions in the last 7 days
      for (var date in habit.completedDates) {
        if (now.difference(date).inDays < 7) {
          completions++;
        }
      }
      // Calculate failures in the last 7 days
      for (var date in habit.failedDates) {
        if (now.difference(date).inDays < 7) {
          failures++;
        }
      }
    }

    return {'completions': completions, 'failures': failures};
  }

  // ═══════════════════════════════════════════════════════════
  // WEEKLY BOSS LOGIC
  // ═══════════════════════════════════════════════════════════

  WeeklyBoss getCurrentWeeklyBoss() {
    return WeeklyBoss.getCurrentBoss();
  }

  bool isWeeklyBossDefeated(UserProvider userProvider) {
    if (userProvider.userProfile == null) return false;

    // Check if the "last defeated week" matches current boss week
    final now = DateTime.now();
    final weekNumber =
        (now.millisecondsSinceEpoch / (1000 * 60 * 60 * 24 * 7)).floor();

    return userProvider.userProfile!.lastBossWeek == weekNumber;
  }

  int getWeeklyBossProgress(WeeklyBoss boss) {
    final now = DateTime.now();
    final oneWeekAgo = now.subtract(const Duration(days: 7));

    if (boss.isNegativeAvoidance) {
      // Count DAYS where the specific bad habit was NOT failed
      if (boss.specificHabitId == null) return 0;

      final habitIndex =
          _habits.indexWhere((h) => h.id == boss.specificHabitId);
      if (habitIndex == -1) {
        return 0; // Habit not found, so technically 100% success? No, 0 progress.
      }

      final habit = _habits[habitIndex];

      // Count days in last 7 days that are NOT in failedDates
      int cleanDays = 0;
      for (int i = 0; i < 7; i++) {
        final day = now.subtract(Duration(days: i));
        // Normalize to midnight
        // Check if failed on this day
        final failedOnDay = habit.failedDates.any((d) =>
            d.year == day.year && d.month == day.month && d.day == day.day);

        if (!failedOnDay) cleanDays++;
      }

      return cleanDays;
    } else {
      // POSITIVE COMPLETION
      if (boss.specificHabitId != null) {
        // Count completions of specific habit
        final habitIndex =
            _habits.indexWhere((h) => h.id == boss.specificHabitId);
        if (habitIndex == -1) return 0;

        final habit = _habits[habitIndex];
        return habit.completedDates.where((d) => d.isAfter(oneWeekAgo)).length;
      } else if (boss.habitIdPrefix != null) {
        // Count completions of habits with prefix
        if (boss.requiresUniqueDays) {
          // Count distinct DAYS with at least one completion
          final distinctDays = <String>{};
          for (final habit in _habits) {
            if (habit.id.startsWith(boss.habitIdPrefix!)) {
              for (final date in habit.completedDates) {
                if (date.isAfter(oneWeekAgo)) {
                  distinctDays.add(
                      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}");
                }
              }
            }
          }
          return distinctDays.length;
        } else {
          // Count TOTAL completions (volume)
          int total = 0;
          for (final habit in _habits) {
            if (habit.id.startsWith(boss.habitIdPrefix!)) {
              total += habit.completedDates
                  .where((d) => d.isAfter(oneWeekAgo))
                  .length;
            }
          }
          return total;
        }
      } else {
        // Any habit completion
        int total = 0;
        for (final habit in _habits) {
          if (habit.type == HabitType.good) {
            total +=
                habit.completedDates.where((d) => d.isAfter(oneWeekAgo)).length;
          }
        }
        return total;
      }
    }
  }

  Future<void> checkAndDefeatWeeklyBoss(UserProvider userProvider) async {
    if (userProvider.userProfile == null) return;
    if (isWeeklyBossDefeated(userProvider)) return;

    final boss = getCurrentWeeklyBoss();
    final progress = getWeeklyBossProgress(boss);

    if (progress >= boss.targetCompletions) {
      // BOSS DEFEATED!
      final now = DateTime.now();
      final weekNumber =
          (now.millisecondsSinceEpoch / (1000 * 60 * 60 * 24 * 7)).floor();

      userProvider.userProfile!.lastBossWeek = weekNumber;
      userProvider.userProfile!.bossesDefeated++;
      userProvider.userProfile!.save();

      // Apply Rewards
      await userProvider.gainXP(boss.xpReward,
          source: 'BOSS SLAIN: ${boss.name}');
      if (boss.statRewards.isNotEmpty) {
        await userProvider.updateStats(boss.statRewards);
      }

      // Add to Notification
      await NotificationService.showAchievementUnlocked(
          'BOSS SLAIN: ${boss.name}');

      notifyListeners();
    }
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

  /// Check if the habit has been failed for [days] consecutive days (ending today)
  bool _isBadHabitStreak(Habit habit, int days) {
    if (habit.failedDates.isEmpty) return false;

    final today = DateTime.now();
    final todayMidnight = DateTime(today.year, today.month, today.day);

    // Create a Set of normalized failure dates for O(1) lookup
    final dates =
        habit.failedDates.map((d) => DateTime(d.year, d.month, d.day)).toSet();

    for (int i = 0; i < days; i++) {
      final target = todayMidnight.subtract(Duration(days: i));
      if (!dates.contains(target)) return false;
    }
    return true;
  }
}
