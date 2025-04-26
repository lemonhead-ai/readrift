import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:ReadRift/screens/dock.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onNavIconTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Wed",
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.orange,
                            fontSize: 55,
                            fontFamily: 'SFProRounded',
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "April 23\n 2025",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                            fontFamily: 'SFProRounded',
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          "Hello, ",
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                          ),
                        ),
                        Icon(
                          Icons.account_circle_outlined,
                          size: 35,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                        Text(
                          " Martin",
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      height: 300,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned(
                            left: 10,
                            top: 0,
                            child: Transform.rotate(
                              angle: math.pi / 24,
                              child: const BookCard(
                                imagePath: "assets/1984.png",
                              ),
                            ),
                          ),
                          Positioned(
                            left: 80,
                            top: 90,
                            child: Transform.rotate(
                              angle: -math.pi / 24,
                              child: const BookCard(
                                imagePath: "assets/atomic_habits.png",
                              ),
                            ),
                          ),
                          Positioned(
                            right: 80,
                            top: 0,
                            child: Transform.rotate(
                              angle: math.pi / 24,
                              child: const BookCard(
                                imagePath: "assets/harry_potter.png",
                              ),
                            ),
                          ),
                          Positioned(
                            right: 10,
                            top: 90,
                            child: Transform.rotate(
                              angle: -math.pi / 24,
                              child: const BookCard(
                                imagePath: "assets/hooked.png",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

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
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          "⌛ 5 Hours",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          "📈 15% into Hooked",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Continue Reading Section
                    Text(
                      "Continue reading",
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 225, // Match the book cover height to constrain the Stack
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          // Overlapping Container with Reading Progress (below the book cover)
                          Positioned(
                            left: 0,
                            right: 0,
                            top: 50,
                            bottom: 0,
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(180, 16, 16, 16), // Push content to the right of the book cover
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness == Brightness.light
                                    ? Colors.grey[300]
                                    : Colors.grey[800],
                                borderRadius: BorderRadius.circular(34),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Reading now",
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "15%",
                                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).textTheme.bodyMedium?.color,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "- 5 hours left",
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  LinearProgressIndicator(
                                    borderRadius: BorderRadius.circular(20),
                                    value: 0.15,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).brightness == Brightness.light
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Book Cover (on top of the container)
                          Positioned(
                            left: 10,
                            bottom: 10,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                width: 160,
                                height: 225,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).brightness == Brightness.light
                                          ? Colors.black12
                                          : Colors.white12,
                                      blurRadius: 8,
                                      offset: const Offset(2, 2),
                                    ),
                                  ],
                                ),
                                child: Image.asset(
                                  "assets/hooked.png",
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 120), // Extra space to ensure content scrolls behind dock
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Dock(
              selectedIndex: _selectedIndex,
              onItemTapped: _onNavIconTapped,
            ),
          ),
        ],
      ),
    );
  }
}

class BookCard extends StatelessWidget {
  final String imagePath;

  const BookCard({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
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
                offset: const Offset(2, 2),
              ),
            ],
          ),
          child: Image.asset(imagePath, fit: BoxFit.cover),
        ),
      ),
    );
  }
}