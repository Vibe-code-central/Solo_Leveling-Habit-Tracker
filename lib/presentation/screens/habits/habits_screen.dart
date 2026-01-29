import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solo_leveling/core/theme/app_theme.dart';
import 'package:solo_leveling/data/models/habit.dart';
import 'package:solo_leveling/presentation/providers/habit_provider.dart';
import 'package:solo_leveling/presentation/providers/user_provider.dart';
import 'package:solo_leveling/presentation/widgets/daily_quest_card.dart';
import 'package:solo_leveling/presentation/widgets/system/system_background.dart';
import 'package:solo_leveling/presentation/widgets/system/system_clipper.dart';
import 'package:solo_leveling/presentation/widgets/system/level_up_dialog.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SystemBackground(
        child: Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.assignment,
                    color: AppTheme.primaryPurple,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'QUEST MANAGEMENT',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontFamily: 'Orbitron',
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),

            // Tab Bar
            SystemContainer(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.zero,
              backgroundColor: AppTheme.cardBg,
              borderColor: AppTheme.primaryPurple,
              cutSize: 8,
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: AppTheme.primaryPurple.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                labelColor: AppTheme.primaryPurple,
                unselectedLabelColor: AppTheme.textSecondary,
                labelStyle: const TextStyle(
                  fontFamily: 'Rajdhani',
                  fontWeight: FontWeight.bold,
                ),
                tabs: const [
                  Tab(text: 'DAILY QUESTS'),
                  Tab(text: 'DEMON TRAPS'),
                  Tab(text: 'CUSTOM'),
                ],
              ),
            ),

            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDailyQuestsTab(),
                  _buildDemonTrapsTab(),
                  _buildCustomHabitsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddHabitDialog(),
        backgroundColor: AppTheme.primaryPurple,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    ));
  }

  Widget _buildDailyQuestsTab() {
    return Consumer2<HabitProvider, UserProvider>(
      builder: (context, habitProvider, userProvider, child) {
        final goodHabits = habitProvider.goodHabits;

        if (goodHabits.isEmpty) {
          return _buildEmptyState(
            'No Daily Quests',
            'Add some good habits to start your journey',
            Icons.assignment_outlined,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: goodHabits.length,
          itemBuilder: (context, index) {
            final habit = goodHabits[index];

            // Check if deadline passed for morning habits (10 AM)
            final now = DateTime.now();
            final isMorningHabit = habit.id.startsWith('morning_');
            final isPast10AM = now.hour >= 10;
            final isDeadlinePassed =
                isMorningHabit && isPast10AM && !habit.isCompletedToday;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DailyQuestCard(
                habit: habit,
                onComplete: () =>
                    _completeHabit(habit.id, habitProvider, userProvider),
                onUndo: () =>
                    _uncompleteHabit(habit.id, habitProvider, userProvider),
                isDeadlinePassed: isDeadlinePassed,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDemonTrapsTab() {
    return Consumer2<HabitProvider, UserProvider>(
      builder: (context, habitProvider, userProvider, child) {
        final badHabits = habitProvider.badHabits;

        if (badHabits.isEmpty) {
          return _buildEmptyState(
            'No Demon Traps',
            'Add bad habits to track and avoid them',
            Icons.warning_outlined,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: badHabits.length,
          itemBuilder: (context, index) {
            final habit = badHabits[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DailyQuestCard(
                habit: habit,
                onComplete: () =>
                    _failHabit(habit.id, habitProvider, userProvider),
                onUndo: () =>
                    _unfailHabit(habit.id, habitProvider, userProvider),
                isDemonTrap: true,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCustomHabitsTab() {
    return Consumer2<HabitProvider, UserProvider>(
      builder: (context, habitProvider, userProvider, child) {
        final customHabits =
            habitProvider.habits.where((h) => h.isCustom).toList();

        if (customHabits.isEmpty) {
          return _buildEmptyState(
            'No Custom Habits',
            'Create your own personalized quests',
            Icons.add_circle_outline,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: customHabits.length,
          itemBuilder: (context, index) {
            final habit = customHabits[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: DailyQuestCard(
                habit: habit,
                onComplete: () => habit.type == HabitType.good
                    ? _completeHabit(habit.id, habitProvider, userProvider)
                    : _failHabit(habit.id, habitProvider, userProvider),
                onUndo: () => habit.type == HabitType.good
                    ? _uncompleteHabit(habit.id, habitProvider, userProvider)
                    : _unfailHabit(habit.id, habitProvider, userProvider),
                isDemonTrap: habit.type == HabitType.bad,
                onDelete: () => _deleteHabit(habit.id, habitProvider),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SystemContainer(
              width: 100,
              height: 100,
              backgroundColor: AppTheme.primaryPurple.withOpacity(0.1),
              borderColor: AppTheme.primaryPurple,
              child: Center(
                child: Icon(
                  icon,
                  color: AppTheme.primaryPurple,
                  size: 48,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showAddHabitDialog(),
              icon: const Icon(Icons.add),
              label: const Text('ADD HABIT'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _completeHabit(String habitId, HabitProvider habitProvider,
      UserProvider userProvider) async {
    final leveledUp = await habitProvider.completeHabit(habitId, userProvider);

    if (mounted) {
      if (leveledUp) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => LevelUpDialog(
            newLevel: userProvider.userProfile!.level,
            onConfirm: () => Navigator.pop(context),
          ),
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Quest completed! XP gained.'),
          backgroundColor: AppTheme.emeraldGreen,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _uncompleteHabit(String habitId, HabitProvider habitProvider,
      UserProvider userProvider) async {
    await habitProvider.uncompleteHabit(habitId, userProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Quest undone. Rewards reversed.'),
          backgroundColor: AppTheme.amberGold,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _unfailHabit(String habitId, HabitProvider habitProvider,
      UserProvider userProvider) async {
    await habitProvider.unfailHabit(habitId, userProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Demon trap undone. Penalties reversed.'),
          backgroundColor: AppTheme.amberGold,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Demon trap triggered! Penalties applied.'),
            backgroundColor: AppTheme.crimsonRed,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _deleteHabit(String habitId, HabitProvider habitProvider) async {
    // Show confirmation dialog before deleting
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'DELETE HABIT',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.crimsonRed,
              ),
        ),
        content: Text(
          'Are you sure you want to delete this habit? This action cannot be undone.',
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
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await habitProvider.deleteHabit(habitId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Habit deleted successfully.'),
            backgroundColor: AppTheme.primaryPurple,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _showAddHabitDialog() {
    showDialog(
      context: context,
      builder: (context) => const AddHabitDialog(),
    );
  }
}

class AddHabitDialog extends StatefulWidget {
  const AddHabitDialog({super.key});

  @override
  State<AddHabitDialog> createState() => _AddHabitDialogState();
}

class _AddHabitDialogState extends State<AddHabitDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  HabitType _selectedType = HabitType.good;
  HabitTier _selectedTier = HabitTier.c;
  int _xpReward = 50;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: SystemContainer(
        padding: const EdgeInsets.all(24),
        backgroundColor: AppTheme.cardBg,
        borderColor: AppTheme.primaryPurple,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CREATE CUSTOM HABIT',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primaryPurple,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),

              // Habit Name
              TextField(
                controller: _nameController,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  labelText: 'Habit Name',
                  labelStyle: TextStyle(color: AppTheme.textSecondary),
                  border: OutlineInputBorder(
                    // borderRadius: BorderRadius.zero, // Default theme handles this
                    borderSide: BorderSide(color: AppTheme.primaryPurple),
                  ),
                  focusedBorder: OutlineInputBorder(
                    // borderRadius: BorderRadius.zero,
                    borderSide:
                        BorderSide(color: AppTheme.electricBlue, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Description
              TextField(
                controller: _descriptionController,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(color: AppTheme.textSecondary),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: AppTheme.primaryPurple),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide:
                        BorderSide(color: AppTheme.electricBlue, width: 2),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Habit Type
              Text(
                'Habit Type',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<HabitType>(
                      title: const Text('Good Habit'),
                      value: HabitType.good,
                      groupValue: _selectedType,
                      onChanged: (value) =>
                          setState(() => _selectedType = value!),
                      activeColor: AppTheme.emeraldGreen,
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<HabitType>(
                      title: const Text('Bad Habit'),
                      value: HabitType.bad,
                      groupValue: _selectedType,
                      onChanged: (value) =>
                          setState(() => _selectedType = value!),
                      activeColor: AppTheme.crimsonRed,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Tier Selection
              Text(
                'Tier',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<HabitTier>(
                value: _selectedTier,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                      value: HabitTier.c, child: Text('C-Tier (Easy)')),
                  DropdownMenuItem(
                      value: HabitTier.b, child: Text('B-Tier (Medium)')),
                  DropdownMenuItem(
                      value: HabitTier.a, child: Text('A-Tier (Hard)')),
                  DropdownMenuItem(
                      value: HabitTier.s, child: Text('S-Tier (Extreme)')),
                ],
                onChanged: (value) => setState(() {
                  _selectedTier = value!;
                  _updateXPReward();
                }),
              ),

              const SizedBox(height: 16),

              // XP Reward
              Text(
                'XP Reward/Penalty: $_xpReward',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Slider(
                value: _xpReward.toDouble(),
                min: 10,
                max: 200,
                divisions: 19,
                activeColor: AppTheme.primaryPurple,
                onChanged: (value) => setState(() => _xpReward = value.toInt()),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('CANCEL'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed:
                        _nameController.text.isNotEmpty ? _createHabit : null,
                    child: const Text('CREATE'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateXPReward() {
    switch (_selectedTier) {
      case HabitTier.c:
        _xpReward = 50;
        break;
      case HabitTier.b:
        _xpReward = 80;
        break;
      case HabitTier.a:
        _xpReward = 120;
        break;
      case HabitTier.s:
        _xpReward = 150;
        break;
      default:
        _xpReward = 50;
    }
  }

  void _createHabit() {
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);

    final habit = Habit(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text,
      description: _descriptionController.text,
      type: _selectedType,
      tier: _selectedTier,
      xpReward: _selectedType == HabitType.good ? _xpReward : 0,
      xpPenalty: _selectedType == HabitType.bad ? _xpReward : 0,
      createdAt: DateTime.now(),
      isCustom: true,
    );

    habitProvider.addCustomHabit(habit);
    Navigator.of(context).pop();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Custom habit "${habit.name}" created!'),
        backgroundColor: AppTheme.emeraldGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
