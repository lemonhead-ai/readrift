import 'package:readrift/models/blurred_status_bar.dart';
import 'package:readrift/security/auth_service.dart';
import 'package:readrift/security/reset_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:readrift/screens/home_screen.dart';
import 'package:readrift/screens/profile_screen.dart';
import 'package:readrift/screens/search_screen.dart';
import 'package:readrift/screens/library_screen.dart';
import 'package:readrift/screens/welcome_screen.dart';
import 'package:readrift/screens/login_screen.dart';
import 'package:readrift/screens/signup_screen.dart';
import 'package:readrift/screens/notifications_screen.dart';
import 'package:readrift/screens/bookmarks_screen.dart';
import 'package:readrift/screens/subscription_screen.dart';
import 'package:readrift/screens/account_settings_screen.dart';
import 'package:readrift/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:readrift/theme/page_transitions.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase

  // Set status bar icon brightness
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark, // For iOS
      statusBarIconBrightness:
          Brightness.dark, // For Android (dark icons in light mode)
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final router = GoRouter(
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
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/bookmarks',
        builder: (context, state) => const BookmarksScreen(),
      ),
      GoRoute(
        path: '/subscription',
        builder: (context, state) => const SubscriptionScreen(),
      ),
      GoRoute(
        path: '/account-settings',
        builder: (context, state) => const AccountSettingsScreen(),
      ),
    ],
    redirect: (BuildContext context, GoRouterState state) {
      final authService = AuthService();
      final user = authService.currentUser;
      final bool isLoggedIn = user != null;

      // Redirect to HomeScreen if user is logged in and trying to access auth screens
      if (isLoggedIn &&
          (state.matchedLocation == '/welcome' ||
              state.matchedLocation == '/login' ||
              state.matchedLocation == '/signup' ||
              state.matchedLocation == '/reset-password')) {
        return '/';
      }

      // Redirect to WelcomeScreen if user is not logged in and trying to access protected screens
      if (!isLoggedIn &&
          (state.matchedLocation == '/' ||
              state.matchedLocation == '/profile' ||
              state.matchedLocation == '/search' ||
              state.matchedLocation == '/library' ||
              state.matchedLocation == '/notifications' ||
              state.matchedLocation == '/bookmarks' ||
              state.matchedLocation == '/subscription' ||
              state.matchedLocation == '/account-settings')) {
        return '/welcome';
      }

      return null; // No redirect needed
    },
  );

  @override
  Widget build(BuildContext context) {
    // Update status bar icon brightness based on theme
    final isLightMode =
        MediaQuery.of(context).platformBrightness == Brightness.light;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: isLightMode ? Brightness.dark : Brightness.light,
        statusBarIconBrightness:
            isLightMode ? Brightness.dark : Brightness.light,
      ),
    );

    return Directionality(
      textDirection: TextDirection.ltr,
      child: BlurredStatusBar(
        child: MaterialApp.router(
          title: 'ReadRift',
          theme: lightTheme(),
          darkTheme: darkTheme(),
          themeMode: ThemeMode.system,
          routerConfig: router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
