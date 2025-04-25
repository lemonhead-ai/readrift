import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Add this import

// Define custom colors for consistency
class AppColors {
  // Light mode colors
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightText = Colors.black;
  static const Color lightSecondaryText = Colors.black54;
  static const Color accentOrange = Colors.orange;
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
    scaffoldBackgroundColor: AppColors.lightBackground,
    textTheme: GoogleFonts.poppinsTextTheme().copyWith( // Add Poppins font here
      headlineMedium: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: AppColors.lightText,
      ),
      bodyLarge: TextStyle(
        fontSize: 24,
        color: AppColors.lightText,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: AppColors.lightSecondaryText,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkBackground,
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
    textTheme: GoogleFonts.poppinsTextTheme().copyWith( // Add Poppins font here
      headlineMedium: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: AppColors.darkText,
      ),
      bodyLarge: TextStyle(
        fontSize: 24,
        color: AppColors.darkText,
      ),
      bodyMedium: TextStyle(
        fontSize: 16,
        color: AppColors.darkSecondaryText,
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.darkDockBackground,
      selectedItemColor: AppColors.darkDockIcon,
      unselectedItemColor: AppColors.darkSecondaryText,
    ),
    iconTheme: IconThemeData(color: AppColors.darkText),
  );
}