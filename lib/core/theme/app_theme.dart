import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryPurple = Color(0xFF6B46C1);
  static const Color electricBlue = Color(0xFF3B82F6);
  static const Color crimsonRed = Color(0xFFDC2626);
  static const Color emeraldGreen = Color(0xFF10B981);
  static const Color amberGold = Color(0xFFF59E0B);
  static const Color darkBg = Color(0xFF0F0F1E);
  static const Color cardBg = Color(0xFF1A1A2E);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: MaterialColor(0xFF6B46C1, {
        50: primaryPurple.withOpacity(0.1),
        100: primaryPurple.withOpacity(0.2),
        200: primaryPurple.withOpacity(0.3),
        300: primaryPurple.withOpacity(0.4),
        400: primaryPurple.withOpacity(0.5),
        500: primaryPurple,
        600: primaryPurple.withOpacity(0.7),
        700: primaryPurple.withOpacity(0.8),
        800: primaryPurple.withOpacity(0.9),
        900: primaryPurple,
      }),
      scaffoldBackgroundColor: darkBg,
      cardColor: cardBg,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Orbitron',
        ),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          fontFamily: 'Orbitron',
        ),
        displayMedium: TextStyle(
          color: textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          fontFamily: 'Orbitron',
        ),
        displaySmall: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'Orbitron',
        ),
        headlineLarge: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Rajdhani',
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'Rajdhani',
        ),
        headlineSmall: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
          fontFamily: 'Rajdhani',
        ),
        bodyLarge: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontFamily: 'Rajdhani',
        ),
        bodyMedium: TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontFamily: 'Rajdhani',
        ),
        bodySmall: TextStyle(
          color: textSecondary,
          fontSize: 12,
          fontFamily: 'Rajdhani',
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryPurple,
          foregroundColor: textPrimary,
          elevation: 8,
          shadowColor: primaryPurple.withOpacity(0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Orbitron',
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: cardBg,
        elevation: 8,
        shadowColor: primaryPurple.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: primaryPurple.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryPurple,
        linearTrackColor: Colors.grey,
      ),
      colorScheme: const ColorScheme.dark(
        primary: primaryPurple,
        secondary: electricBlue,
        error: crimsonRed,
        surface: cardBg,
        background: darkBg,
        onPrimary: textPrimary,
        onSecondary: textPrimary,
        onError: textPrimary,
        onSurface: textPrimary,
        onBackground: textPrimary,
      ),
    );
  }

  static BoxDecoration get glowingContainer {
    return BoxDecoration(
      color: cardBg,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: primaryPurple.withOpacity(0.5),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: primaryPurple.withOpacity(0.3),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ],
    );
  }

  static BoxDecoration get shadowGlow {
    return BoxDecoration(
      gradient: RadialGradient(
        colors: [
          primaryPurple.withOpacity(0.4),
          primaryPurple.withOpacity(0.1),
          Colors.transparent,
        ],
      ),
    );
  }
}