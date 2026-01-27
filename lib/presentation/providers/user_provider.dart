import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../data/models/user_profile.dart';
import '../../data/models/achievement.dart';
import '../../data/services/notification_service.dart';

class UserProvider extends ChangeNotifier {
  UserProfile? _userProfile;
  List<Achievement> _achievements = [];
  bool _isLoading = false;

  late Box<UserProfile> _userBox;
  late Box<Achievement> _achievementBox;

  UserProfile? get userProfile => _userProfile;
  List<Achievement> get achievements => _achievements;
  bool get isLoading => _isLoading;

  Future<void> loadUserProfile() async {
    _isLoading = true;

    try {
      _userBox = Hive.box<UserProfile>('userProfile');
      _achievementBox = Hive.box<Achievement>('achievements');

      if (_userBox.isNotEmpty) {
        _userProfile = _userBox.getAt(0);
        _updateDailyReset();
      }

      await _loadAchievements();
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createUserProfile(String name, HunterClass hunterClass) async {
    final stats = PlayerStats();
    _userProfile = UserProfile(
      name: name,
      hunterClass: hunterClass,
      stats: stats,
      createdAt: DateTime.now(),
      lastActive: DateTime.now(),
    );

    await _userBox.put(0, _userProfile!);
    await _initializeDefaultAchievements();
    notifyListeners();
  }

  Future<void> _loadAchievements() async {
    if (_achievementBox.isEmpty) {
      await _initializeDefaultAchievements();
    } else {
      _achievements = _achievementBox.values.toList();
    }
  }

  Future<void> _initializeDefaultAchievements() async {
    _achievements = Achievement.getDefaultAchievements();
    await _achievementBox.clear();
    for (int i = 0; i < _achievements.length; i++) {
      await _achievementBox.put(i, _achievements[i]);
    }
  }

  void _updateDailyReset() {
    if (_userProfile == null) return;

    final now = DateTime.now();
    final lastActive = _userProfile!.lastActive;

    // Check if it's a new day
    if (now.day != lastActive.day ||
        now.month != lastActive.month ||
        now.year != lastActive.year) {
      // Reset daily resources
      _userProfile!.currentHP = _userProfile!.maxHP;
      _userProfile!.currentMP = _userProfile!.maxMP;

      // Remove expired buffs/debuffs
      _userProfile!.activeBuffs.removeWhere((buff) => buff.isExpired);
      _userProfile!.activeDebuffs.removeWhere((debuff) => debuff.isExpired);

      _userProfile!.lastActive = now;
      _saveUserProfile();
    }
  }

  Future<void> gainXP(int xp, {String? source}) async {
    if (_userProfile == null) return;

    // Apply XP multipliers from active debuffs
    final xpMultiplier = _getXPMultiplier();
    final effectiveXP = (xp * xpMultiplier).round();

    final oldLevel = _userProfile!.level;
    _userProfile!.gainXP(effectiveXP);

    if (_userProfile!.level > oldLevel) {
      await NotificationService.showLevelUpNotification(_userProfile!.level);
      _checkLevelAchievements();
    }

    await _saveUserProfile();
    notifyListeners();
  }

  Future<void> loseXP(int xp, {String? source}) async {
    if (_userProfile == null) return;

    final oldLevel = _userProfile!.level;
    _userProfile!.loseXP(xp);

    if (_userProfile!.level < oldLevel) {
      await NotificationService.showPenaltyNotification(
        'Level Down',
        oldLevel - _userProfile!.level,
      );
    }

    await _saveUserProfile();
    notifyListeners();
  }

  Future<void> takeDamage(int damage) async {
    if (_userProfile == null) return;

    _userProfile!.takeDamage(damage);

    // CHECK FOR CRITICAL STATE: HP = 0
    if (_userProfile!.currentHP <= 0) {
      await _enterCriticalState();
    }

    await _saveUserProfile();
    notifyListeners();
  }

  /// CRITICAL STATE: HP reached 0
  /// As a coach, this means you've completely neglected your physical well-being
  Future<void> _enterCriticalState() async {
    if (_userProfile == null) return;

    // Apply devastating debuff
    final criticalDebuff = ActiveDebuff(
      name: 'Critical State',
      description:
          '💀 HP DEPLETED. You have neglected yourself to the breaking point.\n\n• -75% XP gains\n• -50% ALL stats\n• Risk of level loss\n\nYou MUST recover before you can progress.',
      expiresAt: DateTime.now().add(const Duration(hours: 48)),
      statModifiers: {
        'xpMultiplier': 0.25, // Only 25% XP gains
        'strengthMultiplier': 0.50,
        'willpowerMultiplier': 0.50,
        'charismaMultiplier': 0.50,
        'enduranceMultiplier': 0.50,
        'wisdomMultiplier': 0.50,
      },
    );

    // This debuff overrides all others
    _userProfile!.activeDebuffs.clear();
    _userProfile!.activeDebuffs.add(criticalDebuff);

    // Lose a level as consequence
    if (_userProfile!.level > 1) {
      _userProfile!.levelDown();
      await NotificationService.showPenaltyNotification(
          'CRITICAL STATE - Level Lost', 1);
    }

    // Change title to reflect fallen state
    _userProfile!.title = "The Broken Hunter";
  }

  Future<void> consumeMP(int mp) async {
    if (_userProfile == null) return;

    _userProfile!.consumeMP(mp);

    // CHECK FOR BURNOUT: MP = 0
    if (_userProfile!.currentMP <= 0) {
      await _enterBurnoutState();
    }

    await _saveUserProfile();
    notifyListeners();
  }

  /// BURNOUT STATE: MP reached 0
  /// As a coach, this means you've mentally exhausted yourself
  Future<void> _enterBurnoutState() async {
    if (_userProfile == null) return;

    // Apply burnout debuff
    final burnoutDebuff = ActiveDebuff(
      name: 'Burnout',
      description:
          '🧠 MENTAL EXHAUSTION. Your mind is fried.\n\n• 0% XP gains (BLOCKED)\n• -30% Intelligence\n• -30% Willpower\n\nYou pushed too hard. Rest and recover.',
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
      statModifiers: {
        'xpMultiplier': 0.0, // NO XP gains at all!
        'wisdomMultiplier': 0.70,
        'willpowerMultiplier': 0.70,
      },
    );

    // Don't override Critical State if active
    final hasCriticalState =
        _userProfile!.activeDebuffs.any((d) => d.name == 'Critical State');
    if (!hasCriticalState) {
      _userProfile!.activeDebuffs.clear();
      _userProfile!.activeDebuffs.add(burnoutDebuff);
    }

    // Change title
    _userProfile!.title = "The Exhausted";
  }

  Future<void> addBuff(ActiveBuff buff) async {
    if (_userProfile == null) return;

    // Remove existing buff of same type
    _userProfile!.activeBuffs.removeWhere((b) => b.name == buff.name);
    _userProfile!.activeBuffs.add(buff);

    await _saveUserProfile();
    notifyListeners();
  }

  Future<void> addDebuff(ActiveDebuff debuff) async {
    if (_userProfile == null) return;

    // Remove expired debuffs first
    _userProfile!.activeDebuffs.removeWhere((d) => d.isExpired);

    // Get severity of new debuff
    final newSeverity = _getDebuffSeverity(debuff.name);

    // Check if there's an existing debuff
    if (_userProfile!.activeDebuffs.isNotEmpty) {
      // Get the highest severity existing debuff
      final existingDebuff = _userProfile!.activeDebuffs.reduce((a, b) {
        final severityA = _getDebuffSeverity(a.name);
        final severityB = _getDebuffSeverity(b.name);
        return severityA > severityB ? a : b;
      });

      final existingSeverity = _getDebuffSeverity(existingDebuff.name);

      // Only replace if new debuff has higher severity
      if (newSeverity > existingSeverity) {
        _userProfile!.activeDebuffs.clear();
        _userProfile!.activeDebuffs.add(debuff);
      }
      // If same severity, replace the existing one
      else if (newSeverity == existingSeverity) {
        final index = _userProfile!.activeDebuffs.indexOf(existingDebuff);
        _userProfile!.activeDebuffs[index] = debuff;
      }
      // If lower severity, don't add it
    } else {
      // No existing debuffs, add the new one
      _userProfile!.activeDebuffs.add(debuff);
    }

    await _saveUserProfile();
    notifyListeners();
  }

  /// Get debuff severity level (higher = more severe)
  /// 5 = Critical, 4 = Catastrophic, 3 = Severe, 2 = Moderate, 1 = Minor
  int _getDebuffSeverity(String debuffName) {
    switch (debuffName) {
      case 'Critical State':
        return 5; // Maximum severity - HP depleted
      case 'Burnout':
        return 5; // Maximum severity - MP depleted
      case "Failure's Mark":
        return 5; // Maximum severity - Shadow Execution
      case 'Corrupted State':
        return 4; // Catastrophic
      case "Demon's Grip":
      case 'Time Void':
      case 'Fatigue':
      case 'Discipline Collapse':
        return 3; // Severe
      case 'Weakened State':
      case 'Entertainment Haze':
      case 'Mounting Dread':
      case 'Morning Fog':
        return 2; // Moderate
      case 'Sluggish Start':
      case 'Mind Fog':
      case 'Disorganized':
      case 'Light Sluggish':
        return 1; // Minor
      default:
        return 1; // Default to minor
    }
  }

  Future<void> updateStats(Map<String, int> statChanges) async {
    if (_userProfile == null) return;

    final stats = _userProfile!.stats;
    final statMultipliers = _getStatMultipliers();

    statChanges.forEach((stat, change) {
      // Apply stat multipliers from debuffs
      double multiplier = 1.0;
      switch (stat) {
        case 'strength':
          multiplier = statMultipliers['strength'] ?? 1.0;
          stats.strength =
              (stats.strength + (change * multiplier).round()).clamp(0, 999);
          break;
        case 'willpower':
          multiplier = statMultipliers['willpower'] ?? 1.0;
          stats.willpower =
              (stats.willpower + (change * multiplier).round()).clamp(0, 999);
          break;
        case 'charisma':
          multiplier = statMultipliers['charisma'] ?? 1.0;
          stats.charisma =
              (stats.charisma + (change * multiplier).round()).clamp(0, 999);
          break;
        case 'endurance':
          multiplier = statMultipliers['endurance'] ?? 1.0;
          stats.endurance =
              (stats.endurance + (change * multiplier).round()).clamp(0, 999);
          break;
        case 'wisdom':
          multiplier = statMultipliers['wisdom'] ?? 1.0;
          stats.wisdom =
              (stats.wisdom + (change * multiplier).round()).clamp(0, 999);
          break;
      }
    });

    _checkStatAchievements();
    await _saveUserProfile();
    notifyListeners();
  }

  /// Get combined XP multiplier from all active debuffs
  double _getXPMultiplier() {
    if (_userProfile == null) return 1.0;

    // Remove expired debuffs
    _userProfile!.activeDebuffs.removeWhere((d) => d.isExpired);

    // Since we only keep one debuff active, just get the first one
    if (_userProfile!.activeDebuffs.isEmpty) return 1.0;

    final debuff = _userProfile!.activeDebuffs.first;
    final xpMult = debuff.statModifiers['xpMultiplier'];

    return xpMult ?? 1.0;
  }

  /// Get combined stat multipliers from all active debuffs
  Map<String, double> _getStatMultipliers() {
    final multipliers = <String, double>{
      'strength': 1.0,
      'willpower': 1.0,
      'charisma': 1.0,
      'endurance': 1.0,
      'wisdom': 1.0,
    };

    if (_userProfile == null) return multipliers;

    // Remove expired debuffs
    _userProfile!.activeDebuffs.removeWhere((d) => d.isExpired);

    // Since we only keep one debuff active, just get the first one
    if (_userProfile!.activeDebuffs.isEmpty) return multipliers;

    final debuff = _userProfile!.activeDebuffs.first;

    debuff.statModifiers.forEach((stat, mult) {
      if (stat.endsWith('Multiplier') &&
          stat != 'xpMultiplier' &&
          stat != 'productivityMultiplier') {
        final statName = stat.replaceAll('Multiplier', '');
        if (multipliers.containsKey(statName)) {
          multipliers[statName] = mult;
        }
      }
    });

    return multipliers;
  }

  void _checkLevelAchievements() {
    final level = _userProfile!.level;

    for (final achievement in _achievements) {
      if (!achievement.isUnlocked &&
          achievement.category == AchievementCategory.monarchsPath) {
        if (level >= achievement.targetValue) {
          _unlockAchievement(achievement);
        }
      }
    }
  }

  void _checkStatAchievements() {
    final stats = _userProfile!.stats;

    for (final achievement in _achievements) {
      if (!achievement.isUnlocked &&
          achievement.category == AchievementCategory.statMaster) {
        int currentStatValue = 0;
        switch (achievement.id) {
          case 'strength_adept':
            currentStatValue = stats.strength;
            break;
          case 'willpower_titan':
            currentStatValue = stats.willpower;
            break;
          case 'charisma_master':
            currentStatValue = stats.charisma;
            break;
          case 'endurance_guardian':
            currentStatValue = stats.endurance;
            break;
          case 'wisdom_sage':
            currentStatValue = stats.wisdom;
            break;
        }

        if (currentStatValue >= achievement.targetValue) {
          _unlockAchievement(achievement);
        }
      }
    }
  }

  Future<void> _unlockAchievement(Achievement achievement) async {
    achievement.unlock();

    // Apply rewards
    await gainXP(achievement.xpReward,
        source: 'Achievement: ${achievement.name}');
    if (achievement.statRewards.isNotEmpty) {
      await updateStats(achievement.statRewards);
    }

    // Update title if provided
    if (achievement.titleUnlock != null) {
      _userProfile!.title = achievement.titleUnlock!;
    }

    // Unlock shadow if provided
    if (achievement.shadowUnlock != null &&
        !_userProfile!.unlockedShadows.contains(achievement.shadowUnlock)) {
      _userProfile!.unlockedShadows.add(achievement.shadowUnlock!);
    }

    await NotificationService.showAchievementUnlocked(achievement.name);
    await _saveAchievements();
    await _saveUserProfile();
  }

  Future<void> enterPenaltyZone() async {
    if (_userProfile == null) return;

    _userProfile!.isInPenaltyZone = true;
    _userProfile!.title = "The Fallen Hunter";

    await _saveUserProfile();
    notifyListeners();
  }

  Future<void> exitPenaltyZone() async {
    if (_userProfile == null) return;

    _userProfile!.isInPenaltyZone = false;
    _userProfile!.title = "The Redeemed";

    await _saveUserProfile();
    notifyListeners();
  }

  Future<void> _saveUserProfile() async {
    if (_userProfile != null) {
      await _userBox.put(0, _userProfile!);
    }
  }

  Future<void> _saveAchievements() async {
    await _achievementBox.clear();
    for (int i = 0; i < _achievements.length; i++) {
      await _achievementBox.put(i, _achievements[i]);
    }
  }

  String getRankDisplayName() {
    switch (_userProfile?.rank) {
      case HunterRank.eRank:
        return 'E-Rank Hunter';
      case HunterRank.dRank:
        return 'D-Rank Hunter';
      case HunterRank.cRank:
        return 'C-Rank Hunter';
      case HunterRank.bRank:
        return 'B-Rank Hunter';
      case HunterRank.aRank:
        return 'A-Rank Hunter';
      case HunterRank.sRank:
        return 'S-Rank Hunter';
      case HunterRank.specialSRank:
        return 'Special S-Rank Hunter';
      default:
        return 'Unknown Rank';
    }
  }

  Color getRankColor() {
    switch (_userProfile?.rank) {
      case HunterRank.eRank:
        return Colors.grey;
      case HunterRank.dRank:
        return Colors.brown;
      case HunterRank.cRank:
        return Colors.green;
      case HunterRank.bRank:
        return Colors.blue;
      case HunterRank.aRank:
        return Colors.purple;
      case HunterRank.sRank:
        return Colors.orange;
      case HunterRank.specialSRank:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> resetProgress() async {
    // 1. Delete User Profile
    await _userBox.clear();
    _userProfile = null;

    // 2. Reset Achievements
    await _initializeDefaultAchievements();

    notifyListeners();
  }
}
