import 'package:ReadRift/security/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ReadRift/theme.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    setState(() {
      _isLoading = true;
    });

    String username = _usernameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // Basic input validation
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password must be at least 6 characters long")),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    String? error = await _authService.signUp(
      username: username,
      email: email,
      password: password,
    );

    setState(() {
      _isLoading = false;
    });

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    } else {
      // Navigation handled by GoRouter redirect
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  icon: Icon(
                    Icons.arrow_back,
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppColors.lightText
                        : AppColors.darkText,
                  ),
                  onPressed: () {
                    context.go('/welcome');
                  },
                ),
                const SizedBox(height: 32),
                Text(
                  "Start\nyour journey.",
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 50,
                    fontFamily: 'FuturaPT',
                    color: AppColors.accentOrange,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Create an account to explore unlimited stories.",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontFamily: 'FuturaPT',
                    fontSize: 20,
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppColors.lightSecondaryText
                        : AppColors.darkSecondaryText,
                  ),
                ),
                const SizedBox(height: 32),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    hintText: "Enter your username",
                    hintStyle: TextStyle(
                      color: Theme.of(context).brightness == Brightness.light
                          ? AppColors.lightSecondaryText
                          : AppColors.darkSecondaryText,
                      fontFamily: 'FuturaPT',
                      fontWeight: FontWeight.w500,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.light
                            ? AppColors.lightSecondaryText.withOpacity(0.3)
                            : AppColors.darkSecondaryText.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.accentOrange,
                      ),
                    ),
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppColors.lightText
                        : AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: "Enter your email",
                    hintStyle: TextStyle(
                      color: Theme.of(context).brightness == Brightness.light
                          ? AppColors.lightSecondaryText
                          : AppColors.darkSecondaryText,
                      fontFamily: 'FuturaPT',
                      fontWeight: FontWeight.w500,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.light
                            ? AppColors.lightSecondaryText.withOpacity(0.3)
                            : AppColors.darkSecondaryText.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.accentOrange,
                      ),
                    ),
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppColors.lightText
                        : AppColors.darkText,
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: "Password",
                    hintStyle: TextStyle(
                      color: Theme.of(context).brightness == Brightness.light
                          ? AppColors.lightSecondaryText
                          : AppColors.darkSecondaryText,
                      fontFamily: 'FuturaPT',
                      fontWeight: FontWeight.w500,
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).brightness == Brightness.light
                            ? AppColors.lightSecondaryText.withOpacity(0.3)
                            : AppColors.darkSecondaryText.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.accentOrange,
                      ),
                    ),
                  ),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppColors.lightText
                        : AppColors.darkText,
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                Center(
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: _handleSignUp,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                    ),
                    child: Text(
                      "Sign up",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.warmWhite,
                        fontFamily: 'FuturaPT',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account? ",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).brightness == Brightness.light
                              ? AppColors.lightSecondaryText
                              : AppColors.darkSecondaryText,
                          fontFamily: 'FuturaPT',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          context.go('/login');
                        },
                        child: Text(
                          "Log in",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.accentOrange,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'FuturaPT',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}