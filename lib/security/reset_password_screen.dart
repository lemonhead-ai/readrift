import 'package:ReadRift/security/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ReadRift/theme.dart';


class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  _ResetPasswordScreenState createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLinkSent = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    setState(() {
      _isLoading = true;
    });

    String email = _emailController.text.trim();

    // Basic input validation
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your email")),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    String? error = await _authService.sendPasswordResetEmail(email);

    setState(() {
      _isLoading = false;
      if (error == null) {
        _isLinkSent = true;
      }
    });

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password reset link sent to $email")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
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
                  context.go('/login');
                },
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Reset\nyour story.",
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                        fontFamily: 'FuturaPT',
                        fontWeight: FontWeight.w800,
                        fontSize: 60,
                        color: AppColors.accentOrange,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Enter your email to receive a password reset link.",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).brightness == Brightness.light
                            ? AppColors.lightSecondaryText
                            : AppColors.darkSecondaryText,
                        fontSize: 20,
                        fontFamily: 'FuturaPT',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (!_isLinkSent) ...[
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: "Enter your email",
                          hintStyle: TextStyle(
                            color: Theme.of(context).brightness == Brightness.light
                                ? AppColors.lightSecondaryText
                                : AppColors.darkSecondaryText,
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
                      const SizedBox(height: 32),
                      Center(
                        child: _isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                          onPressed: _sendResetLink,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          ),
                          child: Text(
                            "Send reset link",
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                              color: AppColors.warmWhite,
                              fontFamily: 'FuturaPT',
                            ),
                          ),
                        ),
                      ),
                    ],
                    if (_isLinkSent)
                      Center(
                        child: Text(
                          "A reset link has been sent to your email.",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).brightness == Brightness.light
                                ? AppColors.lightText
                                : AppColors.darkText,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
              Center(
                child: GestureDetector(
                  onTap: () {
                    context.go('/login');
                  },
                  child: Text(
                    "Back to login",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.accentOrange,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'FuturaPT',
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}