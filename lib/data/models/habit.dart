import 'package:hive/hive.dart';

part 'habit.g.dart';

@HiveType(typeId: 6)
class Habit extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  HabitType type;

  @HiveField(4)
  HabitTier tier;

  @HiveField(5)
  int xpReward;

  @HiveField(6)
  int xpPenalty;

  @HiveField(7)
  Map<String, int> statRewards;

  @HiveField(8)
  Map<String, int> statPenalties;

  @HiveField(9)
  int hpDamage;

  @HiveField(10)
  int mpDrain;

  @HiveField(11)
  List<DateTime> completedDates;

  @HiveField(12)
  List<DateTime> failedDates;

  @HiveField(13)
  int currentStreak;

  @HiveField(14)
  int longestStreak;

  @HiveField(15)
  bool isActive;

  @HiveField(16)
  DateTime createdAt;

  @HiveField(17)
  String? debuffName;

  @HiveField(18)
  int streakBonus;

  @HiveField(19)
  bool isCustom;

  Habit({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.tier,
    required this.xpReward,
    this.xpPenalty = 0,
    Map<String, int>? statRewards,
    Map<String, int>? statPenalties,
    this.hpDamage = 0,
    this.mpDrain = 0,
    List<DateTime>? completedDates,
    List<DateTime>? failedDates,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.isActive = true,
    required this.createdAt,
    this.debuffName,
    this.streakBonus = 0,
    this.isCustom = false,
  }) : statRewards = statRewards ?? {},
       statPenalties = statPenalties ?? {},
       completedDates = completedDates ?? [],
       failedDates = failedDates ?? [];

  bool get isCompletedToday {
    final today = DateTime.now();
    return completedDates.any((date) => 
      date.year == today.year && 
      date.month == today.month && 
      date.day == today.day
    );
  }

  bool get isFailedToday {
    final today = DateTime.now();
    return failedDates.any((date) => 
      date.year == today.year && 
      date.month == today.month && 
      date.day == today.day
    );
  }

  double get completionRate {
    final totalDays = completedDates.length + failedDates.length;
    if (totalDays == 0) return 0.0;
    return completedDates.length / totalDays;
  }

  void markCompleted() {
    if (!isCompletedToday) {
      completedDates.add(DateTime.now());
      currentStreak++;
      if (currentStreak > longestStreak) {
        longestStreak = currentStreak;
      }
    }
  }
  
  void unmarkCompleted() {
    final today = DateTime.now();
    completedDates.removeWhere((date) => 
      date.year == today.year && 
      date.month == today.month && 
      date.day == today.day
    );
    if (currentStreak > 0) currentStreak--;
  }

  void markFailed() {
    if (!isFailedToday) {
      failedDates.add(DateTime.now());
      currentStreak = 0;
    }
  }
  
  void unmarkFailed() {
    final today = DateTime.now();
    failedDates.removeWhere((date) => 
      date.year == today.year && 
      date.month == today.month && 
      date.day == today.day
    );
  }

  int getTotalXPReward() {
    return xpReward + (currentStreak * streakBonus);
  }

  int getTotalXPPenalty() {
    // Increase penalty based on consecutive failures
    final recentFailures = _getRecentConsecutiveFailures();
    final multiplier = 1.0 + (recentFailures * 0.2).clamp(0.0, 1.0);
    return (xpPenalty * multiplier).round();
  }

  int _getRecentConsecutiveFailures() {
    int count = 0;
    final now = DateTime.now();
    
    for (int i = 0; i < 5; i++) {
      final checkDate = now.subtract(Duration(days: i));
      final hasFailure = failedDates.any((date) => 
        date.year == checkDate.year && 
        date.month == checkDate.month && 
        date.day == checkDate.day
      );
      
      if (hasFailure) {
        count++;
      } else {
        break;
      }
    }
    
    return count;
  }

  static List<Habit> getDefaultHabits() {
    return [
      // TIER S - MONARCH'S PATH
      Habit(
        id: 'arise_before_dawn',
        name: 'Arise Before Dawn',
        description: 'Wake up between 5:00-6:00 AM',
        type: HabitType.good,
        tier: HabitTier.s,
        xpReward: 100,
        xpPenalty: 120,
        statRewards: {'agility': 2, 'willpower': 1},
        statPenalties: {},
        hpDamage: 3,
        streakBonus: 15,
        createdAt: DateTime.now(),
      ),
      
      Habit(
        id: 'shadow_training',
        name: 'Shadow Training',
        description: '60+ minutes intense workout',
        type: HabitType.good,
        tier: HabitTier.s,
        xpReward: 150,
        xpPenalty: 150,
        statRewards: {'strength': 3, 'vitality': 2},
        statPenalties: {'strength': 2},
        streakBonus: 20,
        createdAt: DateTime.now(),
      ),

      // TIER A - HUNTER'S DISCIPLINE
      Habit(
        id: 'meditation_mindfulness',
        name: 'Meditation & Mindfulness',
        description: '20+ minutes meditation',
        type: HabitType.good,
        tier: HabitTier.a,
        xpReward: 80,
        xpPenalty: 100,
        statRewards: {'sense': 2, 'willpower': 2},
        mpDrain: 50,
        streakBonus: 10,
        createdAt: DateTime.now(),
      ),

      Habit(
        id: 'knowledge_dungeon',
        name: 'Knowledge Dungeon',
        description: '30+ minutes reading/learning',
        type: HabitType.good,
        tier: HabitTier.a,
        xpReward: 90,
        xpPenalty: 80,
        statRewards: {'intelligence': 3},
        statPenalties: {'intelligence': 2},
        streakBonus: 12,
        createdAt: DateTime.now(),
      ),

      Habit(
        id: 'side_quest_progress',
        name: 'Side Quest Progress',
        description: 'Work on business/side project',
        type: HabitType.good,
        tier: HabitTier.a,
        xpReward: 120,
        xpPenalty: 100,
        statRewards: {'intelligence': 2, 'willpower': 1},
        streakBonus: 15,
        createdAt: DateTime.now(),
      ),

      // TIER B - ESSENTIAL TRAINING
      Habit(
        id: 'healthy_nutrition',
        name: 'Healthy Nutrition',
        description: '3 balanced meals, 2L+ water',
        type: HabitType.good,
        tier: HabitTier.b,
        xpReward: 70,
        xpPenalty: 60,
        statRewards: {'vitality': 2},
        statPenalties: {'vitality': 1},
        hpDamage: 100,
        streakBonus: 8,
        createdAt: DateTime.now(),
      ),

      Habit(
        id: 'social_connection',
        name: 'Social Connection',
        description: 'Meaningful conversation/networking',
        type: HabitType.good,
        tier: HabitTier.b,
        xpReward: 60,
        xpPenalty: 50,
        statRewards: {'sense': 1, 'intelligence': 1},
        streakBonus: 8,
        createdAt: DateTime.now(),
      ),

      Habit(
        id: 'daily_quest_log',
        name: 'Daily Quest Log',
        description: 'Journaling/planning',
        type: HabitType.good,
        tier: HabitTier.b,
        xpReward: 50,
        xpPenalty: 40,
        statRewards: {'sense': 1, 'willpower': 1},
        streakBonus: 5,
        createdAt: DateTime.now(),
      ),

      Habit(
        id: 'rest_recovery',
        name: 'Rest & Recovery',
        description: '7-8 hours quality sleep',
        type: HabitType.good,
        tier: HabitTier.b,
        xpReward: 80,
        xpPenalty: 100,
        statRewards: {'vitality': 2, 'willpower': 1},
        statPenalties: {'vitality': 3},
        hpDamage: 200,
        debuffName: 'Fatigue',
        streakBonus: 10,
        createdAt: DateTime.now(),
      ),

      // BAD HABITS - DEMON TRAPS
      Habit(
        id: 'midnight_scrolling',
        name: 'Midnight Scrolling',
        description: 'Social media after 10 PM',
        type: HabitType.bad,
        tier: HabitTier.catastrophic,
        xpReward: 0,
        xpPenalty: 150,
        statPenalties: {'willpower': 3, 'vitality': 2},
        hpDamage: 200,
        debuffName: "Demon's Grip",
        createdAt: DateTime.now(),
      ),

      Habit(
        id: 'gaming_abyss',
        name: 'Gaming Abyss',
        description: '2+ hours gaming on weekdays',
        type: HabitType.bad,
        tier: HabitTier.catastrophic,
        xpReward: 0,
        xpPenalty: 180,
        statPenalties: {'agility': 2, 'willpower': 3},
        mpDrain: 300,
        debuffName: 'Time Void',
        createdAt: DateTime.now(),
      ),

      Habit(
        id: 'junk_food_consumption',
        name: 'Junk Food Consumption',
        description: 'Fast food, processed snacks',
        type: HabitType.bad,
        tier: HabitTier.severe,
        xpReward: 0,
        xpPenalty: 120,
        statPenalties: {'vitality': 3},
        hpDamage: 150,
        debuffName: 'Weakened State',
        createdAt: DateTime.now(),
      ),

      Habit(
        id: 'snooze_defeat',
        name: 'Snooze Defeat',
        description: 'Hitting snooze button',
        type: HabitType.bad,
        tier: HabitTier.severe,
        xpReward: 0,
        xpPenalty: 100,
        statPenalties: {'agility': 2, 'willpower': 2},
        debuffName: 'Sluggish Start',
        createdAt: DateTime.now(),
      ),

      Habit(
        id: 'procrastination_beast',
        name: 'Procrastination Beast',
        description: 'Avoiding important tasks',
        type: HabitType.bad,
        tier: HabitTier.severe,
        xpReward: 0,
        xpPenalty: 130,
        statPenalties: {'intelligence': 2, 'willpower': 2},
        debuffName: 'Mounting Dread',
        createdAt: DateTime.now(),
      ),
    ];
  }
}

@HiveType(typeId: 7)
enum HabitType {
  @HiveField(0)
  good,
  @HiveField(1)
  bad,
}

@HiveType(typeId: 8)
enum HabitTier {
  @HiveField(0)
  s,
  @HiveField(1)
  a,
  @HiveField(2)
  b,
  @HiveField(3)
  c,
  @HiveField(4)
  severe,
  @HiveField(5)
  catastrophic,
}