// lib/main.dart
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
import 'package:provider/provider.dart';
import 'package:readrift/screens/dock.dart';
import 'package:readrift/providers/book_provider.dart';
import 'package:readrift/providers/theme_provider.dart';
import 'package:readrift/theme/page_transitions.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => BookProvider()),
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final GoRouter _router = GoRouter(
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
      ShellRoute(
        builder: (context, state, child) => ScaffoldWithDock(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => buildAdaptivePageRoute(
              context: context,
              state: state,
              child: const HomeScreen(),
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
            path: '/profile',
            pageBuilder: (context, state) => buildAdaptivePageRoute(
              context: context,
              state: state,
              child: const ProfileScreen(),
            ),
          ),
        ],
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

      if (isLoggedIn &&
          (state.matchedLocation == '/welcome' ||
              state.matchedLocation == '/login' ||
              state.matchedLocation == '/signup' ||
              state.matchedLocation == '/reset-password')) {
        return '/';
      }

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

      return null;
    },
  );

  @override
  Widget build(BuildContext context) {
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

    final themeProvider = Provider.of<ThemeProvider>(context);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: BlurredStatusBar(
        child: MaterialApp.router(
          theme: lightTheme(),
          darkTheme: darkTheme(),
          themeMode: themeProvider.themeMode,
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}

class ScaffoldWithDock extends StatelessWidget {
  final Widget child;
  const ScaffoldWithDock({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location == '/search') return 1;
    if (location == '/library') return 2;
    if (location == '/profile') return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _calculateSelectedIndex(context);
    return Scaffold(
      extendBody: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: child,
      bottomNavigationBar: Dock(
        selectedIndex: selectedIndex,
        onItemTapped: (index) {
          switch (index) {
            case 0:
              context.go('/');
              break;
            case 1:
              context.go('/search');
              break;
            case 2:
              context.go('/library');
              break;
            case 3:
              context.go('/profile');
              break;
          }
        },
      ),
    );
  }
}