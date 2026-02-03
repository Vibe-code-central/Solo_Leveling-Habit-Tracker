import 'package:solo_leveling/data/models/user_profile.dart';

void main() {
  print('--- TESTING XP DEBT SCENARIO ---');

  final stats = PlayerStats();
  final user = UserProfile(
    name: 'TestUser',
    stats: stats,
    createdAt: DateTime.now(),
    lastActive: DateTime.now(),
    level: 1,
    currentXP: 0,
    totalXP: 0,
  );

  print(
      'INITIAL: Level ${user.level} | Current: ${user.currentXP} | Total: ${user.totalXP}');

  // 1. Massive Penalty (Ghost Days e.g.)
  print('\n> Applying 1000 XP Penalty...');
  user.loseXP(1000);
  print(
      'STATE: Level ${user.level} | Current: ${user.currentXP} | Total: ${user.totalXP}');

  // 2. Earnings (Working off debt?)
  print('\n> Earning 500 XP...');
  user.gainXP(500); // Should trigger Level up (250 req)

  print(
      'FINAL: Level ${user.level} | Current: ${user.currentXP} | Total: ${user.totalXP}');

  if (user.level > 1 && user.totalXP < 0) {
    print(
        '🚨 REPRODUCED: User is Level ${user.level} with Negative Total XP (${user.totalXP})');
    print(
        '   This explains why the UI (dependent on TotalXP < 0) shows negative progress.');
  } else {
    print('❓ Could not reproduce.');
  }
}
