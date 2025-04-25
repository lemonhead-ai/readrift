import 'package:ReadRift/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'theme.dart'; // Import the theme file

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme(), // Light theme
      darkTheme: darkTheme(), // Dark theme
      themeMode: ThemeMode.system, // Use system theme (or ThemeMode.light/dark for manual control)
      home: HomeScreen(),
    );
  }
}