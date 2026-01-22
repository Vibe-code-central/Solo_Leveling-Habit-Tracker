import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';

class ShadowArmyDisplay extends StatelessWidget {
  final List<String> unlockedShadows;
  final AnimationController animationController;

  const ShadowArmyDisplay({
    super.key,
    required this.unlockedShadows,
    required this.animationController,
  });

  @override
  Widget build(BuildContext context) {
    if (unlockedShadows.isEmpty) {
      return _buildEmptyState(context);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.darkBg.withOpacity(0.8),
            AppTheme.primaryPurple.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryPurple.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.groups,
                color: AppTheme.primaryPurple,
                size: 24,
              ),
              const SizedBox(width: 8),
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
                  '${unlockedShadows.length}/6',
                  style: TextStyle(
                    color: AppTheme.primaryPurple,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Shadow Soldiers Grid
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              ...unlockedShadows.map((shadow) => _buildShadowSoldier(shadow, true)),
              ..._getLockedShadows().map((shadow) => _buildShadowSoldier(shadow, false)),
            ],
          ),
          
          if (unlockedShadows.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildArmyBonus(),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryPurple.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.person_outline,
            color: AppTheme.textSecondary,
            size: 48,
          ),
          const SizedBox(height: 12),
          Text(
            'SOLO HUNTER',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Level up to unlock your first shadow soldier at Level 11',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildShadowSoldier(String shadowName, bool isUnlocked) {
    final shadowData = _getShadowData(shadowName);
    
    return Container(
      width: 80,
      height: 100,
      decoration: BoxDecoration(
        gradient: isUnlocked ? LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            shadowData['color'].withOpacity(0.3),
            shadowData['color'].withOpacity(0.1),
          ],
        ) : null,
        color: isUnlocked ? null : AppTheme.darkBg.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnlocked ? shadowData['color'] : AppTheme.textSecondary.withOpacity(0.3),
          width: isUnlocked ? 2 : 1,
        ),
        boxShadow: isUnlocked ? [
          BoxShadow(
            color: shadowData['color'].withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ] : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: isUnlocked ? 1.0 + (animationController.value * 0.1) : 1.0,
                child: Icon(
                  shadowData['icon'],
                  color: isUnlocked ? shadowData['color'] : AppTheme.textSecondary.withOpacity(0.5),
                  size: 32,
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Text(
            shadowData['name'],
            style: TextStyle(
              color: isUnlocked ? shadowData['color'] : AppTheme.textSecondary.withOpacity(0.5),
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
          if (isUnlocked)
            Text(
              shadowData['bonus'],
              style: TextStyle(
                color: shadowData['color'].withOpacity(0.8),
                fontSize: 8,
              ),
              textAlign: TextAlign.center,
            ),
        ],
      ),
    )
    .animate(target: isUnlocked ? 1 : 0)
    .fadeIn(duration: 500.ms)
    .scale(duration: 300.ms, curve: Curves.easeOut);
  }

  Widget _buildArmyBonus() {
    final totalBonus = _calculateTotalBonus();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.primaryPurple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.primaryPurple.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.trending_up,
            color: AppTheme.primaryPurple,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            'Army Bonus: +${totalBonus}% All Stats',
            style: TextStyle(
              color: AppTheme.primaryPurple,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getLockedShadows() {
    const allShadows = ['Iron', 'Tank', 'Igris', 'Beru', 'Bellion', 'Army'];
    return allShadows.where((shadow) => !unlockedShadows.contains(shadow)).toList();
  }

  Map<String, dynamic> _getShadowData(String shadowName) {
    switch (shadowName) {
      case 'Iron':
        return {
          'name': 'IRON',
          'icon': Icons.shield,
          'color': Colors.grey[400]!,
          'bonus': '+5% STR',
        };
      case 'Tank':
        return {
          'name': 'TANK',
          'icon': Icons.pets,
          'color': Colors.brown[400]!,
          'bonus': '+10% VIT',
        };
      case 'Igris':
        return {
          'name': 'IGRIS',
          'icon': Icons.sports_martial_arts,
          'color': AppTheme.crimsonRed,
          'bonus': '+15% STR/AGI',
        };
      case 'Beru':
        return {
          'name': 'BERU',
          'icon': Icons.bug_report,
          'color': AppTheme.emeraldGreen,
          'bonus': '+20% Combat',
        };
      case 'Bellion':
        return {
          'name': 'BELLION',
          'icon': Icons.military_tech,
          'color': AppTheme.amberGold,
          'bonus': '+25% All',
        };
      case 'Army':
        return {
          'name': 'ARMY',
          'icon': Icons.groups,
          'color': AppTheme.primaryPurple,
          'bonus': '+30% All',
        };
      default:
        return {
          'name': 'UNKNOWN',
          'icon': Icons.help,
          'color': AppTheme.textSecondary,
          'bonus': '',
        };
    }
  }

  int _calculateTotalBonus() {
    int bonus = 0;
    for (final shadow in unlockedShadows) {
      switch (shadow) {
        case 'Iron':
          bonus += 5;
          break;
        case 'Tank':
          bonus += 10;
          break;
        case 'Igris':
          bonus += 15;
          break;
        case 'Beru':
          bonus += 20;
          break;
        case 'Bellion':
          bonus += 25;
          break;
        case 'Army':
          bonus += 30;
          break;
      }
    }
    return bonus;
  }
}