import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:solo_leveling/core/theme/app_theme.dart';
import 'package:solo_leveling/data/models/user_profile.dart';
import 'package:solo_leveling/presentation/providers/habit_provider.dart';
import 'package:solo_leveling/presentation/providers/user_provider.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> with TickerProviderStateMixin {
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
                      Icons.bar_chart,
                      color: AppTheme.primaryPurple,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'HUNTER ANALYTICS',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontFamily: 'Orbitron',
                        fontWeight: FontWeight.bold,
                      ),
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
                    Tab(text: 'OVERVIEW'),
                    Tab(text: 'PROGRESS'),
                    Tab(text: 'HABITS'),
                  ],
                ),
              ),
              
              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOverviewTab(),
                    _buildProgressTab(),
                    _buildHabitsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return Consumer2<UserProvider, HabitProvider>(
      builder: (context, userProvider, habitProvider, child) {
        final user = userProvider.userProfile;
        if (user == null) return const Center(child: CircularProgressIndicator());

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Character Stats Radar Chart
              _buildStatsRadarChart(user),
              
              const SizedBox(height: 20),
              
              // Quick Stats Grid
              _buildQuickStatsGrid(user, habitProvider),
              
              const SizedBox(height: 20),
              
              // Active Buffs/Debuffs
              if (user.activeBuffs.isNotEmpty || user.activeDebuffs.isNotEmpty)
                _buildActiveEffects(user),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressTab() {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.userProfile;
        if (user == null) return const Center(child: CircularProgressIndicator());

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // XP Progress Chart
              _buildXPProgressChart(user),
              
              const SizedBox(height: 20),
              
              // Level Milestones
              _buildLevelMilestones(user),
              
              const SizedBox(height: 20),
              
              // Rank Progress
              _buildRankProgress(user),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHabitsTab() {
    return Consumer<HabitProvider>(
      builder: (context, habitProvider, child) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Completion Rate Chart
              _buildCompletionRateChart(habitProvider),
              
              const SizedBox(height: 20),
              
              // Habit Performance
              _buildHabitPerformance(habitProvider),
              
              const SizedBox(height: 20),
              
              // Weekly Stats
              _buildWeeklyStats(habitProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatsRadarChart(UserProfile user) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glowingContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'CHARACTER STATS',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.primaryPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: RadarChart(
              RadarChartData(
                radarTouchData: RadarTouchData(enabled: false),
                dataSets: [
                  RadarDataSet(
                    fillColor: AppTheme.primaryPurple.withOpacity(0.2),
                    borderColor: AppTheme.primaryPurple,
                    borderWidth: 2,
                    dataEntries: [
                      RadarEntry(value: user.stats.strength.toDouble()),
                      RadarEntry(value: user.stats.agility.toDouble()),
                      RadarEntry(value: user.stats.vitality.toDouble()),
                      RadarEntry(value: user.stats.intelligence.toDouble()),
                      RadarEntry(value: user.stats.sense.toDouble()),
                      RadarEntry(value: user.stats.willpower.toDouble()),
                    ],
                  ),
                ],
                radarBackgroundColor: Colors.transparent,
                borderData: FlBorderData(show: false),
                radarBorderData: BorderSide(
                  color: AppTheme.primaryPurple.withOpacity(0.3),
                  width: 1,
                ),
                titlePositionPercentageOffset: 0.2,
                titleTextStyle: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                getTitle: (index, angle) {
                  switch (index) {
                    case 0:
                      return RadarChartTitle(text: 'STR');
                    case 1:
                      return RadarChartTitle(text: 'AGI');
                    case 2:
                      return RadarChartTitle(text: 'VIT');
                    case 3:
                      return RadarChartTitle(text: 'INT');
                    case 4:
                      return RadarChartTitle(text: 'SEN');
                    case 5:
                      return RadarChartTitle(text: 'WIL');
                    default:
                      return const RadarChartTitle(text: '');
                  }
                },
                tickCount: 5,
                ticksTextStyle: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 10,
                ),
                tickBorderData: BorderSide(
                  color: AppTheme.primaryPurple.withOpacity(0.2),
                  width: 1,
                ),
                gridBorderData: BorderSide(
                  color: AppTheme.primaryPurple.withOpacity(0.2),
                  width: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatsGrid(UserProfile user, HabitProvider habitProvider) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'Total XP',
          user.totalXP.toString(),
          Icons.star,
          AppTheme.amberGold,
        ),
        _buildStatCard(
          'Current Level',
          user.level.toString(),
          Icons.trending_up,
          AppTheme.primaryPurple,
        ),
        _buildStatCard(
          'Today\'s XP',
          habitProvider.getTodayXPEarned().toString(),
          Icons.today,
          AppTheme.emeraldGreen,
        ),
        _buildStatCard(
          'Completion Rate',
          '${(habitProvider.getTodayCompletionRate() * 100).toInt()}%',
          Icons.check_circle,
          AppTheme.electricBlue,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActiveEffects(UserProfile user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glowingContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ACTIVE EFFECTS',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.primaryPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // Active Buffs
          if (user.activeBuffs.isNotEmpty) ...[
            ...user.activeBuffs.map((buff) => _buildEffectItem(
              buff.name,
              buff.description,
              buff.expiresAt,
              AppTheme.emeraldGreen,
              Icons.arrow_upward,
            )),
          ],
          
          // Active Debuffs
          if (user.activeDebuffs.isNotEmpty) ...[
            ...user.activeDebuffs.map((debuff) => _buildEffectItem(
              debuff.name,
              debuff.description,
              debuff.expiresAt,
              AppTheme.crimsonRed,
              Icons.arrow_downward,
            )),
          ],
        ],
      ),
    );
  }

  Widget _buildEffectItem(String name, String description, DateTime expiresAt, Color color, IconData icon) {
    final timeLeft = expiresAt.difference(DateTime.now());
    final hoursLeft = timeLeft.inHours;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${hoursLeft}h',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildXPProgressChart(UserProfile user) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glowingContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'XP PROGRESS',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.primaryPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 1000,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: AppTheme.primaryPurple.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return SideTitleWidget(
                          axisSide: meta.axisSide,
                          child: Text(
                            'Lv${value.toInt()}',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1000,
                      reservedSize: 42,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          '${(value / 1000).toInt()}k',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 1,
                maxX: user.level.toDouble(),
                minY: 0,
                maxY: user.totalXP.toDouble(),
                lineBarsData: [
                  LineChartBarData(
                    spots: _generateXPSpots(user),
                    isCurved: true,
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryPurple,
                        AppTheme.electricBlue,
                      ],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryPurple.withOpacity(0.3),
                          AppTheme.primaryPurple.withOpacity(0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _generateXPSpots(UserProfile user) {
    // Generate mock XP progression data
    List<FlSpot> spots = [];
    double totalXP = 0;
    
    for (int level = 1; level <= user.level; level++) {
      totalXP += (level * 200) + (level * level * 50);
      spots.add(FlSpot(level.toDouble(), totalXP));
    }
    
    return spots;
  }

  Widget _buildLevelMilestones(UserProfile user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glowingContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LEVEL MILESTONES',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.primaryPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildMilestoneItem(10, 'First Steps', user.level >= 10),
          _buildMilestoneItem(25, 'Rising Hunter', user.level >= 25),
          _buildMilestoneItem(50, 'Elite Hunter', user.level >= 50),
          _buildMilestoneItem(100, 'Shadow Monarch', user.level >= 100),
        ],
      ),
    );
  }

  Widget _buildMilestoneItem(int level, String title, bool isCompleted) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCompleted 
            ? AppTheme.emeraldGreen.withOpacity(0.1)
            : AppTheme.textSecondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCompleted 
              ? AppTheme.emeraldGreen.withOpacity(0.3)
              : AppTheme.textSecondary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isCompleted ? AppTheme.emeraldGreen : AppTheme.textSecondary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Level $level',
                  style: TextStyle(
                    color: isCompleted ? AppTheme.emeraldGreen : AppTheme.textSecondary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  title,
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRankProgress(UserProfile user) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glowingContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RANK PROGRESSION',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.primaryPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                'Current Rank: ',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getRankColor(user.rank).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _getRankColor(user.rank)),
                ),
                child: Text(
                  _getRankName(user.rank),
                  style: TextStyle(
                    color: _getRankColor(user.rank),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Next Rank: Level ${_getNextRankLevel(user.rank)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionRateChart(HabitProvider habitProvider) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glowingContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HABIT COMPLETION RATE',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.primaryPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: [
                  PieChartSectionData(
                    color: AppTheme.emeraldGreen,
                    value: habitProvider.getTodayCompletionRate() * 100,
                    title: '${(habitProvider.getTodayCompletionRate() * 100).toInt()}%',
                    radius: 50,
                    titleStyle: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: AppTheme.textSecondary.withOpacity(0.3),
                    value: (1 - habitProvider.getTodayCompletionRate()) * 100,
                    title: '',
                    radius: 50,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHabitPerformance(HabitProvider habitProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glowingContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'HABIT PERFORMANCE',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.primaryPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...habitProvider.goodHabits.take(5).map((habit) => 
            _buildHabitPerformanceItem(habit.name, habit.completionRate)
          ),
        ],
      ),
    );
  }

  Widget _buildHabitPerformanceItem(String habitName, double completionRate) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  habitName,
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${(completionRate * 100).toInt()}%',
                style: TextStyle(
                  color: _getCompletionColor(completionRate),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: completionRate,
            backgroundColor: AppTheme.darkBg,
            valueColor: AlwaysStoppedAnimation(_getCompletionColor(completionRate)),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyStats(HabitProvider habitProvider) {
    final weeklyStats = habitProvider.getWeeklyStats();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.glowingContainer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WEEKLY SUMMARY',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.primaryPurple,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildWeeklyStatItem(
                  'Completions',
                  weeklyStats['completions'].toString(),
                  AppTheme.emeraldGreen,
                  Icons.check_circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildWeeklyStatItem(
                  'Failures',
                  weeklyStats['failures'].toString(),
                  AppTheme.crimsonRed,
                  Icons.cancel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyStatItem(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
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
              fontSize: 18,
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

  Color _getRankColor(HunterRank rank) {
    switch (rank) {
      case HunterRank.eRank:
        return Colors.grey;
      case HunterRank.dRank:
        return Colors.brown;
      case HunterRank.cRank:
        return Colors.green;
      case HunterRank.bRank:
        return Colors.blue;
      case HunterRank.aRank:
        return Colors.purple;
      case HunterRank.sRank:
        return Colors.orange;
      case HunterRank.specialSRank:
        return Colors.red;
    }
  }

  String _getRankName(HunterRank rank) {
    switch (rank) {
      case HunterRank.eRank:
        return 'E-RANK';
      case HunterRank.dRank:
        return 'D-RANK';
      case HunterRank.cRank:
        return 'C-RANK';
      case HunterRank.bRank:
        return 'B-RANK';
      case HunterRank.aRank:
        return 'A-RANK';
      case HunterRank.sRank:
        return 'S-RANK';
      case HunterRank.specialSRank:
        return 'SPECIAL S-RANK';
    }
  }

  int _getNextRankLevel(HunterRank rank) {
    switch (rank) {
      case HunterRank.eRank:
        return 6;
      case HunterRank.dRank:
        return 11;
      case HunterRank.cRank:
        return 21;
      case HunterRank.bRank:
        return 36;
      case HunterRank.aRank:
        return 51;
      case HunterRank.sRank:
        return 71;
      case HunterRank.specialSRank:
        return 100;
    }
  }

  Color _getCompletionColor(double rate) {
    if (rate < 0.3) return AppTheme.crimsonRed;
    if (rate < 0.7) return AppTheme.amberGold;
    return AppTheme.emeraldGreen;
  }
}