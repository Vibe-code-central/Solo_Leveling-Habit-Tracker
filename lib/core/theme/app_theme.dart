import 'package:flutter/material.dart';

class AppTheme {
  // Solo Leveling Palette
  static const Color systemBlack = Color(0xFF050505);
  static const Color systemNavy =
      Color(0xFF0B0B15); // Slightly lighter background for cards
  static const Color systemCyan = Color(0xFF00E5FF);
  static const Color systemPurple = Color(0xFF7000FF);
  static const Color systemCrimson = Color(0xFFFF0033);
  static const Color systemGold = Color(0xFFFFD700);
  static const Color systemWhite = Color(0xFFFFFFFF);
  static const Color systemGrey = Color(0xFF808080);

  static const Color primaryPurple = systemPurple; // Backward compatibility
  static const Color electricBlue = systemCyan; // Backward compatibility
  static const Color crimsonRed = systemCrimson; // Backward compatibility
  static const Color emeraldGreen =
      systemCyan; // Backward compatibility (Mapped to Cyan for system look)
  static const Color amberGold = systemGold; // Backward compatibility
  static const Color darkBg = systemBlack; // Backward compatibility
  static const Color cardBg = systemNavy; // Backward compatibility
  static const Color textPrimary = systemWhite; // Backward compatibility
  static const Color textSecondary = systemGrey; // Backward compatibility

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: systemBlack,
      primaryColor: systemCyan,
      cardColor: systemNavy,

      // Typography
      fontFamily: 'Rajdhani', // Default Body Font
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: systemWhite,
          fontSize: 32,
          fontWeight: FontWeight.bold,
          fontFamily: 'Orbitron',
          letterSpacing: 1.5,
        ),
        displayMedium: TextStyle(
          color: systemWhite,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          fontFamily: 'Orbitron',
          letterSpacing: 1.2,
        ),
        displaySmall: TextStyle(
          color: systemWhite,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          fontFamily: 'Orbitron',
          letterSpacing: 1.0,
        ),
        headlineLarge: TextStyle(
          color: systemWhite,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Orbitron',
          letterSpacing: 0.5,
        ),
        headlineMedium: TextStyle(
          color: systemWhite,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          fontFamily: 'Orbitron',
        ),
        headlineSmall: TextStyle(
          color: systemWhite,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          fontFamily: 'Orbitron',
        ),
        bodyLarge: TextStyle(
          color: systemWhite,
          fontSize: 16,
          fontFamily: 'Rajdhani',
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: systemWhite,
          fontSize: 14,
          fontFamily: 'Rajdhani',
          height: 1.4,
        ),
        bodySmall: TextStyle(
          color: systemGrey,
          fontSize: 12,
          fontFamily: 'Rajdhani',
        ),
      ),

      // Input Decoration (Sharp borders)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: systemNavy,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: systemCyan.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: systemCyan.withOpacity(0.3)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: systemCyan, width: 1.5),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: systemCrimson),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),

      // Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent, // Handled by container usually
          foregroundColor: systemWhite,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.zero, // Sharp corners
          ),
          textStyle: const TextStyle(
            fontFamily: 'Orbitron',
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: systemNavy,
        elevation: 0,
        margin: const EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
          side: BorderSide(
            color: systemCyan.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),

      // Color Scheme
      colorScheme: const ColorScheme.dark(
        primary: systemCyan,
        secondary: systemPurple,
        tertiary: systemGold,
        error: systemCrimson,
        surface: systemNavy,
        background: systemBlack,
        onPrimary: systemBlack,
        onSecondary: systemWhite,
        onError: systemWhite,
        onSurface: systemWhite,
        onBackground: systemWhite,
      ),

      dividerColor: systemCyan.withOpacity(0.2),
      iconTheme: const IconThemeData(color: systemCyan),
    );
  }

  // Legacy/Helper Getters to fit new style
  static BoxDecoration get glowingContainer {
    return BoxDecoration(
      color: systemNavy,
      borderRadius: BorderRadius.zero, // Sharp
      border: Border.all(
        color: systemCyan.withOpacity(0.5),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: systemCyan.withOpacity(0.2),
          blurRadius: 10,
          spreadRadius: 0,
        ),
      ],
    );
  }
}
