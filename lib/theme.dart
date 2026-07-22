import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';

// Define custom colors for consistency
class AppColors {
  // Light mode colors
  static const Color warmWhite = Color(0xFFFFF8E1); // Warm white for background
  static const Color lightText = Colors.black87;
  static const Color lightSecondaryText = Colors.black54;
  static const Color accentOrange = Color(0xFFFC9600); // Specified orange accent
  static const Color lightDockBackground = Color(0xFF212121); // Dark background for light mode dock
  static const Color lightDockIcon = Colors.white;

  // Dark mode colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkText = Colors.white;
  static const Color darkSecondaryText = Colors.white70;
  static const Color darkDockBackground = Color(0xFF212121); // Faded grey for dark mode dock
  static const Color darkDockIcon = Colors.white;
}

// Light Theme (Material 3 + Cupertino Integration)
ThemeData lightTheme() {
  final baseScheme = ColorScheme.fromSeed(
    seedColor: AppColors.accentOrange,
    brightness: Brightness.light,
    surface: AppColors.warmWhite,
    primary: AppColors.accentOrange,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: baseScheme,
    scaffoldBackgroundColor: AppColors.warmWhite,
    cupertinoOverrideTheme: const CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.accentOrange,
      scaffoldBackgroundColor: AppColors.warmWhite,
    ),
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
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

// Dark Theme (Material 3 + Cupertino Integration)
ThemeData darkTheme() {
  final baseScheme = ColorScheme.fromSeed(
    seedColor: AppColors.accentOrange,
    brightness: Brightness.dark,
    surface: AppColors.darkBackground,
    primary: AppColors.accentOrange,
  );

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: baseScheme,
    scaffoldBackgroundColor: AppColors.darkBackground,
    cupertinoOverrideTheme: const CupertinoThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.accentOrange,
      scaffoldBackgroundColor: AppColors.darkBackground,
    ),
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
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
      color: const Color(0xFF1E1E1E),
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