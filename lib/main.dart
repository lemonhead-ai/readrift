import 'package:ReadRift/models/blurred_status_bar.dart';
import 'package:ReadRift/security/reset_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:ReadRift/screens/home_screen.dart';
import 'package:ReadRift/screens/profile_screen.dart';
import 'package:ReadRift/screens/search_screen.dart';
import 'package:ReadRift/screens/library_screen.dart';
import 'package:ReadRift/screens/welcome_screen.dart';
import 'package:ReadRift/screens/login_screen.dart';
import 'package:ReadRift/screens/signup_screen.dart';
import 'package:ReadRift/theme.dart';


void main() {
  // Set status bar icon brightness
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark, // For iOS
      statusBarIconBrightness: Brightness.dark, // For Android (dark icons in light mode)
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final GoRouter _router = GoRouter(
    initialLocation: '/welcome',
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/library',
        builder: (context, state) => const LibraryScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) => const ResetPasswordScreen(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    // Update status bar icon brightness based on theme
    final isLightMode = MediaQuery.of(context).platformBrightness == Brightness.light;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: isLightMode ? Brightness.dark : Brightness.light,
        statusBarIconBrightness: isLightMode ? Brightness.dark : Brightness.light,
      ),
    );

    return Directionality(
      textDirection: TextDirection.ltr, // Set text direction to left-to-right
      child: BlurredStatusBar(
        child: MaterialApp.router(
          theme: lightTheme(),
          darkTheme: darkTheme(),
          themeMode: ThemeMode.system,
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}