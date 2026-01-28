import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solo_leveling/core/theme/app_theme.dart';
import 'package:solo_leveling/data/models/achievement.dart'; // To process Achievement.getDefaultAchievements()
import 'package:solo_leveling/presentation/providers/user_provider.dart';

class TitlesScreen extends StatelessWidget {
  const TitlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get all achievements to map titles to descriptions
    final allAchievements = Achievement.getDefaultAchievements();

    // Extract unique titles and their source achievements
    final Map<String, Achievement> titleSourceMap = {};
    for (var ach in allAchievements) {
      if (ach.titleUnlock != null) {
        titleSourceMap[ach.titleUnlock!] = ach;
      }
    }

    // Add default title manually since it has no achievement source
    // titleSourceMap["The Shadow's Candidate"] = ... (handle manually in builder)

    final titleList = titleSourceMap.keys.toList();
    // Prepend default title
    if (!titleList.contains("The Shadow's Candidate")) {
      titleList.insert(0, "The Shadow's Candidate");
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.darkBg,
              AppTheme.primaryPurple.withOpacity(0.05),
              AppTheme.darkBg,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'TITLE SEALS',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                            fontFamily: 'Orbitron',
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            letterSpacing: 2,
                          ),
                    ),
                  ],
                ),
              ),

              // Title Grid
              Expanded(
                child: Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    final user = userProvider.userProfile;
                    if (user == null) return const SizedBox();

                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                      ),
                      itemCount: titleList.length,
                      itemBuilder: (context, index) {
                        final titleName = titleList[index];
                        final isUnlocked =
                            user.unlockedTitles.contains(titleName);
                        final isEquipped = user.title == titleName;
                        final sourceAchievement = titleSourceMap[titleName];

                        return _buildSealCard(
                          context,
                          titleName: titleName,
                          isUnlocked: isUnlocked,
                          isEquipped: isEquipped,
                          description:
                              sourceAchievement?.description ?? "Default Title",
                          onEquip: () {
                            if (isUnlocked && !isEquipped) {
                              userProvider.equipTitle(titleName);
                            }
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSealCard(
    BuildContext context, {
    required String titleName,
    required bool isUnlocked,
    required bool isEquipped,
    required String description,
    required VoidCallback onEquip,
  }) {
    final cardColor =
        isUnlocked ? AppTheme.cardBg : Colors.grey.withOpacity(0.1);
    final borderColor = isEquipped
        ? AppTheme.amberGold
        : (isUnlocked
            ? AppTheme.primaryPurple.withOpacity(0.5)
            : Colors.transparent);

    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: isEquipped ? 2 : 1),
        boxShadow: isEquipped
            ? [
                BoxShadow(
                    color: AppTheme.amberGold.withOpacity(0.3), blurRadius: 12)
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Seal Icon
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUnlocked
                  ? AppTheme.primaryPurple.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              border: Border.all(
                  color: isUnlocked
                      ? AppTheme.primaryPurple
                      : Colors.grey.withOpacity(0.3)),
            ),
            child: Icon(
              isEquipped
                  ? Icons.shield
                  : (isUnlocked ? Icons.verified_user_outlined : Icons.lock),
              color: isUnlocked ? AppTheme.primaryPurple : Colors.grey,
              size: 30,
            ),
          ),

          const SizedBox(height: 16),

          // Title Name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              isUnlocked ? titleName : "LOCKED SEAL",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isUnlocked ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
                fontFamily: 'Orbitron',
                letterSpacing: 1,
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Requirement / Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              description,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 10,
              ),
            ),
          ),

          const Spacer(),

          // Equip Action
          if (isUnlocked)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: isEquipped
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.amberGold.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "EQUIPPED",
                        style: TextStyle(
                          color: AppTheme.amberGold,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    )
                  : SizedBox(
                      height: 28,
                      child: ElevatedButton(
                        onPressed: onEquip,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryPurple,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        child: const Text(
                          "EQUIP",
                          style: TextStyle(fontSize: 10),
                        ),
                      ),
                    ),
            ),

          if (!isUnlocked)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Icon(Icons.lock_outline,
                  color: Colors.grey.withOpacity(0.3), size: 16),
            )
        ],
      ),
    );
  }
}
