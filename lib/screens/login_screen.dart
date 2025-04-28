import 'package:ReadRift/security/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ReadRift/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    // Basic input validation
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    String? error = await _authService.signIn(email: email, password: password);

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
                  "And the\nstory goes on.",
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 50,
                    fontFamily: 'FuturaPT',
                    color: AppColors.accentOrange,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "Welcome back. Enter your credentials to access your account.",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppColors.lightSecondaryText
                        : AppColors.darkSecondaryText,
                    fontFamily: 'FuturaPT',
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 32),
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
                const SizedBox(height: 32),
                Center(
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                    ),
                    child: Text(
                      "Log in",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: AppColors.warmWhite,
                        fontFamily: 'FuturaPT',
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
                        "Forgot your password? ",
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
                          context.go('/reset-password');
                        },
                        child: Text(
                          "Reset password",
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