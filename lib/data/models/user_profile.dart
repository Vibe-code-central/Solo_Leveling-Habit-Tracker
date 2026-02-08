import 'package:hive/hive.dart';
import 'exp_transaction.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 0)
class UserProfile extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int level;

  @HiveField(2)
  int currentXP;

  @HiveField(3)
  int totalXP;

  @HiveField(4)
  HunterRank rank;

  @HiveField(5)
  HunterClass hunterClass;

  @HiveField(6)
  PlayerStats stats;

  @HiveField(7)
  int currentHP;

  @HiveField(8)
  int maxHP;

  @HiveField(9)
  int currentMP;

  @HiveField(10)
  int maxMP;

  @HiveField(11)
  List<String> unlockedShadows;

  @HiveField(12)
  List<ActiveBuff> activeBuffs;

  @HiveField(13)
  List<ActiveDebuff> activeDebuffs;

  @HiveField(14)
  DateTime createdAt;

  @HiveField(15)
  DateTime lastActive;

  @HiveField(16)
  String title;

  @HiveField(17)
  int consecutiveDays;

  @HiveField(18)
  bool isInPenaltyZone;

  @HiveField(19)
  List<String> unlockedTitles;

  @HiveField(20)
  int bossesDefeated;

  @HiveField(21)
  int currentWeekBossProgress;

  @HiveField(22)
  int lastBossWeek;

  // ═════════════════════════════════════════════════════════════
  // NEW FIELDS - Solo Leveling System v2 Update
  // ═════════════════════════════════════════════════════════════

  /// Gold currency (earned from habits, streaks, gates)
  @HiveField(23)
  int? gold;

  /// Data integrity hash for tamper detection
  @HiveField(24)
  String? dataIntegrityHash;

  /// Counter for security violations (resets never - permanent record)
  @HiveField(25)
  int? securityViolationCount;

  /// XP gain timestamps for rolling 24-hour cap (Unix epoch milliseconds)
  @HiveField(26)
  List<int>? xpGainTimestamps;

  /// EXP transaction logs for history tracking
  @HiveField(27)
  List<ExpTransaction>? expLogs;

  /// Passive XP multiplier from permanent shop upgrades (default 1.0 = no bonus)
  @HiveField(28)
  double? passiveXPMultiplier;

  /// Passive Gold multiplier from permanent shop upgrades (default 1.0 = no bonus)
  @HiveField(29)
  double? passiveGoldMultiplier;

  UserProfile({
    required this.name,
    this.level = 1,
    this.currentXP = 0,
    this.totalXP = 0,
    this.rank = HunterRank.eRank,
    this.hunterClass = HunterClass.warrior,
    required this.stats,
    this.currentHP = 1000,
    this.maxHP = 1000,
    this.currentMP = 500,
    this.maxMP = 500,
    List<String>? unlockedShadows,
    List<ActiveBuff>? activeBuffs,
    List<ActiveDebuff>? activeDebuffs,
    required this.createdAt,
    required this.lastActive,
    this.title = "The Shadow's Candidate",
    this.consecutiveDays = 0,
    this.isInPenaltyZone = false,
    List<String>? unlockedTitles,
    this.bossesDefeated = 0,
    this.currentWeekBossProgress = 0,
    this.lastBossWeek = 0,
    this.gold,
    this.dataIntegrityHash,
    this.securityViolationCount,
    List<int>? xpGainTimestamps,
    List<ExpTransaction>? expLogs,
    this.passiveXPMultiplier = 1.0,
    this.passiveGoldMultiplier = 1.0,
  })  : unlockedShadows = unlockedShadows ?? [],
        xpGainTimestamps = xpGainTimestamps ?? [],
        expLogs = expLogs ?? [],
        activeBuffs = activeBuffs ?? [],
        activeDebuffs = activeDebuffs ?? [],
        unlockedTitles = unlockedTitles ?? ["The Shadow's Candidate"];

  int get xpForNextLevel => (level * 200) + (level * level * 50);

  double get xpProgress => currentXP / xpForNextLevel;

  double get hpPercentage => currentHP / maxHP;

  double get mpPercentage => currentMP / maxMP;

  void gainXP(int xp) {
    currentXP += xp;
    totalXP += xp;

    while (currentXP >= xpForNextLevel) {
      levelUp();
    }
  }

  void loseXP(int xp) {
    currentXP -= xp;
    totalXP -= xp; // Decrease effective total XP (can go negative)

    // Check for level down
    while (currentXP < 0 && level > 1) {
      levelDown();
    }

    // Ensure currentXP doesn't go below 0 after level adjustments
    if (currentXP < 0) {
      currentXP = 0;
    }
  }

  void levelDown() {
    level--;
    final prevLevelXP = (level * 200) + (level * level * 50);
    currentXP += prevLevelXP;

    // Decrease stats on level down
    stats.strength = (stats.strength - 3).clamp(10, 999);
    stats.willpower = (stats.willpower - 3).clamp(10, 999);
    stats.charisma = (stats.charisma - 2).clamp(10, 999);
    stats.endurance = (stats.endurance - 3).clamp(10, 999);
    stats.wisdom = (stats.wisdom - 2).clamp(10, 999);
    stats.intelligence = (stats.intelligence - 2).clamp(10, 999);
    stats.awareness = (stats.awareness - 2).clamp(10, 999);

    // Decrease HP/MP
    maxHP = (maxHP - 50).clamp(1000, 999999);
    maxMP = (maxMP - 25).clamp(500, 999999);
    currentHP = currentHP.clamp(0, maxHP);
    currentMP = currentMP.clamp(0, maxMP);

    // Check for rank down
    _checkRankDown();
  }

  void _checkRankDown() {
    if (level < 6 && rank != HunterRank.eRank) {
      rank = HunterRank.eRank;
      title = "The Shadow's Candidate";
    } else if (level < 11 && rank == HunterRank.dRank) {
      rank = HunterRank.eRank;
      title = "The Shadow's Candidate";
    } else if (level < 21 && rank == HunterRank.cRank) {
      rank = HunterRank.dRank;
      title = "Novice Hunter";
    } else if (level < 36 && rank == HunterRank.bRank) {
      rank = HunterRank.cRank;
      title = "Competent Hunter";
    } else if (level < 51 && rank == HunterRank.aRank) {
      rank = HunterRank.bRank;
      title = "Elite Hunter";
    } else if (level < 71 && rank == HunterRank.sRank) {
      rank = HunterRank.aRank;
      title = "Master Hunter";
    } else if (level < 91 && rank == HunterRank.specialSRank) {
      rank = HunterRank.sRank;
      title = "National Rank Hunter";
    }
  }

  void levelUp() {
    currentXP -= xpForNextLevel;
    level++;

    // Increase stats on level up
    stats.strength += 3;
    stats.willpower += 3;
    stats.charisma += 2;
    stats.endurance += 3;
    stats.wisdom += 2;
    stats.intelligence += 2;
    stats.awareness += 2;

    // Increase HP/MP
    maxHP += 50;
    maxMP += 25;
    currentHP = maxHP;
    currentMP = maxMP;

    // Check for rank up
    _checkRankUp();
    _checkShadowUnlock();
  }

  void _checkRankUp() {
    if (level >= 91 && rank != HunterRank.specialSRank) {
      rank = HunterRank.specialSRank;
      title = "The Shadow Monarch";
    } else if (level >= 71 && rank == HunterRank.sRank) {
      rank = HunterRank.specialSRank;
    } else if (level >= 51 && rank == HunterRank.aRank) {
      rank = HunterRank.sRank;
      title = "National Rank Hunter";
    } else if (level >= 36 && rank == HunterRank.bRank) {
      rank = HunterRank.aRank;
      title = "Master Hunter";
    } else if (level >= 21 && rank == HunterRank.cRank) {
      rank = HunterRank.bRank;
      title = "Elite Hunter";
    } else if (level >= 11 && rank == HunterRank.dRank) {
      rank = HunterRank.cRank;
      title = "Competent Hunter";
    } else if (level >= 6 && rank == HunterRank.eRank) {
      rank = HunterRank.dRank;
      title = "Novice Hunter";
    }
  }

  void _checkShadowUnlock() {
    List<String> newShadows = [];

    if (level >= 11 && !unlockedShadows.contains('Iron')) {
      newShadows.add('Iron');
    }
    if (level >= 21 && !unlockedShadows.contains('Tank')) {
      newShadows.add('Tank');
    }
    if (level >= 36 && !unlockedShadows.contains('Igris')) {
      newShadows.add('Igris');
    }
    if (level >= 51 && !unlockedShadows.contains('Beru')) {
      newShadows.add('Beru');
    }
    if (level >= 71 && !unlockedShadows.contains('Bellion')) {
      newShadows.add('Bellion');
    }
    if (level >= 91 && !unlockedShadows.contains('Army')) {
      newShadows.add('Army');
    }

    unlockedShadows = [...unlockedShadows, ...newShadows];
  }

  void takeDamage(int damage) {
    currentHP = (currentHP - damage).clamp(0, maxHP);
  }

  void consumeMP(int mp) {
    currentMP = (currentMP - mp).clamp(0, maxMP);
  }

  void heal(int amount) {
    currentHP = (currentHP + amount).clamp(0, maxHP);
  }

  void restoreMP(int amount) {
    currentMP = (currentMP + amount).clamp(0, maxMP);
  }
}

@HiveType(typeId: 1)
class PlayerStats extends HiveObject {
  @HiveField(0)
  int strength;

  @HiveField(1)
  int willpower;

  @HiveField(2)
  int charisma;

  @HiveField(3)
  int endurance;

  @HiveField(4)
  int wisdom;

  @HiveField(5)
  int intelligence;

  @HiveField(6)
  int awareness;

  PlayerStats({
    this.strength = 10,
    this.willpower = 10,
    this.charisma = 10,
    this.endurance = 10,
    this.wisdom = 10,
    this.intelligence = 10,
    this.awareness = 10,
  });
}

@HiveType(typeId: 2)
enum HunterRank {
  @HiveField(0)
  eRank,
  @HiveField(1)
  dRank,
  @HiveField(2)
  cRank,
  @HiveField(3)
  bRank,
  @HiveField(4)
  aRank,
  @HiveField(5)
  sRank,
  @HiveField(6)
  specialSRank,
}

@HiveType(typeId: 3)
enum HunterClass {
  @HiveField(0)
  warrior,
  @HiveField(1)
  mage,
  @HiveField(2)
  assassin,
}

@HiveType(typeId: 4)
class ActiveBuff extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String description;

  @HiveField(2)
  DateTime expiresAt;

  @HiveField(3)
  Map<String, double> statModifiers;

  ActiveBuff({
    required this.name,
    required this.description,
    required this.expiresAt,
    required this.statModifiers,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}

@HiveType(typeId: 5)
class ActiveDebuff extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  String description;

  @HiveField(2)
  DateTime expiresAt;

  @HiveField(3)
  Map<String, double> statModifiers;

  @HiveField(4)
  int stackCount;

  ActiveDebuff({
    required this.name,
    required this.description,
    required this.expiresAt,
    required this.statModifiers,
    this.stackCount = 1,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
