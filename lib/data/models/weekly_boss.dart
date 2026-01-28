class WeeklyBoss {
  final String id;
  final String name;
  final String icon;
  final String description;
  final int targetCompletions;
  final String? habitIdPrefix; // e.g., 'morning_' for any morning habit
  final String? specificHabitId; // e.g., 'daily_water'
  final bool isNegativeAvoidance; // If true, target is to NOT fail habits
  final bool
      requiresUniqueDays; // If true, count distinct days instead of total completions
  final int xpReward;
  final Map<String, int> statRewards;

  WeeklyBoss({
    required this.id,
    required this.name,
    required this.icon,
    required this.description,
    required this.targetCompletions,
    this.habitIdPrefix,
    this.specificHabitId,
    this.isNegativeAvoidance = false,
    this.requiresUniqueDays = false,
    required this.xpReward,
    required this.statRewards,
  });

  // Get the boss for the current week number (1-4 rotating cycle)
  static WeeklyBoss getCurrentBoss() {
    // Calculate week number from epoch (resetting cycle every 4 weeks)
    final now = DateTime.now();
    // Simple week calculation: (Day of year / 7)
    // final dayOfYear = int.parse(
    //     "${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}"); // Simplified for demo
    // Better week calc:
    final weekNumber =
        (now.millisecondsSinceEpoch / (1000 * 60 * 60 * 24 * 7)).floor();
    final bossIndex = weekNumber % 4;

    return _bosses[bossIndex];
  }

  // For testing/debugging, get specific boss
  static WeeklyBoss getBossByIndex(int index) {
    return _bosses[index % 4];
  }

  static final List<WeeklyBoss> _bosses = [
    // WEEK 1: DEMON OF SLOTH (Morning Routine)
    WeeklyBoss(
      id: 'boss_sloth',
      name: 'Demon of Sloth',
      icon: '💤',
      description:
          'Defeat the urge to sleep in! Complete your Morning Routine habits 7 times this week.',
      targetCompletions: 7,
      habitIdPrefix: 'morning_',
      requiresUniqueDays: true, // Forces 7 separate days
      xpReward: 500,
      statRewards: {'willpower': 5},
    ),

    // WEEK 2: BEAST OF GLUTTONY (Junk Food Avoidance)
    WeeklyBoss(
      id: 'boss_gluttony',
      name: 'Beast of Gluttony',
      icon: '🍔',
      description:
          'Resist the hunger! Do NOT fail your Junk Food habit avoidance for 7 days.',
      targetCompletions: 7, // 7 days of success (not failing)
      specificHabitId: 'junk_food',
      isNegativeAvoidance: true,
      xpReward: 400,
      statRewards: {'endurance': 5},
    ),

    // WEEK 3: SHADOW OF PROCRASTINATION (General Consistency)
    WeeklyBoss(
      id: 'boss_procrastination',
      name: 'Shadow of Procrastination',
      icon: '⏳',
      description:
          'Stop delaying! Complete at least 20 habits total this week.',
      targetCompletions: 20,
      habitIdPrefix: '', // Any habit counts
      xpReward: 600,
      statRewards: {'strength': 5},
    ),

    // WEEK 4: SPECTER OF DISTRACTION (Screen Time)
    WeeklyBoss(
      id: 'boss_distraction',
      name: 'Specter of Distraction',
      icon: '📱',
      description:
          'Focus your mind! Do NOT fail your Screen Time habit avoidance for 5 days.',
      targetCompletions: 5,
      specificHabitId: 'midnight_scrolling',
      isNegativeAvoidance: true,
      xpReward: 450,
      statRewards: {'wisdom': 5},
    ),
  ];
}
