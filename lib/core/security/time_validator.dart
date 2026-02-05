import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

/// Security utility for detecting time travel and timestamp manipulation
class TimeValidator {
  static const String _SETTINGS_BOX = 'settings';
  static const String _LAST_KNOWN_TIME_KEY = 'last_known_time_epoch';
  static const String _VIOLATION_COUNT_KEY = 'time_violation_count';
  static const String _ACCOUNT_LOCKED_KEY = 'account_locked_time_anomaly';

  /// Time buffer to account for clock drift (2 minutes = 120 seconds)
  static const int TIME_BUFFER_SECONDS = 120;

  /// Check if time travel is detected
  static bool isTimeTravelDetected() {
    try {
      final box = Hive.box(_SETTINGS_BOX);
      final now = DateTime.now();
      final lastKnownTimeEpoch = box.get(_LAST_KNOWN_TIME_KEY, defaultValue: 0);

      if (lastKnownTimeEpoch == 0) {
        // First run, set baseline
        _updateLastKnownTime();
        return false;
      }

      final lastKnownTime =
          DateTime.fromMillisecondsSinceEpoch(lastKnownTimeEpoch);
      final timeDiff = now.difference(lastKnownTime).inSeconds;

      // If current time is significantly earlier than last known time
      if (timeDiff < -TIME_BUFFER_SECONDS) {
        debugPrint('⏰ TIME TRAVEL DETECTED!');
        debugPrint('Last known: $lastKnownTime');
        debugPrint('Current: $now');
        debugPrint('Difference: ${timeDiff}s (backwards)');
        _recordViolation();
        return true;
      }

      // Update last known time
      _updateLastKnownTime();
      return false;
    } catch (e) {
      debugPrint('Error in time travel detection: $e');
      return false;
    }
  }

  /// Check if a timestamp is in the future
  static bool isFutureTimestamp(DateTime timestamp, {int bufferSeconds = 5}) {
    final now = DateTime.now();
    final diff = timestamp.difference(now).inSeconds;

    if (diff > bufferSeconds) {
      debugPrint('⏰ FUTURE TIMESTAMP DETECTED!');
      debugPrint('Timestamp: $timestamp');
      debugPrint('Current: $now');
      debugPrint('Difference: +${diff}s (future)');
      return true;
    }

    return false;
  }

  /// Validate that timestamps are in sequential order
  static bool isSequentialOrder(
    DateTime? previousTimestamp,
    DateTime currentTimestamp,
  ) {
    if (previousTimestamp == null) return true;

    if (currentTimestamp.isBefore(previousTimestamp)) {
      debugPrint('⏰ NON-SEQUENTIAL TIMESTAMP!');
      debugPrint('Previous: $previousTimestamp');
      debugPrint('Current: $currentTimestamp');
      return false;
    }

    return true;
  }

  /// Get last known time
  static DateTime? getLastKnownTime() {
    try {
      final box = Hive.box(_SETTINGS_BOX);
      final epoch = box.get(_LAST_KNOWN_TIME_KEY, defaultValue: 0);
      if (epoch == 0) return null;
      return DateTime.fromMillisecondsSinceEpoch(epoch);
    } catch (e) {
      return null;
    }
  }

  /// Update last known time to current time
  static void _updateLastKnownTime() {
    try {
      final box = Hive.box(_SETTINGS_BOX);
      box.put(_LAST_KNOWN_TIME_KEY, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      debugPrint('Error updating last known time: $e');
    }
  }

  /// Record a time violation
  static void _recordViolation() {
    try {
      final box = Hive.box(_SETTINGS_BOX);
      final currentCount = box.get(_VIOLATION_COUNT_KEY, defaultValue: 0);
      box.put(_VIOLATION_COUNT_KEY, currentCount + 1);

      if (currentCount + 1 >= 3) {
        debugPrint('🚨 CRITICAL: 3+ time violations! Locking account.');
        box.put(_ACCOUNT_LOCKED_KEY, true);
      }
    } catch (e) {
      debugPrint('Error recording violation: $e');
    }
  }

  /// Get violation count
  static int getViolationCount() {
    try {
      final box = Hive.box(_SETTINGS_BOX);
      return box.get(_VIOLATION_COUNT_KEY, defaultValue: 0);
    } catch (e) {
      return 0;
    }
  }

  /// Check if account is locked due to time violations
  static bool isAccountLocked() {
    try {
      final box = Hive.box(_SETTINGS_BOX);
      return box.get(_ACCOUNT_LOCKED_KEY, defaultValue: false);
    } catch (e) {
      return false;
    }
  }

  /// Clear violations (admin/debug only)
  static void clearViolations() {
    try {
      final box = Hive.box(_SETTINGS_BOX);
      box.put(_VIOLATION_COUNT_KEY, 0);
      box.put(_ACCOUNT_LOCKED_KEY, false);
      debugPrint('✅ Time violations cleared');
    } catch (e) {
      debugPrint('Error clearing violations: $e');
    }
  }

  /// Force update time (use when legitimately setting time forward, e.g., testing)
  static void forceUpdateTime() {
    _updateLastKnownTime();
    debugPrint('⏰ Forced time update to ${DateTime.now()}');
  }
}
