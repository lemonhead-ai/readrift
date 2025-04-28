import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Define custom colors for consistency
class AppColors {
  // Light mode colors
  static const Color warmWhite = Color(0xFFFFF8E1); // Warm white for background
  static const Color lightText = Colors.black;
  static const Color lightSecondaryText = Colors.black54;
  static const Color accentOrange = Color(0xFFFC9600); // Updated to match the specified orange
  static const Color lightDockBackground = Color(0xFF212121); // Dark background for light mode dock
  static const Color lightDockIcon = Colors.white;

  // Dark mode colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkText = Colors.white;
  static const Color darkSecondaryText = Colors.white70;
  static const Color darkDockBackground = Color(0xFF212121); // Faded grey for dark mode dock
  static const Color darkDockIcon = Colors.white;
}

// Light Theme
ThemeData lightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.warmWhite, // Updated to warm white
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      headlineLarge: TextStyle(
        fontSize: 32, // Adjusted for "The story begins here."
        fontWeight: FontWeight.bold,
        color: AppColors.lightText,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.lightText,
      ),
      bodyLarge: TextStyle(
        fontSize: 18, // Adjusted for better readability
        color: AppColors.lightText,
      ),
      bodyMedium: TextStyle(
        fontSize: 14, // Adjusted for secondary text
        color: AppColors.lightSecondaryText,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accentOrange,
        foregroundColor: AppColors.warmWhite, // Text/icon color for buttons
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.lightDockBackground,
      selectedItemColor: AppColors.accentOrange,
      unselectedItemColor: AppColors.lightDockIcon,
    ),
    iconTheme: IconThemeData(color: AppColors.lightText),
  );
}

// Dark Theme
ThemeData darkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.darkBackground,
    textTheme: GoogleFonts.poppinsTextTheme().copyWith(
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: AppColors.darkText,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.darkText,
      ),
      bodyLarge: TextStyle(
        fontSize: 18,
        color: AppColors.darkText,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        color: AppColors.darkSecondaryText,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accentOrange,
        foregroundColor: AppColors.warmWhite,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkDockBackground,
      selectedItemColor: AppColors.accentOrange,
      unselectedItemColor: AppColors.darkDockIcon,
    ),
    iconTheme: IconThemeData(color: AppColors.darkText),
  );
}