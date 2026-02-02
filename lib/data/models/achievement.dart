import 'package:hive/hive.dart';

part 'achievement.g.dart';

@HiveType(typeId: 11)
enum AchievementRarity {
  @HiveField(0)
  common,
  @HiveField(1)
  rare,
  @HiveField(2)
  epic,
  @HiveField(3)
  legendary,
  @HiveField(4)
  mythic,
}

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

  @HiveField(13)
  AchievementRarity rarity;

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
    this.rarity = AchievementRarity.rare,
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
        titleUnlock: 'E-Rank Ascendant',
        targetValue: 10,
        icon: '👑',
        rarity: AchievementRarity.common,
      ),

      Achievement(
        id: 'rising_hunter',
        name: 'Rising Hunter',
        description: 'Reach Level 25',
        category: AchievementCategory.monarchsPath,
        xpReward: 500,
        statRewards: {'strength': 5, 'willpower': 5},
        titleUnlock: 'Hunter Awakened',
        targetValue: 25,
        icon: '⚔️',
        rarity: AchievementRarity.common,
      ),

      Achievement(
        id: 'elite_hunter',
        name: 'Elite Hunter',
        description: 'Reach Level 50',
        category: AchievementCategory.monarchsPath,
        xpReward: 1000,
        statRewards: {'strength': 10, 'endurance': 10},
        titleUnlock: 'Shadow Lieutenant',
        shadowUnlock: 'Elite Guard',
        targetValue: 50,
        icon: '🏆',
        rarity: AchievementRarity.rare,
      ),

      Achievement(
        id: 'monarchs_blade',
        name: "Monarch's Blade",
        description: 'Reach Level 75',
        category: AchievementCategory.monarchsPath,
        xpReward: 1750,
        statRewards: {'strength': 15, 'willpower': 15, 'charisma': 15},
        titleUnlock: "The Monarch's Blade",
        targetValue: 75,
        icon: '⚔️',
        rarity: AchievementRarity.epic,
      ),

      Achievement(
        id: 'shadow_monarch',
        name: 'Shadow Sovereign',
        description: 'Reach Level 100 - Become the ultimate hunter',
        category: AchievementCategory.monarchsPath,
        xpReward: 2500,
        statRewards: {
          'strength': 25,
          'willpower': 25,
          'charisma': 25,
          'endurance': 25,
          'wisdom': 25,
          'intelligence': 25,
          'awareness': 25
        },
        titleUnlock: 'SHADOW SOVEREIGN',
        shadowUnlock: 'Full Army',
        targetValue: 100,
        icon: '👑',
        rarity: AchievementRarity.legendary,
      ),

      // FLAME KEEPER - Streak achievements
      Achievement(
        id: 'week_warrior',
        name: 'Week Warrior',
        description: 'Maintain a 7-day streak on any habit',
        category: AchievementCategory.flameKeeper,
        xpReward: 300,
        statRewards: {'willpower': 3},
        titleUnlock: 'Spark Keeper',
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
        titleUnlock: 'Flame Eternal',
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
        titleUnlock: 'Phoenix Reborn',
        targetValue: 100,
        rarity: AchievementRarity.rare,
        icon: '🔥',
      ),

      Achievement(
        id: 'year_legend',
        name: 'Year Legend',
        description: 'Maintain a 365-day streak on any habit',
        category: AchievementCategory.flameKeeper,
        xpReward: 5000,
        statRewards: {'willpower': 50},
        titleUnlock: 'Undying Flame',
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
        titleUnlock: 'Gate Breaker',
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
        titleUnlock: 'Dungeon Conqueror',
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
        titleUnlock: 'Raid Legend',
        targetValue: 25,
        icon: '⚔️',
      ),

      // STAT MASTER - Tiered stat achievements (7 stats × 4 tiers = 28 achievements)

      // STRENGTH TIERS
      Achievement(
        id: 'strength_tier1',
        name: 'Iron Fist',
        description: 'Reach 50 Strength',
        category: AchievementCategory.statMaster,
        xpReward: 250,
        titleUnlock: 'Iron Fist',
        targetValue: 50,
        rarity: AchievementRarity.common,
        icon: '💪',
      ),
      Achievement(
        id: 'strength_tier2',
        name: 'Titan\'s Heir',
        description: 'Reach 100 Strength',
        category: AchievementCategory.statMaster,
        xpReward: 500,
        titleUnlock: 'Titan\'s Heir',
        targetValue: 100,
        rarity: AchievementRarity.rare,
        icon: '💪',
      ),
      Achievement(
        id: 'strength_tier3',
        name: 'Fist of the Monarch',
        description: 'Reach 200 Strength',
        category: AchievementCategory.statMaster,
        xpReward: 1000,
        titleUnlock: 'Fist of the Monarch',
        targetValue: 200,
        rarity: AchievementRarity.epic,
        icon: '💪',
      ),
      Achievement(
        id: 'strength_tier4',
        name: 'The Colossus',
        description: 'Reach 300 Strength - Ultimate destroyer',
        category: AchievementCategory.statMaster,
        xpReward: 2000,
        titleUnlock: 'The Colossus',
        targetValue: 300,
        rarity: AchievementRarity.legendary,
        icon: '💪',
      ),

      // INTELLIGENCE TIERS
      Achievement(
        id: 'intelligence_tier1',
        name: 'The Scholar',
        description: 'Reach 50 Intelligence',
        category: AchievementCategory.statMaster,
        xpReward: 250,
        titleUnlock: 'The Scholar',
        targetValue: 50,
        rarity: AchievementRarity.common,
        icon: '🧠',
      ),
      Achievement(
        id: 'intelligence_tier2',
        name: 'Architect of Knowledge',
        description: 'Reach 100 Intelligence',
        category: AchievementCategory.statMaster,
        xpReward: 500,
        titleUnlock: 'Architect of Knowledge',
        targetValue: 100,
        rarity: AchievementRarity.rare,
        icon: '🧠',
      ),
      Achievement(
        id: 'intelligence_tier3',
        name: 'The System\'s Oracle',
        description: 'Reach 200 Intelligence',
        category: AchievementCategory.statMaster,
        xpReward: 1000,
        titleUnlock: 'The System\'s Oracle',
        targetValue: 200,
        rarity: AchievementRarity.epic,
        icon: '🧠',
      ),
      Achievement(
        id: 'intelligence_tier4',
        name: 'Omniscient One',
        description: 'Reach 300 Intelligence - All-knowing',
        category: AchievementCategory.statMaster,
        xpReward: 2000,
        titleUnlock: 'Omniscient One',
        targetValue: 300,
        rarity: AchievementRarity.legendary,
        icon: '🧠',
      ),

      // AWARENESS TIERS
      Achievement(
        id: 'awareness_tier1',
        name: 'The Vigilant',
        description: 'Reach 50 Awareness',
        category: AchievementCategory.statMaster,
        xpReward: 250,
        titleUnlock: 'The Vigilant',
        targetValue: 50,
        rarity: AchievementRarity.common,
        icon: '👁️',
      ),
      Achievement(
        id: 'awareness_tier2',
        name: 'Shadow\'s Eyes',
        description: 'Reach 100 Awareness',
        category: AchievementCategory.statMaster,
        xpReward: 500,
        titleUnlock: 'Shadow\'s Eyes',
        targetValue: 100,
        rarity: AchievementRarity.rare,
        icon: '👁️',
      ),
      Achievement(
        id: 'awareness_tier3',
        name: 'The All-Seeing',
        description: 'Reach 200 Awareness',
        category: AchievementCategory.statMaster,
        xpReward: 1000,
        titleUnlock: 'The All-Seeing',
        targetValue: 200,
        rarity: AchievementRarity.epic,
        icon: '👁️',
      ),
      Achievement(
        id: 'awareness_tier4',
        name: 'Eyes of the Monarch',
        description: 'Reach 300 Awareness - Perfect perception',
        category: AchievementCategory.statMaster,
        xpReward: 2000,
        titleUnlock: 'Eyes of the Monarch',
        targetValue: 300,
        rarity: AchievementRarity.legendary,
        icon: '👁️',
      ),

      // WILLPOWER TIERS
      Achievement(
        id: 'willpower_tier1',
        name: 'The Unyielding',
        description: 'Reach 50 Willpower',
        category: AchievementCategory.statMaster,
        xpReward: 250,
        titleUnlock: 'The Unyielding',
        targetValue: 50,
        rarity: AchievementRarity.common,
        icon: '🔥',
      ),
      Achievement(
        id: 'willpower_tier2',
        name: 'Breaker of Chains',
        description: 'Reach 100 Willpower',
        category: AchievementCategory.statMaster,
        xpReward: 500,
        titleUnlock: 'Breaker of Chains',
        targetValue: 100,
        rarity: AchievementRarity.rare,
        icon: '🔥',
      ),
      Achievement(
        id: 'willpower_tier3',
        name: 'Defier of Fate',
        description: 'Reach 200 Willpower',
        category: AchievementCategory.statMaster,
        xpReward: 1000,
        titleUnlock: 'Defier of Fate',
        targetValue: 200,
        rarity: AchievementRarity.epic,
        icon: '🔥',
      ),
      Achievement(
        id: 'willpower_tier4',
        name: 'Will of the Monarch',
        description: 'Reach 300 Willpower - Absolute determination',
        category: AchievementCategory.statMaster,
        xpReward: 2000,
        titleUnlock: 'Will of the Monarch',
        targetValue: 300,
        rarity: AchievementRarity.legendary,
        icon: '🔥',
      ),

      // CHARISMA TIERS
      Achievement(
        id: 'charisma_tier1',
        name: 'Silver Tongue',
        description: 'Reach 50 Charisma',
        category: AchievementCategory.statMaster,
        xpReward: 250,
        titleUnlock: 'Silver Tongue',
        targetValue: 50,
        rarity: AchievementRarity.common,
        icon: '💬',
      ),
      Achievement(
        id: 'charisma_tier2',
        name: 'Lord Commander',
        description: 'Reach 100 Charisma',
        category: AchievementCategory.statMaster,
        xpReward: 500,
        titleUnlock: 'Lord Commander',
        targetValue: 100,
        rarity: AchievementRarity.rare,
        icon: '💬',
      ),
      Achievement(
        id: 'charisma_tier3',
        name: 'King\'s Presence',
        description: 'Reach 200 Charisma',
        category: AchievementCategory.statMaster,
        xpReward: 1000,
        titleUnlock: 'King\'s Presence',
        targetValue: 200,
        rarity: AchievementRarity.epic,
        icon: '💬',
      ),
      Achievement(
        id: 'charisma_tier4',
        name: 'The Sovereign',
        description: 'Reach 300 Charisma - Ruler of hearts',
        category: AchievementCategory.statMaster,
        xpReward: 2000,
        titleUnlock: 'The Sovereign',
        targetValue: 300,
        rarity: AchievementRarity.legendary,
        icon: '💬',
      ),

      // ENDURANCE TIERS
      Achievement(
        id: 'endurance_tier1',
        name: 'The Resilient',
        description: 'Reach 50 Endurance',
        category: AchievementCategory.statMaster,
        xpReward: 250,
        titleUnlock: 'The Resilient',
        targetValue: 50,
        rarity: AchievementRarity.common,
        icon: '🛡️',
      ),
      Achievement(
        id: 'endurance_tier2',
        name: 'Iron Fortress',
        description: 'Reach 100 Endurance',
        category: AchievementCategory.statMaster,
        xpReward: 500,
        titleUnlock: 'Iron Fortress',
        targetValue: 100,
        rarity: AchievementRarity.rare,
        icon: '🛡️',
      ),
      Achievement(
        id: 'endurance_tier3',
        name: 'The Immortal',
        description: 'Reach 200 Endurance',
        category: AchievementCategory.statMaster,
        xpReward: 1000,
        titleUnlock: 'The Immortal',
        targetValue: 200,
        rarity: AchievementRarity.epic,
        icon: '🛡️',
      ),
      Achievement(
        id: 'endurance_tier4',
        name: 'Eternal Guardian',
        description: 'Reach 300 Endurance - Survives all',
        category: AchievementCategory.statMaster,
        xpReward: 2000,
        titleUnlock: 'Eternal Guardian',
        targetValue: 300,
        rarity: AchievementRarity.legendary,
        icon: '🛡️',
      ),

      // WISDOM TIERS
      Achievement(
        id: 'wisdom_tier1',
        name: 'The Learned',
        description: 'Reach 50 Wisdom',
        category: AchievementCategory.statMaster,
        xpReward: 250,
        titleUnlock: 'The Learned',
        targetValue: 50,
        rarity: AchievementRarity.common,
        icon: '📚',
      ),
      Achievement(
        id: 'wisdom_tier2',
        name: 'Sage of Shadows',
        description: 'Reach 100 Wisdom',
        category: AchievementCategory.statMaster,
        xpReward: 500,
        titleUnlock: 'Sage of Shadows',
        targetValue: 100,
        rarity: AchievementRarity.rare,
        icon: '📚',
      ),
      Achievement(
        id: 'wisdom_tier3',
        name: 'The Enlightened',
        description: 'Reach 200 Wisdom',
        category: AchievementCategory.statMaster,
        xpReward: 1000,
        titleUnlock: 'The Enlightened',
        targetValue: 200,
        rarity: AchievementRarity.epic,
        icon: '📚',
      ),
      Achievement(
        id: 'wisdom_tier4',
        name: 'Elder of Eternity',
        description: 'Reach 300 Wisdom - Timeless knowledge',
        category: AchievementCategory.statMaster,
        xpReward: 2000,
        titleUnlock: 'Elder of Eternity',
        targetValue: 300,
        rarity: AchievementRarity.legendary,
        icon: '📚',
      ),

      // PERFECT HUNTER - Perfect streaks
      Achievement(
        id: 'perfect_week',
        name: 'Perfect Week',
        description: 'Complete all daily quests for 7 consecutive days',
        category: AchievementCategory.perfectHunter,
        xpReward: 750,
        statRewards: {'willpower': 5},
        titleUnlock: 'The Flawless',
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
        titleUnlock: 'Paragon of Discipline',
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
        titleUnlock: 'Shadow Army Commander',
        targetValue: 6,
        icon: '👥',
      ),

      Achievement(
        id: 'title_master',
        name: 'Title Master',
        description: 'Unlock 10 different titles',
        category: AchievementCategory.collector,
        xpReward: 1500,
        titleUnlock: 'The Boundless',
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
