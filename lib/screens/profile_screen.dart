// lib/screens/profile_screen.dart
import 'package:readrift/security/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:readrift/models/book.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickProfilePhoto() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      File photoFile = File(image.path);
      String? error = await _authService.updateProfilePhoto(photoFile);
      if (!mounted) return;
      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profile photo updated successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      }
    }
  }

  Future<void> _signOut() async {
    await _authService.signOut();
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

            return StreamBuilder<List<Book>>(
              stream: _authService.getUserLibraryStream(authUser.uid),
              builder: (context, librarySnapshot) {
                final books = librarySnapshot.data ?? [];
                final totalBooks = books.length;
                final completedBooks = books.where((b) => b.isCompleted).length;
                final readingHours = 158;  // Calculate dynamically if needed

                return SafeArea(
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
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.color,
                                ),
                                onPressed: () {
                                  context.go('/');
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.logout,
                                  color: Colors.red,
                                ),
                                onPressed: _signOut,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Column(
                              children: [
                                GestureDetector(
                                  onTap: _pickProfilePhoto,
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey[300],
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                          Theme.of(context).brightness ==
                                              Brightness.light
                                              ? Colors.black12
                                              : Colors.white12,
                                          blurRadius: 8,
                                          offset: const Offset(2, 2),
                                        ),
                                      ],
                                    ),
                                    child: photoUrl != null
                                        ? ClipOval(
                                      child: Image.network(
                                        photoUrl,
                                        fit: BoxFit.cover,
                                        width: 100,
                                        height: 100,
                                        errorBuilder: (context, error,
                                            stackTrace) {
                                          return const Icon(
                                            Icons.person,
                                            size: 50,
                                            color: Colors.grey,
                                          );
                                        },
                                      ),
                                    )
                                        : const Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  username,
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
                                const SizedBox(height: 8),
                                Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "You're rock! ",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                        "You've finished last book in 3 days 🔥",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildOptionTile(
                            context,
                            icon: Icons.notifications_outlined,
                            title: "Notifications",
                            hasBadge: true,
                            badgeCount: 2,
                            onTap: () {},
                          ),
                          _buildOptionTile(
                            context,
                            icon: Icons.bookmark_border,
                            title: "Bookmarks",
                            onTap: () {},
                          ),
                          _buildOptionTile(
                            context,
                            icon: Icons.star_border,
                            title: "Subscription plan",
                            onTap: () {},
                          ),
                          _buildOptionTile(
                            context,
                            icon: Icons.settings_outlined,
                            title: "Account settings",
                            onTap: () {},
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(context, "$totalBooks books\nyou have",
                                  Icons.book_outlined),
                              _buildStatItem(context, "$readingHours h\nof reading",
                                  Icons.timer_outlined),
                              _buildStatItem(context, "$completedBooks books\ndone",
                                  Icons.check_circle_outline),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Your bookshelf",
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward,
                                size: 20,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: books.length,
                              itemBuilder: (context, index) {
                                return _buildBookshelfItem(
                                    context, books[index].coverUrl ?? '');
                              },
                            ),
                          ),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildOptionTile(
      BuildContext context, {
        required IconData icon,
        required String title,
        Color? titleColor,
        bool hasBadge = false,
        int badgeCount = 0,
        required VoidCallback onTap,
      }) {
    return ListTile(
      leading: Icon(
        icon,
        color: titleColor ?? Theme.of(context).textTheme.bodyMedium?.color,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color:
          titleColor ?? Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
      trailing: hasBadge
          ? Container(
        padding: const EdgeInsets.all(6),
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        child: Text(
          badgeCount.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ),
      )
          : null,
      onTap: onTap,
    );
  }

  Widget _buildStatItem(BuildContext context, String label, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: Theme.of(context).textTheme.bodyMedium?.color,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBookshelfItem(BuildContext context, String imageUrl) {
    return Container(
      margin: const EdgeInsets.only(right: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imageUrl.isNotEmpty
            ? CachedNetworkImage(
          imageUrl: imageUrl,
          width: 80,
          height: 120,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
          errorWidget: (context, url, error) => const Icon(Icons.book),
        )
            : const Icon(Icons.book, size: 80),
      ),
    );
  }
}