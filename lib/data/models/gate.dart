import 'package:hive/hive.dart';

part 'gate.g.dart';

/// Types of gates
@HiveType(typeId: 32)
enum GateType {
  @HiveField(0)
  surprise, // Blue gate, 10% spawn, quick challenges

  @HiveField(1)
  red, // Red gate, 1-5% spawn, boss battle
}

/// Gate rewards (predetermined at spawn)
@HiveType(typeId: 33)
class GateReward extends HiveObject {
  @HiveField(0)
  int goldEarned;

  @HiveField(1)
  int xpEarned;

  @HiveField(2)
  List<String> itemsDropped; // Shop item IDs

  GateReward({
    required this.goldEarned,
    required this.xpEarned,
    List<String>? itemsDropped,
  }) : itemsDropped = itemsDropped ?? [];
}

/// A spawned gate instance
@HiveType(typeId: 34)
class Gate extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  GateType type;

  @HiveField(2)
  DateTime spawnedAt;

  @HiveField(3)
  DateTime expiresAt;

  @HiveField(4)
  bool isActive;

  @HiveField(5)
  bool isCompleted;

  @HiveField(6)
  bool isFailed;

  /// Rewards are predetermined at spawn (prevents save scumming)
  @HiveField(7)
  GateReward? predeterminedReward;

  /// Random seed used for this gate (for reproducibility)
  @HiveField(8)
  int spawnSeed;

  Gate({
    required this.id,
    required this.type,
    required this.spawnedAt,
    required this.expiresAt,
    this.isActive = true,
    this.isCompleted = false,
    this.isFailed = false,
    this.predeterminedReward,
    required this.spawnSeed,
  });

  /// Check if gate is expired
  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Get remaining time
  Duration get timeRemaining =>
      isExpired ? Duration.zero : expiresAt.difference(DateTime.now());

  /// Get gate display name
  String get displayName {
    switch (type) {
      case GateType.surprise:
        return 'Surprise Gate';
      case GateType.red:
        return 'Red Gate';
    }
  }

  /// Get gate icon/emoji
  String get icon {
    switch (type) {
      case GateType.surprise:
        return '🟦';
      case GateType.red:
        return '🟥';
    }
  }
}

/// Red Gate boss battle state
@HiveType(typeId: 35)
class RedGateBattle extends HiveObject {
  @HiveField(0)
  String gateId;

  @HiveField(1)
  int stage; // 1 = Trials, 2 = Boss Fight

  /// Boss stats
  @HiveField(2)
  int bossCurrentHP;

  @HiveField(3)
  int bossMaxHP;

  /// Player snapshot (stats at time of gate entry - locked)
  @HiveField(4)
  int playerSnapshotHP;

  @HiveField(5)
  int playerSnapshotMP;

  @HiveField(6)
  int playerSnapshotStr;

  @HiveField(7)
  int playerSnapshotInt;

  @HiveField(8)
  int playerSnapshotEnd;

  @HiveField(9)
  int playerSnapshotWil;

  /// Battle progress
  @HiveField(10)
  int playerCurrentHP;

  @HiveField(11)
  int playerCurrentMP;

  @HiveField(12)
  int turnCount;

  @HiveField(13)
  int potionsUsed;

  @HiveField(14)
  bool isActive;

  @HiveField(15)
  List<String> battleLog;

  /// Available inventory items (snapshot at entry)
  @HiveField(16)
  List<String> availableItemIds;

  RedGateBattle({
    required this.gateId,
    this.stage = 1,
    required this.bossCurrentHP,
    required this.bossMaxHP,
    required this.playerSnapshotHP,
    required this.playerSnapshotMP,
    required this.playerSnapshotStr,
    required this.playerSnapshotInt,
    required this.playerSnapshotEnd,
    required this.playerSnapshotWil,
    required this.playerCurrentHP,
    required this.playerCurrentMP,
    this.turnCount = 0,
    this.potionsUsed = 0,
    this.isActive = true,
    List<String>? battleLog,
    List<String>? availableItemIds,
  })  : battleLog = battleLog ?? [],
        availableItemIds = availableItemIds ?? [];

  /// Calculate damage for attack action
  int calculateAttackDamage() {
    return (playerSnapshotStr / 10).round();
  }

  /// Calculate damage for magic action
  int calculateMagicDamage() {
    return (playerSnapshotInt / 10).round();
  }

  /// Calculate healing for defend action
  int calculateDefendHealing() {
    return (playerSnapshotEnd / 5).round();
  }

  /// Calculate damage for special action
  int calculateSpecialDamage() {
    return (playerSnapshotWil / 8).round();
  }

  /// Boss is defeated
  bool get isBossDefeated => bossCurrentHP <= 0;

  /// Player is defeated
  bool get isPlayerDefeated => playerCurrentHP <= 0 || playerCurrentMP < 0;
}
