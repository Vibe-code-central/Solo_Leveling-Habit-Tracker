part of 'user_provider.dart';

extension UserDebuffMethods on UserProvider {
  // 🎯 DEBUFF METHODS

  Future<void> _loadDebuffs() async {
    _activeDebuffs = _debuffBox.values.where((d) => d.isActive).toList();
  }

  Future<void> applyDebuff(Debuff debuff) async {
    await _debuffBox.add(debuff);
    _activeDebuffs.add(debuff);
    notify();
  }

  double getXPMultiplier() {
    double multiplier = 1.0;

    for (var debuff in _activeDebuffs.where((d) => d.isActive)) {
      multiplier -= debuff.xpReductionPercent;
    }

    return multiplier.clamp(0.1, 1.0); // Min 10% XP
  }

  Map<String, int> getTemporaryStatReductions() {
    Map<String, int> total = {};

    for (var debuff in _activeDebuffs.where((d) => d.isActive)) {
      debuff.tempStatReduction.forEach((stat, value) {
        total[stat] = (total[stat] ?? 0) + value;
      });
    }

    return total;
  }

  bool isLevelUpBlocked() {
    return _activeDebuffs.any(
        (d) => d.isActive && d.specialEffect == DebuffSpecialEffect.levelBlock);
  }

  bool canEarnStat(String stat) {
    // Check if INT/WIS blocked
    if ((stat == 'intelligence' || stat == 'wisdom') &&
        _activeDebuffs.any((d) =>
            d.isActive && d.specialEffect == DebuffSpecialEffect.intWisBlock)) {
      return false;
    }

    // Check if STR/END blocked
    if ((stat == 'strength' || stat == 'endurance') &&
        _activeDebuffs.any((d) =>
            d.isActive && d.specialEffect == DebuffSpecialEffect.strEndBlock)) {
      return false;
    }

    return true;
  }

  List<Debuff> get activeDebuffs =>
      _activeDebuffs.where((d) => d.isActive).toList();

  Future<void> resetProgress() async {
    // 1. Delete User Profile
    await _userBox.clear();
    _userProfile = null;

    // 2. Reset Achievements
    await _initializeDefaultAchievements();

    notify();
  }
}
