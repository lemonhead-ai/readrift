import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:readrift/theme.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      "title": "The story\nbegins here.",
      "subtitle": "Unlimited stories in your hand. Immerse yourself into amazing worlds and start your journey today.",
      "image": "assets/welcome_illustration.png",
    },
    {
      "title": "Your local\nuniverse.",
      "subtitle": "Import your own EPUB and PDF files. Read what you love, whenever you want, offline.",
      "image": "assets/welcome_illustration.png", // Reusing for consistency, ideally unique
    },
    {
      "title": "Tailored for\nyou.",
      "subtitle": "Switch between OLED, Sepia, and Snowy themes. Customize your reading experience to perfection.",
      "image": "assets/welcome_illustration.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _onboardingData.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              _onboardingData[index]["image"]!,
                              height: 300,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(height: 12),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _onboardingData[index]["title"]!,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 55,
                                      fontFamily: 'FuturaPT',
                                      color: AppColors.accentOrange,
                                    ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                _onboardingData[index]["subtitle"]!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontSize: 20,
                                      fontFamily: 'FuturaPT',
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).brightness ==
                                              Brightness.light
                                          ? AppColors.lightSecondaryText
                                          : AppColors.darkSecondaryText,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: List.generate(
                          _onboardingData.length,
                          (index) => Container(
                            margin: const EdgeInsets.only(right: 8),
                            height: 8,
                            width: _currentPage == index ? 24 : 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index
                                  ? AppColors.accentOrange
                                  : Colors.grey.withAlpha(100),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          if (_currentPage == _onboardingData.length - 1) {
                            context.go('/login');
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          _currentPage == _onboardingData.length - 1
                              ? "Get Started"
                              : "Next",
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: AppColors.warmWhite,
                                fontFamily: 'FuturaPT',
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontFamily: 'FuturaPT',
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).brightness ==
                                    Brightness.light
                                ? AppColors.lightSecondaryText
                                : AppColors.darkSecondaryText,
                          ),
                    ),
                    GestureDetector(
                      onTap: () {
                        context.go('/login');
                      },
                      child: Text(
                        "Login",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.accentOrange,
                              fontWeight: FontWeight.w500,
                              fontFamily: 'FuturaPT',
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: statusBarHeight,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: Container(
                  color: Theme.of(context).brightness == Brightness.light
                      ? AppColors.lightDockBackground
                          .withAlpha((0.3 * 255).toInt())
                      : AppColors.darkDockBackground
                          .withAlpha((0.3 * 255).toInt()),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
