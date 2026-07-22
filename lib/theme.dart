import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

// Define custom colors for consistency
class AppColors {
  // Light mode colors (Snowy White theme)
  static const Color snowyWhite = Color(0xFFFAFAFC);
  static const Color warmWhite = Color(0xFFFAFAFC);
  static const Color sepia = Color(0xFFFFF8E1);
  static const Color lightText = Colors.black87;
  static const Color lightSecondaryText = Colors.black54;
  static const Color accentOrange = Color(0xFFFC9600);
  static const Color lightDockBackground = Color(0xFF1E1E1E);
  static const Color lightDockIcon = Colors.white;

  // Dark mode colors (OLED Pitch Black theme)
  static const Color oledBlack = Color(0xFF000000);
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkCardBackground = Color(0xFF121214);
  static const Color darkText = Colors.white;
  static const Color darkSecondaryText = Colors.white70;
  static const Color darkDockBackground = Color(0xFF161618);
  static const Color darkDockIcon = Colors.white;
}

// Light Theme (Material 3 Snowy White + Cupertino)
ThemeData lightTheme() {
  final baseScheme = ColorScheme.fromSeed(
    seedColor: AppColors.accentOrange,
    brightness: Brightness.light,
    surface: AppColors.snowyWhite,
    primary: AppColors.accentOrange,
    onSurface: AppColors.lightText,
  );

  final baseTextTheme = ThemeData.light().textTheme;

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: baseScheme,
    scaffoldBackgroundColor: AppColors.snowyWhite,
    cupertinoOverrideTheme: const CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.accentOrange,
      scaffoldBackgroundColor: AppColors.snowyWhite,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(baseTextTheme).copyWith(
      headlineLarge: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.lightText,
      ),
      headlineMedium: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.lightText,
      ),
      bodyLarge: const TextStyle(
        fontSize: 18,
        color: AppColors.lightText,
      ),
      bodyMedium: const TextStyle(
        fontSize: 14,
        color: AppColors.lightSecondaryText,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.white,
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: AppColors.lightText,
      textColor: AppColors.lightText,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accentOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightDockBackground,
      selectedItemColor: AppColors.accentOrange,
      unselectedItemColor: AppColors.lightDockIcon,
    ),
    iconTheme: const IconThemeData(color: AppColors.lightText),
  );
}

// Dark Theme (Material 3 OLED Pitch Black + Cupertino)
ThemeData darkTheme() {
  final baseScheme = ColorScheme.fromSeed(
    seedColor: AppColors.accentOrange,
    brightness: Brightness.dark,
    surface: AppColors.oledBlack,
    primary: AppColors.accentOrange,
    onSurface: AppColors.darkText,
  );

  final baseTextTheme = ThemeData.dark().textTheme;

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: baseScheme,
    scaffoldBackgroundColor: AppColors.oledBlack,
    cupertinoOverrideTheme: const CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.accentOrange,
      scaffoldBackgroundColor: AppColors.oledBlack,
    ),
    textTheme: GoogleFonts.poppinsTextTheme(baseTextTheme).copyWith(
      headlineLarge: const TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.darkText,
      ),
      headlineMedium: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.darkText,
      ),
      bodyLarge: const TextStyle(
        fontSize: 18,
        color: AppColors.darkText,
      ),
      bodyMedium: const TextStyle(
        fontSize: 14,
        color: AppColors.darkSecondaryText,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: AppColors.darkCardBackground,
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: AppColors.darkText,
      textColor: AppColors.darkText,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accentOrange,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkDockBackground,
      selectedItemColor: AppColors.accentOrange,
      unselectedItemColor: AppColors.darkDockIcon,
    ),
    iconTheme: const IconThemeData(color: AppColors.darkText),
  );
}