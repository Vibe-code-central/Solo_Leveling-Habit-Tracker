import 'package:hive/hive.dart';

part 'shop_item.g.dart';

/// Types of shop items
@HiveType(typeId: 25)
enum ShopItemType {
  @HiveField(0)
  consumable, // One-time use (potions, buffs)

  @HiveField(1)
  protection, // Penalty blockers, shields

  @HiveField(2)
  streakItem, // Streak freeze, revival, bonuses

  @HiveField(3)
  permanent, // Permanent stat boosts, passive upgrades

  @HiveField(4)
  legendary, // Rare permanent passive items

  @HiveField(5)
  cosmetic, // Titles, avatar frames, themes

  @HiveField(6)
  special, // Mystery boxes, special mechanics

  @HiveField(7)
  lifestylePass, // Weekend pass, vacation mode
}

/// Rarity levels (affects visuals, pricing)
@HiveType(typeId: 26)
enum ShopItemRarity {
  @HiveField(0)
  common, // White

  @HiveField(1)
  rare, // Blue

  @HiveField(2)
  epic, // Purple

  @HiveField(3)
  legendary, // Gold
}

/// Shop item definition
@HiveType(typeId: 27)
class ShopItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  int cost;

  @HiveField(4)
  ShopItemType type;

  @HiveField(5)
  ShopItemRarity rarity;

  @HiveField(6)
  bool isOneTimeUse;

  /// Max stock available in shop (null = unlimited)
  @HiveField(7)
  int? maxStock;

  /// Max lifetime purchases allowed (null = unlimited)
  @HiveField(8)
  int? lifetimePurchaseLimit;

  /// Cooldown between purchases in hours (null = no cooldown)
  @HiveField(9)
  int? cooldownHours;

  /// Effects data (varies by item type)
  /// Examples:
  /// - {"hpRestore": 300} for healing potion
  /// - {"statBonus": {"strength": 5}} for stat boost
  /// - {"xpBoostPercent": 25, "durationHours": 24} for XP buff
  @HiveField(10)
  Map<String, dynamic>? effects;

  ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.type,
    required this.rarity,
    required this.isOneTimeUse,
    this.maxStock,
    this.lifetimePurchaseLimit,
    this.cooldownHours,
    this.effects,
  });

  /// Get display color based on rarity
  int get rarityColor {
    switch (rarity) {
      case ShopItemRarity.common:
        return 0xFFB0B0B0; // Gray
      case ShopItemRarity.rare:
        return 0xFF00D9FF; // Blue
      case ShopItemRarity.epic:
        return 0xFF9D4EDD; // Purple
      case ShopItemRarity.legendary:
        return 0xFFFFD700; // Gold
    }
  }

  /// Get rarity name
  String get rarityName {
    switch (rarity) {
      case ShopItemRarity.common:
        return 'Common';
      case ShopItemRarity.rare:
        return 'Rare';
      case ShopItemRarity.epic:
        return 'Epic';
      case ShopItemRarity.legendary:
        return 'Legendary';
    }
  }
}
