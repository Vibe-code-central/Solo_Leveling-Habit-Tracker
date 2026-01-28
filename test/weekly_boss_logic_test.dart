import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:solo_leveling/data/models/achievement.dart'; // Needed for adapter
import 'package:solo_leveling/data/models/weekly_boss.dart';
import 'package:solo_leveling/data/models/habit.dart';
import 'package:solo_leveling/data/models/user_profile.dart';
import 'package:solo_leveling/presentation/providers/habit_provider.dart';
import 'package:solo_leveling/presentation/providers/user_provider.dart';

void main() {
  late Directory tempDir;
  late Box<Habit> habitBox;
  late Box<UserProfile> userBox;
  late Box settingsBox;
  late Box<Achievement> achievementBox;

  setUp(() async {
    // 1. Setup Temp Directory for Hive
    tempDir = await Directory.systemTemp.createTemp();
    Hive.init(tempDir.path);

    // 2. Register Adapters
    if (!Hive.isAdapterRegistered(0))
      Hive.registerAdapter(UserProfileAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(HabitAdapter());
    if (!Hive.isAdapterRegistered(9))
      Hive.registerAdapter(AchievementAdapter());
    if (!Hive.isAdapterRegistered(2))
      Hive.registerAdapter(PlayerStatsAdapter());
    if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(HunterRankAdapter());
    if (!Hive.isAdapterRegistered(4))
      Hive.registerAdapter(HunterClassAdapter());
    if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(ActiveBuffAdapter());
    if (!Hive.isAdapterRegistered(6))
      Hive.registerAdapter(ActiveDebuffAdapter());
    if (!Hive.isAdapterRegistered(10))
      Hive.registerAdapter(AchievementCategoryAdapter());
    if (!Hive.isAdapterRegistered(7)) Hive.registerAdapter(HabitTypeAdapter());
    if (!Hive.isAdapterRegistered(8)) Hive.registerAdapter(HabitTierAdapter());

    // 3. Open Boxes
    habitBox = await Hive.openBox<Habit>('habits');
    userBox =
        await Hive.openBox<UserProfile>('userProfile'); // Matches provider
    settingsBox = await Hive.openBox('settings');
    achievementBox = await Hive.openBox<Achievement>('achievements');
  });

  tearDown(() async {
    await Hive.close();
    await tempDir.delete(recursive: true);
  });

  test('Verify Weekly Boss Defeat and Rewards', () async {
    // A. Setup User
    final userProfile = UserProfile(
      name: 'Test Hunter',
      stats: PlayerStats(
          strength: 10, willpower: 10, charisma: 10, endurance: 10, wisdom: 10),
      createdAt: DateTime.now(),
      lastActive: DateTime.now(),
    );
    await userBox.add(userProfile);

    final userProvider = UserProvider();
    await userProvider.loadUserProfile(); // Loads from box

    // B. Setup HabitProvider
    final habitProvider = HabitProvider();
    await habitProvider.loadHabits();

    // C. Get Current Boss - FORCED to SLOTH for this test to verify loophole fix
    final boss = WeeklyBoss.getBossByIndex(0); // Sloth (requires unique days)
    print('Current Weekly Boss: ${boss.name} (${boss.id})');
    print('Target: ${boss.targetCompletions}');

    // D. Simulate Progress (Testing Spam Loophole Fix)
    // Attempt 1: Add 7 completions on the SAME DAY (Spamming)
    // Since Sloth boss requires unique days, this should only count as 1.

    final now = DateTime.now();
    final morningHabit = Habit(
      id: 'morning_test_habit',
      name: 'Test Morning Habit',
      description: 'Testing',
      type: HabitType.good,
      tier: HabitTier.c,
      xpReward: 10,
      xpPenalty: 10,
      createdAt: now,
    );

    // Spam 7 completions on today
    for (int i = 0; i < 7; i++) {
      morningHabit.completedDates.add(now);
    }

    await habitBox.put('morning_test_habit', morningHabit);
    await habitProvider.loadHabits();

    // Check Progress - Should be 1, NOT 7
    int progress = habitProvider.getWeeklyBossProgress(boss);
    print('Spam Progress (All same day): $progress');
    expect(progress, 1,
        reason:
            'Multiple completions on same day should count as 1 for Sloth boss');

    // Attempt 2: Distribute completions across 7 DISTINCT days
    morningHabit.completedDates.clear();
    for (int i = 0; i < 7; i++) {
      // completing on different days (today, yesterday, etc.)
      morningHabit.completedDates.add(now.subtract(Duration(days: i)));
    }
    await habitBox.put('morning_test_habit', morningHabit); // Update
    await habitProvider.loadHabits();

    progress = habitProvider.getWeeklyBossProgress(boss);
    print('Legit Progress (Distinct days): $progress');

    expect(progress >= boss.targetCompletions, true,
        reason:
            'Progress ($progress) should be >= Target (${boss.targetCompletions}) with distinct days');

    // E. Execute Defeat Logic
    final initialXP = userProvider.userProfile!.currentXP;
    final initialBossDefeated = userProvider.userProfile!.bossesDefeated;

    await habitProvider.checkAndDefeatWeeklyBoss(userProvider);

    // F. Verify Results
    final updatedXP = userProvider.userProfile!.currentXP;
    final updatedBossDefeated = userProvider.userProfile!.bossesDefeated;
    final lastBossWeek = userProvider.userProfile!.lastBossWeek;

    expect(updatedBossDefeated, initialBossDefeated + 1,
        reason: 'Bosses Defeated count should increment');
    // Using > check from previous step
    expect(updatedXP > initialXP, true, reason: 'XP should increase');

    final currentWeek =
        (DateTime.now().millisecondsSinceEpoch / (1000 * 60 * 60 * 24 * 7))
            .floor();
    expect(lastBossWeek, currentWeek,
        reason: 'Last Boss Week should be updated to current week');

    // G. Verify Anti-Farming (Running it again should not reward)
    await habitProvider.checkAndDefeatWeeklyBoss(userProvider);
    expect(userProvider.userProfile!.bossesDefeated, updatedBossDefeated,
        reason: 'Should not defeat boss twice in same week');
    expect(userProvider.userProfile!.currentXP, updatedXP,
        reason: 'XP should not increase again');
  });
}
