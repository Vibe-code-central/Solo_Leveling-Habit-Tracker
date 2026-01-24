import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solo_leveling/core/theme/app_theme.dart';
import 'package:solo_leveling/presentation/providers/habit_provider.dart';
import 'package:solo_leveling/presentation/providers/user_provider.dart';
import 'package:solo_leveling/presentation/widgets/active_debuff_banner.dart';
import 'package:solo_leveling/presentation/widgets/daily_quest_card.dart';
import 'package:solo_leveling/presentation/widgets/hunter_profile_card.dart';
import 'package:solo_leveling/presentation/widgets/shadow_army_display.dart';
import 'package:solo_leveling/presentation/widgets/system_message_card.dart';
import 'package:solo_leveling/presentation/screens/stats/stats_screen.dart';
import 'package:solo_leveling/presentation/screens/habits/habits_screen.dart';
import 'package:solo_leveling/presentation/screens/achievements/achievements_screen.dart';
import 'package:solo_leveling/presentation/screens/profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _shadowAnimationController;
  late AnimationController _glowAnimationController;

  @override
  void initState() {
    super.initState();
    _shadowAnimationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _glowAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shadowAnimationController.dispose();
    _glowAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.darkBg,
              AppTheme.primaryPurple.withOpacity(0.1),
              AppTheme.darkBg,
            ],
          ),
        ),
        child: _buildBody(),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeContent();
      case 1:
        return const StatsScreen();
      case 2:
        return const HabitsScreen();
      case 3:
        return const AchievementsScreen();
      case 4:
        return const ProfileScreen();
      default:
        return _buildHomeContent();
    }
  }

  Widget _buildHomeContent() {
    return SafeArea(
      child: Consumer2<UserProvider, HabitProvider>(
        builder: (context, userProvider, habitProvider, child) {
          final user = userProvider.userProfile;
          if (user == null)
            return const Center(child: CircularProgressIndicator());

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    'HUNTER SYSTEM',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontFamily: 'Orbitron',
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  centerTitle: true,
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.notifications),
                    onPressed: () => _showSystemMessages(context),
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // Active Debuff Banner
                    if (user.activeDebuffs.isNotEmpty)
                      ActiveDebuffBanner(
                        activeDebuffs: user.activeDebuffs,
                      ),
                    if (user.activeDebuffs.isNotEmpty)
                      const SizedBox(height: 16),

                    // Hunter Profile Card
                    HunterProfileCard(
                      userProfile: user,
                      glowAnimation: _glowAnimationController,
                    ),
                    const SizedBox(height: 20),

                    // Shadow Army Display
                    ShadowArmyDisplay(
                      unlockedShadows: user.unlockedShadows,
                      animationController: _shadowAnimationController,
                    ),
                    const SizedBox(height: 20),

                    // System Message
                    SystemMessageCard(
                      completionRate: habitProvider.getTodayCompletionRate(),
                      xpEarned: habitProvider.getTodayXPEarned(),
                      xpLost: habitProvider.getTodayXPLost(),
                    ),
                    const SizedBox(height: 20),

                    // Habit Performance Section
                    _buildSectionHeader('HABIT PERFORMANCE', Icons.trending_up),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: AppTheme.glowingContainer,
                      child: Column(
                        children: habitProvider.goodHabits.take(5).map((habit) {
                          final completionRate = habit.completedDates.length > 0
                              ? (habit.currentStreak /
                                      (habit.completedDates.length +
                                          habit.failedDates.length) *
                                      100)
                                  .clamp(0, 100)
                              : 0.0;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    habit.name,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                                Text(
                                  '${completionRate.toInt()}%',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: completionRate > 50
                                            ? AppTheme.emeraldGreen
                                            : AppTheme.crimsonRed,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Weekly Summary
                    _buildSectionHeader('WEEKLY SUMMARY', Icons.calendar_today),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppTheme.emeraldGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.emeraldGreen.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.check_circle,
                                    color: AppTheme.emeraldGreen, size: 32),
                                const SizedBox(height: 8),
                                Text(
                                  '${habitProvider.getWeeklyStats()['completions']}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineLarge
                                      ?.copyWith(
                                        color: AppTheme.emeraldGreen,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Text(
                                  'Completions',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: AppTheme.crimsonRed.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppTheme.crimsonRed.withOpacity(0.3),
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(Icons.cancel,
                                    color: AppTheme.crimsonRed, size: 32),
                                const SizedBox(height: 8),
                                Text(
                                  '${habitProvider.getWeeklyStats()['failures']}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineLarge
                                      ?.copyWith(
                                        color: AppTheme.crimsonRed,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                Text(
                                  'Failures',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Daily Quests Section
                    _buildSectionHeader('DAILY QUESTS', Icons.assignment),
                    const SizedBox(height: 12),

                    // Good Habits (Daily Quests)
                    ...habitProvider.goodHabits.map((habit) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: DailyQuestCard(
                            habit: habit,
                            onComplete: () => _completeHabit(
                                habit.id, habitProvider, userProvider),
                            onUndo: () => _uncompleteHabit(
                                habit.id, habitProvider, userProvider),
                          ),
                        )),

                    const SizedBox(height: 20),

                    // Demon Traps Section
                    _buildSectionHeader('DEMON TRAPS', Icons.warning,
                        color: AppTheme.crimsonRed),
                    const SizedBox(height: 12),

                    // Bad Habits (Demon Traps)
                    ...habitProvider.badHabits.map((habit) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: DailyQuestCard(
                            habit: habit,
                            onComplete: () => _failHabit(
                                habit.id, habitProvider, userProvider),
                            onUndo: () => _unfailHabit(
                                habit.id, habitProvider, userProvider),
                            isDemonTrap: true,
                          ),
                        )),

                    const SizedBox(
                        height: 100), // Bottom padding for navigation
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, {Color? color}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (color ?? AppTheme.primaryPurple).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: color ?? AppTheme.primaryPurple,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: color ?? AppTheme.primaryPurple,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        border: Border(
          top: BorderSide(
            color: AppTheme.primaryPurple.withOpacity(0.3),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryPurple.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        selectedItemColor: AppTheme.primaryPurple,
        unselectedItemColor: AppTheme.textSecondary,
        selectedLabelStyle: const TextStyle(
          fontFamily: 'Rajdhani',
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Rajdhani',
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Habits',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Achievements',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Future<void> _completeHabit(String habitId, HabitProvider habitProvider,
      UserProvider userProvider) async {
    final habit = habitProvider.habits.firstWhere((h) => h.id == habitId);
    final xpGained = habit.getTotalXPReward();
    final oldLevel = userProvider.userProfile!.level;

    await habitProvider.completeHabit(habitId, userProvider);

    final newLevel = userProvider.userProfile!.level;
    final leveledUp = newLevel > oldLevel;

    if (mounted) {
      // Show XP gain notification
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Quest Completed!',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text('+$xpGained XP gained'),
                      if (leveledUp)
                        Text(
                          '🎉 LEVEL UP! Now Level $newLevel',
                          style: TextStyle(
                              color: AppTheme.amberGold,
                              fontWeight: FontWeight.bold),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.emeraldGreen,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: Duration(seconds: leveledUp ? 2 : 1),
          ),
        );

      // Show level up dialog if leveled up
      if (leveledUp) {
        _showLevelUpDialog(newLevel);
      }
    }
  }

  Future<void> _failHabit(String habitId, HabitProvider habitProvider,
      UserProvider userProvider) async {
    // Show confirmation dialog for demon traps
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'DEMON TRAP TRIGGERED',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.crimsonRed,
              ),
        ),
        content: Text(
          'You have fallen into a demon trap. This will result in penalties. Are you sure?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.crimsonRed),
            child: const Text('CONFIRM'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await habitProvider.failHabit(habitId, userProvider);

      if (mounted) {
        ScaffoldMessenger.of(context)
          ..removeCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: const Text('Demon trap triggered! Penalties applied.'),
              backgroundColor: AppTheme.crimsonRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              duration: const Duration(seconds: 1),
            ),
          );
      }
    }
  }

  Future<void> _uncompleteHabit(String habitId, HabitProvider habitProvider,
      UserProvider userProvider) async {
    await habitProvider.uncompleteHabit(habitId, userProvider);

    if (mounted) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Quest undone. Rewards reversed.'),
            backgroundColor: AppTheme.amberGold,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 1),
          ),
        );
    }
  }

  Future<void> _unfailHabit(String habitId, HabitProvider habitProvider,
      UserProvider userProvider) async {
    await habitProvider.unfailHabit(habitId, userProvider);

    if (mounted) {
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Trap undone. Penalties reversed.'),
            backgroundColor: AppTheme.amberGold,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 1),
          ),
        );
    }
  }

  void _showSystemMessages(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          border: Border.all(
            color: AppTheme.primaryPurple.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textSecondary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '「SYSTEM NOTIFICATIONS」',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primaryPurple,
                    ),
              ),
              const SizedBox(height: 20),
              _buildSystemMessage(
                '⚠️ Daily Quest Reminder',
                'Complete your remaining quests before midnight to avoid penalties.',
                AppTheme.amberGold,
              ),
              const SizedBox(height: 12),
              _buildSystemMessage(
                '🎯 Weekly Boss Challenge',
                'New boss challenge available: "Demon of Procrastination"',
                AppTheme.electricBlue,
              ),
              const SizedBox(height: 12),
              _buildSystemMessage(
                '🔥 Streak Alert',
                'You are on a 7-day streak! Keep it up, Hunter.',
                AppTheme.emeraldGreen,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLevelUpDialog(int newLevel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.amberGold.withOpacity(0.9),
                AppTheme.primaryPurple.withOpacity(0.9),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppTheme.amberGold, width: 3),
            boxShadow: [
              BoxShadow(
                color: AppTheme.amberGold.withOpacity(0.5),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.emoji_events, color: Colors.white, size: 80),
              const SizedBox(height: 16),
              Text(
                'LEVEL UP!',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Level $newLevel',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'All stats increased!',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryPurple,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                child: Text('CONTINUE',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSystemMessage(String title, String message, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
