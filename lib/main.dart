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
import 'package:readrift/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:readrift/services/book_service.dart';
import 'package:readrift/screens/dock.dart';
import 'package:readrift/models/book.dart';

class BookProvider with ChangeNotifier {
  List<Book> recommendations = [];
  List<Book> library = [];

  Future<void> fetchRecommendations() async {
    recommendations = await BookService().getRecommendations();
    notifyListeners();
  }
}

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
        builder: (context, state) => const WelcomeScreen(),
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
      ShellRoute(
        builder: (context, state, child) => ScaffoldWithDock(child: child),
        routes: [
          GoRoute(
            path: '/',
            pageBuilder: (context, state) => const CustomTransitionPage(
              child: HomeScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: '/search',
            pageBuilder: (context, state) => const CustomTransitionPage(
              child: SearchScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: '/library',
            pageBuilder: (context, state) => const CustomTransitionPage(
              child: LibraryScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (context, state) => const CustomTransitionPage(
              child: ProfileScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
        ],
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
              state.matchedLocation == '/library')) {
        return '/welcome';
      }

      return null;
    },
  );

  static Widget _fadeTransition(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    return FadeTransition(opacity: animation, child: child);
  }

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

    return Directionality(
      textDirection: TextDirection.ltr,
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

class ScaffoldWithDock extends StatefulWidget {
  final Widget child;
  const ScaffoldWithDock({super.key, required this.child});

  @override
  State<ScaffoldWithDock> createState() => _ScaffoldWithDockState();
}

class _ScaffoldWithDockState extends State<ScaffoldWithDock> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      //backgroundColor: Colors.transparent,
      body: widget.child,
      bottomNavigationBar: Dock(
        selectedIndex: _selectedIndex,
        onItemTapped: (index) {
          setState(() => _selectedIndex = index);
          switch (index) {
            case 0: context.go('/'); break;
            case 1: context.go('/search'); break;
            case 2: context.go('/library'); break;
            case 3: context.go('/profile'); break;
          }
        },
      ),
    );
  }
}