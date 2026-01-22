import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  // static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    // tz.initializeTimeZones();
    // Notification initialization disabled for now
  }

  static Future<void> _requestPermissions() async {
    // Permission requests disabled for now
  }

  static Future<void> scheduleDailyReminders() async {
    // Daily reminders disabled for now
  }

  static Future<void> showLevelUpNotification(int newLevel) async {
    // Level up notifications disabled for now
  }

  static Future<void> showRankUpNotification(String newRank) async {
    // Rank up notifications disabled for now
  }

  static Future<void> showPenaltyNotification(String habitName, int xpLoss) async {
    // Penalty notifications disabled for now
  }

  static Future<void> showAchievementUnlocked(String achievementName) async {
    // Achievement notifications disabled for now
  }

  static Future<void> showBuffAvailable(String buffName) async {
    // Buff notifications disabled for now
  }
}