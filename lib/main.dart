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
import 'package:readrift/screens/reader_screen.dart';
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
        pageBuilder: (context, state) => buildAdaptivePageRoute(
          context: context,
          state: state,
          child: const WelcomeScreen(),
        ),
      ),
      GoRoute(
        path: '/',
        pageBuilder: (context, state) => buildAdaptivePageRoute(
          context: context,
          state: state,
          child: const HomeScreen(),
        ),
      ),
      GoRoute(
        path: '/profile',
        pageBuilder: (context, state) => buildAdaptivePageRoute(
          context: context,
          state: state,
          child: const ProfileScreen(),
        ),
      ),
      GoRoute(
        path: '/search',
        pageBuilder: (context, state) => buildAdaptivePageRoute(
          context: context,
          state: state,
          child: const SearchScreen(),
        ),
      ),
      GoRoute(
        path: '/library',
        pageBuilder: (context, state) => buildAdaptivePageRoute(
          context: context,
          state: state,
          child: const LibraryScreen(),
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => buildAdaptivePageRoute(
          context: context,
          state: state,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/signup',
        pageBuilder: (context, state) => buildAdaptivePageRoute(
          context: context,
          state: state,
          child: const SignUpScreen(),
        ),
      ),
      GoRoute(
        path: '/reset-password',
        pageBuilder: (context, state) => buildAdaptivePageRoute(
          context: context,
          state: state,
          child: const ResetPasswordScreen(),
        ),
      ),
      GoRoute(
        path: '/notifications',
        pageBuilder: (context, state) => buildAdaptivePageRoute(
          context: context,
          state: state,
          child: const NotificationsScreen(),
        ),
      ),
      GoRoute(
        path: '/bookmarks',
        pageBuilder: (context, state) => buildAdaptivePageRoute(
          context: context,
          state: state,
          child: const BookmarksScreen(),
        ),
      ),
      GoRoute(
        path: '/subscription',
        pageBuilder: (context, state) => buildAdaptivePageRoute(
          context: context,
          state: state,
          child: const SubscriptionScreen(),
        ),
      ),
      GoRoute(
        path: '/account-settings',
        pageBuilder: (context, state) => buildAdaptivePageRoute(
          context: context,
          state: state,
          child: const AccountSettingsScreen(),
        ),
      ),
      GoRoute(
        path: '/reader',
        pageBuilder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return buildAdaptivePageRoute(
            context: context,
            state: state,
            child: ReaderScreen(
              bookId: extra['bookId'] as String,
              filePath: extra['filePath'] as String,
              bookTitle: extra['bookTitle'] as String,
              fileType: extra['fileType'] as String,
            ),
          );
        },
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
              state.matchedLocation == '/account-settings' ||
              state.matchedLocation == '/reader')) {
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
