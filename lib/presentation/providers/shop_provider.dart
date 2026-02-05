import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../data/models/shop_item.dart';
import '../../data/models/user_profile.dart'; // Required for ActiveBuff
import 'user_provider.dart';

class ShopProvider extends ChangeNotifier {
  late Box _shopBox;

  List<ShopItem> _catalog = [];
  Map<String, int> _stock = {}; // Current stock for limited items
  Map<String, DateTime> _lastPurchase = {}; // For cooldowns

  List<ShopItem> get catalog => _catalog;

  // Filter by category
  List<ShopItem> get consumables =>
      _catalog.where((i) => i.type == ShopItemType.consumable).toList();
  List<ShopItem> get protection =>
      _catalog.where((i) => i.type == ShopItemType.protection).toList();
  List<ShopItem> get streakItems =>
      _catalog.where((i) => i.type == ShopItemType.streakItem).toList();
  List<ShopItem> get permanent =>
      _catalog.where((i) => i.type == ShopItemType.permanent).toList();
  List<ShopItem> get legendary =>
      _catalog.where((i) => i.type == ShopItemType.legendary).toList();
  List<ShopItem> get cosmetic =>
      _catalog.where((i) => i.type == ShopItemType.cosmetic).toList();
  List<ShopItem> get special =>
      _catalog.where((i) => i.type == ShopItemType.special).toList();
  List<ShopItem> get lifestylePass =>
      _catalog.where((i) => i.type == ShopItemType.lifestylePass).toList();

  Future<void> initialize() async {
    _shopBox = Hive.box('shop');

    _loadCatalog();
    _loadStock();
    _loadCooldowns();
  }

  void _loadCatalog() {
    _catalog = _getDefaultCatalog();
  }

  void _loadStock() {
    _stock = Map<String, int>.from(_shopBox.get('stock', defaultValue: {}));
  }

  void _loadCooldowns() {
    final Map cooldownData = _shopBox.get('cooldowns', defaultValue: {});
    _lastPurchase = cooldownData.map((key, value) =>
        MapEntry(key, DateTime.fromMillisecondsSinceEpoch(value)));
  }

  // Check if item can be purchased
  bool canPurchase(String itemId, UserProvider userProvider) {
    final item = _catalog.firstWhere((i) => i.id == itemId);
    final inventory = userProvider.inventory;

    if (inventory == null) return false;

    // Check Gold
    if (inventory.gold < item.cost) return false;

    // Check stock
    if (item.maxStock != null) {
      final currentStock = _stock[itemId] ?? item.maxStock!;
      if (currentStock <= 0) return false;
    }

    // Check lifetime purchase limit
    if (item.lifetimePurchaseLimit != null) {
      final purchased =
          inventory.items.where((i) => i.shopItemId == itemId).length;
      if (purchased >= item.lifetimePurchaseLimit!) return false;
    }

    // Check cooldown
    if (item.cooldownHours != null && _lastPurchase.containsKey(itemId)) {
      final hoursSince =
          DateTime.now().difference(_lastPurchase[itemId]!).inHours;
      if (hoursSince < item.cooldownHours!) return false;
    }

    return true;
  }

  // Purchase item
  Future<bool> purchaseItem(String itemId, UserProvider userProvider) async {
    if (!canPurchase(itemId, userProvider)) return false;

    final item = _catalog.firstWhere((i) => i.id == itemId);

    // Deduct Gold
    final success =
        await userProvider.spendGold(item.cost, 'Shop: ${item.name}');
    if (!success) return false;

    // Add to inventory
    await userProvider.addInventoryItem(itemId);

    // Update stock
    if (item.maxStock != null) {
      _stock[itemId] = (_stock[itemId] ?? item.maxStock!) - 1;
      await _shopBox.put('stock', _stock);
    }

    // Update cooldown
    if (item.cooldownHours != null) {
      _lastPurchase[itemId] = DateTime.now();
      final cooldownData = _lastPurchase
          .map((key, value) => MapEntry(key, value.millisecondsSinceEpoch));
      await _shopBox.put('cooldowns', cooldownData);
    }

    debugPrint('🛒 Purchased: ${item.name} for ${item.cost} Gold');
    notifyListeners();
    return true;
  }

  // Use/activate item
  Future<Map<String, dynamic>> useItem(
      String inventoryItemId, UserProvider userProvider) async {
    final inventory = userProvider.inventory;
    if (inventory == null)
      return {'success': false, 'message': 'Inventory not found'};

    final inventoryItem = inventory.items
        .where((i) => i.id == inventoryItemId && !i.isUsed)
        .firstOrNull;
    if (inventoryItem == null)
      return {'success': false, 'message': 'Item not found or already used'};

    final shopItem =
        _catalog.firstWhere((i) => i.id == inventoryItem.shopItemId);

    // Apply effects based on item type
    final result = await _applyItemEffects(shopItem, userProvider);

    // Mark as used
    await userProvider.useInventoryItem(inventoryItemId);

    notifyListeners();
    return result;
  }

  Future<Map<String, dynamic>> _applyItemEffects(
      ShopItem item, UserProvider userProvider) async {
    final effects = item.effects;
    final user = userProvider.userProfile;

    if (user == null) return {'success': false, 'message': 'User not found'};
    if (effects == null)
      return {'success': true, 'message': 'Item used (no effects)'};

    String message = '';

    // HP Restore
    if (effects.containsKey('hpRestore')) {
      final amount = (effects['hpRestore'] as num?)?.toInt() ?? 0;
      user.currentHP = (user.currentHP + amount).clamp(0, user.maxHP).toInt();
      message += '+$amount HP restored. ';
    }

    // MP Restore
    if (effects.containsKey('mpRestore')) {
      final amount = (effects['mpRestore'] as num?)?.toInt() ?? 0;
      user.currentMP = (user.currentMP + amount).clamp(0, user.maxMP).toInt();
      message += '+$amount MP restored. ';
    }

    // Full HP/MP
    if (effects.containsKey('fullRestore') && effects['fullRestore'] == true) {
      user.currentHP = user.maxHP;
      user.currentMP = user.maxMP;
      message += 'HP and MP fully restored! ';
    }

    // Streak Protection (handled externally by checking inventory)
    if (effects.containsKey('streakProtectionDays')) {
      message +=
          'Streak protected for ${effects['streakProtectionDays']} days! ';
    }

    // XP Boost
    if (effects.containsKey('xpBoostPercent')) {
      final percent = (effects['xpBoostPercent'] as num).toDouble();
      final durationHours = (effects['durationHours'] as num?)?.toInt() ?? 1;

      final buff = ActiveBuff(
        name: item.name,
        description: '+${percent.toInt()}% XP for $durationHours hours',
        expiresAt: DateTime.now().add(Duration(hours: durationHours)),
        statModifiers: {'xpMultiplier': 1.0 + (percent / 100.0)},
      );

      await userProvider.addBuff(buff);
      message +=
          '+${percent.toInt()}% XP boost activated for $durationHours hours! ';
    }

    // Gold Boost (TODO: UserProvider needs goldMultiplier support, but we can store it in Buff now)
    if (effects.containsKey('goldBoostPercent')) {
      final percent = (effects['goldBoostPercent'] as num).toDouble();
      final durationHours = (effects['durationHours'] as num?)?.toInt() ?? 1;

      final buff = ActiveBuff(
        name: item.name,
        description: '+${percent.toInt()}% Gold for $durationHours hours',
        expiresAt: DateTime.now().add(Duration(hours: durationHours)),
        statModifiers: {'goldMultiplier': 1.0 + (percent / 100.0)},
      );

      await userProvider.addBuff(buff);
      message +=
          '+${percent.toInt()}% Gold boost activated for $durationHours hours! ';
    }

    // Stat Increase (permanent)
    final stats = effects['statBonus'] as Map<String, dynamic>?;
    if (stats != null) {
      for (var entry in stats.entries) {
        switch (entry.key) {
          case 'strength':
            user.stats.strength += (entry.value as num).toInt();
            break;
          case 'awareness':
            user.stats.awareness += (entry.value as num).toInt();
            break;
          case 'intelligence':
            user.stats.intelligence += (entry.value as num).toInt();
            break;
          case 'willpower':
            user.stats.willpower += (entry.value as num).toInt();
            break;
          case 'endurance':
            user.stats.endurance += (entry.value as num).toInt();
            break;
        }
      }
      message += 'Stats permanently increased! ';
    }

    await user.save();

    return {'success': true, 'message': message.trim()};
  }

  // ══════════════════════════════════════════════════════════════
  // 🛒 SHOP CATALOG (36 ITEMS)
  // ══════════════════════════════════════════════════════════════

  List<ShopItem> _getDefaultCatalog() {
    return [
      // ──────────────────────────────────────────────────────────
      // CONSUMABLES (Potions & Buffs)
      // ──────────────────────────────────────────────────────────
      ShopItem(
        id: 'lesser_healing_potion',
        name: 'Lesser Healing Potion',
        description: 'Restores 300 HP. A basic potion for minor injuries.',
        cost: 150,
        type: ShopItemType.consumable,
        rarity: ShopItemRarity.common,
        isOneTimeUse: true,
        effects: {'hpRestore': 300},
      ),
      ShopItem(
        id: 'healing_potion',
        name: 'Healing Potion',
        description: 'Restores 500 HP. Standard healing for serious wounds.',
        cost: 300,
        type: ShopItemType.consumable,
        rarity: ShopItemRarity.rare,
        isOneTimeUse: true,
        effects: {'hpRestore': 500},
      ),
      ShopItem(
        id: 'greater_healing_potion',
        name: 'Greater Healing Potion',
        description: 'Restores 1000 HP. Powerful healing for grave injuries.',
        cost: 600,
        type: ShopItemType.consumable,
        rarity: ShopItemRarity.epic,
        isOneTimeUse: true,
        effects: {'hpRestore': 1000},
      ),
      ShopItem(
        id: 'mana_elixir',
        name: 'Mana Elixir',
        description: 'Restores 300 MP. Replenish your mana reserves.',
        cost: 200,
        type: ShopItemType.consumable,
        rarity: ShopItemRarity.rare,
        isOneTimeUse: true,
        effects: {'mpRestore': 300},
      ),
      ShopItem(
        id: 'elixir_of_life',
        name: 'Elixir of Life',
        description: 'Fully restores HP and MP. A miraculous remedy.',
        cost: 1500,
        type: ShopItemType.consumable,
        rarity: ShopItemRarity.legendary,
        isOneTimeUse: true,
        maxStock: 3,
        effects: {'fullRestore': true},
      ),
      ShopItem(
        id: 'xp_boost_small',
        name: 'Hunter\'s Blessing',
        description: '+25% XP for 24 hours. Train more effectively.',
        cost: 500,
        type: ShopItemType.consumable,
        rarity: ShopItemRarity.rare,
        isOneTimeUse: true,
        effects: {'xpBoostPercent': 25, 'durationHours': 24},
      ),
      ShopItem(
        id: 'xp_boost_large',
        name: 'System\'s Favor',
        description: '+50% XP for 48 hours. The System smiles upon you.',
        cost: 1200,
        type: ShopItemType.consumable,
        rarity: ShopItemRarity.epic,
        isOneTimeUse: true,
        maxStock: 5,
        effects: {'xpBoostPercent': 50, 'durationHours': 48},
      ),
      ShopItem(
        id: 'gold_boost',
        name: 'Merchant\'s Charm',
        description: '+30% Gold from habits for 24 hours.',
        cost: 800,
        type: ShopItemType.consumable,
        rarity: ShopItemRarity.rare,
        isOneTimeUse: true,
        effects: {'goldBoostPercent': 30, 'durationHours': 24},
      ),

      // ──────────────────────────────────────────────────────────
      // PROTECTION (Safety Nets)
      // ──────────────────────────────────────────────────────────
      ShopItem(
        id: 'streak_freeze_1day',
        name: 'Ice Shield',
        description: 'Protect your streak for 1 day if you miss a habit.',
        cost: 300,
        type: ShopItemType.protection,
        rarity: ShopItemRarity.common,
        isOneTimeUse: true,
        effects: {'streakProtectionDays': 1},
      ),
      ShopItem(
        id: 'streak_freeze_3day',
        name: 'Frost Barrier',
        description: 'Protect your streak for 3 days of inactivity.',
        cost: 750,
        type: ShopItemType.protection,
        rarity: ShopItemRarity.rare,
        isOneTimeUse: true,
        effects: {'streakProtectionDays': 3},
      ),
      ShopItem(
        id: 'streak_freeze_week',
        name: 'Glacial Fortress',
        description: 'Protect your streak for an entire week!',
        cost: 1500,
        type: ShopItemType.protection,
        rarity: ShopItemRarity.epic,
        isOneTimeUse: true,
        maxStock: 2,
        effects: {'streakProtectionDays': 7},
      ),
      ShopItem(
        id: 'penalty_shield',
        name: 'Guardian\'s Blessing',
        description: 'Negate the next bad habit penalty.',
        cost: 400,
        type: ShopItemType.protection,
        rarity: ShopItemRarity.rare,
        isOneTimeUse: true,
        effects: {'negateNextPenalty': true},
      ),
      ShopItem(
        id: 'resurrection_stone',
        name: 'Resurrection Stone',
        description: 'Revive with 50% HP/MP if you hit 0 HP. One-time save.',
        cost: 2000,
        type: ShopItemType.protection,
        rarity: ShopItemRarity.legendary,
        isOneTimeUse: true,
        lifetimePurchaseLimit: 3,
        effects: {'reviveOnDeath': true, 'revivePercent': 50},
      ),

      // ──────────────────────────────────────────────────────────
      // STREAK ITEMS
      // ──────────────────────────────────────────────────────────
      ShopItem(
        id: 'streak_milestone_boost',
        name: 'Momentum Amplifier',
        description: '+100 Gold bonus at your next streak milestone.',
        cost: 500,
        type: ShopItemType.streakItem,
        rarity: ShopItemRarity.rare,
        isOneTimeUse: true,
        effects: {'streakBonusGold': 100},
      ),
      ShopItem(
        id: 'double_streak_reward',
        name: 'Echo of Achievement',
        description: 'Double your next streak milestone reward.',
        cost: 1000,
        type: ShopItemType.streakItem,
        rarity: ShopItemRarity.epic,
        isOneTimeUse: true,
        maxStock: 5,
        effects: {'doubleNextMilestone': true},
      ),

      // ──────────────────────────────────────────────────────────
      // PERMANENT UPGRADES
      // ──────────────────────────────────────────────────────────
      ShopItem(
        id: 'stat_token_common',
        name: 'Lesser Stat Stone',
        description: '+1 to any stat permanently.',
        cost: 800,
        type: ShopItemType.permanent,
        rarity: ShopItemRarity.common,
        isOneTimeUse: false,
        effects: {
          'statBonus': {'any': 1}
        },
      ),
      ShopItem(
        id: 'stat_token_rare',
        name: 'Stat Crystal',
        description: '+3 to any stat permanently.',
        cost: 2000,
        type: ShopItemType.permanent,
        rarity: ShopItemRarity.rare,
        isOneTimeUse: false,
        effects: {
          'statBonus': {'any': 3}
        },
      ),
      ShopItem(
        id: 'hp_boost_permanent',
        name: 'Vitality Orb',
        description: '+100 Max HP permanently.',
        cost: 1500,
        type: ShopItemType.permanent,
        rarity: ShopItemRarity.rare,
        isOneTimeUse: false,
        lifetimePurchaseLimit: 10,
        effects: {'maxHpBonus': 100},
      ),
      ShopItem(
        id: 'mp_boost_permanent',
        name: 'Arcane Core',
        description: '+100 Max MP permanently.',
        cost: 1500,
        type: ShopItemType.permanent,
        rarity: ShopItemRarity.rare,
        isOneTimeUse: false,
        lifetimePurchaseLimit: 10,
        effects: {'maxMpBonus': 100},
      ),
      ShopItem(
        id: 'xp_multiplier_passive',
        name: 'Hunter\'s Mark',
        description: '+5% XP gain permanently.',
        cost: 3000,
        type: ShopItemType.permanent,
        rarity: ShopItemRarity.epic,
        isOneTimeUse: false,
        lifetimePurchaseLimit: 5,
        effects: {'passiveXpBoost': 5},
      ),
      ShopItem(
        id: 'gold_multiplier_passive',
        name: 'Merchant\'s License',
        description: '+10% Gold gain permanently.',
        cost: 3500,
        type: ShopItemType.permanent,
        rarity: ShopItemRarity.epic,
        isOneTimeUse: false,
        lifetimePurchaseLimit: 3,
        effects: {'passiveGoldBoost': 10},
      ),

      // ──────────────────────────────────────────────────────────
      // LEGENDARY ITEMS
      // ──────────────────────────────────────────────────────────
      ShopItem(
        id: 'shadow_monarch_blessing',
        name: 'Shadow Monarch\'s Blessing',
        description:
            'All stats +5, +20% XP, +20% Gold permanently. True power.',
        cost: 10000,
        type: ShopItemType.legendary,
        rarity: ShopItemRarity.legendary,
        isOneTimeUse: false,
        lifetimePurchaseLimit: 1,
        effects: {
          'statBonus': {
            'strength': 5,
            'agility': 5,
            'intelligence': 5,
            'willpower': 5,
            'endurance': 5
          },
          'passiveXpBoost': 20,
          'passiveGoldBoost': 20,
        },
      ),
      ShopItem(
        id: 'system_override',
        name: 'System Override Key',
        description: 'Unlock a secret System feature. (Future content)',
        cost: 15000,
        type: ShopItemType.legendary,
        rarity: ShopItemRarity.legendary,
        isOneTimeUse: false,
        lifetimePurchaseLimit: 1,
        maxStock: 1,
        effects: {'unlockSecret': true},
      ),
      ShopItem(
        id: 'eternal_growth',
        name: 'Essence of Eternal Growth',
        description: 'Gain +1 to all stats every 7-day streak milestone.',
        cost: 20000,
        type: ShopItemType.legendary,
        rarity: ShopItemRarity.legendary,
        isOneTimeUse: false,
        lifetimePurchaseLimit: 1,
        effects: {'autoStatGrowth': true},
      ),

      // ──────────────────────────────────────────────────────────
      // TITLES & COSMETICS
      // ──────────────────────────────────────────────────────────
      ShopItem(
        id: 'title_monarch_shadows',
        name: 'Title: Monarch of Shadows',
        description: 'Unlock the prestigious title for your profile.',
        cost: 5000,
        type: ShopItemType.cosmetic,
        rarity: ShopItemRarity.legendary,
        isOneTimeUse: false,
        lifetimePurchaseLimit: 1,
        effects: {'unlockTitle': 'Monarch of Shadows'},
      ),
      ShopItem(
        id: 'title_solo_player',
        name: 'Title: The Solo Player',
        description: 'For those who walk alone.',
        cost: 2500,
        type: ShopItemType.cosmetic,
        rarity: ShopItemRarity.epic,
        isOneTimeUse: false,
        lifetimePurchaseLimit: 1,
        effects: {'unlockTitle': 'The Solo Player'},
      ),
      ShopItem(
        id: 'title_demon_slayer',
        name: 'Title: Demon Slayer',
        description: 'Master of vanquishing bad habits.',
        cost: 1500,
        type: ShopItemType.cosmetic,
        rarity: ShopItemRarity.rare,
        isOneTimeUse: false,
        lifetimePurchaseLimit: 1,
        effects: {'unlockTitle': 'Demon Slayer'},
      ),
      ShopItem(
        id: 'profile_theme_shadow',
        name: 'Shadow Army Theme',
        description: 'Unlock dark, shadowy UI theme.',
        cost: 3000,
        type: ShopItemType.cosmetic,
        rarity: ShopItemRarity.epic,
        isOneTimeUse: false,
        lifetimePurchaseLimit: 1,
        effects: {'unlockTheme': 'shadow_army'},
      ),

      // ──────────────────────────────────────────────────────────
      // SPECIAL & MYSTERY
      // ──────────────────────────────────────────────────────────
      ShopItem(
        id: 'mystery_box_common',
        name: 'Mystery Box',
        description: 'Contains a random common or rare item.',
        cost: 400,
        type: ShopItemType.special,
        rarity: ShopItemRarity.common,
        isOneTimeUse: true,
        cooldownHours: 48,
        effects: {'mysteryReward': 'common_rare'},
      ),
      ShopItem(
        id: 'mystery_box_epic',
        name: 'Epic Mystery Box',
        description: 'Contains a random epic or legendary item!',
        cost: 2000,
        type: ShopItemType.special,
        rarity: ShopItemRarity.epic,
        isOneTimeUse: true,
        maxStock: 10,
        cooldownHours: 168, // 1 week
        effects: {'mysteryReward': 'epic_legendary'},
      ),
      ShopItem(
        id: 'daily_refresh',
        name: 'Daily Quest Refresh',
        description: 'Reset all today\'s habits and get another chance.',
        cost: 1000,
        type: ShopItemType.special,
        rarity: ShopItemRarity.rare,
        isOneTimeUse: true,
        cooldownHours: 24,
        effects: {'resetDailyQuests': true},
      ),
      ShopItem(
        id: 'instant_level_up',
        name: 'Leveling Stone',
        description: 'Instantly gain enough XP to level up once.',
        cost: 5000,
        type: ShopItemType.special,
        rarity: ShopItemRarity.legendary,
        isOneTimeUse: true,
        lifetimePurchaseLimit: 3,
        effects: {'instantLevelUp': true},
      ),

      // ──────────────────────────────────────────────────────────
      // LIFESTYLE PASSES
      // ──────────────────────────────────────────────────────────
      ShopItem(
        id: 'weekend_pass',
        name: 'Weekend Warrior Pass',
        description: 'No penalties on weekends for 30 days.',
        cost: 1500,
        type: ShopItemType.lifestylePass,
        rarity: ShopItemRarity.rare,
        isOneTimeUse: false,
        effects: {'weekendPenaltyImmunity': 30},
      ),
      ShopItem(
        id: 'vacation_mode',
        name: 'Vacation Mode (7 Days)',
        description: 'Pause all penalties for 7 days. Streaks are preserved.',
        cost: 3000,
        type: ShopItemType.lifestylePass,
        rarity: ShopItemRarity.epic,
        isOneTimeUse: true,
        effects: {'vacationDays': 7},
      ),
    ];
  }
}
