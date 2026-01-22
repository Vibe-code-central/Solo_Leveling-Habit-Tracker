import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class BuffsDebuffsGuideScreen extends StatelessWidget {
  const BuffsDebuffsGuideScreen({super.key});

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
              _buildHeader(context),
              
              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildOverviewSection(),
                      const SizedBox(height: 24),
                      _buildHowItWorksSection(),
                      const SizedBox(height: 24),
                      _buildDebuffsSection(),
                      const SizedBox(height: 24),
                      _buildBuffsSection(),
                      const SizedBox(height: 24),
                      _buildTipsSection(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.primaryPurple.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            color: AppTheme.textPrimary,
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'BUFFS & DEBUFFS GUIDE',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontFamily: 'Orbitron',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection() {
    return _buildSection(
      title: '📚 Overview',
      icon: Icons.info_outline,
      color: AppTheme.electricBlue,
      children: [
        _buildInfoCard(
          'What are Buffs & Debuffs?',
          'Buffs and Debuffs are temporary status effects that modify your XP gains and stats. They add strategic depth to your habit-tracking journey.',
          AppTheme.electricBlue,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          'Buffs',
          'Positive effects that enhance your performance. Currently, buffs are stored but not yet implemented in the game.',
          AppTheme.emeraldGreen,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          'Debuffs',
          'Negative effects applied when you fail bad habits (Demon Traps). They reduce your XP gains and stat improvements. Only the highest severity debuff remains active at a time.',
          AppTheme.crimsonRed,
        ),
      ],
    );
  }

  Widget _buildHowItWorksSection() {
    return _buildSection(
      title: '⚙️ How It Works',
      icon: Icons.settings,
      color: AppTheme.primaryPurple,
      children: [
        _buildStepCard(
          '1',
          'Failing Bad Habits',
          'When you fail a bad habit (like "Midnight Scrolling" or "Gaming Abyss"), a debuff is automatically applied.',
          AppTheme.crimsonRed,
        ),
        const SizedBox(height: 12),
        _buildStepCard(
          '2',
          'Debuff Effects',
          'Debuffs reduce your XP gains and stat improvements by applying multipliers. For example, "Demon\'s Grip" reduces XP by 25%.',
          AppTheme.amberGold,
        ),
        const SizedBox(height: 12),
        _buildStepCard(
          '3',
          'Highest Severity Only',
          'Only the highest severity debuff remains active. If you get a more severe debuff, it replaces the current one.',
          AppTheme.electricBlue,
        ),
        const SizedBox(height: 12),
        _buildStepCard(
          '4',
          'Expiration',
          'Debuffs automatically expire after their duration (24h, 30h, 36h, or 7 days). They are removed when you open the app on a new day.',
          AppTheme.emeraldGreen,
        ),
      ],
    );
  }

  Widget _buildDebuffsSection() {
    return _buildSection(
      title: '🔴 Active Debuffs',
      icon: Icons.warning,
      color: AppTheme.crimsonRed,
      children: [
        _buildDebuffCard(
          "Demon's Grip",
          '25% XP reduction for 36h',
          'Applied when failing "Midnight Scrolling"',
          'Reduces all XP gains by 25%',
          '36 hours',
          AppTheme.crimsonRed,
        ),
        const SizedBox(height: 12),
        _buildDebuffCard(
          'Sluggish Start',
          '-15% XP for 24h',
          'Applied when failing certain habits',
          'Reduces all XP gains by 15%',
          '24 hours',
          AppTheme.amberGold,
        ),
        const SizedBox(height: 12),
        _buildDebuffCard(
          'Weakened State',
          '-20% Strength for 36h',
          'Applied when failing "Junk Food Consumption"',
          'Reduces Strength stat gains by 20%',
          '36 hours',
          AppTheme.crimsonRed,
        ),
        const SizedBox(height: 12),
        _buildDebuffCard(
          'Mind Fog',
          '-10% Intelligence for 24h',
          'Applied when failing certain habits',
          'Reduces Intelligence stat gains by 10%',
          '24 hours',
          AppTheme.electricBlue,
        ),
        const SizedBox(height: 12),
        _buildDebuffCard(
          'Fatigue',
          '-20% all stats for 30h',
          'Applied when failing "Rest & Recovery"',
          'Reduces ALL stat gains by 20%',
          '30 hours',
          AppTheme.crimsonRed,
        ),
        const SizedBox(height: 12),
        _buildDebuffCard(
          'Entertainment Haze',
          '-20% productivity (36h)',
          'Applied when failing certain habits',
          'Reduces productivity-related gains',
          '36 hours',
          AppTheme.amberGold,
        ),
        const SizedBox(height: 12),
        _buildDebuffCard(
          'Time Void',
          'Lose 1 day of progress (30h)',
          'Applied when failing "Gaming Abyss"',
          'Visual indicator of lost progress',
          '30 hours',
          AppTheme.crimsonRed,
        ),
        const SizedBox(height: 12),
        _buildDebuffCard(
          'Mounting Dread',
          'Anxiety meter increases (24h)',
          'Applied when failing certain habits',
          'Visual indicator of mounting stress',
          '24 hours',
          AppTheme.crimsonRed,
        ),
        const SizedBox(height: 12),
        _buildDebuffCard(
          'Disorganized',
          'Next day planning disabled (24h)',
          'Applied when failing certain habits',
          'Affects planning capabilities',
          '24 hours',
          AppTheme.electricBlue,
        ),
        const SizedBox(height: 12),
        _buildDebuffCard(
          'Corrupted State',
          'Severe corruption (7 days)',
          'Applied when failing severe habits',
          'Long-term negative effect',
          '7 days',
          AppTheme.crimsonRed,
        ),
      ],
    );
  }

  Widget _buildBuffsSection() {
    return _buildSection(
      title: '🟢 Buffs (Coming Soon)',
      icon: Icons.auto_awesome,
      color: AppTheme.emeraldGreen,
      children: [
        _buildInfoCard(
          'Future Feature',
          'Buffs will be positive effects that enhance your performance. They may be earned through achievements, completing streaks, or special events.',
          AppTheme.emeraldGreen,
        ),
        const SizedBox(height: 12),
        _buildInfoCard(
          'Potential Buff Types',
          '• XP Boost: Increase XP gains\n• Stat Boost: Enhance stat improvements\n• Streak Protection: Prevent streak loss\n• Resource Boost: Increase HP/MP regeneration',
          AppTheme.electricBlue,
        ),
      ],
    );
  }

  Widget _buildTipsSection() {
    return _buildSection(
      title: '💡 Tips & Strategies',
      icon: Icons.lightbulb_outline,
      color: AppTheme.amberGold,
      children: [
        _buildTipCard(
          'Avoid Bad Habits',
          'The best way to avoid debuffs is to avoid failing bad habits. Focus on completing good habits instead!',
          Icons.shield,
        ),
        const SizedBox(height: 12),
        _buildTipCard(
          'Check Your Status',
          'View your active debuff at the top of the Home screen. Only the highest severity debuff is shown.',
          Icons.visibility,
        ),
        const SizedBox(height: 12),
        _buildTipCard(
          'Plan Your Day',
          'If you have active debuffs, plan your habit completions accordingly. You\'ll earn less XP, so focus on consistency.',
          Icons.calendar_today,
        ),
        const SizedBox(height: 12),
        _buildTipCard(
          'Wait It Out',
          'Debuffs expire automatically. Only one debuff can be active at a time (the highest severity). Wait for it to expire before attempting major habit completions.',
          Icons.timer,
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1);
  }

  Widget _buildInfoCard(String title, String content, Color color) {
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepCard(String number, String title, String content, Color color) {
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDebuffCard(
    String name,
    String description,
    String trigger,
    String effect,
    String duration,
    Color color,
  ) {
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
          Row(
            children: [
              Icon(Icons.warning, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDetailRow('Description', description),
          const SizedBox(height: 8),
          _buildDetailRow('Trigger', trigger),
          const SizedBox(height: 8),
          _buildDetailRow('Effect', effect),
          const SizedBox(height: 8),
          _buildDetailRow('Duration', duration),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            '$label:',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTipCard(String title, String content, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.amberGold.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.amberGold.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.amberGold, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.amberGold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
