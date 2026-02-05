import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import '../../data/models/user_profile.dart';

/// Security utility for detecting data tampering and integrity violations
class IntegrityChecker {
  // Secret salt for hashing (in production, store securely or generate per-device)
  static const String _SECRET_SALT = 'SOLO_LEVELING_SYSTEM_INTEGRITY_v1';

  /// Calculate integrity hash for user profile
  /// Includes critical data: level, XP, gold, stats
  static String calculateHash(UserProfile profile) {
    try {
      // Concatenate critical data
      final data = StringBuffer()
        ..write(profile.level)
        ..write('-')
        ..write(profile.totalXP)
        ..write('-')
        ..write(profile.gold ?? 0)
        ..write('-')
        ..write(profile.stats.strength)
        ..write('-')
        ..write(profile.stats.willpower)
        ..write('-')
        ..write(profile.stats.intelligence)
        ..write('-')
        ..write(profile.stats.endurance)
        ..write('-')
        ..write(profile.stats.wisdom)
        ..write('-')
        ..write(profile.stats.awareness)
        ..write('-')
        ..write(profile.stats.charisma)
        ..write('-')
        ..write(_SECRET_SALT);

      // Generate SHA-256 hash
      final bytes = utf8.encode(data.toString());
      final hash = sha256.convert(bytes);
      return hash.toString();
    } catch (e) {
      debugPrint('Error calculating hash: $e');
      return '';
    }
  }

  /// Validate if stored hash matches current data
  static bool validateIntegrity(UserProfile profile) {
    if (profile.dataIntegrityHash == null ||
        profile.dataIntegrityHash!.isEmpty) {
      // First time using integrity check, generate and store hash
      profile.dataIntegrityHash = calculateHash(profile);
      return true;
    }

    final calculatedHash = calculateHash(profile);
    final isValid = calculatedHash == profile.dataIntegrityHash;

    if (!isValid) {
      debugPrint('🚨 INTEGRITY VIOLATION DETECTED!');
      debugPrint('Stored hash: ${profile.dataIntegrityHash}');
      debugPrint('Calculated hash: $calculatedHash');
      profile.securityViolationCount =
          (profile.securityViolationCount ?? 0) + 1;
    }

    return isValid;
  }

  /// Update hash after legitimate changes
  static void updateHash(UserProfile profile) {
    profile.dataIntegrityHash = calculateHash(profile);
  }

  /// Detect anomalous stat/gold changes
  static List<String> detectAnomalies(
    UserProfile currentProfile,
    UserProfile? previousProfile,
  ) {
    final anomalies = <String>[];

    if (previousProfile == null) return anomalies;

    // Check for impossible level jumps (max 3 levels per day is realistic)
    final levelDiff = currentProfile.level - previousProfile.level;
    if (levelDiff > 5) {
      anomalies.add('Level increased by $levelDiff (suspicious)');
    }

    // Check for massive gold spikes (max realistic: 3000 from Red Gate)
    final goldDiff = (currentProfile.gold ?? 0) - (previousProfile.gold ?? 0);
    if (goldDiff > 5000) {
      anomalies.add('Gold increased by $goldDiff (suspicious)');
    }

    // Check for impossible stat increases (max realistic: 20 per stat per session)
    final statChecks = {
      'Strength':
          currentProfile.stats.strength - previousProfile.stats.strength,
      'Willpower':
          currentProfile.stats.willpower - previousProfile.stats.willpower,
      'Intelligence': currentProfile.stats.intelligence -
          previousProfile.stats.intelligence,
      'Endurance':
          currentProfile.stats.endurance - previousProfile.stats.endurance,
      'Wisdom': currentProfile.stats.wisdom - previousProfile.stats.wisdom,
      'Awareness':
          currentProfile.stats.awareness - previousProfile.stats.awareness,
      'Charisma':
          currentProfile.stats.charisma - previousProfile.stats.charisma,
    };

    statChecks.forEach((statName, diff) {
      if (diff > 50) {
        anomalies.add('$statName increased by $diff (suspicious)');
      }
    });

    // Check for XP anomalies
    final xpDiff = currentProfile.totalXP - previousProfile.totalXP;
    if (xpDiff > 10000) {
      anomalies.add('Total XP increased by $xpDiff (suspicious)');
    }

    if (anomalies.isNotEmpty) {
      debugPrint('🚨 ANOMALIES DETECTED:');
      for (final anomaly in anomalies) {
        debugPrint('  - $anomaly');
      }
      currentProfile.securityViolationCount =
          (currentProfile.securityViolationCount ?? 0) + anomalies.length;
    }

    return anomalies;
  }

  /// Check if account should be flagged for violations
  static bool shouldFlagAccount(UserProfile profile) {
    return (profile.securityViolationCount ?? 0) >= 5;
  }

  /// Get security status message
  static String getSecurityStatus(UserProfile profile) {
    final violations = profile.securityViolationCount ?? 0;

    if (violations == 0) {
      return '✅ Account secure. No violations detected.';
    } else if (violations < 3) {
      return '⚠️ $violations minor anomaly detected. The System is watching.';
    } else if (violations < 5) {
      return '🚨 $violations anomalies detected. Suspicious activity flagged.';
    } else {
      return '💀 CRITICAL: $violations violations. Data integrity compromised.';
    }
  }
}
