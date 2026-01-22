import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:solo_leveling/core/theme/app_theme.dart';
import 'package:solo_leveling/data/models/achievement.dart';
import 'package:solo_leveling/presentation/providers/user_provider.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      color: AppTheme.amberGold,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'ACHIEVEMENTS',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontFamily: 'Orbitron',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Consumer<UserProvider>(
                      builder: (context, userProvider, child) {
                        final unlockedCount = userProvider.achievements
                            .where((a) => a.isUnlocked)
                            .length;
                        final totalCount = userProvider.achievements.length;
                        
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.amberGold.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppTheme.amberGold),
                          ),
                          child: Text(
                            '$unlockedCount/$totalCount',
                            style: TextStyle(
                              color: AppTheme.amberGold,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              // Tab Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryPurple.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicator: BoxDecoration(
                    color: AppTheme.primaryPurple.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelColor: AppTheme.primaryPurple,
                  unselectedLabelColor: AppTheme.textSecondary,
                  labelStyle: const TextStyle(
                    fontFamily: 'Rajdhani',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  tabs: const [
                    Tab(text: 'ALL'),
                    Tab(text: 'MONARCH\'S PATH'),
                    Tab(text: 'FLAME KEEPER'),
                    Tab(text: 'BOSS SLAYER'),
                    Tab(text: 'STAT MASTER'),
                    Tab(text: 'COLLECTOR'),
                  ],
                ),
              ),
              
              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAllAchievements(),
                    _buildCategoryAchievements(AchievementCategory.monarchsPath),
                    _buildCategoryAchievements(AchievementCategory.flameKeeper),
                    _buildCategoryAchievements(AchievementCategory.bossSlayer),
                    _buildCategoryAchievements(AchievementCategory.statMaster),
                    _buildCategoryAchievements(AchievementCategory.collector),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAllAchievements() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final achievements = userProvider.achievements;
        
        if (achievements.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            final achievement = achievements[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildAchievementCard(achievement),
            );
          },
        );
      },
    );
  }

  Widget _buildCategoryAchievements(AchievementCategory category) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final achievements = userProvider.achievements
            .where((a) => a.category == category)
            .toList();
        
        if (achievements.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: achievements.length,
          itemBuilder: (context, index) {
            final achievement = achievements[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildAchievementCard(achievement),
            );
          },
        );
      },
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    final isUnlocked = achievement.isUnlocked;
    final categoryColor = _getCategoryColor(achievement.category);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: isUnlocked ? LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            categoryColor.withOpacity(0.2),
            categoryColor.withOpacity(0.05),
          ],
        ) : null,
        color: isUnlocked ? null : AppTheme.cardBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked ? categoryColor : AppTheme.textSecondary.withOpacity(0.3),
          width: isUnlocked ? 2 : 1,
        ),
        boxShadow: isUnlocked ? [
          BoxShadow(
            color: categoryColor.withOpacity(0.3),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ] : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              // Achievement Icon
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: isUnlocked 
                      ? categoryColor.withOpacity(0.2)
                      : AppTheme.textSecondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isUnlocked ? categoryColor : AppTheme.textSecondary.withOpacity(0.3),
                  ),
                ),
                child: Center(
                  child: Text(
                    achievement.icon,
                    style: TextStyle(
                      fontSize: 24,
                      color: isUnlocked ? categoryColor : AppTheme.textSecondary.withOpacity(0.5),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Achievement Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      achievement.name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: isUnlocked ? categoryColor : AppTheme.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      achievement.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: isUnlocked ? AppTheme.textPrimary : AppTheme.textSecondary.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Status Icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isUnlocked 
                      ? AppTheme.emeraldGreen.withOpacity(0.2)
                      : AppTheme.textSecondary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isUnlocked ? Icons.check : Icons.lock,
                  color: isUnlocked ? AppTheme.emeraldGreen : AppTheme.textSecondary,
                  size: 20,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Progress Bar (if not completed)
          if (!achievement.isCompleted) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Text(
                  '${achievement.currentProgress}/${achievement.targetValue}',
                  style: TextStyle(
                    color: isUnlocked ? categoryColor : AppTheme.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            LinearProgressIndicator(
              value: achievement.progressPercentage,
              backgroundColor: AppTheme.darkBg,
              valueColor: AlwaysStoppedAnimation(
                isUnlocked ? categoryColor : AppTheme.textSecondary.withOpacity(0.5),
              ),
            ),
          ],
          
          const SizedBox(height: 12),
          
          // Rewards
          Row(
            children: [
              // XP Reward
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.amberGold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.amberGold.withOpacity(0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      color: AppTheme.amberGold,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+${achievement.xpReward} XP',
                      style: TextStyle(
                        color: AppTheme.amberGold,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Title Unlock
              if (achievement.titleUnlock != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.primaryPurple.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.title,
                        color: AppTheme.primaryPurple,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        achievement.titleUnlock!,
                        style: TextStyle(
                          color: AppTheme.primaryPurple,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          
          // Unlock Date
          if (isUnlocked && achievement.unlockedAt != null) ...[
            const SizedBox(height: 8),
            Text(
              'Unlocked: ${_formatDate(achievement.unlockedAt!)}',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    )
    .animate(target: isUnlocked ? 1 : 0)
    .fadeIn(duration: 500.ms)
    .scale(duration: 300.ms, curve: Curves.easeOut)
    .then()
    .shimmer(duration: 2000.ms, color: categoryColor.withOpacity(0.3));
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.amberGold.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.amberGold.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.emoji_events,
                color: AppTheme.amberGold,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Achievements Yet',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Complete quests and level up to unlock achievements',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.monarchsPath:
        return AppTheme.primaryPurple;
      case AchievementCategory.flameKeeper:
        return AppTheme.amberGold;
      case AchievementCategory.bossSlayer:
        return AppTheme.crimsonRed;
      case AchievementCategory.statMaster:
        return AppTheme.electricBlue;
      case AchievementCategory.perfectHunter:
        return AppTheme.emeraldGreen;
      case AchievementCategory.collector:
        return Colors.orange;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}