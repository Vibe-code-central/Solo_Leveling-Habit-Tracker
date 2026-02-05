import 'package:hive/hive.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

part 'activity_data.g.dart';

/// Daily activity tracking data (for GitHub-style heatmap)
@HiveType(typeId: 36)
class ActivityData extends HiveObject {
  @HiveField(0)
  String date; // "2026-02-05" format

  @HiveField(1)
  double completionRate; // 0.0 to 1.0

  @HiveField(2)
  int goodHabitsCompleted;

  @HiveField(3)
  int totalGoodHabits;

  @HiveField(4)
  int badHabitsCommitted;

  @HiveField(5)
  int goldEarned;

  @HiveField(6)
  int xpEarned;

  @HiveField(7)
  List<String> completedHabitIds;

  /// Hash chain for tamper detection (includes previous day's hash)
  @HiveField(8)
  String? previousDayHash;

  @HiveField(9)
  String? currentDayHash;

  ActivityData({
    required this.date,
    required this.completionRate,
    required this.goodHabitsCompleted,
    required this.totalGoodHabits,
    this.badHabitsCommitted = 0,
    this.goldEarned = 0,
    this.xpEarned = 0,
    List<String>? completedHabitIds,
    this.previousDayHash,
    this.currentDayHash,
  }) : completedHabitIds = completedHabitIds ?? [];

  /// Get tile color for heatmap
  /// 🟥 Red: 0-25%
  /// 🟨 Yellow: 26-75%
  /// 🟩 Green: 76-100%
  int get tileColor {
    if (completionRate <= 0.25) {
      return 0xFFFF4757; // Red
    } else if (completionRate <= 0.75) {
      return 0xFFFFD700; // Yellow/Gold
    } else {
      return 0xFF00D2D3; // Green/Cyan
    }
  }

  /// Get color name for display
  String get tileColorName {
    if (completionRate <= 0.25) {
      return 'Red';
    } else if (completionRate <= 0.75) {
      return 'Yellow';
    } else {
      return 'Green';
    }
  }

  /// Calculate hash for this day's data
  String calculateHash(String salt) {
    final data = StringBuffer()
      ..write(date)
      ..write('-')
      ..write(completionRate.toStringAsFixed(2))
      ..write('-')
      ..write(goodHabitsCompleted)
      ..write('-')
      ..write(totalGoodHabits)
      ..write('-')
      ..write(badHabitsCommitted)
      ..write('-')
      ..write(previousDayHash ?? 'GENESIS')
      ..write('-')
      ..write(salt);

    final bytes = utf8.encode(data.toString());
    return sha256.convert(bytes).toString();
  }

  /// Validate hash chain
  static bool validateChain(List<ActivityData> activityHistory, String salt) {
    for (int i = 0; i < activityHistory.length; i++) {
      final activity = activityHistory[i];
      final expectedHash = activity.calculateHash(salt);

      if (activity.currentDayHash != expectedHash) {
        return false; // Tampered!
      }

      // Validate chain link
      if (i > 0) {
        final previousActivity = activityHistory[i - 1];
        if (activity.previousDayHash != previousActivity.currentDayHash) {
          return false; // Chain broken!
        }
      }
    }

    return true;
  }
}
