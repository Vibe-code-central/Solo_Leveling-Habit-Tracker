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
import 'data/models/debuff.dart'; // Import Debuff model
import 'data/models/shop_item.dart'; // NEW: Shop system
import 'data/models/user_inventory.dart'; // NEW: Inventory & Gold
import 'data/models/gate.dart'; // NEW: Gate system
import 'data/models/activity_data.dart'; // NEW: Activity tracker
import 'data/models/exp_transaction.dart'; // NEW: XP transaction tracking
import 'data/services/notification_service.dart';
import 'presentation/providers/user_provider.dart';
import 'presentation/providers/habit_provider.dart';
import 'presentation/providers/shop_provider.dart';
import 'presentation/providers/gate_provider.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';
import 'presentation/widgets/system/gate_dialog.dart';

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) {
//     return Future.value(true);
//   });
// }

void main() async {
  try {
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
    Hive.registerAdapter(AchievementRarityAdapter()); // Register rarity adapter
    Hive.registerAdapter(DebuffAdapter()); // Register Debuff adapter
    Hive.registerAdapter(DebuffSpecialEffectAdapter()); // Register enum adapter
    Hive.registerAdapter(HabitTypeAdapter());
    Hive.registerAdapter(HabitTierAdapter());

    // ═════════════════════════════════════════════════════════════
    // NEW ADAPTERS - Solo Leveling System v2 (MUST be in typeId order!)
    // ═════════════════════════════════════════════════════════════
    Hive.registerAdapter(ShopItemTypeAdapter()); // typeId: 25
    Hive.registerAdapter(ShopItemRarityAdapter()); // typeId: 26
    Hive.registerAdapter(ShopItemAdapter()); // typeId: 27
    Hive.registerAdapter(TransactionTypeAdapter()); // typeId: 28
    Hive.registerAdapter(TransactionAdapter()); // typeId: 29
    Hive.registerAdapter(InventoryItemAdapter()); // typeId: 30
    Hive.registerAdapter(UserInventoryAdapter()); // typeId: 31
    Hive.registerAdapter(GateTypeAdapter()); // typeId: 32
    Hive.registerAdapter(GateRewardAdapter()); // typeId: 33
    Hive.registerAdapter(GateAdapter()); // typeId: 34
    Hive.registerAdapter(RedGateBattleAdapter()); // typeId: 35
    Hive.registerAdapter(ActivityDataAdapter()); // typeId: 36
    Hive.registerAdapter(ExpTransactionTypeAdapter()); // typeId: 38
    Hive.registerAdapter(ExpTransactionAdapter()); // typeId: 39

    await Hive.openBox<UserProfile>('userProfile');
    await Hive.openBox<Habit>('habits');

    // Migration: Handle corrupt achievements
    try {
      await Hive.openBox<Achievement>('achievements');
    } catch (e) {
      await Hive.deleteBoxFromDisk('achievements');
      await Hive.openBox<Achievement>('achievements');
    }

    await Hive.openBox<Debuff>('debuffs'); // Open debuffs box

    // NEW BOXES - Solo Leveling System v2
    await Hive.openBox('inventory'); // User inventory & Gold
    await Hive.openBox('gates'); // Active gates
    await Hive.openBox('activity'); // Activity tracker data
    await Hive.openBox('shop'); // Shop stock & cooldowns

    await Hive.openBox('settings');

    // SystemChrome setup
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0F0F1E),
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    runApp(const SoloLevelingApp());
  } catch (e) {
    // Fallback if initialization fails
    runApp(MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              'Initialization Error:\n$e\n\nPlease reinstall the app.',
              style: const TextStyle(color: Colors.red, fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    ));
  }
}

class SoloLevelingApp extends StatelessWidget {
  const SoloLevelingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => HabitProvider()),
        ChangeNotifierProvider(create: (_) => ShopProvider()),
        ChangeNotifierProvider(create: (_) => GateProvider()),
      ],
      child: MaterialApp(
        title: 'ARISE',
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
  bool _isInitializing = true;

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
    final shopProvider = Provider.of<ShopProvider>(context, listen: false);
    final gateProvider = Provider.of<GateProvider>(context, listen: false);

    await userProvider.loadUserProfile();
    await habitProvider.loadHabits();
    await shopProvider.initialize();
    await gateProvider.initialize();

    // Check for random gate spawn (-1% chance for Red Gate, 10% for Blue)
    // Runs once per app launch (provider handles daily/hourly limit cooldown)
    final spawnSuccess = await gateProvider.checkForGateSpawn(userProvider);
    if (spawnSuccess && mounted) {
      final gate = gateProvider.activeGate;
      if (gate != null) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => GateDialog(gate: gate),
        );
      }
      debugPrint("⛩️ GATE SPAWNED! UI NEEDED");
    }

    // await NotificationService.scheduleDailyReminders();

    if (mounted) {
      setState(() {
        _isInitializing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isInitializing) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F0F1E),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF6B46C1)),
        ),
      );
    }

    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return userProvider.userProfile == null
            ? const OnboardingScreen()
            : const HomeScreen();
      },
    );
  }
}
