import 'package:hive/hive.dart';

part 'habit.g.dart';

@HiveType(typeId: 6)
class Habit extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  HabitType type;

  @HiveField(4)
  HabitTier tier;

  @HiveField(5)
  int xpReward;

  @HiveField(6)
  int xpPenalty;

  @HiveField(7)
  Map<String, int> statRewards;

  @HiveField(8)
  Map<String, int> statPenalties;

  @HiveField(9)
  int hpDamage;

  @HiveField(10)
  int mpDrain;

  @HiveField(11)
  List<DateTime> completedDates;

  @HiveField(12)
  List<DateTime> failedDates;

  @HiveField(13)
  int currentStreak;

  @HiveField(14)
  int longestStreak;

  @HiveField(15)
  bool isActive;

  @HiveField(16)
  DateTime createdAt;

  @HiveField(17)
  String? debuffName;

  @HiveField(18)
  int streakBonus;

  @HiveField(19)
  bool isCustom;

  Habit({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.tier,
    required this.xpReward,
    this.xpPenalty = 0,
    Map<String, int>? statRewards,
    Map<String, int>? statPenalties,
    this.hpDamage = 0,
    this.mpDrain = 0,
    List<DateTime>? completedDates,
    List<DateTime>? failedDates,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.isActive = true,
    required this.createdAt,
    this.debuffName,
    this.streakBonus = 0,
    this.isCustom = false,
  })  : statRewards = statRewards ?? {},
        statPenalties = statPenalties ?? {},
        completedDates = completedDates ?? [],
        failedDates = failedDates ?? [];

  bool get isCompletedToday {
    final today = DateTime.now();
    return completedDates.any((date) =>
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day);
  }

  bool get isFailedToday {
    final today = DateTime.now();
    return failedDates.any((date) =>
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day);
  }

  double get completionRate {
    final totalDays = completedDates.length + failedDates.length;
    if (totalDays == 0) return 0.0;
    return completedDates.length / totalDays;
  }

  void markCompleted() {
    if (!isCompletedToday) {
      completedDates.add(DateTime.now());
      currentStreak++;
      if (currentStreak > longestStreak) {
        longestStreak = currentStreak;
      }
    }
  }

  void unmarkCompleted() {
    final today = DateTime.now();
    completedDates.removeWhere((date) =>
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day);
    if (currentStreak > 0) currentStreak--;
  }

  void markFailed() {
    if (!isFailedToday) {
      failedDates.add(DateTime.now());
      currentStreak = 0;
    }
  }

  void unmarkFailed() {
    final today = DateTime.now();
    failedDates.removeWhere((date) =>
        date.year == today.year &&
        date.month == today.month &&
        date.day == today.day);
  }

  int getTotalXPReward() {
    return xpReward + (currentStreak * streakBonus);
  }

  int getTotalXPPenalty() {
    // Increase penalty based on consecutive failures
    final recentFailures = _getRecentConsecutiveFailures();
    final multiplier = 1.0 + (recentFailures * 0.2).clamp(0.0, 1.0);
    return (xpPenalty * multiplier).round();
  }

  int _getRecentConsecutiveFailures() {
    int count = 0;
    final now = DateTime.now();

    for (int i = 0; i < 5; i++) {
      final checkDate = now.subtract(Duration(days: i));
      final hasFailure = failedDates.any((date) =>
          date.year == checkDate.year &&
          date.month == checkDate.month &&
          date.day == checkDate.day);

      if (hasFailure) {
        count++;
      } else {
        break;
      }
    }

    return count;
  }

  static List<Habit> getDefaultHabits() {
    return [
      // ═══════════════════════════════════════════════════════════
      // MORNING ROUTINE HABITS - 5 Core Habits for 2-Week Challenge
      // ═══════════════════════════════════════════════════════════

      // HABIT 1: WAKE UP - The Keystone Habit
      Habit(
        id: 'morning_wake_up',
        name: '⏰ Wake Up on Time',
        description: '''WEEK 1 TARGET: 6:15 AM
WEEK 2 TARGET: 5:45 AM

This is your keystone habit. Everything else depends on this.
• Set alarm ACROSS the room (not beside bed)
• No phone alarm - use a real alarm clock
• Getting this right enables all other habits''',
        type: HabitType.good,
        tier: HabitTier.s,
        xpReward: 150,
        xpPenalty: 200,
        statRewards: {'willpower': 3, 'agility': 2},
        statPenalties: {'willpower': 3, 'agility': 2},
        hpDamage: 100,
        streakBonus: 20,
        debuffName: 'Light Sluggish',
        createdAt: DateTime.now(),
      ),

      // HABIT 2: GET OUT OF BED - No Snooze Protocol
      Habit(
        id: 'morning_get_up',
        name: '🚀 Get Out of Bed (60 sec)',
        description: '''NO SNOOZE. NO SITTING ON BED.

Protocol:
1. Alarm rings
2. Stand up within 60 SECONDS
3. Walk to another room immediately
4. Do NOT sit back on bed (you WILL fall asleep)

The snooze button is your enemy. Destroy it.''',
        type: HabitType.good,
        tier: HabitTier.s,
        xpReward: 120,
        xpPenalty: 180,
        statRewards: {'willpower': 3, 'agility': 1},
        statPenalties: {'willpower': 2, 'agility': 1},
        hpDamage: 80,
        streakBonus: 15,
        debuffName: 'Light Sluggish',
        createdAt: DateTime.now(),
      ),

      // HABIT 3: 20 PUSHUPS - Wake Up Your Body
      Habit(
        id: 'morning_pushups',
        name: '💪 20 Pushups',
        description: '''IMMEDIATELY after getting out of bed.

Why pushups?
• Spikes cortisol (wake-up hormone)
• Gets blood flowing to brain
• Builds discipline before brain is awake
• Takes less than 60 seconds

Can't do 20? Start with 10. Or 5. Just DO THEM.
No thinking. Just drop and push.''',
        type: HabitType.good,
        tier: HabitTier.a,
        xpReward: 100,
        xpPenalty: 120,
        statRewards: {'strength': 2, 'willpower': 2},
        statPenalties: {'strength': 1, 'willpower': 1},
        hpDamage: 50,
        streakBonus: 12,
        debuffName: 'Morning Fog',
        createdAt: DateTime.now(),
      ),

      // HABIT 4: COLD WATER FACE - Mental Clarity
      Habit(
        id: 'morning_cold_water',
        name: '💧 Cold Water on Face',
        description: '''Go to bathroom. Splash COLD water on face.

Benefits:
• Activates vagus nerve
• Sharpens mental clarity instantly
• Reduces morning grogginess
• Prepares you for the cold shower

This takes 10 seconds. No excuses.''',
        type: HabitType.good,
        tier: HabitTier.a,
        xpReward: 80,
        xpPenalty: 100,
        statRewards: {'sense': 2, 'vitality': 1},
        statPenalties: {'sense': 1, 'vitality': 1},
        hpDamage: 30,
        streakBonus: 10,
        debuffName: 'Morning Fog',
        createdAt: DateTime.now(),
      ),

      // HABIT 5: SHOWER - Self-Respect Foundation
      Habit(
        id: 'morning_shower',
        name: '🚿 Morning Shower',
        description: '''SHOWER EVERY SINGLE MORNING.

Protocol:
1. Regular shower (5-7 minutes)
2. COLD FINISH: 30 seconds cold water
3. Get dressed immediately after

Why this matters:
• Self-respect (you're worth basic care)
• Confidence boost for the day
• Cold finish = energy spike
• Signals to brain: "Day has started"

No more showering once a week. That stops TODAY.''',
        type: HabitType.good,
        tier: HabitTier.s,
        xpReward: 130,
        xpPenalty: 160,
        statRewards: {'vitality': 2, 'sense': 2},
        statPenalties: {'vitality': 2, 'sense': 1},
        hpDamage: 80,
        streakBonus: 18,
        debuffName: 'Light Sluggish',
        createdAt: DateTime.now(),
      ),

      // ═══════════════════════════════════════════════════════════
      // DEMON TRAPS - Bad Habits to Avoid
      // ═══════════════════════════════════════════════════════════

      // DEMON TRAP 1: Midnight Scrolling
      Habit(
        id: 'midnight_scrolling',
        name: '📵 Screen After 10 PM',
        description: '''THE BIGGEST ENEMY OF YOUR MORNING.

If you scroll at night:
• Blue light destroys melatonin
• You'll sleep 1-2 hours later
• Wake up groggy, hit snooze
• Morning routine fails

RULE: Phone on charger in ANOTHER ROOM by 10 PM.
No exceptions. No "just checking one thing."''',
        type: HabitType.bad,
        tier: HabitTier.catastrophic,
        xpReward: 0,
        xpPenalty: 200,
        statPenalties: {'willpower': 4, 'vitality': 2},
        hpDamage: 150,
        mpDrain: 100,
        debuffName: "Demon's Grip",
        createdAt: DateTime.now(),
      ),

      // DEMON TRAP 2: Snooze Defeat
      Habit(
        id: 'snooze_defeat',
        name: '😴 Snooze Button',
        description: '''YOU HIT SNOOZE. YOU ALREADY LOST.

Every snooze:
• Fragments your sleep cycles
• Makes you MORE tired, not less
• Weakens willpower for the day
• Creates a habit of giving up

This is the first test of your day.
WIN IT.''',
        type: HabitType.bad,
        tier: HabitTier.severe,
        xpReward: 0,
        xpPenalty: 150,
        statPenalties: {'willpower': 3, 'agility': 2},
        hpDamage: 100,
        debuffName: 'Sluggish Start',
        createdAt: DateTime.now(),
      ),

      // DEMON TRAP 3: Gaming Abyss
      Habit(
        id: 'gaming_abyss',
        name: '🎮 Gaming (2+ hrs weekday)',
        description: '''THE TIME VOID.

2+ hours gaming on a weekday = day wasted.

• No workout today
• No reading today
• No progress today
• Sleep will be late

Weekend gaming is fine. Weekdays are for building.''',
        type: HabitType.bad,
        tier: HabitTier.severe,
        xpReward: 0,
        xpPenalty: 180,
        statPenalties: {'willpower': 3, 'intelligence': 2},
        mpDrain: 200,
        debuffName: 'Time Void',
        createdAt: DateTime.now(),
      ),

      // DEMON TRAP 4: Junk Food
      Habit(
        id: 'junk_food',
        name: '🍔 Junk Food',
        description: '''POISON FOR YOUR BODY AND MIND.

What happens after junk food:
• Energy crash in 2 hours
• Brain fog all day
• Sleep quality tanks
• The cravings get worse

Your body is your tool. Don't sabotage it.''',
        type: HabitType.bad,
        tier: HabitTier.severe,
        xpReward: 0,
        xpPenalty: 120,
        statPenalties: {'vitality': 3, 'strength': 1},
        hpDamage: 120,
        debuffName: 'Weakened State',
        createdAt: DateTime.now(),
      ),

      // ═══════════════════════════════════════════════════════════
      // REDEMPTION SYSTEM - Missed Morning → Evening Task → Or DEATH
      // ═══════════════════════════════════════════════════════════

      // REDEMPTION TASK: If you missed morning, do this in evening
      Habit(
        id: 'evening_redemption_pushups',
        name: '🔥 Evening Redemption (10 Pushups)',
        description: '''YOU MISSED YOUR MORNING. THIS IS YOUR CHANCE.

DO 10 PUSHUPS RIGHT NOW.
Not later. Not tomorrow. NOW.

This is your redemption for the failed morning.
• Complete this = reduced penalty
• Skip this = SHADOW EXECUTION

You owe a debt to yourself. PAY IT.''',
        type: HabitType.good,
        tier: HabitTier.a,
        xpReward: 30, // Small reward - this is damage control, not progress
        xpPenalty: 0, // No penalty here - penalty comes from the FAILURE habit
        statRewards: {'strength': 1, 'willpower': 1},
        statPenalties: {},
        hpDamage: 0,
        streakBonus: 0, // No streak bonus - you're just recovering
        createdAt: DateTime.now(),
      ),

      // THE NUCLEAR OPTION: Skipped both morning AND redemption
      Habit(
        id: 'shadow_execution',
        name: '💀 SHADOW EXECUTION',
        description: '''YOU FAILED YOUR MORNING.
YOU SKIPPED YOUR REDEMPTION.
THERE ARE CONSEQUENCES.

A shadow soldier has been EXECUTED for your weakness.

• XP WIPED: Lose 500 XP
• LEVEL RISK: May lose a level
• HP CRITICAL: Massive damage
• STATS CRUSHED: Multiple stat penalties
• DEBUFF: Failure's Mark (72 hours)

This is what happens when you break promises to yourself.
TWICE.

Mark this if you missed morning AND skipped evening pushups.''',
        type: HabitType.bad,
        tier: HabitTier.catastrophic,
        xpReward: 0,
        xpPenalty: 500, // DEVASTATING
        statPenalties: {
          'willpower': 5,
          'strength': 3,
          'agility': 2,
          'vitality': 2,
        },
        hpDamage: 300, // Nearly 1/3 of starting HP
        mpDrain: 200,
        debuffName: "Failure's Mark",
        createdAt: DateTime.now(),
      ),
    ];
  }
}

@HiveType(typeId: 7)
enum HabitType {
  @HiveField(0)
  good,
  @HiveField(1)
  bad,
}

@HiveType(typeId: 8)
enum HabitTier {
  @HiveField(0)
  s,
  @HiveField(1)
  a,
  @HiveField(2)
  b,
  @HiveField(3)
  c,
  @HiveField(4)
  severe,
  @HiveField(5)
  catastrophic,
}
