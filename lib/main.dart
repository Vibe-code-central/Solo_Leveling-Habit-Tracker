import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:workmanager/workmanager.dart';

import 'core/theme/app_theme.dart';
import 'data/models/user_profile.dart';
import 'data/models/habit.dart';
import 'data/models/achievement.dart';
import 'data/services/notification_service.dart';
import 'presentation/providers/user_provider.dart';
import 'presentation/providers/habit_provider.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) {
//     return Future.value(true);
//   });
// }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Hive.initFlutter();
  Hive.registerAdapter(UserProfileAdapter());
  Hive.registerAdapter(PlayerStatsAdapter());
  Hive.registerAdapter(HunterRankAdapter());
  Hive.registerAdapter(HunterClassAdapter());
  Hive.registerAdapter(ActiveBuffAdapter());
  Hive.registerAdapter(ActiveDebuffAdapter());
  Hive.registerAdapter(HabitAdapter());
  Hive.registerAdapter(AchievementAdapter());
  Hive.registerAdapter(AchievementCategoryAdapter());
  Hive.registerAdapter(HabitTypeAdapter());
  Hive.registerAdapter(HabitTierAdapter());
  
  await Hive.openBox<UserProfile>('userProfile');
  await Hive.openBox<Habit>('habits');
  await Hive.openBox<Achievement>('achievements');
  await Hive.openBox('settings');
  
  // await NotificationService.initialize();
  // await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);
  
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0F0F1E),
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  
  runApp(const SoloLevelingApp());
}

class SoloLevelingApp extends StatelessWidget {
  const SoloLevelingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => HabitProvider()),
      ],
      child: MaterialApp(
        title: 'Solo Leveling: Shadow Monarch',
        theme: AppTheme.darkTheme,
        home: const AppInitializer(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final habitProvider = Provider.of<HabitProvider>(context, listen: false);
    
    await userProvider.loadUserProfile();
    await habitProvider.loadHabits();
    // await NotificationService.scheduleDailyReminders();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.isLoading) {
          return const Scaffold(
            backgroundColor: Color(0xFF0F0F1E),
            body: Center(
              child: CircularProgressIndicator(color: Color(0xFF6B46C1)),
            ),
          );
        }
        
        return userProvider.userProfile == null 
            ? const OnboardingScreen() 
            : const HomeScreen();
      },
    );
  }
}