import 'package:readrift/security/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:readrift/screens/dock.dart';
import 'package:readrift/theme.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  LibraryScreenState createState() => LibraryScreenState();
}

class LibraryScreenState extends State<LibraryScreen> {
  int _selectedIndex = 2;
  final AuthService _authService = AuthService();

  final List<Map<String, dynamic>> books = const [
    {
      "title": "1984",
      "author": "George Orwell",
      "imagePath": "assets/1984.png",
      "isCompleted": false,
    },
    {
      "title": "Atomic Habits",
      "author": "James Clear",
      "imagePath": "assets/atomic_habits.png",
      "isCompleted": true,
    },
    {
      "title": "Harry Potter and the Philosopher's Stone",
      "author": "J.K. Rowling",
      "imagePath": "assets/harry_potter.png",
      "isCompleted": false,
    },
    {
      "title": "Hooked",
      "author": "Nir Eyal",
      "imagePath": "assets/hooked.png",
      "isCompleted": true,
    },
    {
      "title": "Rich Dad Poor Dad",
      "author": "Robert Kiyosaki",
      "imagePath": "assets/rich_dad.png",
      "isCompleted": false,
    },
    {
      "title": "The Subtle Art of Not Giving a F*ck",
      "author": "Mark Manson",
      "imagePath": "assets/subtle_art.png",
      "isCompleted": false,
    },
    {
      "title": "The Alchemist",
      "author": "Paulo Coelho",
      "imagePath": "assets/the_alchemist.png",
      "isCompleted": true,
    },
  ];

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

            final photoUrl = authUser.photoURL;

            final screenWidth = MediaQuery.of(context).size.width;
            const bookCardWidth = 120.0;
            final crossAxisCount =
                (screenWidth / bookCardWidth).clamp(1, 4).floor();

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
                                IconButton(
                                  icon: Icon(
                                    Icons.arrow_back,
                                    color: Theme.of(context).brightness ==
                                            Brightness.light
                                        ? AppColors.lightText
                                        : AppColors.darkText,
                                  ),
                                  onPressed: () {
                                    context.go('/');
                                  },
                                ),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.bookmark_border,
                                        color: Theme.of(context).brightness ==
                                                Brightness.light
                                            ? AppColors.lightText
                                            : AppColors.darkText,
                                      ),
                                      onPressed: () {
                                      },
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        context.go('/profile');
                                      },
                                      icon: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.grey[300],
                                        ),
                                        child: photoUrl != null
                                            ? ClipOval(
                                                child: Image.network(
                                                  photoUrl,
                                                  fit: BoxFit.cover,
                                                  width: 40,
                                                  height: 40,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
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
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "My Library",
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).brightness ==
                                                Brightness.light
                                            ? AppColors.lightText
                                            : AppColors.darkText,
                                      ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.book,
                                      size: 16,
                                      color: Theme.of(context).brightness ==
                                              Brightness.light
                                          ? AppColors.lightSecondaryText
                                          : AppColors.darkSecondaryText,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      "${books.length} books",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                        .brightness ==
                                                    Brightness.light
                                                ? AppColors.lightSecondaryText
                                                : AppColors.darkSecondaryText,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 8.0,
                                mainAxisSpacing: 8.0,
                                childAspectRatio: 0.6,
                              ),
                              itemCount: books.length,
                              itemBuilder: (context, index) {
                                final book = books[index];
                                return _buildBookCard(
                                  context,
                                  book["title"],
                                  book["author"],
                                  book["imagePath"],
                                  book["isCompleted"],
                                );
                              },
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

  Widget _buildBookCard(BuildContext context, String title, String author,
      String imagePath, bool isCompleted) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
        ),
        if (isCompleted)
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    "Done",
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
