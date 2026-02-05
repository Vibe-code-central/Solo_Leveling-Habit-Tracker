import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:solo_leveling/core/theme/app_theme.dart';
import 'package:solo_leveling/data/models/gate.dart';
import 'package:solo_leveling/presentation/providers/gate_provider.dart';
import 'package:solo_leveling/presentation/providers/user_provider.dart';
import 'package:solo_leveling/presentation/widgets/system/system_background.dart';

class GateScreen extends StatelessWidget {
  final Gate gate;

  const GateScreen({super.key, required this.gate});

  @override
  Widget build(BuildContext context) {
    return Consumer<GateProvider>(
      builder: (context, gateProvider, child) {
        final isRedGate = gate.type == GateType.red;
        final primaryColor =
            isRedGate ? AppTheme.systemCrimson : AppTheme.systemCyan;

        // Check if battle is active for Red Gate
        if (isRedGate &&
            gateProvider.activeBattle != null &&
            gateProvider.activeBattle!.isActive) {
          return _RedGateBattleView(gateProvider: gateProvider);
        }

        // Default Gate Entry / Prep Screen
        return SystemBackground(
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: IconThemeData(color: primaryColor),
              title: Text(
                gate.displayName.toUpperCase(),
                style: TextStyle(
                  color: primaryColor,
                  fontFamily: 'Orbitron',
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    gate.icon,
                    style: const TextStyle(fontSize: 80),
                  )
                      .animate()
                      .scale(duration: 600.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: 24),

                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: AppTheme.systemNavy.withOpacity(0.8),
                      border: Border.all(color: primaryColor),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'MISSION OBJECTIVE',
                          style: TextStyle(
                            color: primaryColor,
                            fontFamily: 'Orbitron',
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isRedGate
                              ? 'SURVIVE.\nDefeat the dungeon boss to escape.'
                              : 'Complete the designated workout to close the rift.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Rajdhani',
                            color: AppTheme.systemWhite,
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (isRedGate)
                          const Text(
                            'WARNING: Escape is impossible once entered.',
                            style: TextStyle(color: Colors.red, fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Action Button
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        if (isRedGate) {
                          final userProvider =
                              Provider.of<UserProvider>(context, listen: false);
                          gateProvider.enterRedGate(userProvider);
                        } else {
                          // Blue Gate Navigation
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => _SurpriseGateView(
                                  gate: gate, gateProvider: gateProvider),
                            ),
                          );
                        }
                      },
                      child: Text(
                        'START MISSION',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Orbitron',
                            fontSize: 16),
                      ),
                    ),
                  )
                      .animate(
                          onPlay: (controller) =>
                              controller.repeat(reverse: true))
                      .shimmer(
                          duration: 2000.ms,
                          color: primaryColor.withOpacity(0.5)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SurpriseGateView extends StatelessWidget {
  final Gate gate;
  final GateProvider gateProvider;

  const _SurpriseGateView({required this.gate, required this.gateProvider});

  String _getTaskDescription(int seed) {
    // Deterministic task generation based on seed
    final tasks = [
      "Perform 50 Pushups",
      "Perform 50 Squats",
      "Plank for 2 Minutes",
      "Run 2 Kilometers",
      "Perform 100 Sit-ups",
      "Meditate for 10 Minutes",
    ];
    return tasks[seed % tasks.length];
  }

  @override
  Widget build(BuildContext context) {
    final task = _getTaskDescription(gate.spawnSeed);
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return SystemBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: const Text('SURPRISE MISSION',
              style: TextStyle(
                  color: AppTheme.systemCyan, fontFamily: 'Orbitron')),
          centerTitle: true,
          automaticallyImplyLeading: false,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.timer, size: 80, color: AppTheme.systemCyan),
              const SizedBox(height: 24),

              // Timer Display (Static 1 Hour or simpler)
              const Text(
                'TIME REMAINING: 59:00', // Placeholder
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 24,
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 48),

              // Task Card
              Container(
                padding: const EdgeInsets.all(32),
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  color: AppTheme.systemNavy,
                  border: Border.all(color: AppTheme.systemCyan),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text(
                      'OBJECTIVE',
                      style: TextStyle(
                        color: AppTheme.systemCyan,
                        fontFamily: 'Orbitron',
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      task.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 28, // Large text
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 60),

              // Complete Button
              SizedBox(
                width: 250,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.systemCyan,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () async {
                    await gateProvider.completeSurpriseGate(userProvider);
                    if (context.mounted) {
                      Navigator.pop(context); // Close Task View
                      Navigator.pop(context); // Close Gate Screen
                    }
                  },
                  child: const Text(
                    'COMPLETE',
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RedGateBattleView extends StatelessWidget {
  final GateProvider gateProvider;

  const _RedGateBattleView({required this.gateProvider});

  @override
  Widget build(BuildContext context) {
    final battle = gateProvider.activeBattle!;
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final double bossHpPercent =
        (battle.bossCurrentHP / battle.bossMaxHP).clamp(0.0, 1.0);
    final double playerHpPercent =
        (battle.playerCurrentHP / battle.playerSnapshotHP).clamp(0.0, 1.0);
    final double playerMpPercent =
        (battle.playerCurrentMP / battle.playerSnapshotMP).clamp(0.0, 1.0);

    return SystemBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // No AppBar or simple one
        body: SafeArea(
          child: Column(
            children: [
              // HEADER
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: const Text('RED GATE - BOSS ROOM',
                    style: TextStyle(
                        color: Colors.red,
                        fontFamily: 'Orbitron',
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
              ),

              // BOSS AREA
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text('DUNGEON BOSS',
                          style: TextStyle(
                              color: Colors.red, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      // Boss HP Bar
                      LinearProgressIndicator(
                        value: bossHpPercent,
                        backgroundColor: Colors.red.withOpacity(0.2),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.red),
                        minHeight: 12,
                      ),
                      Text('${battle.bossCurrentHP} / ${battle.bossMaxHP} HP',
                          style: const TextStyle(color: Colors.white70)),
                      const SizedBox(height: 20),
                      // Boss Sprite (Placeholder)
                      const Icon(Icons.android, size: 80, color: Colors.red)
                          .animate()
                          .shake(
                              duration: 2000.ms,
                              hz: 0.5) // Breathing/Aggressive idle
                          .tint(color: Colors.redAccent, duration: 1.seconds),
                    ],
                  ),
                ),
              ),

              // BATTLE LOG
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    border: Border.all(color: Colors.white24),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ListView.builder(
                    reverse:
                        true, // Show newest at bottom (requires reversing list or careful logic)
                    itemCount: battle.battleLog.length,
                    itemBuilder: (context, index) {
                      final log =
                          battle.battleLog[battle.battleLog.length - 1 - index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Text(log,
                            style: const TextStyle(
                                color: Colors.white, fontFamily: 'Rajdhani')),
                      );
                    },
                  ),
                ),
              ),

              // PLAYER AREA
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Player Stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('PLAYER',
                              style: TextStyle(
                                  color: AppTheme.systemCyan,
                                  fontWeight: FontWeight.bold)),
                          Text('Unused Potions: ${5 - battle.potionsUsed}',
                              style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // HP
                      LinearProgressIndicator(
                        value: playerHpPercent,
                        backgroundColor: Colors.grey[800],
                        valueColor: AlwaysStoppedAnimation<Color>(
                            playerHpPercent < 0.3 ? Colors.red : Colors.green),
                        minHeight: 8,
                      ),
                      Text(
                          '${battle.playerCurrentHP} / ${battle.playerSnapshotHP} HP',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white)),
                      const SizedBox(height: 4),
                      // MP
                      LinearProgressIndicator(
                        value: playerMpPercent,
                        backgroundColor: Colors.grey[800],
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.blue),
                        minHeight: 8,
                      ),
                      Text(
                          '${battle.playerCurrentMP} / ${battle.playerSnapshotMP} MP',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.white)),

                      const Spacer(),

                      // ACTION BUTTONS
                      GridView.count(
                        shrinkWrap: true,
                        crossAxisCount: 2,
                        childAspectRatio: 2.5,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          _ActionButton(
                            label: 'ATTACK',
                            color: Colors.red,
                            icon: Icons.flash_on,
                            onTap: () => gateProvider.performBattleAction(
                                BattleAction.attack, userProvider),
                          ),
                          _ActionButton(
                            label: 'SKILL',
                            color: Colors.purple,
                            icon: Icons.auto_fix_high,
                            subtitle: '(-20 MP)',
                            onTap: () => gateProvider.performBattleAction(
                                BattleAction.skill, userProvider),
                          ),
                          _ActionButton(
                            label: 'DEFEND',
                            color: Colors.blue,
                            icon: Icons.shield,
                            onTap: () => gateProvider.performBattleAction(
                                BattleAction.defend, userProvider),
                          ),
                          _ActionButton(
                            label: 'ITEM',
                            color: Colors.orange,
                            icon: Icons.local_drink,
                            subtitle: '(HP Potion)',
                            onTap: () => gateProvider.performBattleAction(
                                BattleAction.potion, userProvider),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final String? subtitle;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.2),
        foregroundColor: color,
        side: BorderSide(color: color),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onPressed: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontFamily: 'Orbitron', fontWeight: FontWeight.bold)),
              if (subtitle != null)
                Text(subtitle!,
                    style:
                        const TextStyle(fontSize: 10, color: Colors.white70)),
            ],
          ),
        ],
      ),
    );
  }
}
