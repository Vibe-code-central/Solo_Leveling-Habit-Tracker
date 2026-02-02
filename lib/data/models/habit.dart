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

  // Counter-based habit fields (for water tracking, etc.)
  @HiveField(20)
  int currentCount;

  @HiveField(21)
  int maxCount;

  @HiveField(22)
  int xpPerCount;

  @HiveField(23)
  bool isCounterBased;

  // Cooldown tracking for counter-based habits
  @HiveField(24)
  DateTime? lastCounterIncrement;

  @HiveField(25)
  int minMinutesBetweenIncrements;

  Habit({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.tier,
    required this.xpReward,
    required this.xpPenalty,
    required this.createdAt,
    Map<String, int>? statRewards,
    Map<String, int>? statPenalties,
    this.hpDamage = 0,
    this.mpDrain = 0,
    this.debuffName,
    this.streakBonus = 0,
    List<DateTime>? completedDates,
    List<DateTime>? failedDates,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.isActive = true,
    this.isCustom = false,
    this.currentCount = 0,
    this.maxCount = 0,
    this.xpPerCount = 0,
    this.isCounterBased = false,
    this.lastCounterIncrement,
    int? minMinutesBetweenIncrements, // Nullable to handle existing Hive data
  })  : minMinutesBetweenIncrements = minMinutesBetweenIncrements ?? 0,
        statRewards = statRewards ?? {},
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

      // HABIT 1: ARISE - The Ultimate Keystone Habit
      Habit(
        id: 'morning_arise',
        name: '⚡ ARISE',
        description: '''WEEK 1 TARGET: 6:15 AM
WEEK 2 TARGET: 5:45 AM

THE ULTIMATE KEYSTONE HABIT - Everything depends on this.

PROTOCOL:
1. Alarm rings (set ACROSS the room, not beside bed)
2. Stand up within 60 SECONDS - NO SNOOZE
3. Walk to another room immediately
4. Do NOT sit back on bed (you WILL fall asleep)

This is the first battle of your day. WIN IT.

• No phone alarm - use a real alarm clock
• The snooze button is your enemy. Destroy it.
• Getting this right enables all other habits''',
        type: HabitType.good,
        tier: HabitTier.s,
        xpReward: 100, // S-tier = Hard difficulty
        xpPenalty: 150,
        statRewards: {'willpower': 2, 'endurance': 1}, // Max 2 stats
        statPenalties: {'willpower': 4, 'endurance': 2},
        hpDamage: 150,
        streakBonus: 25,
        debuffName: 'Light Sluggish',
        createdAt: DateTime.now(),
      ),

      // HABIT 3: 10 PUSHUPS - Wake Up Your Body
      Habit(
        id: 'morning_pushups',
        name: '💪 10 Pushups',
        description: '''IMMEDIATELY after getting out of bed.

Why pushups?
• Spikes cortisol (wake-up hormone)
• Gets blood flowing to brain
• Builds discipline before brain is awake
• Takes less than 60 seconds

Can't do 10? Start with 5. Just DO THEM.
No thinking. Just drop and push.''',
        type: HabitType.good,
        tier: HabitTier.a,
        xpReward: 50, // A-tier = Medium difficulty
        xpPenalty: 70,
        statRewards: {'strength': 2, 'endurance': 1}, // Max 2 stats
        statPenalties: {'strength': 1, 'endurance': 1},
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
        xpReward: 25, // A-tier = Easy difficulty (quick task)
        xpPenalty: 50,
        statRewards: {'awareness': 2, 'willpower': 1}, // Max 2 stats
        statPenalties: {'awareness': 1, 'willpower': 1},
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
        xpReward: 100, // S-tier = Important daily habit
        xpPenalty: 100,
        statRewards: {
          'awareness': 2,
          'endurance': 1
        }, // Max 2 stats (clean feeling)
        statPenalties: {'charisma': 2, 'endurance': 1},
        hpDamage: 80,
        streakBonus: 18,
        debuffName: 'Light Sluggish',
        createdAt: DateTime.now(),
      ),

      // HABIT 6: CHALICE OF LIFE - Hydration Quest (COUNTER-BASED)
      Habit(
        id: 'daily_water',
        name: '💧 Chalice of Life (2L Water)',
        description: '''DAILY QUEST: Consume 2 Liters of Water

Like a healing potion in the dungeon, water restores your vitality.

PROTOCOL:
• Track each glass (250ml)
• Goal: 8 glasses = 2000ml (2L)
• Earn 25 XP per glass
• Stats awarded at full completion

Benefits:
• +Energy throughout the day
• +Mental clarity and focus
• +Physical performance
• +Recovery and healing

Track your intake. Your body is your weapon - keep it hydrated.''',
        type: HabitType.good,
        tier: HabitTier.b,
        xpReward: 50, // B-tier: 200ml per glass = medium effort
        xpPenalty: 30,
        statRewards: {
          'endurance': 2,
          'awareness': 1
        }, // Max 2 stats (body awareness)
        statPenalties: {'endurance': 1},
        hpDamage: 30,
        streakBonus: 8,
        createdAt: DateTime.now(),
        isCounterBased: true,
        maxCount: 8,
        xpPerCount: 6, // 6 XP per glass (50 XP / 8 glasses = 6.25)
        minMinutesBetweenIncrements: 15, // 15-minute cooldown
      ),

      // HABIT 7: DAILY READING - Intelligence Stat
      Habit(
        id: 'daily_reading',
        name: '📖 Daily Reading (10 Pages)',
        description: '''READING EXPANDS THE MIND.
        
PROTOCOL:
• Read 10 pages of a non-fiction or skill-building book.
• Audiobooks count ONLY if you take notes.
• Articles/Tweets do NOT count.

Rewards:
• +100 XP
• +2 Intelligence
• +1 Wisdom

"A reader lives a thousand lives before he dies."''',
        type: HabitType.good,
        tier: HabitTier.a,
        xpReward: 50, // A-tier = Medium difficulty (20 min)
        xpPenalty: 50,
        statRewards: {'intelligence': 2, 'wisdom': 1}, // Perfect 2 stats
        statPenalties: {'intelligence': 1},
        streakBonus: 10,
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
        statPenalties: {'willpower': 5, 'endurance': 3, 'awareness': 2},
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
        statPenalties: {'willpower': 4, 'endurance': 2},
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
        statPenalties: {'willpower': 4, 'intelligence': 2},
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
        statPenalties: {'endurance': 3, 'strength': 2, 'awareness': 1},
        hpDamage: 120,
        debuffName: 'Weakened State',
        createdAt: DateTime.now(),
      ),

      // ═══════════════════════════════════════════════════════════
      // AUTOMATIC PENALTY SYSTEM
      // ═══════════════════════════════════════════════════════════
      // Morning Incomplete penalty → AUTO-APPLIED at 10 AM if habits incomplete
      // Shadow Execution penalty → AUTO-APPLIED at 10 PM if redemption not done
      // ═══════════════════════════════════════════════════════════

      // REDEMPTION TASK - Complete this to avoid Shadow Execution
      Habit(
        id: 'evening_redemption_pushups',
        name: '🔥 Evening Redemption (15 Pushups)',
        description: '''⚠️ AUTOMATIC PENALTY SYSTEM ⚠️

If you MISSED your morning routine by 10 AM:
→ Penalty was AUTO-APPLIED (-50 XP, debuff)
→ You now OWE a debt

TO CLEAR YOUR DEBT:
→ DO 15 PUSHUPS RIGHT NOW
→ COMPLETE this habit BEFORE 10 PM

If you DON'T complete this by 10 PM:
→ SHADOW EXECUTION auto-triggers
→ -250 XP, -300 HP, 72h debuff

If your morning was SUCCESSFUL:
→ You don't need this. Skip it.''',
        type: HabitType.good,
        tier: HabitTier.a,
        xpReward: 25, // Easy difficulty
        xpPenalty: 0,
        statRewards: {'willpower': 2, 'strength': 1}, // Perfect 2 stats
        statPenalties: {},
        hpDamage: 0,
        streakBonus: 0,
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
