import 'package:hive/hive.dart';

part 'achievement.g.dart';

@HiveType(typeId: 9)
class Achievement extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  AchievementCategory category;

  @HiveField(4)
  int xpReward;

  @HiveField(5)
  Map<String, int> statRewards;

  @HiveField(6)
  String? titleUnlock;

  @HiveField(7)
  String? shadowUnlock;

  @HiveField(8)
  bool isUnlocked;

  @HiveField(9)
  DateTime? unlockedAt;

  @HiveField(10)
  int targetValue;

  @HiveField(11)
  int currentProgress;

  @HiveField(12)
  String icon;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.xpReward,
    this.statRewards = const {},
    this.titleUnlock,
    this.shadowUnlock,
    this.isUnlocked = false,
    this.unlockedAt,
    required this.targetValue,
    this.currentProgress = 0,
    required this.icon,
  });

  double get progressPercentage => 
      targetValue > 0 ? (currentProgress / targetValue).clamp(0.0, 1.0) : 0.0;

  bool get isCompleted => currentProgress >= targetValue;

  void updateProgress(int value) {
    currentProgress = value.clamp(0, targetValue);
    if (isCompleted && !isUnlocked) {
      unlock();
    }
  }

  void unlock() {
    isUnlocked = true;
    unlockedAt = DateTime.now();
  }

  static List<Achievement> getDefaultAchievements() {
    return [
      // MONARCH'S PATH - Level milestones
      Achievement(
        id: 'first_steps',
        name: 'First Steps',
        description: 'Reach Level 10',
        category: AchievementCategory.monarchsPath,
        xpReward: 200,
        statRewards: {'willpower': 5},
        titleUnlock: 'The Awakened',
        targetValue: 10,
        icon: '👑',
      ),

      Achievement(
        id: 'rising_hunter',
        name: 'Rising Hunter',
        description: 'Reach Level 25',
        category: AchievementCategory.monarchsPath,
        xpReward: 500,
        statRewards: {'strength': 5, 'agility': 5},
        titleUnlock: 'The Ascending',
        targetValue: 25,
        icon: '⚔️',
      ),

      Achievement(
        id: 'elite_hunter',
        name: 'Elite Hunter',
        description: 'Reach Level 50',
        category: AchievementCategory.monarchsPath,
        xpReward: 1000,
        statRewards: {'strength': 10, 'vitality': 10},
        titleUnlock: 'The Elite',
        shadowUnlock: 'Elite Guard',
        targetValue: 50,
        icon: '🏆',
      ),

      Achievement(
        id: 'shadow_monarch',
        name: 'Shadow Monarch',
        description: 'Reach Level 100',
        category: AchievementCategory.monarchsPath,
        xpReward: 2500,
        statRewards: {'strength': 25, 'agility': 25, 'vitality': 25, 'intelligence': 25, 'sense': 25, 'willpower': 25},
        titleUnlock: 'The Shadow Monarch',
        shadowUnlock: 'Full Army',
        targetValue: 100,
        icon: '👑',
      ),

      // FLAME KEEPER - Streak achievements
      Achievement(
        id: 'week_warrior',
        name: 'Week Warrior',
        description: 'Maintain a 7-day streak on any habit',
        category: AchievementCategory.flameKeeper,
        xpReward: 300,
        statRewards: {'willpower': 3},
        titleUnlock: 'The Persistent',
        targetValue: 7,
        icon: '🔥',
      ),

      Achievement(
        id: 'month_master',
        name: 'Month Master',
        description: 'Maintain a 30-day streak on any habit',
        category: AchievementCategory.flameKeeper,
        xpReward: 1000,
        statRewards: {'willpower': 10},
        titleUnlock: 'The Disciplined',
        targetValue: 30,
        icon: '🔥',
      ),

      Achievement(
        id: 'century_champion',
        name: 'Century Champion',
        description: 'Maintain a 100-day streak on any habit',
        category: AchievementCategory.flameKeeper,
        xpReward: 2000,
        statRewards: {'willpower': 20},
        titleUnlock: 'The Unstoppable',
        targetValue: 100,
        icon: '🔥',
      ),

      Achievement(
        id: 'year_legend',
        name: 'Year Legend',
        description: 'Maintain a 365-day streak on any habit',
        category: AchievementCategory.flameKeeper,
        xpReward: 5000,
        statRewards: {'willpower': 50},
        titleUnlock: 'The Legendary',
        targetValue: 365,
        icon: '🔥',
      ),

      // BOSS SLAYER - Weekly challenges
      Achievement(
        id: 'first_victory',
        name: 'First Victory',
        description: 'Complete your first weekly boss challenge',
        category: AchievementCategory.bossSlayer,
        xpReward: 250,
        statRewards: {'strength': 3},
        titleUnlock: 'The Victor',
        targetValue: 1,
        icon: '⚔️',
      ),

      Achievement(
        id: 'boss_hunter',
        name: 'Boss Hunter',
        description: 'Complete 10 weekly boss challenges',
        category: AchievementCategory.bossSlayer,
        xpReward: 1500,
        statRewards: {'strength': 15},
        titleUnlock: 'The Boss Hunter',
        targetValue: 10,
        icon: '⚔️',
      ),

      Achievement(
        id: 'raid_master',
        name: 'Raid Master',
        description: 'Complete 25 weekly boss challenges',
        category: AchievementCategory.bossSlayer,
        xpReward: 3000,
        statRewards: {'strength': 30},
        titleUnlock: 'The Raid Master',
        targetValue: 25,
        icon: '⚔️',
      ),

      // STAT MASTER - Stat thresholds
      Achievement(
        id: 'strength_adept',
        name: 'Strength Adept',
        description: 'Reach 100 Strength',
        category: AchievementCategory.statMaster,
        xpReward: 500,
        titleUnlock: 'The Strong',
        targetValue: 100,
        icon: '💪',
      ),

      Achievement(
        id: 'agility_master',
        name: 'Agility Master',
        description: 'Reach 100 Agility',
        category: AchievementCategory.statMaster,
        xpReward: 500,
        titleUnlock: 'The Swift',
        targetValue: 100,
        icon: '⚡',
      ),

      Achievement(
        id: 'vitality_guardian',
        name: 'Vitality Guardian',
        description: 'Reach 100 Vitality',
        category: AchievementCategory.statMaster,
        xpReward: 500,
        titleUnlock: 'The Enduring',
        targetValue: 100,
        icon: '🛡️',
      ),

      Achievement(
        id: 'intelligence_sage',
        name: 'Intelligence Sage',
        description: 'Reach 100 Intelligence',
        category: AchievementCategory.statMaster,
        xpReward: 500,
        titleUnlock: 'The Wise',
        targetValue: 100,
        icon: '🧠',
      ),

      Achievement(
        id: 'sense_mystic',
        name: 'Sense Mystic',
        description: 'Reach 100 Sense',
        category: AchievementCategory.statMaster,
        xpReward: 500,
        titleUnlock: 'The Aware',
        targetValue: 100,
        icon: '👁️',
      ),

      Achievement(
        id: 'willpower_titan',
        name: 'Willpower Titan',
        description: 'Reach 100 Willpower',
        category: AchievementCategory.statMaster,
        xpReward: 500,
        titleUnlock: 'The Determined',
        targetValue: 100,
        icon: '🔥',
      ),

      // PERFECT HUNTER - Perfect streaks
      Achievement(
        id: 'perfect_week',
        name: 'Perfect Week',
        description: 'Complete all daily quests for 7 consecutive days',
        category: AchievementCategory.perfectHunter,
        xpReward: 750,
        statRewards: {'willpower': 5},
        titleUnlock: 'The Perfect',
        targetValue: 7,
        icon: '⭐',
      ),

      Achievement(
        id: 'perfect_month',
        name: 'Perfect Month',
        description: 'Complete all daily quests for 30 consecutive days',
        category: AchievementCategory.perfectHunter,
        xpReward: 2500,
        statRewards: {'willpower': 25},
        titleUnlock: 'The Flawless',
        targetValue: 30,
        icon: '⭐',
      ),

      // COLLECTOR - Collection achievements
      Achievement(
        id: 'shadow_collector',
        name: 'Shadow Collector',
        description: 'Unlock all shadow soldiers',
        category: AchievementCategory.collector,
        xpReward: 2000,
        titleUnlock: 'The Collector',
        targetValue: 6,
        icon: '👥',
      ),

      Achievement(
        id: 'title_master',
        name: 'Title Master',
        description: 'Unlock 10 different titles',
        category: AchievementCategory.collector,
        xpReward: 1500,
        titleUnlock: 'The Titled',
        targetValue: 10,
        icon: '🏷️',
      ),
    ];
  }
}

@HiveType(typeId: 10)
enum AchievementCategory {
  @HiveField(0)
  monarchsPath,
  @HiveField(1)
  flameKeeper,
  @HiveField(2)
  bossSlayer,
  @HiveField(3)
  statMaster,
  @HiveField(4)
  perfectHunter,
  @HiveField(5)
  collector,
}