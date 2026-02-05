import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:solo_leveling/core/theme/app_theme.dart';
import 'package:solo_leveling/data/models/user_profile.dart';
import 'package:solo_leveling/presentation/providers/user_provider.dart';
import 'package:solo_leveling/presentation/providers/habit_provider.dart';
import 'package:solo_leveling/presentation/screens/onboarding/onboarding_screen.dart';
import 'buffs_debuffs_guide_screen.dart';
import 'titles_screen.dart';
import 'package:solo_leveling/data/models/debuff.dart';
import 'package:solo_leveling/presentation/widgets/system/system_dialog.dart';
import 'package:solo_leveling/presentation/widgets/system/system_clipper.dart';
import 'package:solo_leveling/presentation/widgets/system/system_background.dart';
import '../inventory/inventory_screen.dart';
import '../../widgets/activity_heatmap.dart';
import 'package:solo_leveling/data/models/habit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SystemBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              final habitProvider = Provider.of<HabitProvider>(context);
              final user = userProvider.userProfile;
              if (user == null) {
                return const Center(child: CircularProgressIndicator());
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          color: AppTheme.primaryPurple,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'HUNTER PROFILE',
                          style: Theme.of(context)
                              .textTheme
                              .displaySmall
                              ?.copyWith(
                                fontFamily: 'Orbitron',
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Profile Card
                    _buildProfileCard(context, user, userProvider),

                    const SizedBox(height: 16),

                    // Inventory Button
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const InventoryScreen())),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.systemCyan.withOpacity(0.1),
                          border: Border.all(color: AppTheme.systemCyan),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.backpack, color: AppTheme.systemCyan),
                            SizedBox(width: 8),
                            Text("OPEN INVENTORY",
                                style: TextStyle(
                                    color: AppTheme.systemCyan,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Orbitron',
                                    letterSpacing: 1.5)),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const SizedBox(height: 24),
                    // Stats Overview
                    _buildStatsOverview(context, user),

                    const SizedBox(height: 24),
                    // Activity Heatmap
                    _buildHeatmapSection(habitProvider),

                    // 🔴 ACTIVE DEBUFFS SECTION
                    if (userProvider.activeDebuffs.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      _buildActiveEffectsSection(
                          context, userProvider.activeDebuffs),
                    ],

                    const SizedBox(height: 24),
                    // Shadow Army
                    _buildShadowArmySection(context, user),

                    const SizedBox(height: 20),

                    // Achievements Summary
                    _buildAchievementsSummary(context, userProvider),

                    const SizedBox(height: 20),

                    // Guides Section
                    _buildGuidesSection(context),

                    const SizedBox(height: 20),

                    // Settings
                    _buildSettingsSection(context),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(
      BuildContext context, UserProfile user, UserProvider userProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        border: Border.all(color: userProvider.getRankColor()),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Avatar and Basic Info
          Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      userProvider.getRankColor(),
                      userProvider.getRankColor().withOpacity(0.3),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: userProvider.getRankColor().withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    _getClassImagePath(user.hunterClass),
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const TitlesScreen(),
                          ),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(
                              user.title,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: AppTheme.electricBlue,
                                    fontStyle: FontStyle.italic,
                                    decoration: TextDecoration.underline,
                                  ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.edit,
                              color: AppTheme.electricBlue, size: 14),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: userProvider.getRankColor().withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: userProvider.getRankColor()),
                      ),
                      child: Text(
                        userProvider.getRankDisplayName(),
                        style: TextStyle(
                          color: userProvider.getRankColor(),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Level and XP
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Level',
                  user.level.toString(),
                  Icons.trending_up,
                  AppTheme.primaryPurple,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'Total XP',
                  user.totalXP.toString(),
                  Icons.star,
                  AppTheme.amberGold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Days Active',
                  _calculateDaysActive(user.createdAt).toString(),
                  Icons.calendar_today,
                  AppTheme.emeraldGreen,
                ),
              ),
              Expanded(
                child: _buildInfoItem(
                  'Shadows',
                  user.unlockedShadows.length.toString(),
                  Icons.groups,
                  AppTheme.electricBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.2, duration: 300.ms, curve: Curves.easeOut);
  }

  Widget _buildInfoItem(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(BuildContext context, UserProfile user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.systemNavy,
        border: Border.all(color: AppTheme.primaryPurple),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'STATS OVERVIEW',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.primaryPurple,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1.2,
            children: [
              _buildStatItem('STR', user.stats.strength, Icons.fitness_center),
              _buildStatItem('WIL', user.stats.willpower, Icons.psychology_alt),
              _buildStatItem('CHA', user.stats.charisma, Icons.star),
              _buildStatItem('END', user.stats.endurance, Icons.favorite),
              _buildStatItem('WIS', user.stats.wisdom, Icons.psychology),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmapSection(HabitProvider habitProvider) {
    final habits = habitProvider.habits.where((h) => h.type == HabitType.good);
    final Map<DateTime, int> activityMap = {};

    for (var habit in habits) {
      for (var date in habit.completedDates) {
        // Normalize date to prevent timestamp mismatch
        final normalized = DateTime(date.year, date.month, date.day);
        activityMap[normalized] = (activityMap[normalized] ?? 0) + 1;
      }
    }

    return ActivityHeatmap(
      activityData: activityMap,
    );
  }

  Widget _buildStatItem(String label, int value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.darkBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.primaryPurple.withOpacity(0.3),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: AppTheme.textSecondary, size: 16),
          const SizedBox(height: 4),
          Text(
            value.toString(),
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShadowArmySection(BuildContext context, UserProfile user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.systemNavy,
        border: Border.all(color: AppTheme.primaryPurple),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'SHADOW ARMY',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primaryPurple,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryPurple.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${user.unlockedShadows.length}/6',
                  style: TextStyle(
                    color: AppTheme.primaryPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (user.unlockedShadows.isEmpty)
            Text(
              'No shadows unlocked yet. Reach Level 11 to unlock your first shadow soldier.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: user.unlockedShadows
                  .map(
                    (shadow) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryPurple.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: AppTheme.primaryPurple.withOpacity(0.5)),
                      ),
                      child: Text(
                        shadow,
                        style: TextStyle(
                          color: AppTheme.primaryPurple,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSummary(
      BuildContext context, UserProvider userProvider) {
    final unlockedCount =
        userProvider.achievements.where((a) => a.isUnlocked).length;
    final totalCount = userProvider.achievements.length;
    final completionRate = totalCount > 0 ? unlockedCount / totalCount : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.systemNavy,
        border: Border.all(color: AppTheme.primaryPurple),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ACHIEVEMENTS',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.primaryPurple,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Unlocked: $unlockedCount/$totalCount',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: completionRate,
                      backgroundColor: AppTheme.darkBg,
                      valueColor: AlwaysStoppedAnimation(AppTheme.amberGold),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.amberGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: AppTheme.amberGold.withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    Icon(Icons.emoji_events,
                        color: AppTheme.amberGold, size: 20),
                    const SizedBox(height: 4),
                    Text(
                      '${(completionRate * 100).toInt()}%',
                      style: TextStyle(
                        color: AppTheme.amberGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGuidesSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.systemNavy,
        border: Border.all(color: AppTheme.electricBlue),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.menu_book,
                color: AppTheme.electricBlue,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'GUIDES',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppTheme.electricBlue,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildGuideItem(
            context,
            'Buffs & Debuffs Guide',
            'Learn how buffs and debuffs affect your XP gains and stats',
            Icons.auto_awesome,
            AppTheme.electricBlue,
            () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BuffsDebuffsGuideScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGuideItem(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 12,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: color,
          size: 16,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.systemNavy,
        border: Border.all(color: AppTheme.primaryPurple),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SETTINGS',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.primaryPurple,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          _buildSettingsItem(
            'Notifications',
            'Manage quest reminders and alerts',
            Icons.notifications,
            () => _showNotificationSettings(context),
          ),
          _buildSettingsItem(
            'Data Export',
            'Export your progress data',
            Icons.download,
            () => _showDataExport(context),
          ),
          _buildSettingsItem(
            'Reset Progress',
            'Start your journey over',
            Icons.refresh,
            () => _showResetConfirmation(context),
          ),
          _buildSettingsItem(
            'About',
            'App version and information',
            Icons.info,
            () => _showAboutDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(
      String title, String subtitle, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.primaryPurple.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppTheme.primaryPurple, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: AppTheme.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppTheme.textSecondary,
      ),
      onTap: onTap,
    );
  }

  String _getClassImagePath(HunterClass hunterClass) {
    switch (hunterClass) {
      case HunterClass.warrior:
        return 'assets/images/warrior_avatar.png';
      case HunterClass.mage:
        return 'assets/images/mage_avatar.png';
      case HunterClass.assassin:
        return 'assets/images/assassin_avatar.png';
    }
  }

  int _calculateDaysActive(DateTime createdAt) {
    return DateTime.now().difference(createdAt).inDays + 1;
  }

  void _showNotificationSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Notification Settings',
          style: TextStyle(color: AppTheme.primaryPurple),
        ),
        content: const Text('Notification settings will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showDataExport(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Data Export',
          style: TextStyle(color: AppTheme.primaryPurple),
        ),
        content:
            const Text('Data export functionality will be implemented here.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Reset Progress',
          style: TextStyle(color: AppTheme.crimsonRed),
        ),
        content: const Text(
          'Are you sure you want to reset all your progress? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();

              // 1. Reset Providers
              final userProvider =
                  Provider.of<UserProvider>(context, listen: false);
              final habitProvider =
                  Provider.of<HabitProvider>(context, listen: false);

              await userProvider.resetProgress();
              await habitProvider.resetHabits();

              // 2. Navigate to Onboarding
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => const OnboardingScreen()),
                  (route) => false,
                );
              }
            },
            style:
                ElevatedButton.styleFrom(backgroundColor: AppTheme.crimsonRed),
            child: const Text('RESET'),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SystemDialog(
        title: 'SYSTEM INFORMATION',
        message: 'Solo Leveling: Shadow Monarch\nVersion 1.0.2\n\n'
            'Transform your daily habits into an immersive RPG experience. '
            'Level up your real life through the power of the Shadow Monarch.',
        primaryColor: AppTheme.primaryPurple,
        icon: Icons.info_outline,
        confirmText: 'CLOSE',
        onConfirm: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildActiveEffectsSection(
      BuildContext context, List<Debuff> debuffs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Icon(Icons.gpp_bad, color: AppTheme.crimsonRed, size: 20),
              const SizedBox(width: 8),
              Text(
                'ACTIVE STATUS EFFECTS',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.crimsonRed,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...debuffs.map((debuff) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.crimsonRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.crimsonRed.withOpacity(0.4)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.crimsonRed.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.bolt, color: AppTheme.crimsonRed, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        debuff.name.toUpperCase(),
                        style: const TextStyle(
                          color: AppTheme.crimsonRed,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'tier ${debuff.tier} • -${(debuff.xpReductionPercent * 100).toInt()}% XP',
                        style: TextStyle(
                          color: AppTheme.crimsonRed.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                      if (debuff.specialEffect != null)
                        Text(
                          'CURSE: ${debuff.specialEffect.toString().split('.').last.toUpperCase()}',
                          style: const TextStyle(
                            color: AppTheme.crimsonRed,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                    ],
                  ),
                ),
                // Timer
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'EXPIRES IN',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 8,
                      ),
                    ),
                    Text(
                      '${debuff.hoursRemaining}h',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}
