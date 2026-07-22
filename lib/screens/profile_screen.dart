// lib/screens/profile_screen.dart
import 'package:readrift/security/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:readrift/providers/theme_provider.dart';
import 'package:readrift/theme.dart';
import 'package:readrift/widgets/bouncy_tap.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickProfilePhoto() async {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const Text('Update Profile Photo'),
        message: const Text('Choose a source to select your photo'),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            child: const Text('Photo Library'),
            onPressed: () {
              Navigator.pop(context);
              _getImage(ImageSource.gallery);
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Camera'),
            onPressed: () {
              Navigator.pop(context);
              _getImage(ImageSource.camera);
            },
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  Future<void> _getImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
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
    showAdaptiveDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text("Sign Out"),
        content: const Text("Are you sure you want to sign out of ReadRift?"),
        actions: [
          CupertinoDialogAction(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(context);
              await _authService.signOut();
            },
            child: const Text("Sign Out"),
          ),
        ],
      ),
    );
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
            body: Center(child: CircularProgressIndicator.adaptive()),
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
                body: Center(child: CircularProgressIndicator.adaptive()),
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

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _authService.getUserLibraryStream(authUser.uid),
              builder: (context, librarySnapshot) {
                final booksDocs = librarySnapshot.data?.docs ?? [];
                final books = booksDocs.map((doc) => doc.data()).toList();
                final totalBooks = books.length;
                final completedBooks =
                    books.where((b) => b['isCompleted'] == true).length;
                final readingHours = 158;

                final textColor = Theme.of(context).colorScheme.onSurface;

                return Scaffold(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  body: SafeArea(
                    bottom: false,
                    child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(
                        parent: AlwaysScrollableScrollPhysics()),
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
                                  Icons.arrow_back_ios_new_rounded,
                                  color: textColor,
                                ),
                                onPressed: () {
                                  if (context.canPop()) {
                                    context.pop();
                                  } else {
                                    context.go('/');
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.logout_rounded,
                                  color: Colors.redAccent,
                                ),
                                onPressed: _signOut,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: Column(
                              children: [
                                BouncyTap(
                                  onTap: _pickProfilePhoto,
                                  child: Container(
                                    width: 100,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey[300],
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context).brightness ==
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
                                              errorBuilder:
                                                  (context, error, stackTrace) {
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
                                        color: textColor,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "You rock! Keep up your reading streak 🔥",
                                  style: TextStyle(
                                    color: textColor.withValues(alpha: 0.7),
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Theme Mode Selector
                          _buildThemeSelector(context),
                          const SizedBox(height: 20),

                          _buildOptionTile(
                            context,
                            icon: Icons.notifications_active_rounded,
                            title: "Notifications",
                            hasBadge: true,
                            badgeCount: 2,
                            onTap: () => context.push('/notifications'),
                          ),
                          _buildOptionTile(
                            context,
                            icon: Icons.bookmark_border_rounded,
                            title: "Bookmarks",
                            onTap: () => context.push('/bookmarks'),
                          ),
                          _buildOptionTile(
                            context,
                            icon: Icons.workspace_premium_rounded,
                            title: "Subscription plan",
                            onTap: () => context.push('/subscription'),
                          ),
                          _buildOptionTile(
                            context,
                            icon: Icons.settings_rounded,
                            title: "Account settings",
                            onTap: () => context.push('/account-settings'),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatItem(
                                  context,
                                  "$totalBooks books\nyou have",
                                  Icons.auto_stories_rounded),
                              _buildStatItem(
                                  context,
                                  "$readingHours h\nof reading",
                                  Icons.timer_rounded),
                              _buildStatItem(
                                  context,
                                  "$completedBooks books\ndone",
                                  Icons.check_circle_rounded),
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
                                      color: textColor,
                                    ),
                              ),
                              BouncyTap(
                                onTap: () => context.go('/library'),
                                child: Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 18,
                                  color: textColor,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 140,
                            child: books.isEmpty
                                ? Center(
                                    child: Text(
                                      "No books in library",
                                      style: TextStyle(
                                          color: textColor.withValues(alpha: 0.5)),
                                    ),
                                  )
                                : ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: books.length,
                                    itemBuilder: (context, index) {
                                      final b = books[index];
                                      final imagePath =
                                          b['imagePath'] as String? ?? '';
                                      final filePath = b['filePath'] as String?;
                                      final downloaded =
                                          b['downloaded'] == true;
                                      return _buildBookshelfItem(
                                        context,
                                        imagePath: imagePath,
                                        onTap: () {
                                          if (downloaded && filePath != null) {
                                            context.push('/reader', extra: {
                                              'bookId':
                                                  b['bookId'].toString(),
                                              'filePath': filePath,
                                              'bookTitle':
                                                  b['title'] ?? 'Book',
                                              'fileType':
                                                  b['fileType'] ?? 'epub',
                                            });
                                          }
                                        },
                                      );
                                    },
                                  ),
                          ),
                          const SizedBox(height: 120),
                        ],
                      ),
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

  Widget _buildThemeSelector(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentMode = themeProvider.themeMode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF18181C) : Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildThemeSegment(
              context,
              label: "System",
              icon: Icons.brightness_auto_rounded,
              isSelected: currentMode == ThemeMode.system,
              onTap: () => themeProvider.setThemeMode(ThemeMode.system),
            ),
          ),
          Expanded(
            child: _buildThemeSegment(
              context,
              label: "Snowy",
              icon: Icons.wb_sunny_rounded,
              isSelected: currentMode == ThemeMode.light,
              onTap: () => themeProvider.setThemeMode(ThemeMode.light),
            ),
          ),
          Expanded(
            child: _buildThemeSegment(
              context,
              label: "OLED",
              icon: Icons.dark_mode_rounded,
              isSelected: currentMode == ThemeMode.dark,
              onTap: () => themeProvider.setThemeMode(ThemeMode.dark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSegment(
    BuildContext context, {
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return BouncyTap(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentOrange
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.accentOrange.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
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
    final defaultColor = Theme.of(context).colorScheme.onSurface;

    return BouncyTap(
      onTap: onTap,
      child: ListTile(
        leading: Icon(
          icon,
          color: titleColor ?? defaultColor,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: titleColor ?? defaultColor,
                fontWeight: FontWeight.w500,
              ),
        ),
        trailing: hasBadge
            ? Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.redAccent,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badgeCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : Icon(
                Icons.chevron_right_rounded,
                color: defaultColor.withValues(alpha: 0.4),
              ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, IconData icon) {
    final textColor = Theme.of(context).colorScheme.onSurface;

    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: AppColors.accentOrange,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildBookshelfItem(
    BuildContext context, {
    required String imagePath,
    required VoidCallback onTap,
  }) {
    Widget imageWidget;
    if (imagePath.startsWith('assets/')) {
      imageWidget = Image.asset(
        imagePath,
        width: 80,
        height: 120,
        fit: BoxFit.cover,
      );
    } else if (imagePath.isNotEmpty) {
      imageWidget = CachedNetworkImage(
        imageUrl: imagePath,
        width: 80,
        height: 120,
        fit: BoxFit.cover,
        placeholder: (context, url) =>
            const Center(child: CircularProgressIndicator.adaptive()),
        errorWidget: (context, url, error) => const Icon(Icons.book),
      );
    } else {
      imageWidget = Container(
        width: 80,
        height: 120,
        color: Colors.grey[300],
        child: const Icon(Icons.book, size: 40),
      );
    }

    return BouncyTap(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imageWidget,
        ),
      ),
    );
  }
}
