import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Wed",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.orange,
                      fontFamily: 'ComicSansMS',
                    ),
                  ),
                  Text(
                    "November 20\n               2024",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    "Hello, ",
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    "Emerald.",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.orange,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.lock,
                    size: 20,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ],
              ),
              SizedBox(height: 24),

              // Book Covers
              SizedBox(
                height: 320,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Book 1 (Top-left)
                    Positioned(
                      left: 20,
                      top: 0,
                      child: Transform.rotate(
                        angle: math.pi / 24,
                        child: BookCard(
                          imagePath: "assets/1984.png",
                        ),
                      ),
                    ),
                    // Book 2 (Pushed down, overlaps Book 1)
                    Positioned(
                      left: 90,
                      top: 90,
                      child: Transform.rotate(
                        angle: -math.pi / 24,
                        child: BookCard(
                          imagePath: "assets/atomic_habits.png",
                        ),
                      ),
                    ),
                    // Book 3 (Top-right)
                    Positioned(
                      right: 90,
                      top: 0,
                      child: Transform.rotate(
                        angle: math.pi / 24,
                        child: BookCard(
                          imagePath: "assets/harry_potter.png",
                        ),
                      ),
                    ),
                    // Book 4 (Pushed down, overlaps Book 3)
                    Positioned(
                      right: 20,
                      top: 90,
                      child: Transform.rotate(
                        angle: -math.pi / 24,
                        child: BookCard(
                          imagePath: "assets/hooked.png",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Progress
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: "You're currently reading ",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: "Hooked",
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.bold, color: Colors.orange),
                    ),
                    TextSpan(
                      text: ". You have 📚 ",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: "4 books ",
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.bold, color: Colors.orange),
                    ),
                    TextSpan(
                      text: "in progress. You're free to read for 🕒 ",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TextSpan(
                      text: "45 mins",
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(fontWeight: FontWeight.bold, color: Colors.orange),
                    ),
                    TextSpan(
                      text: " after 8 PM.",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    "⌛ 5 Hours",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(width: 16),
                  Text(
                    "📈 15% into Hooked",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      // Apple-style bottom navigation dock
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(60.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .bottomNavigationBarTheme
                    .backgroundColor
                    ?.withValues(alpha: 0.9), // Replaced withOpacity with withValues
                borderRadius: BorderRadius.circular(60.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 30,
                    offset: Offset(0, 10),
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.2),
                  width: 1.0,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavIcon(Icons.home_max_rounded, isSelected: true, context: context),
                  _buildNavIcon(Icons.search_rounded, context: context),
                  _buildNavIcon(Icons.menu_book_rounded, context: context),
                  _buildNavIcon(Icons.person_outline_rounded, context: context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData icon, {bool isSelected = false, required BuildContext context}) {
    return GestureDetector(
      onTap: () {
        // Handle tap logic here
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: isSelected
            ? BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
        )
            : null,
        child: Icon(
          icon,
          size: 30,
          color: isSelected
              ? Theme.of(context).bottomNavigationBarTheme.selectedItemColor
              : Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
        ),
      ),
    );
  }
}

// 📚 Custom Widget for Book Cards
class BookCard extends StatelessWidget {
  final String imagePath;

  const BookCard({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 120,
          height: 180,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).brightness == Brightness.light
                    ? Colors.black12
                    : Colors.white12,
                blurRadius: 8,
                offset: Offset(2, 2),
              ),
            ],
          ),
          child: Image.asset(imagePath, fit: BoxFit.cover),
        ),
      ),
    );
  }
}