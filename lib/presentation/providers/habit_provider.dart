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
  
  late Box<Habit> _habitBox;

  List<Habit> get habits => _habits;
  List<Habit> get goodHabits => _habits.where((h) => h.type == HabitType.good && h.isActive).toList();
  List<Habit> get badHabits => _habits.where((h) => h.type == HabitType.bad && h.isActive).toList();
  bool get isLoading => _isLoading;

  Future<void> loadHabits() async {
    _isLoading = true;
    notifyListeners();

    try {
      _habitBox = Hive.box<Habit>('habits');
      
      if (_habitBox.isEmpty) {
        await _initializeDefaultHabits();
      } else {
        _habits = _habitBox.values.toList();
      }
    } catch (e) {
      debugPrint('Error loading habits: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _initializeDefaultHabits() async {
    _habits = Habit.getDefaultHabits();
    await _habitBox.clear();
    for (int i = 0; i < _habits.length; i++) {
      await _habitBox.put(i, _habits[i]);
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
  
  Future<void> uncompleteHabit(String habitId, UserProvider userProvider) async {
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
      await userProvider.loseXP(totalXPPenalty, source: 'Failed: ${habit.name}');
      
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
      
      await NotificationService.showPenaltyNotification(habit.name, totalXPPenalty);
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
      default:
        return 'Negative effect applied';
    }
  }

  Duration _getDebuffDuration(String debuffName) {
    switch (debuffName) {
      case "Demon's Grip":
        return const Duration(hours: 36); // Medium-long duration
      case 'Sluggish Start':
        return const Duration(hours: 24); // Medium duration
      case 'Fatigue':
        return const Duration(hours: 30); // Medium duration
      case 'Weakened State':
        return const Duration(hours: 36); // Medium-long duration
      case 'Entertainment Haze':
        return const Duration(hours: 36); // Medium-long duration
      case 'Mind Fog':
        return const Duration(hours: 24); // Medium duration
      case 'Disorganized':
        return const Duration(hours: 24); // Medium duration
      case 'Time Void':
        return const Duration(hours: 30); // Medium duration
      case 'Mounting Dread':
        return const Duration(hours: 24); // Medium duration
      case 'Corrupted State':
        return const Duration(days: 7); // Long but not permanent (1 week)
      default:
        return const Duration(hours: 24); // Default medium duration
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
    final now = DateTime.now();
    int consecutiveFailureDays = 0;
    
    // Check last 7 days for any completed good habits
    for (int i = 0; i < 7; i++) {
      final checkDate = now.subtract(Duration(days: i));
      bool hasAnyCompletion = false;
      
      for (final habit in goodHabits) {
        final hasCompletion = habit.completedDates.any((date) => 
          date.year == checkDate.year && 
          date.month == checkDate.month && 
          date.day == checkDate.day
        );
        
        if (hasCompletion) {
          hasAnyCompletion = true;
          break;
        }
      }
      
      if (!hasAnyCompletion) {
        consecutiveFailureDays++;
      } else {
        break;
      }
    }
    
    // Enter penalty zone if 7 consecutive days without any good habit completion
    if (consecutiveFailureDays >= 7 && !userProvider.userProfile!.isInPenaltyZone) {
      await userProvider.enterPenaltyZone();
    }
  }

  Future<void> addCustomHabit(Habit habit) async {
    _habits.add(habit);
    await _saveHabits();
    notifyListeners();
  }

  Future<void> updateHabit(Habit updatedHabit) async {
    final index = _habits.indexWhere((h) => h.id == updatedHabit.id);
    if (index != -1) {
      _habits[index] = updatedHabit;
      await _saveHabits();
      notifyListeners();
    }
  }

  Future<void> deleteHabit(String habitId) async {
    _habits.removeWhere((h) => h.id == habitId);
    await _saveHabits();
    notifyListeners();
  }

  Future<void> _saveHabits() async {
    await _habitBox.clear();
    for (int i = 0; i < _habits.length; i++) {
      await _habitBox.put(i, _habits[i]);
    }
  }

  // Analytics methods
  double getTodayCompletionRate() {
    final activeGoodHabits = goodHabits;
    if (activeGoodHabits.isEmpty) return 0.0;
    
    final completedToday = activeGoodHabits.where((h) => h.isCompletedToday).length;
    return completedToday / activeGoodHabits.length;
  }

  int getTodayXPEarned() {
    int totalXP = 0;
    for (final habit in goodHabits) {
      if (habit.isCompletedToday) {
        totalXP += habit.getTotalXPReward();
      }
    }
    return totalXP;
  }

  int getTodayXPLost() {
    int totalXP = 0;
    for (final habit in badHabits) {
      if (habit.isFailedToday) {
        totalXP += habit.getTotalXPPenalty();
      }
    }
    return totalXP;
  }

  List<Habit> getHabitsByTier(HabitTier tier) {
    return _habits.where((h) => h.tier == tier && h.isActive).toList();
  }

  Map<String, int> getWeeklyStats() {
    final now = DateTime.now();
    int completions = 0;
    int failures = 0;
    
    for (int i = 0; i < 7; i++) {
      final checkDate = now.subtract(Duration(days: i));
      
      for (final habit in _habits) {
        final hasCompletion = habit.completedDates.any((date) => 
          date.year == checkDate.year && 
          date.month == checkDate.month && 
          date.day == checkDate.day
        );
        
        final hasFailure = habit.failedDates.any((date) => 
          date.year == checkDate.year && 
          date.month == checkDate.month && 
          date.day == checkDate.day
        );
        
        if (hasCompletion) completions++;
        if (hasFailure) failures++;
      }
    }
    
    return {
      'completions': completions,
      'failures': failures,
    };
  }
}