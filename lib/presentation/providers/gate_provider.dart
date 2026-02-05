import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../data/models/gate.dart';
import '../../data/models/user_inventory.dart'; // TransactionType
import 'user_provider.dart';

class GateProvider extends ChangeNotifier {
  late Box _gateBox;
  Gate? _activeGate;

  Gate? get activeGate => _activeGate;

  /// Initialize provider
  Future<void> initialize() async {
    _gateBox = Hive.box('gates');
    _loadActiveGate();
    _loadActiveBattle();
  }

  /// Load active gate from storage
  void _loadActiveGate() {
    // Check if there's a stored gate
    final storedGate = _gateBox.get('active_gate');
    if (storedGate != null && storedGate is Gate) {
      if (storedGate.isExpired && !storedGate.isCompleted) {
        // Expired gate logic (despawn)
        _gateBox.delete('active_gate');
        _activeGate = null;
        debugPrint('🚪 Gate expired and despawned');
      } else {
        _activeGate = storedGate;
      }
    }
  }

  void _loadActiveBattle() {
    final storedBattle = _gateBox.get('active_battle');
    if (storedBattle != null && storedBattle is RedGateBattle) {
      _activeBattle = storedBattle;
    }
  }

  /// Check for random gate spawn
  /// Should be called periodically or on screen transitions
  Future<bool> checkForGateSpawn(UserProvider userProvider) async {
    // Don't spawn if one exists
    if (_activeGate != null) return false;

    // Modified: Respect User Schedule (Office 7 AM - 8 PM)
    final now = DateTime.now();
    final hour = now.hour;

    // Block spawns during office hours (07:00 - 20:00)
    // 7 is 7:00 AM, 20 is 8:00 PM
    if (hour >= 7 && hour < 20) {
      return false;
    }

    // Check every 30 minutes
    final lastSpawnTime = DateTime.fromMillisecondsSinceEpoch(
        _gateBox.get('last_spawn_check', defaultValue: 0));

    if (DateTime.now().difference(lastSpawnTime).inMinutes < 30) {
      return false;
    }

    // Update check time
    await _gateBox.put(
        'last_spawn_check', DateTime.now().millisecondsSinceEpoch);

    final rng = Random();
    final roll = rng.nextInt(100) + 1; // 1-100

    GateType? spawnType;
    int durationMinutes = 60;

    // Default Spawns:
    // 1% Chance: RED GATE
    if (roll == 100) {
      // 1%
      spawnType = GateType.red;
      durationMinutes = 24 * 60;
    }
    // 10% Chance: SURPRISE GATE (Blue)
    else if (roll <= 10) {
      spawnType = GateType.surprise;
      durationMinutes = 60; // 1 hour
    }

    if (spawnType != null) {
      await _spawnGate(spawnType, durationMinutes, userProvider);
      return true;
    }

    return false;
  }

  Future<void> _spawnGate(
      GateType type, int durationMinutes, UserProvider userProvider) async {
    final now = DateTime.now();
    final expiresAt = now.add(Duration(minutes: durationMinutes));
    final id = 'gate_${now.millisecondsSinceEpoch}';

    // Predetermined Rewards
    final rng = Random();
    int gold = 0;
    int xp = 0;

    final userLevel = userProvider.userProfile?.level ?? 1;

    if (type == GateType.surprise) {
      gold = (rng.nextInt(100) + 50) + userLevel * 10;
      xp = (rng.nextInt(200) + 100) + userLevel * 20;
    } else if (type == GateType.red) {
      gold = (rng.nextInt(1000) + 500) + userLevel * 100;
      xp = (rng.nextInt(2000) + 1000) + userLevel * 200;
    }

    final reward = GateReward(
      goldEarned: gold,
      xpEarned: xp,
      itemsDropped: [],
    );

    _activeGate = Gate(
      id: id,
      type: type,
      spawnedAt: now,
      expiresAt: expiresAt,
      predeterminedReward: reward,
      spawnSeed: rng.nextInt(999999),
    );

    await _gateBox.put('active_gate', _activeGate);
    notifyListeners();
    debugPrint('⛩️ ${type.name.toUpperCase()} GATE OPENED! (ID: $id)');
  }

  // RE-IMPLEMENTED BATTLE LOGIC FROM PREVIOUS STEPS

  RedGateBattle? _activeBattle;
  RedGateBattle? get activeBattle => _activeBattle;

  /// Enter Red Gate - Initialize Battle
  Future<void> enterRedGate(UserProvider userProvider) async {
    if (_activeGate == null || _activeGate!.type != GateType.red) return;

    final user = userProvider.userProfile;
    if (user == null) return;

    // Snapshot stats
    final stats = user.stats;
    int str = stats.strength;
    int intel = stats.intelligence;
    int end = stats.endurance;
    int wil = stats.willpower;

    // Boss Scaling (S-Rank logic)
    // Boss HP = Player HP * 3
    final int bossMaxHP = (user.currentHP * 3).round();

    _activeBattle = RedGateBattle(
      gateId: _activeGate!.id,
      bossCurrentHP: bossMaxHP,
      bossMaxHP: bossMaxHP,
      playerSnapshotHP: user.currentHP,
      playerSnapshotMP: user.currentMP,
      playerSnapshotStr: str,
      playerSnapshotInt: intel,
      playerSnapshotEnd: end,
      playerSnapshotWil: wil,
      playerCurrentHP: user.currentHP,
      playerCurrentMP: user.currentMP,
      battleLog: ['You stepped into the Red Gate used entirely by the System.'],
    );

    await _gateBox.put('active_battle', _activeBattle);
    notifyListeners();
  }

  /// Perform Battle Action
  Future<void> performBattleAction(
      BattleAction action, UserProvider userProvider) async {
    if (_activeBattle == null || !_activeBattle!.isActive) return;

    final battle = _activeBattle!;
    String logEntry = '';

    // PLAYER TURN
    switch (action) {
      case BattleAction.attack:
        final dmg = battle.calculateAttackDamage();
        battle.bossCurrentHP -= dmg;
        logEntry = '⚔️ You attacked for $dmg damage!';
        break;

      case BattleAction.skill:
        if (battle.playerCurrentMP >= 20) {
          final dmg = battle.calculateMagicDamage();
          final specialDmg = (dmg * 1.5).round();
          battle.bossCurrentHP -= specialDmg;
          battle.playerCurrentMP -= 20;
          logEntry = '🔥 You used a Skill! Dealt $specialDmg damage! (-20 MP)';
        } else {
          logEntry = '⚠️ Not enough MP!';
          battle.battleLog.add(logEntry);
          notifyListeners();
          return; // Don't end turn
        }
        break;

      case BattleAction.defend:
        final heal = battle.calculateDefendHealing();
        battle.playerCurrentHP =
            min(battle.playerCurrentHP + heal, battle.playerSnapshotHP);
        logEntry = '🛡️ You defended and recovered $heal HP!';
        break;

      case BattleAction.potion:
        battle.playerCurrentHP =
            min(battle.playerCurrentHP + 500, battle.playerSnapshotHP);
        battle.potionsUsed++;
        logEntry = '🧪 You drank a potion. Restored 500 HP.';
        break;
    }

    battle.battleLog.add(logEntry);
    battle.turnCount++;

    // CHECK WIN
    if (battle.isBossDefeated) {
      await _resolveBattleWin(userProvider);
      return;
    }

    // ENEMY TURN
    await Future.delayed(const Duration(milliseconds: 600));
    await _enemyTurn(userProvider);
  }

  /// Enemy Turn Logic
  Future<void> _enemyTurn(UserProvider userProvider) async {
    if (_activeBattle == null) return;
    final battle = _activeBattle!;

    final rng = Random();
    final roll = rng.nextInt(100);

    int dmg = 0;
    String enemyLog = '';

    // Base damage scaling based on Player HP
    final baseDmg = (battle.playerSnapshotHP * 0.08).round();

    if (roll < 20) {
      dmg = (baseDmg * 1.5).round();
      enemyLog = '👹 Boss CRITICAL HIT you for $dmg damage!';
    } else if (roll < 80) {
      dmg = baseDmg;
      enemyLog = '👹 Boss attacked you for $dmg damage.';
    } else {
      dmg = (baseDmg * 0.5).round();
      enemyLog = '👹 Boss grazed you for $dmg damage.';
    }

    battle.playerCurrentHP -= dmg;
    battle.battleLog.add(enemyLog);

    // CHECK LOSS
    if (battle.isPlayerDefeated) {
      await _resolveBattleLoss(userProvider);
    } else {
      notifyListeners();
    }
  }

  Future<void> _resolveBattleWin(UserProvider userProvider) async {
    if (_activeBattle == null || _activeGate == null) return;

    final reward = _activeGate!.predeterminedReward;
    if (reward != null) {
      await userProvider.gainXP(reward.xpEarned);
      // Use public getGold/earnGold if available. Assuming TransactionType is imported.
      await userProvider.earnGold(
          reward.goldEarned, 'Red Gate Clear', TransactionType.gateClear);

      _activeBattle!.battleLog.add(
          '🏆 VICTORY! Earned ${reward.xpEarned} XP & ${reward.goldEarned} Gold.');
    }

    _activeBattle!.isActive = false;
    _activeGate!.isCompleted = true;
    _activeGate!.isActive = false;

    await _gateBox.put('active_gate', _activeGate);
    await _gateBox.delete('active_battle');

    notifyListeners();
  }

  Future<void> _resolveBattleLoss(UserProvider userProvider) async {
    if (_activeBattle == null) return;

    _activeBattle!.battleLog.add('💀 DEFEAT... You crawled out barely alive.');

    // Logic for penalty could be added here

    _activeBattle!.isActive = false;
    _activeGate!.isFailed = true;
    _activeGate!.isActive = false;

    await _gateBox.put('active_gate', _activeGate);
    await _gateBox.delete('active_battle');

    notifyListeners();
  }

  /// Complete Surprise Gate (Blue Gate)
  Future<void> completeSurpriseGate(UserProvider userProvider) async {
    if (_activeGate == null || _activeGate!.type != GateType.surprise) return;

    final reward = _activeGate!.predeterminedReward;
    if (reward != null) {
      await userProvider.gainXP(reward.xpEarned);
      // Use public earnGold
      // Surprise gates are usually quick, so 'Simple Quest' source
      await userProvider.earnGold(
          reward.goldEarned, 'Surprise Gate Clear', TransactionType.gateClear);
    }

    _activeGate!.isCompleted = true;
    _activeGate!.isActive = false;

    await _gateBox.put('active_gate', _activeGate);
    notifyListeners();
  }

  /// Close/Dismiss Gate
  Future<void> dismissGate() async {
    _activeGate = null;
    _activeBattle = null;
    await _gateBox.delete('active_gate');
    await _gateBox.delete('active_battle');
    notifyListeners();
  }
}

enum BattleAction { attack, skill, defend, potion }
