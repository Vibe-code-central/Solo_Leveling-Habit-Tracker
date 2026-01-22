import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:solo_leveling/core/theme/app_theme.dart';
import 'package:solo_leveling/data/models/user_profile.dart';
import 'package:solo_leveling/presentation/providers/user_provider.dart';
import 'package:solo_leveling/presentation/screens/home/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  final TextEditingController _nameController = TextEditingController();
  int _currentPage = 0;
  HunterClass _selectedClass = HunterClass.warrior;

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
              AppTheme.primaryPurple.withOpacity(0.2),
              AppTheme.darkBg,
            ],
          ),
        ),
        child: PageView(
          controller: _pageController,
          onPageChanged: (page) => setState(() => _currentPage = page),
          children: [
            _buildWelcomePage(),
            _buildNameInputPage(),
            _buildClassSelectionPage(),
            _buildCompletePage(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.primaryPurple,
                  AppTheme.primaryPurple.withOpacity(0.3),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryPurple.withOpacity(0.5),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: const Icon(
              Icons.person,
              size: 100,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'SOLO LEVELING',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 36,
                  letterSpacing: 4,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Shadow Monarch Transformation System',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.electricBlue,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          Text(
            'Transform your daily habits into an immersive RPG experience. Level up your real life through the power of the Shadow Monarch.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 60),
          ElevatedButton(
            onPressed: () => _nextPage(),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'BEGIN YOUR JOURNEY',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameInputPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'HUNTER REGISTRATION',
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: AppTheme.glowingContainer,
            child: Column(
              children: [
                Text(
                  'Enter your Hunter name',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _nameController,
                  onChanged: (_) => setState(() {}),
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: 'Your name...',
                    hintStyle: TextStyle(color: AppTheme.textSecondary),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.primaryPurple),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                          BorderSide(color: AppTheme.electricBlue, width: 2),
                    ),
                    filled: true,
                    fillColor: AppTheme.darkBg.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _previousPage(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: const Text('BACK'),
              ),
              ElevatedButton(
                onPressed: _nameController.text.trim().isNotEmpty
                    ? () => _nextPage()
                    : null,
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: const Text('CONTINUE'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClassSelectionPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'CHOOSE YOUR CLASS',
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Expanded(
            child: ListView(
              children: [
                _buildClassCard(
                  HunterClass.warrior,
                  'WARRIOR',
                  'Masters of physical strength and endurance',
                  'assets/images/warrior_avatar.png',
                  AppTheme.crimsonRed,
                ),
                const SizedBox(height: 16),
                _buildClassCard(
                  HunterClass.mage,
                  'MAGE',
                  'Wielders of knowledge and magical power',
                  'assets/images/mage_avatar.png',
                  AppTheme.electricBlue,
                ),
                const SizedBox(height: 16),
                _buildClassCard(
                  HunterClass.assassin,
                  'ASSASSIN',
                  'Swift and precise, masters of agility',
                  'assets/images/assassin_avatar.png',
                  AppTheme.amberGold,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () => _previousPage(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: const Text('BACK'),
              ),
              ElevatedButton(
                onPressed: () => _nextPage(),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
                child: const Text('CONTINUE'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClassCard(HunterClass hunterClass, String name,
      String description, String imagePath, Color color) {
    final isSelected = _selectedClass == hunterClass;

    return GestureDetector(
      onTap: () => setState(() => _selectedClass = hunterClass),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : AppTheme.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : AppTheme.primaryPurple.withOpacity(0.3),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ]
                    : null,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.asset(
                  imagePath,
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
                    name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: isSelected ? color : null,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: color, size: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletePage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.emeraldGreen,
                  AppTheme.emeraldGreen.withOpacity(0.3),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.emeraldGreen.withOpacity(0.5),
                  blurRadius: 30,
                  spreadRadius: 10,
                ),
              ],
            ),
            child: const Icon(
              Icons.check,
              size: 80,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 40),
          Text(
            'WELCOME, HUNTER',
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            _nameController.text,
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: AppTheme.electricBlue,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: AppTheme.glowingContainer,
            child: Column(
              children: [
                Text(
                  'Your journey as a ${_getClassName(_selectedClass)} begins now.',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  'Complete daily quests, level up your stats, and unlock the power of the Shadow Monarch.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 60),
          ElevatedButton(
            onPressed: () => _completeOnboarding(),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Text(
              'ENTER THE SYSTEM',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  String _getClassName(HunterClass hunterClass) {
    switch (hunterClass) {
      case HunterClass.warrior:
        return 'Warrior';
      case HunterClass.mage:
        return 'Mage';
      case HunterClass.assassin:
        return 'Assassin';
    }
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.createUserProfile(_nameController.text, _selectedClass);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
