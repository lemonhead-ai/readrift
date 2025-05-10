import 'package:readrift/security/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:readrift/screens/dock.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final AuthService _authService = AuthService();

  void _onNavIconTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text("No user logged in")),
      );
    }

    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, authSnapshot) {
        if (authSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final authUser = authSnapshot.data;
        if (authUser == null) {
          return const Scaffold(
            body: Center(child: Text("No user logged in")),
          );
        }

        return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: _authService.getUserDataStream(authUser.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (!snapshot.hasData || snapshot.data?.data() == null) {
              return const Scaffold(
                body: Center(child: Text("User data not found")),
              );
            }

            final userData = snapshot.data!.data()!;
            final username = userData['username'] ?? "User";
            final photoUrl = authUser.photoURL;

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
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        color: Colors.orange,
                                        fontSize: 60,
                                        fontFamily: 'SFProRounded',
                                        fontWeight: FontWeight.w900,
                                      ),
                                ),
                                Text(
                                  "November, 23\n 2025",
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color,
                                        fontFamily: 'SFProRounded',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 18,
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
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.color,
                                      ),
                                ),
                                Container(
                                  width: 35,
                                  height: 35,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.grey[300],
                                  ),
                                  child: photoUrl != null
                                      ? ClipOval(
                                          child: Image.network(
                                            photoUrl,
                                            fit: BoxFit.cover,
                                            width: 35,
                                            height: 35,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return const Icon(
                                                Icons.person,
                                                size: 24,
                                                color: Colors.grey,
                                              );
                                            },
                                          ),
                                        )
                                      : const Icon(
                                          Icons.person,
                                          size: 24,
                                          color: Colors.grey,
                                        ),
                                ),
                                Text(
                                  " $username",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
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
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: "Hooked",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange),
                                  ),
                                  TextSpan(
                                    text: ". You have 📚 ",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: "4 books ",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange),
                                  ),
                                  TextSpan(
                                    text:
                                        "in progress. You're free to read for 🕒 ",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: "45 mins",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange),
                                  ),
                                  TextSpan(
                                    text: " after 8 PM.",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(fontWeight: FontWeight.bold),
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
                            Text(
                              "Continue reading",
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color,
                                  ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 225,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Positioned(
                                    left: 0,
                                    right: 0,
                                    top: 50,
                                    bottom: 0,
                                    child: Container(
                                      padding: const EdgeInsets.fromLTRB(
                                          180, 16, 16, 16),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).brightness ==
                                                Brightness.light
                                            ? Colors.grey[300]
                                            : Colors.grey[800],
                                        borderRadius: BorderRadius.circular(34),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Reading now",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: Colors.grey,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "15%",
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.color,
                                                ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            "- 5 hours left",
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: Colors.grey,
                                                ),
                                          ),
                                          const SizedBox(height: 8),
                                          LinearProgressIndicator(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            value: 0.15,
                                            backgroundColor: Colors.grey[300],
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Theme.of(context).brightness ==
                                                      Brightness.light
                                                  ? Colors.black
                                                  : Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
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
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.light
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
                            const SizedBox(height: 120),
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
          },
        );
      },
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
